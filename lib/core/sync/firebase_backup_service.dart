import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
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
  _SyncScope? _scope;
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
  }

  void clearUserScope() {
    _scope = null;
    _lastAttemptAt = null;
    _hasSuccessfulSync = false;
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (_scope != null &&
          results.any((result) => result != ConnectivityResult.none)) {
        unawaited(syncNow(reason: 'connectivity'));
      }
    });
  }

  Future<SyncResult> syncNow({String reason = 'manual', bool force = false}) {
    final scope = _scope;
    if (scope == null) {
      return Future.value(
        const SyncResult(
          SyncStatus.skipped,
          message: 'Sincronização aguardando usuário logado.',
        ),
      );
    }
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
    final sync = _sync(reason, scope)
        .then((result) {
          _setResult(result);
          return result;
        })
        .whenComplete(() => _activeSync = null);
    _activeSync = sync;
    return sync;
  }

  Future<SyncResult> syncForLoginUsername(String username) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty) {
      return const SyncResult(SyncStatus.skipped);
    }
    try {
      if (!_canUseFirebase()) {
        return const SyncResult(SyncStatus.skipped);
      }
      if (!await _hasConnection()) {
        return const SyncResult(SyncStatus.offline);
      }
      await _ensureAuthenticated();
      final usersSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: normalizedUsername)
          .limit(1)
          .get()
          .timeout(_networkTimeout);
      if (usersSnapshot.docs.isEmpty) {
        return const SyncResult(SyncStatus.idle);
      }
      final user = _toLocalRow(usersSnapshot.docs.first.data());
      final userId = user['id']?.toString();
      final tenantId = user['tenantId']?.toString() ?? defaultTenantId;
      if (userId == null || userId.isEmpty) {
        return const SyncResult(SyncStatus.idle);
      }
      final permissionsSnapshot = await _firestore
          .collection('user_permissions')
          .where('user_id', isEqualTo: userId)
          .get()
          .timeout(_networkTimeout);
      final isSuperAdmin = permissionsSnapshot.docs
          .map((doc) => _toLocalRow(doc.data())['permission'])
          .contains('system.super_admin');
      final scope = _SyncScope(
        userId: userId,
        tenantId: tenantId,
        isSuperAdmin: isSuperAdmin,
      );
      final result = await _sync('login_missing_user', scope);
      _setResult(result);
      return result;
    } on FirebaseException catch (error) {
      return SyncResult(
        SyncStatus.failed,
        message: '${error.code}: ${error.message ?? 'erro do Firebase'}',
      );
    } catch (error) {
      return SyncResult(SyncStatus.failed, message: error.toString());
    }
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

  Future<SyncResult> _sync(String reason, _SyncScope scope) async {
    try {
      if (!_canUseFirebase()) {
        return const SyncResult(SyncStatus.skipped);
      }
      if (!await _hasConnection()) {
        return const SyncResult(SyncStatus.offline);
      }
      await _ensureAuthenticated();

      final preferences = await SharedPreferences.getInstance();
      final localPayload = await _localPayload(scope);
      final localHash = _hashPayload(localPayload);
      final remotePayload = await _remotePayload(scope);
      final remoteHash = remotePayload == null
          ? null
          : _hashPayload(remotePayload);
      final lastLocalHash = preferences.getString(
        _scopedPreferenceKey(_lastLocalHashKey, scope),
      );
      final lastRemoteHash = preferences.getString(
        _scopedPreferenceKey(_lastRemoteHashKey, scope),
      );

      if (remotePayload == null) {
        if (!_hasRows(localPayload)) return const SyncResult(SyncStatus.idle);
        await _upload(localPayload, scope);
        await _rememberHashes(preferences, scope, localHash, localHash);
        return const SyncResult(SyncStatus.uploaded);
      }

      if (localHash == remoteHash) {
        await _rememberHashes(preferences, scope, localHash, remoteHash!);
        return const SyncResult(SyncStatus.idle);
      }

      if (!_hasLocalUsers(localPayload) && _hasLocalUsers(remotePayload)) {
        await _restoreLocalPayload(remotePayload, scope);
        await _rememberHashes(preferences, scope, remoteHash!, remoteHash);
        return const SyncResult(SyncStatus.downloaded);
      }

      if (lastLocalHash == localHash && lastRemoteHash != remoteHash) {
        final mergedPayload = _mergePayloads(localPayload, remotePayload);
        final mergedHash = _hashPayload(mergedPayload);
        await _restoreLocalPayload(mergedPayload, scope);
        await _upload(mergedPayload, scope);
        await _rememberHashes(preferences, scope, mergedHash, mergedHash);
        return const SyncResult(SyncStatus.merged);
      }

      if (lastRemoteHash == remoteHash && lastLocalHash != localHash) {
        await _upload(localPayload, scope);
        await _rememberHashes(preferences, scope, localHash, localHash);
        return const SyncResult(SyncStatus.uploaded);
      }

      final mergedPayload = _mergePayloads(localPayload, remotePayload);
      final mergedHash = _hashPayload(mergedPayload);
      await _restoreLocalPayload(mergedPayload, scope);
      await _upload(mergedPayload, scope);
      await _rememberHashes(preferences, scope, mergedHash, mergedHash);
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

  Future<Map<String, dynamic>?> _remotePayload(_SyncScope scope) async {
    final payload = <String, dynamic>{'format': 'SELETO_SYNC_V1'};
    if (!scope.isSuperAdmin) {
      return _remoteTenantPayload(scope);
    }
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

  Future<Map<String, dynamic>?> _remoteTenantPayload(_SyncScope scope) async {
    final payload = <String, dynamic>{'format': 'SELETO_SYNC_V1'};
    final tenantSnapshot = await _firestore
        .collection('tenants')
        .where('id', isEqualTo: scope.tenantId)
        .get()
        .timeout(_networkTimeout);
    payload['tenants'] = tenantSnapshot.docs
        .map((doc) => _toLocalRow(doc.data()))
        .toList();

    final userSnapshot = await _firestore
        .collection('users')
        .where('tenant_id', isEqualTo: scope.tenantId)
        .get()
        .timeout(_networkTimeout);
    final userRows = userSnapshot.docs
        .map((doc) => _toLocalRow(doc.data()))
        .toList();
    payload['users'] = userRows;
    final userIds = userRows
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    payload['userPermissions'] = await _queryRowsWhereIn(
      remoteTable: 'user_permissions',
      field: 'user_id',
      values: userIds,
    );
    payload['auditLogs'] = await _queryRowsWhereIn(
      remoteTable: 'audit_logs',
      field: 'user_id',
      values: userIds,
    );

    for (final key in _createdByCollectionKeys) {
      payload[key] = await _queryTenantScopedRows(
        remoteTable: _specFor(key).remoteTable,
        tenantId: scope.tenantId,
        createdByUserIds: userIds,
      );
    }

    for (final entry in _childCollectionParents.entries) {
      final parentIds = _rows(payload, entry.value.parentCollectionKey)
          .map((row) => row[entry.value.parentJsonKey]?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();
      payload[entry.key] = await _queryRowsWhereIn(
        remoteTable: _specFor(entry.key).remoteTable,
        field: entry.value.remoteField,
        values: parentIds,
      );
    }

    return _hasRows(payload) ? _normalizePayload(payload) : null;
  }

  Future<List<Map<String, dynamic>>> _queryRowsWhereIn({
    required String remoteTable,
    required String field,
    required Set<String> values,
  }) async {
    if (values.isEmpty) return const [];
    final rows = <Map<String, dynamic>>[];
    for (final chunk in _chunks(values.toList()..sort(), 30)) {
      final snapshot = await _firestore
          .collection(remoteTable)
          .where(field, whereIn: chunk)
          .get()
          .timeout(_networkTimeout);
      rows.addAll(snapshot.docs.map((doc) => _toLocalRow(doc.data())));
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> _queryTenantScopedRows({
    required String remoteTable,
    required String tenantId,
    required Set<String> createdByUserIds,
  }) async {
    final byId = <String, Map<String, dynamic>>{};
    final scopedSnapshot = await _firestore
        .collection(remoteTable)
        .where('tenant_scope', isEqualTo: tenantId)
        .get()
        .timeout(_networkTimeout);
    for (final doc in scopedSnapshot.docs) {
      final row = _toLocalRow(doc.data());
      byId[(row['id'] ?? doc.id).toString()] = row;
    }
    for (final row in await _queryRowsWhereIn(
      remoteTable: remoteTable,
      field: 'created_by',
      values: createdByUserIds,
    )) {
      byId[(row['id'] ?? _hashPayload(row)).toString()] = row;
    }
    return byId.values.toList();
  }

  Future<void> _upload(Map<String, dynamic> payload, _SyncScope scope) async {
    await _ensureAuthenticated();
    final normalized = _normalizePayload(payload);
    if (scope.isSuperAdmin) await _deleteLegacyBackup();
    final tenantByUserId = {
      for (final user in _rows(normalized, 'users'))
        if (user['id'] != null)
          user['id'].toString():
              user['tenantId']?.toString() ?? defaultTenantId,
    };

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
      final rows = _rows(normalized, spec.collectionKey).map((row) {
        final rowTenantScope =
            _tenantScopeForRow(spec.collectionKey, row, tenantByUserId) ??
            (scope.isSuperAdmin ? 'global' : scope.tenantId);
        return _toRemoteRow({...row, 'tenantScope': rowTenantScope});
      });
      final localIds = <String>{};
      for (final row in rows) {
        final id = _documentIdFor(row, spec);
        localIds.add(id);
        await queue((batch) {
          batch.set(collection.doc(id), row);
        });
      }

      final existing = scope.isSuperAdmin
          ? await collection.get().timeout(_networkTimeout)
          : await collection
                .where('tenant_scope', isEqualTo: scope.tenantId)
                .get()
                .timeout(_networkTimeout);
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
      // Insumos e formulações são localmente autoritativos (_localAuthoritativeOnMerge).
      // Usar insertOrIgnore para que dados apagados localmente NÃO sejam reinseridos
      // pela sincronização. O próximo upload removerá os itens do Firestore também.
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

  Map<String, dynamic> _mergePayloads(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = <String, dynamic>{'format': 'SELETO_SYNC_V1'};
    for (final key in _syncCollectionKeys) {
      merged[key] = _localAuthoritativeOnMerge.contains(key)
          ? _rows(local, key)
          : _mergeRows(_rows(local, key), _rows(remote, key), key);
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

Iterable<List<T>> _chunks<T>(List<T> values, int size) sync* {
  for (var index = 0; index < values.length; index += size) {
    final end = index + size > values.length ? values.length : index + size;
    yield values.sublist(index, end);
  }
}

String? _tenantScopeForRow(
  String collectionKey,
  Map<String, dynamic> row,
  Map<String, String> tenantByUserId,
) {
  if (collectionKey == 'tenants') return row['id']?.toString();
  if (collectionKey == 'users') {
    return row['tenantId']?.toString() ?? defaultTenantId;
  }
  final userId = switch (collectionKey) {
    'userPermissions' => row['userId']?.toString(),
    'auditLogs' => row['userId']?.toString(),
    'orderStatusHistory' => row['changedBy']?.toString(),
    _ => row['createdBy']?.toString(),
  };
  if (userId == null || userId.isEmpty || userId == 'system') return null;
  return tenantByUserId[userId] ?? defaultTenantId;
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

const _globalOnlyCollectionKeys = {
  'feedRecommendations',
  'notificationSettings',
  'appSettings',
};

const _localAuthoritativeOnMerge = {
  'ingredients',
  'prices',
  'ingredientLots',
  'ingredientStockMovements',
  'formulas',
  'formulaItems',
};

const _createdByCollectionKeys = {
  'lots',
  'birdMovements',
  'eggCollections',
  'eggStockMovements',
  'ingredients',
  'prices',
  'ingredientLots',
  'ingredientStockMovements',
  'formulas',
  'feedBatches',
  'feedStock',
  'feedings',
  'customers',
  'orders',
  'packagingItems',
  'packagingLots',
  'packagingStockMovements',
  'eggTrayBatches',
  'eggTrayStockMovements',
  'sales',
  'finance',
  'investments',
  'lightingPrograms',
  'lotLighting',
  'calendarEvents',
};

const _childCollectionParents = {
  'formulaItems': _ChildCollectionParent(
    'formulas',
    parentJsonKey: 'id',
    remoteField: 'formula_id',
  ),
  'feedBatchItems': _ChildCollectionParent(
    'feedBatches',
    parentJsonKey: 'id',
    remoteField: 'batch_id',
  ),
  'orderItems': _ChildCollectionParent(
    'orders',
    parentJsonKey: 'id',
    remoteField: 'order_id',
  ),
  'orderStatusHistory': _ChildCollectionParent(
    'orders',
    parentJsonKey: 'id',
    remoteField: 'order_id',
  ),
  'lightingSteps': _ChildCollectionParent(
    'lightingPrograms',
    parentJsonKey: 'id',
    remoteField: 'program_id',
  ),
};

class _ChildCollectionParent {
  const _ChildCollectionParent(
    this.parentCollectionKey, {
    required this.parentJsonKey,
    required this.remoteField,
  });

  final String parentCollectionKey;
  final String parentJsonKey;
  final String remoteField;
}

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
