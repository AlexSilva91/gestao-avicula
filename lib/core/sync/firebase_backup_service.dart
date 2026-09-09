import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
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

class FirebaseBackupService extends ChangeNotifier {
  FirebaseBackupService(
    this._database, {
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  }) : _firestoreOverride = firestore,
       _authOverride = auth;

  final AppDatabase _database;
  final FirebaseFirestore? _firestoreOverride;
  final firebase_auth.FirebaseAuth? _authOverride;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Future<SyncResult>? _activeSync;
  DateTime? _lastAttemptAt;
  bool _started = false;
  bool _disposed = false;
  bool _hasSuccessfulSync = false;
  SyncResult _lastResult = const SyncResult(SyncStatus.idle);

  static const _deviceIdKey = 'seleto.sync.device_id';
  static const _lastLocalHashKey = 'seleto.sync.last_local_hash';
  static const _lastRemoteHashKey = 'seleto.sync.last_remote_hash';
  static const _minimumSyncInterval = Duration(minutes: 5);
  static const _networkTimeout = Duration(seconds: 10);
  static const _configTestCollection = 'seleto_config_tests';
  static const _legacyBackupCollection = 'seleto_backups';
  static const _legacyBackupDocument = 'operacional';

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;
  firebase_auth.FirebaseAuth get _auth =>
      _authOverride ?? firebase_auth.FirebaseAuth.instance;
  DocumentReference<Map<String, dynamic>> get _legacyDocument =>
      _firestore.collection(_legacyBackupCollection).doc(_legacyBackupDocument);
  SyncResult get lastResult => _lastResult;
  bool get isSynced => _hasSuccessfulSync;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(syncNow(reason: 'connectivity'));
      }
    });
    await syncNow(reason: 'startup', force: true);
  }

  Future<SyncResult> syncNow({String reason = 'manual', bool force = false}) {
    final activeSync = _activeSync;
    if (activeSync != null) return activeSync;
    final now = DateTime.now();
    if (!force &&
        _lastAttemptAt != null &&
        now.difference(_lastAttemptAt!) < _minimumSyncInterval) {
      return Future.value(const SyncResult(SyncStatus.skipped));
    }
    _lastAttemptAt = now;
    _setResult(const SyncResult(SyncStatus.syncing));
    final sync = _sync(reason)
        .then((result) {
          _setResult(result);
          return result;
        })
        .whenComplete(() => _activeSync = null);
    _activeSync = sync;
    return sync;
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_connectivitySubscription?.cancel());
    super.dispose();
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

  Future<SyncResult> _sync(String reason) async {
    try {
      if (!_canUseFirebase()) {
        return const SyncResult(SyncStatus.skipped);
      }
      if (!await _hasConnection()) {
        return const SyncResult(SyncStatus.offline);
      }
      await _ensureAuthenticated();

      final preferences = await SharedPreferences.getInstance();
      final localPayload = await _localPayload();
      final localHash = _hashPayload(localPayload);
      final remotePayload = await _remotePayload();
      final remoteHash = remotePayload == null
          ? null
          : _hashPayload(remotePayload);
      final lastLocalHash = preferences.getString(_lastLocalHashKey);
      final lastRemoteHash = preferences.getString(_lastRemoteHashKey);

      if (remotePayload == null) {
        if (!_hasRows(localPayload)) return const SyncResult(SyncStatus.idle);
        await _upload(localPayload);
        await _rememberHashes(preferences, localHash, localHash);
        return const SyncResult(SyncStatus.uploaded);
      }

      if (localHash == remoteHash) {
        await _rememberHashes(preferences, localHash, remoteHash!);
        return const SyncResult(SyncStatus.idle);
      }

      if (!_hasLocalUsers(localPayload) && _hasLocalUsers(remotePayload)) {
        await _restoreLocalPayload(remotePayload);
        await _rememberHashes(preferences, remoteHash!, remoteHash);
        return const SyncResult(SyncStatus.downloaded);
      }

      if (lastLocalHash == localHash && lastRemoteHash != remoteHash) {
        await _restoreLocalPayload(remotePayload);
        await _rememberHashes(preferences, remoteHash!, remoteHash);
        return const SyncResult(SyncStatus.downloaded);
      }

      if (lastRemoteHash == remoteHash && lastLocalHash != localHash) {
        await _upload(localPayload);
        await _rememberHashes(preferences, localHash, localHash);
        return const SyncResult(SyncStatus.uploaded);
      }

      final mergedPayload = _mergePayloads(localPayload, remotePayload);
      final mergedHash = _hashPayload(mergedPayload);
      await _restoreLocalPayload(mergedPayload);
      await _upload(mergedPayload);
      await _rememberHashes(preferences, mergedHash, mergedHash);
      return const SyncResult(SyncStatus.merged);
    } on FirebaseException catch (error) {
      return SyncResult(
        SyncStatus.failed,
        message: '${error.code}: ${error.message ?? 'erro do Firebase'}',
      );
    } catch (error) {
      return SyncResult(SyncStatus.failed, message: error.toString());
    }
  }

  bool _canUseFirebase() {
    if (_firestoreOverride != null && _authOverride != null) return true;
    if (Firebase.apps.isEmpty) return false;
    try {
      FirebaseFirestore.instance;
      firebase_auth.FirebaseAuth.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity.any((result) => result != ConnectivityResult.none);
  }

  Future<Map<String, dynamic>?> _remotePayload() async {
    final payload = <String, dynamic>{'format': 'SELETO_SYNC_V1'};
    for (final spec in _syncTables) {
      final snapshot = await _firestore
          .collection(spec.remoteTable)
          .get()
          .timeout(_networkTimeout);
      payload[spec.collectionKey] = snapshot.docs
          .map((doc) => _toLocalRow(doc.data()))
          .toList();
    }
    return _hasRows(payload) ? _normalizePayload(payload) : null;
  }

  Future<void> _upload(Map<String, dynamic> payload) async {
    await _ensureAuthenticated();
    final normalized = _normalizePayload(payload);
    await _deleteLegacyBackup();

    var batch = _firestore.batch();
    var pendingWrites = 0;

    Future<void> flush() async {
      if (pendingWrites == 0) return;
      await batch.commit().timeout(_networkTimeout);
      batch = _firestore.batch();
      pendingWrites = 0;
    }

    Future<void> queue(void Function(WriteBatch batch) write) async {
      if (pendingWrites >= 450) await flush();
      write(batch);
      pendingWrites++;
    }

    for (final spec in _syncTables) {
      final collection = _firestore.collection(spec.remoteTable);
      final rows = _rows(normalized, spec.collectionKey).map(_toRemoteRow);
      final localIds = <String>{};
      for (final row in rows) {
        final id = _documentIdFor(row, spec);
        localIds.add(id);
        await queue((batch) {
          batch.set(collection.doc(id), row);
        });
      }

      final existing = await collection.get().timeout(_networkTimeout);
      for (final document in existing.docs) {
        if (!localIds.contains(document.id)) {
          await queue((batch) => batch.delete(document.reference));
        }
      }
    }

    await flush();
  }

  Future<Map<String, dynamic>> testConfiguration() async {
    final checkedAt = DateTime.now().toIso8601String();
    final app = Firebase.apps.isEmpty ? null : Firebase.app();
    final result = <String, dynamic>{
      'servico': 'Firebase Firestore',
      'status': 'erro',
      'verificadoEm': checkedAt,
      'firebaseInicializado': app != null,
      'projeto': app?.options.projectId,
      'appId': app?.options.appId,
      'backup': {
        'modelo': 'colecao_por_tabela',
        'tabelas': _syncTables.map((spec) => spec.remoteTable).toList(),
      },
    };
    if (!_canUseFirebase()) {
      result['erro'] = {
        'codigo': 'firebase-nao-inicializado',
        'mensagem': 'O Firebase não foi inicializado neste ambiente.',
      };
      return result;
    }
    try {
      final uid = await _ensureAuthenticated();
      final deviceId = await _deviceId();
      final probe = _firestore.collection(_configTestCollection).doc(deviceId);
      await probe
          .set({
            'format': 'SELETO_FIREBASE_TEST_V1',
            'deviceId': deviceId,
            'firebaseUid': uid,
            'testedAt': FieldValue.serverTimestamp(),
            'testedAtLocal': checkedAt,
          })
          .timeout(_networkTimeout);
      final snapshot = await probe.get().timeout(_networkTimeout);
      result
        ..['status'] = 'sucesso'
        ..['autenticacao'] = {'tipo': 'anonima', 'uid': uid}
        ..['firestore'] = {
          'leitura': snapshot.exists,
          'escrita': true,
          'caminhoTeste': probe.path,
          'tabelas': _syncTables.map((spec) => spec.remoteTable).toList(),
        };
      return result;
    } on FirebaseException catch (error) {
      result['erro'] = {
        'codigo': error.code,
        'mensagem': error.message ?? 'Erro retornado pelo Firebase.',
      };
      if (error.code == 'permission-denied') {
        result['correcaoSugerida'] =
            'No console do Firebase, libere o Firestore para usuários autenticados ou publique as regras do arquivo docs/firestore.rules.';
      } else if (error.code == 'operation-not-allowed') {
        result['correcaoSugerida'] =
            'Ative o provedor Anônimo em Firebase Authentication > Sign-in method.';
      }
      return result;
    } catch (error) {
      result['erro'] = {
        'codigo': 'erro-desconhecido',
        'mensagem': error.toString(),
      };
      return result;
    }
  }

  Future<String?> _ensureAuthenticated() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return currentUser.uid;
    final credential = await _auth.signInAnonymously().timeout(_networkTimeout);
    return credential.user?.uid;
  }

  Future<String> _deviceId() async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getString(_deviceIdKey);
    if (current != null && current.isNotEmpty) return current;
    final created = const Uuid().v4();
    await preferences.setString(_deviceIdKey, created);
    return created;
  }

  Future<Map<String, dynamic>> _localPayload() async {
    final backup = jsonDecode(await _database.exportJson());
    final payload = (backup as Map).cast<String, dynamic>()
      ..remove('exportedAt')
      ..['format'] = 'SELETO_SYNC_V1';
    payload['users'] = (await _database.select(_database.users).get())
        .map((row) => row.toJson())
        .toList();
    payload['userPermissions'] =
        (await _database.select(_database.userPermissions).get())
            .map((row) => row.toJson())
            .toList();
    payload['auditLogs'] = (await _database.select(_database.auditLogs).get())
        .map((row) => row.toJson())
        .toList();
    return _normalizePayload(payload);
  }

  Future<void> _restoreLocalPayload(Map<String, dynamic> payload) async {
    await _restoreAuthPayload(payload);
    final backupPayload = Map<String, dynamic>.from(payload)
      ..['format'] = 'SELETO_BACKUP_V1';
    await _database.restoreJson(
      jsonEncode(backupPayload),
      actorId: 'sync',
      writeAudit: false,
    );
  }

  Future<void> _restoreAuthPayload(Map<String, dynamic> payload) async {
    await _database.transaction(() async {
      for (final row in _rows(payload, 'users')) {
        await _database
            .into(_database.users)
            .insertOnConflictUpdate(User.fromJson(row));
      }
      await _database.delete(_database.userPermissions).go();
      for (final row in _rows(payload, 'userPermissions')) {
        await _database
            .into(_database.userPermissions)
            .insert(
              UserPermission.fromJson(row),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final row in _rows(payload, 'auditLogs')) {
        await _database
            .into(_database.auditLogs)
            .insert(AuditLog.fromJson(row), mode: InsertMode.insertOrIgnore);
      }
    });
  }

  Future<void> _rememberHashes(
    SharedPreferences preferences,
    String localHash,
    String remoteHash,
  ) async {
    await preferences.setString(_lastLocalHashKey, localHash);
    await preferences.setString(_lastRemoteHashKey, remoteHash);
  }

  Map<String, dynamic> _mergePayloads(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = <String, dynamic>{'format': 'SELETO_SYNC_V1'};
    for (final key in _syncCollectionKeys) {
      merged[key] = _mergeRows(_rows(local, key), _rows(remote, key), key);
    }
    return _normalizePayload(merged);
  }

  List<Map<String, dynamic>> _mergeRows(
    List<Map<String, dynamic>> localRows,
    List<Map<String, dynamic>> remoteRows,
    String collectionKey,
  ) {
    final primaryKey = _specFor(collectionKey).jsonPrimaryKey;
    final byId = <String, Map<String, dynamic>>{};
    for (final row in remoteRows) {
      final id = row[primaryKey]?.toString();
      if (id != null && id.isNotEmpty) byId[id] = row;
    }
    for (final localRow in localRows) {
      final id = localRow[primaryKey]?.toString();
      if (id == null || id.isEmpty) continue;
      final remoteRow = byId[id];
      byId[id] = remoteRow == null
          ? localRow
          : _newerOrRemote(localRow, remoteRow);
    }
    final rows = byId.values.toList();
    rows.sort((a, b) {
      final left = (a[primaryKey] ?? '').toString();
      final right = (b[primaryKey] ?? '').toString();
      return left.compareTo(right);
    });
    return rows;
  }

  Map<String, dynamic> _newerOrRemote(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    if (_canonicalJson(local) == _canonicalJson(remote)) return remote;
    final localDate = _rowDate(local);
    final remoteDate = _rowDate(remote);
    if (localDate != null && remoteDate != null) {
      return localDate.isAfter(remoteDate) ? local : remote;
    }
    if (localDate != null && remoteDate == null) return local;
    return remote;
  }

  DateTime? _rowDate(Map<String, dynamic> row) {
    for (final key in _timestampKeys) {
      final value = row[key];
      if (value == null) continue;
      if (value is DateTime) return value;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      }
      if (value is String) return DateTime.tryParse(value);
    }
    return null;
  }

  bool _hasRows(Map<String, dynamic> payload) =>
      _syncCollectionKeys.any((key) => _rows(payload, key).isNotEmpty);

  bool _hasLocalUsers(Map<String, dynamic> payload) =>
      _rows(payload, 'users').isNotEmpty;

  List<Map<String, dynamic>> _rows(Map<String, dynamic> payload, String key) =>
      (payload[key] as List? ?? const [])
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .toList();

  String _hashPayload(Map<String, dynamic> payload) =>
      sha256.convert(utf8.encode(_canonicalJson(payload))).toString();

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

  Future<void> _deleteLegacyBackup() async {
    try {
      final chunks = await _legacyDocument
          .collection('chunks')
          .get()
          .timeout(_networkTimeout);
      var batch = _firestore.batch();
      var pendingWrites = 0;
      Future<void> flush() async {
        if (pendingWrites == 0) return;
        await batch.commit().timeout(_networkTimeout);
        batch = _firestore.batch();
        pendingWrites = 0;
      }

      for (final chunk in chunks.docs) {
        if (pendingWrites >= 450) await flush();
        batch.delete(chunk.reference);
        pendingWrites++;
      }
      if (pendingWrites >= 450) await flush();
      batch.delete(_legacyDocument);
      pendingWrites++;
      await flush();
    } catch (_) {
      // Best effort: old chunk-based backup should not block the correct mirror.
    }
  }

  String _documentIdFor(Map<String, dynamic> row, _SyncTableSpec spec) {
    final id = row[spec.primaryKey]?.toString();
    if (id != null && id.isNotEmpty && !id.contains('/')) return id;
    return _hashPayload({'row': row});
  }

  Map<String, dynamic> _toRemoteRow(Map<String, dynamic> localRow) {
    final remoteRow = <String, dynamic>{};
    for (final entry in localRow.entries) {
      remoteRow[_camelToSnake(entry.key)] = _toFirestoreValue(entry.value);
    }
    return remoteRow;
  }

  Map<String, dynamic> _toLocalRow(Map<String, dynamic> remoteRow) {
    final localRow = <String, dynamic>{};
    for (final entry in remoteRow.entries) {
      localRow[_snakeToCamel(entry.key)] = _fromFirestoreValue(entry.value);
    }
    return localRow;
  }

  Object? _toFirestoreValue(Object? value) {
    if (value is DateTime) return value.toIso8601String();
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _toFirestoreValue(entry.value),
      };
    }
    if (value is Iterable) return value.map(_toFirestoreValue).toList();
    return value;
  }

  Object? _fromFirestoreValue(Object? value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _fromFirestoreValue(entry.value),
      };
    }
    if (value is Iterable) return value.map(_fromFirestoreValue).toList();
    return value;
  }

  String _camelToSnake(String value) => value.replaceAllMapped(
    RegExp(r'(?<=[a-z0-9])[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );

  String _snakeToCamel(String value) => value.replaceAllMapped(
    RegExp(r'_([a-z0-9])'),
    (match) => match.group(1)!.toUpperCase(),
  );

  _SyncTableSpec _specFor(String collectionKey) =>
      _syncTables.firstWhere((spec) => spec.collectionKey == collectionKey);
}

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

String _snakeToCamelStatic(String value) => value.replaceAllMapped(
  RegExp(r'_([a-z0-9])'),
  (match) => match.group(1)!.toUpperCase(),
);

const _syncTables = [
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
  _SyncTableSpec('lightingPrograms', 'lighting_programs'),
  _SyncTableSpec('lightingSteps', 'lighting_program_steps'),
  _SyncTableSpec('lotLighting', 'lot_lighting_programs'),
  _SyncTableSpec('calendarEvents', 'calendar_events'),
  _SyncTableSpec('notificationSettings', 'notification_settings'),
  _SyncTableSpec('appSettings', 'app_settings', primaryKey: 'key'),
];

final _syncCollectionKeys = _syncTables
    .map((spec) => spec.collectionKey)
    .toList(growable: false);

const _timestampKeys = [
  'updatedAt',
  'createdAt',
  'timestamp',
  'occurredAt',
  'collectedOn',
  'effectiveDate',
  'entryDate',
  'validFrom',
  'producedAt',
  'feedingDate',
  'requestedDate',
  'purchasedAt',
  'assembledAt',
  'soldAt',
  'investmentDate',
  'startsAt',
  'assignedAt',
  'changedAt',
];

final firebaseBackupServiceProvider =
    ChangeNotifierProvider<FirebaseBackupService>((ref) {
      final service = FirebaseBackupService(ref.watch(databaseProvider));
      return service;
    });
