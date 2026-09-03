import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/demo_seed.dart';
import 'core/platform/alert_scheduler.dart';
import 'core/platform/notification_service.dart';
import 'core/widgets/app_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const persistDatabase = bool.fromEnvironment(
    'SELETO_PERSIST_DB',
    defaultValue: true,
  );
  const demoDatabase = bool.fromEnvironment('SELETO_DEMO_DB');
  const resetDatabase =
      demoDatabase ||
      !persistDatabase ||
      bool.fromEnvironment('SELETO_RESET_DB');
  const testDatabase = demoDatabase || bool.fromEnvironment('SELETO_TEST_DB');
  final database = await AppDatabase.open(
    resetOnStart: resetDatabase,
    testDatabase: testDatabase,
  );
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: _AppBootstrap(database: database),
    ),
  );
}

/// Shows a first frame immediately while the local database and locale data
/// are warming up. Previously these operations blocked [runApp], which made a
/// cold Web launch look unresponsive.
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap({required this.database});
  final AppDatabase database;

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final Future<void> _initialization = _initialize();

  Future<void> _initialize() async {
    await Future.wait([
      initializeDateFormatting('pt_BR'),
      const bool.fromEnvironment('SELETO_DEMO_DB')
          ? seedDemoDatabase(widget.database)
          : widget.database.seedInitialData(),
      NotificationService().initialize(),
    ]);
    await schedulePersistedAlerts(widget.database);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return MaterialApp(
          home: Scaffold(
            body: SeletoAppBackground(
              imagePath: 'assets/images/backgrounds/bg_caipira_orange_yolk.png',
              alignment: Alignment.centerRight,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Não foi possível preparar o banco local. Reinicie o aplicativo.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const MaterialApp(home: _StartupScreen());
      }
      return const SeletoApp();
    },
  );
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SeletoAppBackground(
      imagePath: 'assets/images/backgrounds/bg_caipira_orange_yolk.png',
      alignment: Alignment.centerRight,
      topOpacity: .68,
      bottomOpacity: .88,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('SELETO_LOGO.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'GRANJA SELETO',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    ),
  );
}
