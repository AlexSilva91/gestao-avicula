import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:drift_flutter/drift_flutter.dart';

const _sqlite3Wasm = 'sqlite3.wasm';
const _driftWorker = 'drift_worker.js';

Future<QueryExecutor> openDatabaseConnection({
  required bool resetOnStart,
  required bool testDatabase,
}) async {
  final name = resetOnStart
      ? 'seleto_execucao'
      : testDatabase
      ? 'seleto_teste'
      : 'seleto';
  if (resetOnStart) {
    return _openResetWebDatabase(name);
  }
  return driftDatabase(
    name: name,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse(_sqlite3Wasm),
      driftWorker: Uri.parse(_driftWorker),
    ),
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  );
}

Future<QueryExecutor> _openResetWebDatabase(String name) async {
  final sqlite3Uri = Uri.parse(_sqlite3Wasm);
  final workerUri = Uri.parse(_driftWorker);
  final probe = await WasmDatabase.probe(
    sqlite3Uri: sqlite3Uri,
    driftWorkerUri: workerUri,
    databaseName: name,
  );
  for (final database in probe.existingDatabases) {
    if (database.$2 == name) {
      await probe.deleteDatabase(database);
    }
  }
  final result = await WasmDatabase.open(
    databaseName: name,
    sqlite3Uri: sqlite3Uri,
    driftWorkerUri: workerUri,
  );
  return result.resolvedExecutor;
}
