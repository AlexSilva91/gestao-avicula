import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:seleto/app.dart';
import 'package:seleto/core/database/app_database.dart';
import 'package:seleto/core/widgets/app_shell.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));
  for (final width in [360.0, 412.0, 600.0, 1024.0, 1440.0]) {
    testWidgets('login has no overflow at ${width.toInt()} px', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.seedInitialData();
      addTearDown(db.close);
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const SeletoApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bem-vindo de volta'), findsOneWidget);
      expect(find.text('Ainda não tem conta?'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Criar conta'), findsOneWidget);
      expect(find.textContaining('Acesso inicial'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('first access creates the administrator account', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.seedInitialData();
    addTearDown(db.close);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const SeletoApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pumpAndSettle();
    expect(find.text('Criar conta'), findsWidgets);
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'Administrador');
    await tester.enterText(find.byType(TextFormField).at(2), 'Seleto@2026');
    await tester.enterText(find.byType(TextFormField).at(3), 'Seleto@2026');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();
    expect(find.text('Visão geral'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('login explains when user does not exist', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.seedInitialData();
    await _createTestAdmin(db);
    addTearDown(db.close);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const SeletoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'naoexiste');
    await tester.enterText(find.byType(TextFormField).at(1), 'Senha123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Usuário não encontrado'), findsOneWidget);
    expect(find.textContaining('Instance of'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login explains when password is wrong', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.seedInitialData();
    await _createTestAdmin(db);
    addTearDown(db.close);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const SeletoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'errada123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Senha incorreta para este usuário.'), findsOneWidget);
    expect(find.textContaining('Instance of'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('self service account shows pending activation message', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.seedInitialData();
    await _createTestAdmin(db);
    addTearDown(db.close);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const SeletoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'operador');
    await tester.enterText(find.byType(TextFormField).at(1), 'Operador');
    await tester.enterText(find.byType(TextFormField).at(2), 'Operador123');
    await tester.enterText(find.byType(TextFormField).at(3), 'Operador123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Conta criada'), findsOneWidget);
    expect(find.textContaining('ativar'), findsOneWidget);
    expect(find.text('Visão geral'), findsNothing);
    final created = await db.userByUsername('operador');
    expect(created?.isActive, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('administrator logs in and sees the responsive dashboard', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.seedInitialData();
    await _createTestAdmin(db);
    addTearDown(db.close);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const SeletoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await _loginAsAdmin(tester);
    await tester.pumpAndSettle();
    expect(find.text('Visão geral'), findsWidgets);
    expect(find.text('Aves ativas'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'administrator can navigate through every module without overflow',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.seedInitialData();
      await _createTestAdmin(db);
      addTearDown(db.close);
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const SeletoApp(),
        ),
      );
      await tester.pumpAndSettle();
      await _loginAsAdmin(tester);
      await tester.pumpAndSettle();
      for (final destination in seletoDestinations.skip(1)) {
        GoRouter.of(
          tester.element(find.byType(AppShell)),
        ).go(destination.route);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));
        expect(
          tester.takeException(),
          isNull,
          reason: 'Falha ao abrir ${destination.label}',
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('all modules render on a 412 px mobile viewport', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.seedInitialData();
    await _createTestAdmin(db);
    addTearDown(db.close);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const SeletoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await _loginAsAdmin(tester);
    await tester.pumpAndSettle();
    for (final destination in seletoDestinations.skip(1)) {
      GoRouter.of(tester.element(find.byType(AppShell))).go(destination.route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      expect(
        tester.takeException(),
        isNull,
        reason: 'Overflow mobile em ${destination.label}',
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('lighting assignment dialog has no overflow on mobile', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.seedInitialData();
    await _createTestAdmin(db);
    await db.registerLotPurchase(
      name: 'Lote de recria com nome comprido para validar responsividade',
      quantity: 120,
      receivedAt: DateTime(2026, 8, 1),
      arrivalAgeDays: 70,
      actorId: 'seed-admin',
    );
    addTearDown(db.close);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const SeletoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await _loginAsAdmin(tester);
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(AppShell))).go('/calendar');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.ensureVisible(find.text('Atribuir ao lote'));
    await tester.tap(find.text('Atribuir ao lote'));
    await tester.pumpAndSettle();

    expect(find.text('Programa de luz do lote'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });
}

Future<void> _createTestAdmin(AppDatabase db) => db.createFirstAdminAccount(
  username: 'admin',
  displayName: 'Administrador',
  password: 'Seleto@2026',
);

Future<void> _loginAsAdmin(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'admin');
  await tester.enterText(find.byType(TextFormField).at(1), 'Seleto@2026');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
}
