import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/operations_repository.dart';

enum SyncStatus {
  idle,
  syncing,
  skipped,
  uploaded,
  downloaded,
  merged,
  offline,
  failed,
}

class SyncResult {
  const SyncResult(this.status, {this.message});

  final SyncStatus status;
  final String? message;

  bool get changed =>
      status == SyncStatus.uploaded ||
      status == SyncStatus.downloaded ||
      status == SyncStatus.merged;
}

class SyncServerException implements Exception {
  const SyncServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class SyncRuntimeConfig {
  const SyncRuntimeConfig({
    required this.baseUrl,
    required this.token,
    required this.tokenConfigured,
    required this.usingBuildToken,
  });

  final String baseUrl;
  final String token;
  final bool tokenConfigured;
  final bool usingBuildToken;
}

class SeletoSyncService extends ChangeNotifier with WidgetsBindingObserver {
  SeletoSyncService(
    this._database, {
    http.Client? httpClient,
    String? baseUrl,
    String? token,
  }) : _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null,
       _baseUri = Uri.parse(baseUrl ?? _defaultBaseUrl),
       _syncToken = token ?? _defaultSyncToken;

  final AppDatabase _database;
  final http.Client _httpClient;
  final bool _ownsHttpClient;
  Uri _baseUri;
  String _syncToken;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _presenceTimer;
  Timer? _realtimeSyncTimer;
  Future<SyncResult>? _activeSync;
  Future<void>? _activePresence;
  _SyncScope? _scope;
  DateTime? _lastAttemptAt;
  DateTime? _lastRemoteStatusCheckAt;
  bool _started = false;
  bool _disposed = false;
  bool _hasSuccessfulSync = false;
  SyncResult _lastResult = const SyncResult(SyncStatus.idle);

  static const _deviceIdKey = 'seleto.sync.device_id';
  static const _lastLocalHashKey = 'seleto.sync.last_local_hash';
  static const _lastRemoteHashKey = 'seleto.sync.last_remote_hash';
  static const _runtimeBaseUrlKey = 'seleto.sync.base_url';
  static const _runtimeTokenKey = 'seleto.sync.token';
  static const _minimumSyncInterval = Duration(seconds: 15);
  static const _remoteStatusCheckInterval = Duration(minutes: 2);
  static const _presenceInterval = Duration(seconds: 8);
  static const _networkTimeout = Duration(seconds: 60);
  static const _presenceTimeout = Duration(seconds: 4);
  static const _defaultBaseUrl = String.fromEnvironment(
    'SELETO_SYNC_BASE_URL',
    defaultValue: 'http://131.221.236.34:5005',
  );
  static const _defaultSyncToken = String.fromEnvironment('SELETO_SYNC_TOKEN');

  SyncResult get lastResult => _lastResult;
  bool get isSynced => _hasSuccessfulSync;

  Future<SyncRuntimeConfig> configuration() async {
    await _loadStoredConfiguration();
    return SyncRuntimeConfig(
      baseUrl: _baseUri.toString(),
      token: _syncToken,
      tokenConfigured: _syncToken.isNotEmpty,
      usingBuildToken: _syncToken.isNotEmpty && _syncToken == _defaultSyncToken,
    );
  }

  Future<void> configureRuntime({
    required String baseUrl,
    String? token,
    bool clearToken = false,
  }) async {
    final normalizedUrl = baseUrl.trim().isEmpty
        ? _defaultBaseUrl
        : baseUrl.trim();
    final nextUri = Uri.tryParse(normalizedUrl);
    if (nextUri == null || !nextUri.hasScheme || nextUri.host.isEmpty) {
      throw ArgumentError('Informe uma URL válida para o servidor de sync.');
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_runtimeBaseUrlKey, nextUri.toString());
    _baseUri = nextUri;
    if (clearToken) {
      await preferences.remove(_runtimeTokenKey);
      _syncToken = _defaultSyncToken;
    } else if (token != null && token.trim().isNotEmpty) {
      _syncToken = token.trim();
      await preferences.setString(_runtimeTokenKey, _syncToken);
    }
    _lastAttemptAt = null;
    _hasSuccessfulSync = false;
    if (_started) {
      _startPresenceHeartbeat();
      _startRealtimeSync();
    }
    if (!_disposed) notifyListeners();
  }

  void setUserScope({
    required String userId,
    required String tenantId,
    required bool isSuperAdmin,
  }) {
    final next = _SyncScope(
      userId: userId,
      tenantId: tenantId,
      isSuperAdmin: isSuperAdmin,
    );
    if (_scope?.key != next.key) {
      _lastAttemptAt = null;
      _hasSuccessfulSync = false;
    }
    _scope = next;
    if (_started) {
      _startPresenceHeartbeat();
      _startRealtimeSync();
    }
  }

  void clearUserScope() {
    final oldScope = _scope;
    if (oldScope != null) {
      unawaited(_sendPresence(online: false, scopeOverride: oldScope));
    }
    _presenceTimer?.cancel();
    _presenceTimer = null;
    _realtimeSyncTimer?.cancel();
    _realtimeSyncTimer = null;
    _scope = null;
    _lastAttemptAt = null;
    _hasSuccessfulSync = false;
  }

  Future<void> start() async {
    if (_started) return;
    await _loadStoredConfiguration();
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (_scope != null &&
          results.any((result) => result != ConnectivityResult.none)) {
        _startPresenceHeartbeat();
        _startRealtimeSync();
        unawaited(syncNow(reason: 'connectivity'));
      }
    });
    _startPresenceHeartbeat();
    _startRealtimeSync();
  }

  Future<SyncResult> syncNow({
    String reason = 'manual',
    bool force = false,
  }) async {
    await _loadStoredConfiguration();
    final scope = _scope;
    if (scope == null) {
      return Future.value(
        const SyncResult(
          SyncStatus.skipped,
          message: 'Sincronização aguardando usuário logado.',
        ),
      );
    }
    final now = DateTime.now();
    if (!force &&
        _lastAttemptAt != null &&
        now.difference(_lastAttemptAt!) < _minimumSyncInterval) {
      return Future.value(const SyncResult(SyncStatus.skipped));
    }
    final activeSync = _activeSync;
    if (activeSync != null) return activeSync;
    _lastAttemptAt = now;
    if (!force && !await _shouldEnqueueAutomaticSync(scope, reason)) {
      await _database.cleanupAutomaticSyncQueue(scopeKey: scope.key);
      final result = const SyncResult(
        SyncStatus.idle,
        message: 'Sem alterações locais ou remotas.',
      );
      _setResult(result);
      return result;
    }
    await _database.enqueueSync(
      scopeKey: scope.key,
      tenantId: scope.tenantId,
      userId: scope.userId,
      reason: reason,
      priority: force ? 10 : 100,
      coalescePending: !force,
    );
    _setResult(const SyncResult(SyncStatus.syncing));
    final sync = _drainQueue(scope.key)
        .then((result) {
          _setResult(result);
          return result;
        })
        .whenComplete(() => _activeSync = null);
    _activeSync = sync;
    return sync;
  }

  Future<SyncResult> _drainQueue(String scopeKey) async {
    SyncResult lastResult = const SyncResult(SyncStatus.idle);
    while (true) {
      final item = await _database.claimNextSyncQueueItem(scopeKey: scopeKey);
      if (item == null) return lastResult;
      final startedAt = DateTime.now();
      final scope = _SyncScope(
        userId: item.userId ?? _scope?.userId ?? '',
        tenantId: item.tenantId,
        isSuperAdmin: item.scopeKey == 'super_admin',
      );
      try {
        final result = await _sync(item.reason, scope);
        lastResult = result;
        final failed =
            result.status == SyncStatus.failed ||
            result.status == SyncStatus.offline;
        if (failed) {
          await _database.failSyncQueueItem(
            item: item,
            message: result.message ?? _statusLabel(result.status),
            startedAt: startedAt,
          );
        } else if (result.status == SyncStatus.idle ||
            result.status == SyncStatus.skipped) {
          await _database.completeSyncQueueItem(
            item: item,
            status: _statusLabel(result.status),
            message: result.message,
            startedAt: startedAt,
            recordHistory: false,
          );
        } else {
          await _database.completeSyncQueueItem(
            item: item,
            status: _statusLabel(result.status),
            message: result.message,
            startedAt: startedAt,
          );
        }
      } catch (error) {
        lastResult = SyncResult(SyncStatus.failed, message: error.toString());
        await _database.failSyncQueueItem(
          item: item,
          message: error.toString(),
          startedAt: startedAt,
        );
      }
    }
  }

  Future<bool> _shouldEnqueueAutomaticSync(
    _SyncScope scope,
    String reason,
  ) async {
    if (!_isConfigured || !await _hasConnection()) return true;
    final preferences = await SharedPreferences.getInstance();
    final localHash = _hashStablePayload(await _localPayload(scope));
    final lastLocalHash = preferences.getString(
      _scopedPreferenceKey(_lastLocalHashKey, scope),
    );
    if (lastLocalHash == null || localHash != lastLocalHash) return true;

    if (_isQuietAutomaticReason(reason)) return false;

    final now = DateTime.now();
    if (_lastRemoteStatusCheckAt != null &&
        now.difference(_lastRemoteStatusCheckAt!) <
            _remoteStatusCheckInterval) {
      return false;
    }
    _lastRemoteStatusCheckAt = now;
    try {
      final status = await _postJson('/sync/v1/status', {
        'scopeKey': scope.key,
        'tenantId': scope.tenantId,
        'userId': scope.userId,
        'isSuperAdmin': scope.isSuperAdmin,
        'deviceId': await _deviceId(),
        'reason': '${reason}_status',
      });
      final remoteHash = status['payloadHash']?.toString();
      final lastRemoteHash = preferences.getString(
        _scopedPreferenceKey(_lastRemoteHashKey, scope),
      );
      return remoteHash != null && remoteHash != lastRemoteHash;
    } catch (_) {
      return false;
    }
  }

  bool _isQuietAutomaticReason(String reason) => const {
    'realtime',
    'realtime_start',
    'remembered_session',
  }.contains(reason);

  Future<SyncResult> syncForLoginUsername(String username) async {
    await _loadStoredConfiguration();
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty) {
      return const SyncResult(SyncStatus.skipped);
    }
    if (!_isConfigured) {
      return const SyncResult(
        SyncStatus.skipped,
        message:
            'Servidor de sincronização sem token. Informe o token em Configurações > Servidor SELETO Sync.',
      );
    }
    try {
      if (!await _hasConnection()) {
        return const SyncResult(
          SyncStatus.offline,
          message: 'Sem conexão para consultar o servidor de sincronização.',
        );
      }
      final response = await _postJson('/sync/v1/login', {
        'username': normalizedUsername,
        'deviceId': await _deviceId(),
      });
      if (response['exists'] != true) {
        return const SyncResult(SyncStatus.idle);
      }
      final userId = response['userId']?.toString();
      final tenantId = response['tenantId']?.toString() ?? defaultTenantId;
      final payload = _payloadFromResponse(response);
      if (userId == null || userId.isEmpty || payload == null) {
        return const SyncResult(SyncStatus.idle);
      }
      final scope = _SyncScope(
        userId: userId,
        tenantId: tenantId,
        isSuperAdmin: response['isSuperAdmin'] == true,
      );
      await _restoreLocalPayload(payload, scope);
      final payloadHash =
          response['payloadHash']?.toString() ?? _hashPayload(payload);
      final preferences = await SharedPreferences.getInstance();
      await _rememberHashes(preferences, scope, payloadHash, payloadHash);
      final result = const SyncResult(SyncStatus.downloaded);
      _setResult(result);
      return result;
    } on SyncServerException catch (error) {
      return SyncResult(SyncStatus.failed, message: error.message);
    } catch (error) {
      return SyncResult(SyncStatus.failed, message: error.toString());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _presenceTimer?.cancel();
    _realtimeSyncTimer?.cancel();
    unawaited(_connectivitySubscription?.cancel());
    if (_ownsHttpClient) _httpClient.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_scope == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _startPresenceHeartbeat();
        _startRealtimeSync();
        unawaited(syncNow(reason: 'app_resumed'));
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _presenceTimer?.cancel();
        _presenceTimer = null;
        _realtimeSyncTimer?.cancel();
        _realtimeSyncTimer = null;
        unawaited(_sendPresence(online: false, appState: state.name));
    }
  }

  void _setResult(SyncResult result) {
    _lastResult = result;
    if (result.status == SyncStatus.syncing ||
        result.status == SyncStatus.offline ||
        result.status == SyncStatus.failed) {
      _hasSuccessfulSync = false;
    } else if (result.status == SyncStatus.idle ||
        result.status == SyncStatus.uploaded ||
        result.status == SyncStatus.downloaded ||
        result.status == SyncStatus.merged) {
      _hasSuccessfulSync = true;
    }
    if (!_disposed) notifyListeners();
  }

  Future<SyncResult> _sync(String reason, _SyncScope scope) async {
    try {
      await _loadStoredConfiguration();
      if (!_isConfigured) {
        return const SyncResult(
          SyncStatus.skipped,
          message:
              'Servidor de sincronização sem token. Informe o token em Configurações > Servidor SELETO Sync.',
        );
      }
      if (!await _hasConnection()) {
        return const SyncResult(SyncStatus.offline);
      }

      final preferences = await SharedPreferences.getInstance();
      final localPayload = await _localPayload(scope);
      final localHash = _hashPayload(localPayload);
      final stableLocalHash = _hashStablePayload(localPayload);
      final lastRemoteHash = preferences.getString(
        _scopedPreferenceKey(_lastRemoteHashKey, scope),
      );
      final response = await _postJson('/sync/v1/sync', {
        'scopeKey': scope.key,
        'tenantId': scope.tenantId,
        'userId': scope.userId,
        'isSuperAdmin': scope.isSuperAdmin,
        'deviceId': await _deviceId(),
        'reason': reason,
        'lastRemoteHash': lastRemoteHash,
        'preferLocalOnFirstSync': lastRemoteHash == null,
        'payload': localPayload,
      });
      unawaited(_sendPresence(online: true, appState: 'sync_$reason'));
      final status = response['status']?.toString() ?? 'idle';
      final remotePayload = _payloadFromResponse(response);
      final remoteHash = response['payloadHash']?.toString();

      if ((status == 'downloaded' || status == 'merged') &&
          remotePayload != null) {
        await _restoreLocalPayload(remotePayload, scope);
        final restoredPayload = _normalizePayload(remotePayload);
        final restoredHash = _hashPayload(restoredPayload);
        await _rememberHashes(
          preferences,
          scope,
          _hashStablePayload(restoredPayload),
          remoteHash ?? restoredHash,
        );
      } else if (status == 'uploaded') {
        await _rememberHashes(
          preferences,
          scope,
          stableLocalHash,
          remoteHash ?? localHash,
        );
      } else if (remoteHash != null) {
        await _rememberHashes(preferences, scope, stableLocalHash, remoteHash);
      }

      return SyncResult(_statusFromServer(status));
    } on SyncServerException catch (error) {
      return SyncResult(SyncStatus.failed, message: error.message);
    } catch (error) {
      return SyncResult(SyncStatus.failed, message: error.toString());
    }
  }

  Future<bool> _hasConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity.any((result) => result != ConnectivityResult.none);
  }

  bool get _isConfigured =>
      _syncToken.isNotEmpty && _baseUri.hasScheme && _baseUri.host.isNotEmpty;

  Future<Map<String, dynamic>> testConfiguration() async {
    await _loadStoredConfiguration();
    final checkedAt = DateTime.now().toIso8601String();
    final result = <String, dynamic>{
      'servico': 'Servidor SELETO Sync',
      'status': 'erro',
      'verificadoEm': checkedAt,
      'endpoint': _baseUri.toString(),
      'tokenConfiguradoNoApp': _syncToken.isNotEmpty,
      'backup': {
        'modelo': 'tabelas_postgresql',
        'tabelas': _syncTables.map((spec) => spec.remoteTable).toList(),
      },
    };
    try {
      final deviceId = await _deviceId();
      final health = await _getJson('/health');
      final status = await _postJson('/sync/v1/status', {
        'scopeKey': _scope?.key ?? 'tenant_$defaultTenantId',
        'tenantId': _scope?.tenantId ?? defaultTenantId,
        'userId': _scope?.userId,
        'isSuperAdmin': _scope?.isSuperAdmin ?? false,
        'deviceId': deviceId,
      });
      result
        ..['status'] = 'sucesso'
        ..['health'] = health
        ..['escopo'] = status;
      return result;
    } on SyncServerException catch (error) {
      result['erro'] = {
        'codigo': 'http-${error.statusCode ?? 'erro'}',
        'mensagem': error.message,
      };
      return result;
    } catch (error) {
      result['erro'] = {
        'codigo': 'erro-desconhecido',
        'mensagem': error.toString(),
      };
      return result;
    }
  }

  Future<Map<String, dynamic>> checkRemoteHealth() async {
    await _loadStoredConfiguration();
    final checkedAt = DateTime.now();
    final started = DateTime.now();
    try {
      final health = await _getJson('/health');
      return {
        'status': 'sucesso',
        'endpoint': _baseUri.toString(),
        'latenciaMs': DateTime.now().difference(started).inMilliseconds,
        'verificadoEm': checkedAt.toIso8601String(),
        'health': health,
      };
    } on SyncServerException catch (error) {
      return {
        'status': 'erro',
        'endpoint': _baseUri.toString(),
        'latenciaMs': DateTime.now().difference(started).inMilliseconds,
        'verificadoEm': checkedAt.toIso8601String(),
        'erro': {
          'codigo': 'http-${error.statusCode ?? 'erro'}',
          'mensagem': error.message,
        },
      };
    } catch (error) {
      return {
        'status': 'erro',
        'endpoint': _baseUri.toString(),
        'latenciaMs': DateTime.now().difference(started).inMilliseconds,
        'verificadoEm': checkedAt.toIso8601String(),
        'erro': {'mensagem': error.toString()},
      };
    }
  }

  Future<String> _deviceId() async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getString(_deviceIdKey);
    if (current != null && current.isNotEmpty) return current;
    final created = const Uuid().v4();
    await preferences.setString(_deviceIdKey, created);
    return created;
  }

  Future<void> _loadStoredConfiguration() async {
    final preferences = await SharedPreferences.getInstance();
    final storedBaseUrl = preferences.getString(_runtimeBaseUrlKey);
    final parsedBaseUrl = Uri.tryParse(
      storedBaseUrl?.trim().isNotEmpty == true
          ? storedBaseUrl!.trim()
          : _defaultBaseUrl,
    );
    if (parsedBaseUrl != null &&
        parsedBaseUrl.hasScheme &&
        parsedBaseUrl.host.isNotEmpty) {
      _baseUri = parsedBaseUrl;
    }
    final storedToken = preferences.getString(_runtimeTokenKey);
    _syncToken = storedToken?.trim().isNotEmpty == true
        ? storedToken!.trim()
        : _defaultSyncToken;
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    await _loadStoredConfiguration();
    final response = await _httpClient
        .get(_endpoint(path), headers: _headers())
        .timeout(_networkTimeout);
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    await _loadStoredConfiguration();
    final encoded = jsonEncode(body);
    final response = await _httpClient
        .post(
          _endpoint(path),
          headers: _headers('POST', path, encoded),
          body: encoded,
        )
        .timeout(_networkTimeout);
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postPresenceJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    await _loadStoredConfiguration();
    final encoded = jsonEncode(body);
    final response = await _httpClient
        .post(
          _endpoint(path),
          headers: _headers('POST', path, encoded),
          body: encoded,
        )
        .timeout(_presenceTimeout);
    return _decodeResponse(response);
  }

  Uri _endpoint(String path) {
    final normalizedBasePath = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return _baseUri.replace(path: '$normalizedBasePath$normalizedPath');
  }

  Map<String, String> _headers([
    String method = 'GET',
    String path = '/health',
    String body = '',
  ]) {
    final headers = {
      'accept': 'application/json',
      'content-type': 'application/json; charset=utf-8',
      if (_syncToken.isNotEmpty) 'authorization': 'Bearer $_syncToken',
    };
    if (_syncToken.isEmpty || method.toUpperCase() != 'POST') return headers;
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final nonce = const Uuid().v4();
    final signed = [
      method.toUpperCase(),
      path.startsWith('/') ? path : '/$path',
      timestamp,
      nonce,
      body,
    ].join('\n');
    final signature = Hmac(
      sha256,
      utf8.encode(_syncToken),
    ).convert(utf8.encode(signed)).toString();
    headers
      ..['x-seleto-sync-timestamp'] = timestamp
      ..['x-seleto-sync-nonce'] = nonce
      ..['x-seleto-sync-signature'] = signature;
    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(response.body) as Map).cast<String, dynamic>();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message']?.toString() ??
          'Servidor de sincronização retornou HTTP ${response.statusCode}.';
      throw SyncServerException(message, statusCode: response.statusCode);
    }
    return decoded;
  }

  Map<String, dynamic>? _payloadFromResponse(Map<String, dynamic> response) {
    final payload = response['payload'];
    if (payload is Map) return payload.cast<String, dynamic>();
    return null;
  }

  SyncStatus _statusFromServer(String status) => switch (status) {
    'uploaded' => SyncStatus.uploaded,
    'downloaded' => SyncStatus.downloaded,
    'merged' => SyncStatus.merged,
    'offline' => SyncStatus.offline,
    'skipped' => SyncStatus.skipped,
    'failed' || 'erro' || 'error' => SyncStatus.failed,
    _ => SyncStatus.idle,
  };

  String _statusLabel(SyncStatus status) => switch (status) {
    SyncStatus.idle => 'IDLE',
    SyncStatus.syncing => 'RUNNING',
    SyncStatus.skipped => 'SKIPPED',
    SyncStatus.uploaded => 'UPLOADED',
    SyncStatus.downloaded => 'DOWNLOADED',
    SyncStatus.merged => 'MERGED',
    SyncStatus.offline => 'OFFLINE',
    SyncStatus.failed => 'FAILED',
  };

  void _startPresenceHeartbeat() {
    unawaited(_startPresenceHeartbeatLoaded());
  }

  void _startRealtimeSync() {
    unawaited(_startRealtimeSyncLoaded());
  }

  Future<void> _startPresenceHeartbeatLoaded() async {
    await _loadStoredConfiguration();
    if (!_started || _scope == null || !_isConfigured) return;
    _presenceTimer?.cancel();
    unawaited(_sendPresence(online: true, appState: 'active'));
    _presenceTimer = Timer.periodic(_presenceInterval, (_) {
      unawaited(_sendPresence(online: true, appState: 'active'));
    });
  }

  Future<void> _startRealtimeSyncLoaded() async {
    await _loadStoredConfiguration();
    if (!_started || _scope == null || !_isConfigured) return;
    _realtimeSyncTimer?.cancel();
    _realtimeSyncTimer = null;
    unawaited(_database.cleanupAutomaticSyncQueue(scopeKey: _scope!.key));
  }

  Future<void> _sendPresence({
    required bool online,
    _SyncScope? scopeOverride,
    String appState = 'active',
  }) async {
    await _loadStoredConfiguration();
    if (!_isConfigured) return;
    final scope = scopeOverride ?? _scope;
    if (scope == null) return;
    final activePresence = _activePresence;
    if (activePresence != null && online) return activePresence;
    final request = _sendPresenceRequest(
      online: online,
      scope: scope,
      appState: appState,
    );
    if (online) {
      final tracked = request.whenComplete(() => _activePresence = null);
      _activePresence = tracked;
      return tracked;
    }
    return request;
  }

  Future<void> _sendPresenceRequest({
    required bool online,
    required _SyncScope scope,
    required String appState,
  }) async {
    try {
      if (online && !await _hasConnection()) return;
      final response = await _postPresenceJson('/sync/v1/presence', {
        'scopeKey': scope.key,
        'tenantId': scope.tenantId,
        'userId': scope.userId,
        'isSuperAdmin': scope.isSuperAdmin,
        'deviceId': await _deviceId(),
        'state': online ? 'online' : 'offline',
        'appState': appState,
        'clientTime': DateTime.now().toIso8601String(),
      });
      await _applyPresenceResponse(response, scope);
    } catch (_) {
      // Presenca nao pode derrubar login/sincronizacao; o proximo heartbeat corrige.
    }
  }

  Future<void> _applyPresenceResponse(
    Map<String, dynamic> response,
    _SyncScope scope,
  ) async {
    final activeUsers = response['activeUsers'];
    if (activeUsers is! List) return;
    await _database.transaction(() async {
      for (final item in activeUsers.whereType<Map>()) {
        final row = item.cast<String, dynamic>();
        final userId = row['userId']?.toString();
        if (userId == null || userId.isEmpty) continue;
        if (!scope.isSuperAdmin &&
            (row['tenantId']?.toString() ?? defaultTenantId) !=
                scope.tenantId) {
          continue;
        }
        final lastSeenAt = _parseDateTime(row['lastSeenAt']);
        if (lastSeenAt == null) continue;
        await (_database.update(_database.users)
              ..where((user) => user.id.equals(userId)))
            .write(UsersCompanion(lastSeenAt: Value(lastSeenAt)));
      }
    });
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  Future<Map<String, dynamic>> _localPayload(_SyncScope scope) async {
    final backup = jsonDecode(
      await _database.exportJson(
        tenantId: scope.isSuperAdmin ? null : scope.tenantId,
      ),
    );
    final payload = (backup as Map).cast<String, dynamic>()
      ..remove('exportedAt')
      ..['format'] = 'SELETO_SYNC_V1';
    final tenantsQuery = _database.select(_database.tenants);
    final usersQuery = _database.select(_database.users);
    if (!scope.isSuperAdmin) {
      tenantsQuery.where((row) => row.id.equals(scope.tenantId));
      usersQuery.where((row) => row.tenantId.equals(scope.tenantId));
      for (final key in _globalOnlyCollectionKeys) {
        payload[key] = const <Map<String, dynamic>>[];
      }
    }
    final userRows = await usersQuery.get();
    final userIds = userRows.map((row) => row.id).toSet();
    payload['tenants'] = (await tenantsQuery.get())
        .map((row) => row.toJson())
        .toList();
    payload['users'] = userRows.map((row) => row.toJson()).toList();
    payload['userPermissions'] = userIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : (await (_database.select(_database.userPermissions)
                ..where((row) => row.userId.isIn(userIds)))
              .map((row) => row.toJson())
              .get());
    payload['auditLogs'] = userIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : (await (_database.select(_database.auditLogs)
                ..where((row) => row.userId.isIn(userIds)))
              .map((row) => row.toJson())
              .get());
    return _normalizePayload(payload);
  }

  Future<void> _restoreLocalPayload(
    Map<String, dynamic> payload,
    _SyncScope scope,
  ) async {
    await _restoreAuthPayload(payload, scope);
    final backupPayload = Map<String, dynamic>.from(payload)
      ..['format'] = 'SELETO_BACKUP_V1';
    if (scope.isSuperAdmin) {
      await _database.restoreJson(
        jsonEncode(backupPayload),
        actorId: 'sync',
        writeAudit: false,
      );
      return;
    }
    await _restoreTenantOperationalPayload(backupPayload, scope);
  }

  Future<void> _restoreAuthPayload(
    Map<String, dynamic> payload,
    _SyncScope scope,
  ) async {
    await _database.transaction(() async {
      final tenantRows = scope.isSuperAdmin
          ? _rows(payload, 'tenants')
          : _rows(
              payload,
              'tenants',
            ).where((row) => row['id'] == scope.tenantId);
      for (final row in tenantRows) {
        await _database
            .into(_database.tenants)
            .insertOnConflictUpdate(Tenant.fromJson(row));
      }
      final userRows = scope.isSuperAdmin
          ? _rows(payload, 'users')
          : _rows(payload, 'users').where(
              (row) => (row['tenantId'] ?? defaultTenantId) == scope.tenantId,
            );
      final userIds = <String>{};
      for (final row in userRows) {
        final userId = row['id']?.toString();
        if (userId != null && userId.isNotEmpty) userIds.add(userId);
        await _database
            .into(_database.users)
            .insertOnConflictUpdate(User.fromJson(_userJson(row)));
      }
      if (scope.isSuperAdmin) {
        await _database.delete(_database.userPermissions).go();
      } else if (userIds.isNotEmpty) {
        await (_database.delete(
          _database.userPermissions,
        )..where((row) => row.userId.isIn(userIds))).go();
      }
      final permissionRows = scope.isSuperAdmin
          ? _rows(payload, 'userPermissions')
          : _rows(
              payload,
              'userPermissions',
            ).where((row) => userIds.contains(row['userId']));
      for (final row in permissionRows) {
        await _database
            .into(_database.userPermissions)
            .insert(
              UserPermission.fromJson(row),
              mode: InsertMode.insertOrIgnore,
            );
      }
      final auditRows = scope.isSuperAdmin
          ? _rows(payload, 'auditLogs')
          : _rows(
              payload,
              'auditLogs',
            ).where((row) => userIds.contains(row['userId']));
      for (final row in auditRows) {
        await _database
            .into(_database.auditLogs)
            .insert(AuditLog.fromJson(row), mode: InsertMode.insertOrIgnore);
      }
    });
  }

  Future<void> _restoreTenantOperationalPayload(
    Map<String, dynamic> payload,
    _SyncScope scope,
  ) async {
    await _database.transaction(() async {
      for (final row in _rows(payload, 'lots')) {
        await _database
            .into(_database.lots)
            .insertOnConflictUpdate(Lot.fromJson(row));
      }
      for (final row in _rows(payload, 'birdMovements')) {
        await _database
            .into(_database.birdMovements)
            .insertOnConflictUpdate(BirdMovement.fromJson(row));
      }
      for (final row in _rows(payload, 'eggCollections')) {
        await _database
            .into(_database.eggCollections)
            .insertOnConflictUpdate(
              EggCollection.fromJson(_eggCollectionJson(row)),
            );
      }
      for (final row in _rows(payload, 'eggStockMovements')) {
        await _database
            .into(_database.eggStockMovements)
            .insertOnConflictUpdate(EggStockMovement.fromJson(row));
      }
      // Insumos e formulações são localmente autoritativos.
      // Usar insertOrIgnore para que dados apagados localmente NÃO sejam reinseridos
      // pela sincronização. O próximo upload removerá os itens do servidor também.
      for (final row in _rows(payload, 'ingredients')) {
        await _database
            .into(_database.ingredients)
            .insert(Ingredient.fromJson(row), mode: InsertMode.insertOrIgnore);
      }
      for (final row in _rows(payload, 'prices')) {
        await _database
            .into(_database.ingredientPriceHistory)
            .insert(
              IngredientPriceHistoryData.fromJson(row),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final row in _rows(payload, 'ingredientLots')) {
        await _database
            .into(_database.ingredientLots)
            .insert(
              IngredientLot.fromJson(row),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final row in _rows(payload, 'ingredientStockMovements')) {
        await _database
            .into(_database.ingredientStockMovements)
            .insert(
              IngredientStockMovement.fromJson(row),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final row in _rows(payload, 'formulas')) {
        await _database
            .into(_database.feedFormulas)
            .insert(FeedFormula.fromJson(row), mode: InsertMode.insertOrIgnore);
      }
      for (final row in _rows(payload, 'formulaItems')) {
        await _database
            .into(_database.feedFormulaItems)
            .insert(
              FeedFormulaItem.fromJson(row),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final row in _rows(payload, 'feedBatches')) {
        await _database
            .into(_database.feedBatches)
            .insertOnConflictUpdate(FeedBatche.fromJson(row));
      }
      for (final row in _rows(payload, 'feedBatchItems')) {
        await _database
            .into(_database.feedBatchItems)
            .insertOnConflictUpdate(FeedBatchItem.fromJson(row));
      }
      for (final row in _rows(payload, 'feedStock')) {
        await _database
            .into(_database.feedStockMovements)
            .insertOnConflictUpdate(FeedStockMovement.fromJson(row));
      }
      for (final row in _rows(payload, 'feedings')) {
        await _database
            .into(_database.dailyFeedings)
            .insertOnConflictUpdate(DailyFeeding.fromJson(row));
      }
      for (final row in _rows(payload, 'customers')) {
        await _database
            .into(_database.customers)
            .insertOnConflictUpdate(Customer.fromJson(row));
      }
      for (final row in _rows(payload, 'orders')) {
        await _database
            .into(_database.orders)
            .insertOnConflictUpdate(Order.fromJson(row));
      }
      for (final row in _rows(payload, 'orderItems')) {
        await _database
            .into(_database.orderItems)
            .insertOnConflictUpdate(OrderItem.fromJson(row));
      }
      for (final row in _rows(payload, 'orderStatusHistory')) {
        await _database
            .into(_database.orderStatusHistory)
            .insertOnConflictUpdate(OrderStatusHistoryData.fromJson(row));
      }
      for (final row in _rows(payload, 'packagingItems')) {
        await _database
            .into(_database.packagingItems)
            .insertOnConflictUpdate(PackagingItem.fromJson(row));
      }
      for (final row in _rows(payload, 'packagingLots')) {
        await _database
            .into(_database.packagingLots)
            .insertOnConflictUpdate(PackagingLot.fromJson(row));
      }
      for (final row in _rows(payload, 'packagingStockMovements')) {
        await _database
            .into(_database.packagingStockMovements)
            .insertOnConflictUpdate(PackagingStockMovement.fromJson(row));
      }
      for (final row in _rows(payload, 'eggTrayBatches')) {
        await _database
            .into(_database.eggTrayBatches)
            .insertOnConflictUpdate(EggTrayBatch.fromJson(_trayJson(row)));
      }
      for (final row in _rows(payload, 'eggTrayStockMovements')) {
        await _database
            .into(_database.eggTrayStockMovements)
            .insertOnConflictUpdate(EggTrayStockMovement.fromJson(row));
      }
      for (final row in _rows(payload, 'sales')) {
        await _database
            .into(_database.sales)
            .insertOnConflictUpdate(Sale.fromJson(_saleJson(row)));
      }
      for (final row in _rows(payload, 'finance')) {
        await _database
            .into(_database.financeTransactions)
            .insertOnConflictUpdate(FinanceTransaction.fromJson(row));
      }
      for (final row in _rows(payload, 'investments')) {
        await _database
            .into(_database.investments)
            .insertOnConflictUpdate(Investment.fromJson(row));
      }
      for (final row in _rows(payload, 'financialEstablishments')) {
        await _database
            .into(_database.financialEstablishments)
            .insertOnConflictUpdate(FinancialEstablishment.fromJson(row));
      }
      for (final row in _rows(payload, 'personalFinance')) {
        await _database
            .into(_database.personalFinanceTransactions)
            .insertOnConflictUpdate(PersonalFinanceTransaction.fromJson(row));
      }
      for (final row in _rows(payload, 'financialReserves')) {
        await _database
            .into(_database.financialReserves)
            .insertOnConflictUpdate(FinancialReserve.fromJson(row));
      }
      for (final row in _rows(payload, 'personalInvestments')) {
        await _database
            .into(_database.personalInvestments)
            .insertOnConflictUpdate(PersonalInvestment.fromJson(row));
      }
      for (final row in _rows(payload, 'personalDebts')) {
        await _database
            .into(_database.personalDebts)
            .insertOnConflictUpdate(PersonalDebt.fromJson(row));
      }
      for (final row in _rows(payload, 'lightingPrograms')) {
        await _database
            .into(_database.lightingPrograms)
            .insertOnConflictUpdate(LightingProgram.fromJson(row));
      }
      for (final row in _rows(payload, 'lightingSteps')) {
        await _database
            .into(_database.lightingProgramSteps)
            .insertOnConflictUpdate(LightingProgramStep.fromJson(row));
      }
      for (final row in _rows(payload, 'lotLighting')) {
        await _database
            .into(_database.lotLightingPrograms)
            .insertOnConflictUpdate(LotLightingProgram.fromJson(row));
      }
      for (final row in _rows(payload, 'calendarEvents')) {
        await _database
            .into(_database.calendarEvents)
            .insertOnConflictUpdate(CalendarEvent.fromJson(_eventJson(row)));
      }
      for (final row in _rows(payload, 'vaccinationRecords')) {
        await _database
            .into(_database.vaccinationRecords)
            .insertOnConflictUpdate(VaccinationRecord.fromJson(row));
      }
    });
  }

  Future<void> _rememberHashes(
    SharedPreferences preferences,
    _SyncScope scope,
    String localHash,
    String remoteHash,
  ) async {
    await preferences.setString(
      _scopedPreferenceKey(_lastLocalHashKey, scope),
      localHash,
    );
    await preferences.setString(
      _scopedPreferenceKey(_lastRemoteHashKey, scope),
      remoteHash,
    );
  }

  String _scopedPreferenceKey(String baseKey, _SyncScope scope) =>
      '$baseKey.${scope.key}';

  List<Map<String, dynamic>> _rows(Map<String, dynamic> payload, String key) =>
      (payload[key] as List? ?? const [])
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .toList();

  String _hashPayload(Map<String, dynamic> payload) =>
      sha256.convert(utf8.encode(_canonicalJson(payload))).toString();

  String _hashStablePayload(Map<String, dynamic> payload) =>
      _hashPayload(_stableChangePayload(payload));

  Map<String, dynamic> _stableChangePayload(Map<String, dynamic> payload) {
    final stable = <String, dynamic>{...payload};
    final users = stable['users'];
    if (users is List) {
      stable['users'] = users.whereType<Map>().map((item) {
        final user = Map<String, dynamic>.from(item.cast<String, dynamic>())
          ..remove('lastSeenAt');
        return user;
      }).toList();
    }
    return stable;
  }

  String _canonicalJson(Object? value) {
    if (value is Map) {
      final sorted = <String, Object?>{};
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      for (final key in keys) {
        sorted[key] = _canonicalValue(value[key]);
      }
      return jsonEncode(sorted);
    }
    return jsonEncode(_canonicalValue(value));
  }

  Object? _canonicalValue(Object? value) {
    if (value is Map) {
      final sorted = <String, Object?>{};
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      for (final key in keys) {
        sorted[key] = _canonicalValue(value[key]);
      }
      return sorted;
    }
    if (value is List) return value.map(_canonicalValue).toList();
    return value;
  }

  Map<String, dynamic> _normalizePayload(Map<String, dynamic> payload) {
    final normalized = <String, dynamic>{'format': 'SELETO_SYNC_V1'};
    for (final key in _syncCollectionKeys) {
      final primaryKey = _specFor(key).jsonPrimaryKey;
      final rows = _rows(payload, key);
      rows.sort((a, b) {
        final left = (a[primaryKey] ?? '').toString();
        final right = (b[primaryKey] ?? '').toString();
        return left.compareTo(right);
      });
      normalized[key] = rows;
    }
    return normalized;
  }

  _SyncTableSpec _specFor(String collectionKey) =>
      _syncTables.firstWhere((spec) => spec.collectionKey == collectionKey);
}

Map<String, dynamic> _userJson(Map<String, dynamic> json) => {
  ...json,
  'tenantId': json['tenantId'] ?? defaultTenantId,
};

Map<String, dynamic> _eggCollectionJson(Map<String, dynamic> json) {
  if (json.containsKey('cleanEggs') &&
      json.containsKey('dirtyEggs') &&
      json.containsKey('crackedEggs')) {
    return json;
  }
  final quantity = json['quantity'] as int? ?? 0;
  final broken = json['brokenEggs'] as int? ?? 0;
  final discarded = json['discardedEggs'] as int? ?? 0;
  return {
    ...json,
    'cleanEggs': (quantity - broken - discarded).clamp(0, quantity),
    'dirtyEggs': 0,
    'crackedEggs': discarded,
  };
}

Map<String, dynamic> _trayJson(Map<String, dynamic> json) => {
  ...json,
  'unitPackagingCostCents': json['unitPackagingCostCents'] ?? 0,
  'finalUnitPriceCents': json['finalUnitPriceCents'] ?? 0,
};

Map<String, dynamic> _saleJson(Map<String, dynamic> json) => {
  ...json,
  'status': json['status'] ?? 'CONFIRMED',
};

Map<String, dynamic> _eventJson(Map<String, dynamic> json) => {
  ...json,
  'alertEnabled': json['alertEnabled'] ?? true,
  'alertTime': json['alertTime'] ?? '08:00',
  'recurrence': json['recurrence'] ?? 'ONCE',
};

class _SyncTableSpec {
  const _SyncTableSpec(
    this.collectionKey,
    this.remoteTable, {
    this.primaryKey = 'id',
  });

  final String collectionKey;
  final String remoteTable;
  final String primaryKey;

  String get jsonPrimaryKey => _snakeToCamelStatic(primaryKey);
}

class _SyncScope {
  const _SyncScope({
    required this.userId,
    required this.tenantId,
    required this.isSuperAdmin,
  });

  final String userId;
  final String tenantId;
  final bool isSuperAdmin;

  String get key => isSuperAdmin ? 'super_admin' : 'tenant_$tenantId';
}

String _snakeToCamelStatic(String value) => value.replaceAllMapped(
  RegExp(r'_([a-z0-9])'),
  (match) => match.group(1)!.toUpperCase(),
);

const _syncTables = [
  _SyncTableSpec('tenants', 'tenants'),
  _SyncTableSpec('users', 'users'),
  _SyncTableSpec('userPermissions', 'user_permissions'),
  _SyncTableSpec('auditLogs', 'audit_logs'),
  _SyncTableSpec('lots', 'lots'),
  _SyncTableSpec('birdMovements', 'bird_movements'),
  _SyncTableSpec('eggCollections', 'egg_collections'),
  _SyncTableSpec('eggStockMovements', 'egg_stock_movements'),
  _SyncTableSpec('ingredients', 'ingredients'),
  _SyncTableSpec('prices', 'ingredient_price_history'),
  _SyncTableSpec('ingredientLots', 'ingredient_lots'),
  _SyncTableSpec('ingredientStockMovements', 'ingredient_stock_movements'),
  _SyncTableSpec('formulas', 'feed_formulas'),
  _SyncTableSpec('formulaItems', 'feed_formula_items'),
  _SyncTableSpec('feedBatches', 'feed_batches'),
  _SyncTableSpec('feedBatchItems', 'feed_batch_items'),
  _SyncTableSpec('feedStock', 'feed_stock_movements'),
  _SyncTableSpec('feedings', 'daily_feedings'),
  _SyncTableSpec('feedRecommendations', 'feed_consumption_recommendations'),
  _SyncTableSpec('customers', 'customers'),
  _SyncTableSpec('orders', 'orders'),
  _SyncTableSpec('orderItems', 'order_items'),
  _SyncTableSpec('orderStatusHistory', 'order_status_history'),
  _SyncTableSpec('packagingItems', 'packaging_items'),
  _SyncTableSpec('packagingLots', 'packaging_lots'),
  _SyncTableSpec('packagingStockMovements', 'packaging_stock_movements'),
  _SyncTableSpec('eggTrayBatches', 'egg_tray_batches'),
  _SyncTableSpec('eggTrayStockMovements', 'egg_tray_stock_movements'),
  _SyncTableSpec('sales', 'sales'),
  _SyncTableSpec('finance', 'finance_transactions'),
  _SyncTableSpec('investments', 'investments'),
  _SyncTableSpec('financialEstablishments', 'financial_establishments'),
  _SyncTableSpec('personalFinance', 'personal_finance_transactions'),
  _SyncTableSpec('financialReserves', 'financial_reserves'),
  _SyncTableSpec('personalInvestments', 'personal_investments'),
  _SyncTableSpec('personalDebts', 'personal_debts'),
  _SyncTableSpec('lightingPrograms', 'lighting_programs'),
  _SyncTableSpec('lightingSteps', 'lighting_program_steps'),
  _SyncTableSpec('lotLighting', 'lot_lighting_programs'),
  _SyncTableSpec('calendarEvents', 'calendar_events'),
  _SyncTableSpec('vaccinationRecords', 'vaccination_records'),
  _SyncTableSpec('notificationSettings', 'notification_settings'),
  _SyncTableSpec('appSettings', 'app_settings', primaryKey: 'key'),
];

final _syncCollectionKeys = _syncTables
    .map((spec) => spec.collectionKey)
    .toList(growable: false);

const _globalOnlyCollectionKeys = {
  'feedRecommendations',
  'notificationSettings',
  'appSettings',
};

final seletoSyncServiceProvider = ChangeNotifierProvider<SeletoSyncService>((
  ref,
) {
  final service = SeletoSyncService(ref.watch(databaseProvider));
  return service;
});
