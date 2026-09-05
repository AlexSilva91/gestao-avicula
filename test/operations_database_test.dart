import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/core/database/app_database.dart';
import 'package:seleto/core/database/operational_data_import.dart';
import 'package:seleto/core/database/operations_repository.dart';

void main() {
  late AppDatabase db;
  const actor = 'seed-admin';
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.seedInitialData();
  });
  tearDown(() => db.close());

  test(
    'bird purchase creates lot, movement and financial expense atomically',
    () async {
      await db.registerLotPurchase(
        name: 'Lote teste',
        quantity: 20,
        receivedAt: DateTime(2026, 8, 1),
        arrivalAgeDays: 30,
        unitValueCents: 2500,
        actorId: actor,
      );
      final lots = await db.watchLotSummaries().first;
      expect(lots.single.activeBirds, 20);
      final finance = await db.watchFinance().first;
      expect(finance.single.amountCents, 50000);
      expect(finance.single.type, 'EXPENSE');
    },
  );

  test(
    'feed manufacture snapshots prices and feeding cannot make stock negative',
    () async {
      final ingredients = await db.watchIngredientOverviews().first;
      for (final item in ingredients) {
        await db.registerIngredientStockEntry(
          ingredientId: item.ingredient.id,
          entryDate: DateTime(2026),
          packageUnit: 'KG',
          packageQuantity: 100,
          packageWeightKg: 1,
          totalCostCents: 20000,
          actorId: actor,
        );
      }
      final formula = (await db.watchFormulaOverviews().first).firstWhere(
        (f) => f.formula.phase == 'CRIA',
      );
      await db.manufactureFeed(
        formula: formula,
        quantityKg: 25,
        date: DateTime(2026, 8, 1),
        actorId: actor,
      );
      final batch = (await db.watchFeedBatchBalances().first).single;
      expect(batch.balanceKg, 25);
      expect(batch.batch.totalCostCents, 5000);
      await db.registerLotPurchase(
        name: 'Cria',
        quantity: 10,
        receivedAt: DateTime(2026, 8, 1),
        arrivalAgeDays: 2,
        actorId: actor,
      );
      final lot = (await db.watchLotSummaries().first).single;
      await expectLater(
        db.registerFeeding(
          lotId: lot.lot.id,
          batchId: batch.batch.id,
          quantityKg: 26,
          date: DateTime(2026, 8, 2),
          actorId: actor,
        ),
        throwsStateError,
      );
      expect(await db.feedBalanceFor(batch.batch.id), 25);
      await db.registerFeeding(
        lotId: lot.lot.id,
        batchId: batch.batch.id,
        quantityKg: 2.5,
        date: DateTime(2026, 8, 2),
        actorId: actor,
      );
      expect(await db.feedBalanceFor(batch.batch.id), 22.5);
    },
  );

  test('feed manufacture consumes oldest ingredient lots first', () async {
    final ingredient = (await db.watchIngredientOverviews().first).firstWhere(
      (item) => item.ingredient.name == 'Milho',
    );
    await db.registerIngredientStockEntry(
      ingredientId: ingredient.ingredient.id,
      entryDate: DateTime(2026, 1, 1),
      packageUnit: 'KG',
      packageQuantity: 10,
      packageWeightKg: 1,
      totalCostCents: 1000,
      actorId: actor,
    );
    await db.registerIngredientStockEntry(
      ingredientId: ingredient.ingredient.id,
      entryDate: DateTime(2026, 1, 2),
      packageUnit: 'KG',
      packageQuantity: 10,
      packageWeightKg: 1,
      totalCostCents: 2000,
      actorId: actor,
    );
    final lots = await db
        .watchIngredientLotBalances(ingredientId: ingredient.ingredient.id)
        .first;
    final newest = lots.firstWhere((lot) => lot.lot.entryDate.day == 2);
    final oldest = lots.firstWhere((lot) => lot.lot.entryDate.day == 1);

    final formula = FormulaOverview(
      formula: FeedFormula(
        id: 'manual-formula',
        name: 'Manual',
        phase: 'CRIA',
        version: 1,
        isActive: true,
        validFrom: DateTime(2026),
        notes: null,
        createdBy: actor,
        createdAt: DateTime(2026),
      ),
      items: [
        FormulaIngredient(
          ingredientId: ingredient.ingredient.id,
          name: ingredient.ingredient.name,
          quantityKg: 100,
        ),
      ],
    );
    await db.manufactureFeed(
      formula: formula,
      quantityKg: 12,
      date: DateTime(2026, 1, 3),
      actorId: actor,
    );

    expect(await db.ingredientLotBalanceFor(oldest.lot.id), 0);
    expect(await db.ingredientLotBalanceFor(newest.lot.id), 8);
    final batch = (await db.watchFeedBatchBalances().first).single;
    expect(batch.batch.totalCostCents, 1400);
    expect(batch.batch.costPerKgCents, closeTo(116.67, .01));
  });

  test('ready feed purchase enters stock and creates expense', () async {
    await db.registerReadyFeedPurchase(
      name: 'Ração crescimento pronta',
      phase: 'crescimento',
      quantityKg: 40,
      totalCostCents: 9600,
      date: DateTime(2026, 8, 5),
      supplier: 'Agro Seleto',
      actorId: actor,
    );

    final batch = (await db.watchFeedBatchBalances().first).single;
    expect(batch.isReadyFeed, isTrue);
    expect(batch.displayName, 'Ração crescimento pronta');
    expect(batch.batch.phase, 'CRESCIMENTO');
    expect(batch.balanceKg, 40);
    expect(batch.batch.costPerKgCents, 240);

    final finance = await db.watchFinance().first;
    expect(finance.single.type, 'EXPENSE');
    expect(finance.single.category, 'Ração');
    expect(finance.single.amountCents, 9600);
  });

  test('ingredients and formulas can be edited and deactivated', () async {
    final ingredient = (await db.watchIngredientOverviews().first).first;
    await db.updateIngredient(
      ingredientId: ingredient.ingredient.id,
      name: 'Insumo editado',
      unit: 'kg',
      isActive: false,
      notes: 'Desativado no teste',
      actorId: actor,
    );
    final editedIngredient = (await db.watchIngredientOverviews().first)
        .firstWhere((item) => item.ingredient.id == ingredient.ingredient.id);
    expect(editedIngredient.ingredient.name, 'Insumo editado');
    expect(editedIngredient.ingredient.isActive, isFalse);

    final formula = (await db.watchFormulaOverviews().first).first;
    await db.updateFormula(
      source: formula,
      name: 'Formula editada',
      phase: 'teste',
      isActive: false,
      quantities: {
        for (final item in formula.items) item.ingredientId: item.quantityKg,
      },
      notes: 'Desativada no teste',
      actorId: actor,
    );
    final editedFormula = (await db.watchFormulaOverviews().first).firstWhere(
      (item) => item.formula.id == formula.formula.id,
    );
    expect(editedFormula.formula.name, 'Formula editada');
    expect(editedFormula.formula.phase, 'TESTE');
    expect(editedFormula.formula.isActive, isFalse);
    expect(editedFormula.items.length, formula.items.length);
  });

  test('laying rate history is calculated daily and monthly per lot', () async {
    await db.registerLotPurchase(
      name: 'Postura',
      quantity: 10,
      receivedAt: DateTime(2026, 1, 1),
      arrivalAgeDays: 160,
      actorId: actor,
    );
    final lot = (await db.watchLotSummaries().first).single;

    await db.registerEggCollection(
      collectedOn: DateTime(2026, 1, 2),
      lotId: lot.lot.id,
      quantity: 8,
      brokenEggs: 1,
      discardedEggs: 0,
      actorId: actor,
    );
    await db.registerBirdOutflow(
      lotId: lot.lot.id,
      type: 'MORTALITY',
      quantity: 2,
      occurredAt: DateTime(2026, 1, 3),
      actorId: actor,
    );
    await db.registerEggCollection(
      collectedOn: DateTime(2026, 1, 3),
      lotId: lot.lot.id,
      quantity: 6,
      brokenEggs: 0,
      discardedEggs: 0,
      actorId: actor,
    );

    final daily = await db.watchDailyLayingRates(days: 365).first;
    final januarySecond = daily.singleWhere(
      (entry) => entry.periodStart == DateTime(2026, 1, 2),
    );
    final januaryThird = daily.singleWhere(
      (entry) => entry.periodStart == DateTime(2026, 1, 3),
    );
    expect(januarySecond.totalEggs, 8);
    expect(januarySecond.stockEggs, 7);
    expect(januarySecond.activeBirdDays, 10);
    expect(januarySecond.layingRate, closeTo(.8, .001));
    expect(januaryThird.activeBirdDays, 8);
    expect(januaryThird.layingRate, closeTo(.75, .001));

    final monthly = await db.watchMonthlyLayingRates(months: 24).first;
    final january = monthly.single;
    expect(january.totalEggs, 14);
    expect(january.stockEggs, 13);
    expect(january.lostEggs, 1);
    expect(january.collectionDays, 2);
    expect(january.activeBirdDays, 18);
    expect(january.layingRate, closeTo(.777, .001));
  });

  test('egg sale creates stock out and finance in one transaction', () async {
    await db.registerLotPurchase(
      name: 'Poedeiras',
      quantity: 30,
      receivedAt: DateTime(2026, 1, 1),
      arrivalAgeDays: 200,
      actorId: actor,
    );
    final lot = (await db.watchLotSummaries().first).single;
    await db.registerEggCollection(
      collectedOn: DateTime.now(),
      lotId: lot.lot.id,
      quantity: 120,
      brokenEggs: 2,
      discardedEggs: 2,
      actorId: actor,
    );
    await db.createEggSale(
      dozens: 5,
      looseEggs: 0,
      dozenPriceCents: 1200,
      paymentMethod: 'PIX',
      actorId: actor,
    );
    expect(await db.eggStockBalance(), 56);
    final finance = await db.watchFinance().first;
    expect(finance.first.type, 'INCOME');
    expect(finance.first.amountCents, 6000);
  });

  test('cancelled egg sale restores stock and cancels revenue', () async {
    await db.registerLotPurchase(
      name: 'Poedeiras',
      quantity: 30,
      receivedAt: DateTime(2026, 1, 1),
      arrivalAgeDays: 200,
      actorId: actor,
    );
    final lot = (await db.watchLotSummaries().first).single;
    await db.registerEggCollection(
      collectedOn: DateTime.now(),
      lotId: lot.lot.id,
      quantity: 120,
      brokenEggs: 2,
      discardedEggs: 2,
      actorId: actor,
    );
    await db.createEggSale(
      dozens: 5,
      looseEggs: 0,
      dozenPriceCents: 1200,
      paymentMethod: 'PIX',
      actorId: actor,
    );
    final sale = (await db.watchSales().first).single;
    await db.cancelSale(sale.id, actorId: actor);

    expect(await db.eggStockBalance(), 116);
    expect((await db.watchSales().first).single.status, 'CANCELLED');
    expect((await db.watchFinance().first).single.status, 'CANCELLED');
    expect((await db.watchFinanceMetrics().first).incomeCents, 0);
  });

  test(
    'cancelled manual finance entry leaves audit trail and zeroes metric',
    () async {
      await db.addFinance(
        type: 'INCOME',
        category: 'Ajuste',
        description: 'Entrada manual',
        amountCents: 1500,
        actorId: actor,
      );
      final entry = (await db.watchFinance().first).single;
      await db.cancelFinance(entry.id, actorId: actor);

      expect((await db.watchFinance().first).single.status, 'CANCELLED');
      expect((await db.watchFinanceMetrics().first).incomeCents, 0);
      final auditActions = (await db.watchAuditLogs().first).map(
        (l) => l.action,
      );
      expect(auditActions, contains('finance.cancel'));
    },
  );

  test('delivering an order is idempotent', () async {
    await db.registerLotPurchase(
      name: 'Postura',
      quantity: 30,
      receivedAt: DateTime(2026, 1, 1),
      arrivalAgeDays: 200,
      actorId: actor,
    );
    final lot = (await db.watchLotSummaries().first).single;
    await db.registerEggCollection(
      collectedOn: DateTime.now(),
      lotId: lot.lot.id,
      quantity: 100,
      brokenEggs: 0,
      discardedEggs: 0,
      actorId: actor,
    );
    await db.createOrder(
      productType: 'DOZEN',
      quantity: 2,
      unitPriceCents: 1200,
      requestedDate: DateTime.now(),
      actorId: actor,
    );
    final order = (await db.watchOrders().first).single;
    await db.updateOrderStatus(
      orderId: order.id,
      newStatus: 'DELIVERED',
      actorId: actor,
    );
    await db.updateOrderStatus(
      orderId: order.id,
      newStatus: 'DELIVERED',
      actorId: actor,
    );
    final sales = await db.watchSales().first;
    expect(sales.length, 1);
    expect(await db.eggStockBalance(), 76);
  });

  test('backup round trip restores operational data', () async {
    await db.registerLotPurchase(
      name: 'Backup',
      quantity: 12,
      receivedAt: DateTime(2026, 8, 1),
      arrivalAgeDays: 20,
      actorId: actor,
    );
    final backup = await db.exportJson();
    await db.registerLotPurchase(
      name: 'Temporário',
      quantity: 5,
      receivedAt: DateTime(2026, 8, 2),
      arrivalAgeDays: 10,
      actorId: actor,
    );
    expect((await db.watchLotSummaries().first).length, 2);
    await db.restoreJson(backup, actorId: actor);
    final lots = await db.watchLotSummaries().first;
    expect(lots.length, 1);
    expect(lots.single.lot.name, 'BACKUP');
  });

  test('operational import strips protected user and audit sections', () {
    final result = parseOperationalImport(
      filename: 'dados.json',
      bytes: Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'format': 'SELETO_BACKUP_V1',
            'users': [
              {'username': 'intruso'},
            ],
            'userPermissions': [
              {'permission': '*'},
            ],
            'auditLogs': [
              {'action': 'tamper'},
            ],
            'appSettings': [
              {
                'key': 'production_feed_grams_per_bird',
                'value': '120',
                'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
                'updatedBy': actor,
              },
            ],
          }),
        ),
      ),
    );

    final payload = jsonDecode(result.backupJson) as Map<String, dynamic>;
    expect(payload.containsKey('users'), isFalse);
    expect(payload.containsKey('userPermissions'), isFalse);
    expect(payload.containsKey('auditLogs'), isFalse);
    expect(payload['appSettings'], isNotEmpty);
  });

  test('operational import preserves created users', () async {
    final admin = await db.createFirstAdminAccount(
      username: 'admin',
      displayName: 'Admin SELETO',
      password: 'Seleto@2026',
    );
    final beforePermissions = await db.permissionsOf(admin.id);

    await db.importOperationalData(
      filename: 'configuracoes.json',
      bytes: Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'format': 'SELETO_BACKUP_V1',
            'users': [
              {
                'id': 'malicious',
                'username': 'novo-admin',
                'displayName': 'Novo Admin',
                'passwordHash': 'invalid',
                'isSuperuser': true,
                'isActive': true,
                'createdAt': DateTime(2026, 1, 1).toIso8601String(),
                'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
              },
            ],
            'appSettings': [
              {
                'key': 'production_feed_grams_per_bird',
                'value': '125',
                'updatedAt': DateTime(2026, 1, 2).toIso8601String(),
                'updatedBy': actor,
              },
            ],
          }),
        ),
      ),
      actorId: admin.id,
    );

    expect(await db.userByUsername('admin'), isNotNull);
    expect(await db.userByUsername('novo-admin'), isNull);
    expect(await db.permissionsOf(admin.id), beforePermissions);
  });
}
