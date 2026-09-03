import 'package:drift/drift.dart';

import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.html) 'database_connection_web.dart';

Future<QueryExecutor> openSeletoDatabaseConnection({
  required bool resetOnStart,
  required bool testDatabase,
}) => openDatabaseConnection(
  resetOnStart: resetOnStart,
  testDatabase: testDatabase,
);
