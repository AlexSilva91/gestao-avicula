import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<QueryExecutor> openDatabaseConnection({
  required bool resetOnStart,
  required bool testDatabase,
}) async {
  final directory = await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  final fileName = resetOnStart
      ? 'seleto_execucao.sqlite'
      : testDatabase
      ? 'seleto_teste.sqlite'
      : 'seleto.sqlite';
  final databaseFile = File(p.join(directory.path, fileName));
  if (resetOnStart) {
    await Future.wait([
      _deleteIfExists(databaseFile),
      _deleteIfExists(File('${databaseFile.path}-wal')),
      _deleteIfExists(File('${databaseFile.path}-shm')),
    ]);
  }
  return NativeDatabase.createInBackground(databaseFile);
}

Future<void> _deleteIfExists(File file) async {
  if (await file.exists()) {
    await file.delete();
  }
}
