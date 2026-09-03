import 'package:drift/drift.dart';
import 'package:drift/native.dart';

Future<QueryExecutor> openDatabaseConnection({
  required bool resetOnStart,
  required bool testDatabase,
}) async {
  return NativeDatabase.memory();
}
