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

  test('lot transfer can unify and be undone with history', () async {
    final fromId = await db.registerLotPurchase(
      name: 'Origem',
      quantity: 10,
      receivedAt: DateTime(2026, 8),
      arrivalAgeDays: 30,
      actorId: actor,
    );
    final toId = await db.registerLotPurchase(
      name: 'Destino',
      quantity: 3,
      receivedAt: DateTime(2026, 8),
      arrivalAgeDays: 30,
      actorId: actor,
    );

    await db.transferBirds(
      fromLotId: fromId,
      toLotId: toId,
      quantity: 10,
      date: DateTime(2026, 8, 10),
      notes: 'Unificação',
      deactivateFromLot: true,
      actorId: actor,
    );

    var lots = await db.watchLotSummaries().first;
    expect(lots.firstWhere((l) => l.lot.id == fromId).activeBirds, 0);
    expect(lots.firstWhere((l) => l.lot.id == fromId).lot.status, 'INACTIVE');
    expect(lots.firstWhere((l) => l.lot.id == toId).activeBirds, 13);
    final transferOut = (await db.watchBirdMovementOverviews().first)
        .firstWhere((item) => item.movement.type == 'TRANSFER_OUT');
    expect(transferOut.lotName, 'ORIGEM');
    expect(transferOut.relatedLotName, 'DESTINO');
    expect(transferOut.canUndoTransfer, isTrue);

    await db.undoBirdTransfer(
      reference: transferOut.movement.reference!,
      actorId: actor,
    );

    lots = await db.watchLotSummaries().first;
    expect(lots.firstWhere((l) => l.lot.id == fromId).activeBirds, 10);
    expect(lots.firstWhere((l) => l.lot.id == fromId).lot.status, 'ACTIVE');
    expect(lots.firstWhere((l) => l.lot.id == toId).activeBirds, 3);
    final movements = await db.watchBirdMovementOverviews().first;
    expect(
      movements
          .firstWhere(
            (item) => item.movement.reference == transferOut.movement.reference,
          )
          .transferUndone,
      isTrue,
    );
    expect(
      movements.where(
        (item) => item.movement.reference?.startsWith('undo:') ?? false,
      ),
      isNotEmpty,
    );
    expect(movements.where((item) => item.canUndoTransfer), isEmpty);
  });

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

  test(
    'feed consumption recommendations can be imported from simple csv',
    () async {
      final result = await db.importFeedConsumptionRecommendations(
        filename: 'consumoracao.csv',
        bytes: Uint8List.fromList(
          utf8.encode(
            'semana,gramasPorAveDia,fase,fonte\n'
            '1,18,CRIA,Manual teste\n'
            '2,24,CRIA,Manual teste\n'
            '25,125,PRODUCAO_II,Manual teste\n',
          ),
        ),
        actorId: actor,
      );

      expect(result.rowCount, 3);
      final recommendations = await db
          .watchFeedConsumptionRecommendations()
          .first;
      expect(recommendations, hasLength(3));
      expect(recommendations.first.startWeek, 1);
      expect(recommendations.first.endWeek, 1);
      expect(recommendations.first.gramsPerBirdDay, 18);
      expect(recommendations.first.source, 'Manual teste');
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

  test('calendar records litter changes and sanitary treatments', () async {
    final lotId = await db.registerLotPurchase(
      name: 'Postura manejo',
      quantity: 12,
      receivedAt: DateTime(2026, 8, 1),
      arrivalAgeDays: 120,
      actorId: actor,
    );
    await db.addCalendarEvent(
      title: 'Troca de cama',
      type: 'LITTER_CHANGE',
      startsAt: DateTime(2026, 8, 5),
      lotId: lotId,
      notes: 'Cama substituída',
      alertEnabled: false,
      actorId: actor,
    );
    await db.addCalendarEvent(
      title: 'Tratamento sanitário',
      type: 'SANITARY_TREATMENT',
      startsAt: DateTime(2026, 8, 6),
      lotId: lotId,
      notes: 'Vermífugo',
      alertEnabled: false,
      actorId: actor,
    );

    final events = await db
        .watchCalendarEvents(DateTime(2026, 8), DateTime(2026, 9))
        .first;
    expect(events.map((event) => event.type), contains('LITTER_CHANGE'));
    expect(events.map((event) => event.type), contains('SANITARY_TREATMENT'));
    expect(events.every((event) => event.lotId == lotId), isTrue);
  });

  test('calendar alerts can be edited and deactivated', () async {
    final eventId = await db.addCalendarEvent(
      title: 'Alerta de manejo',
      type: 'ALERT',
      startsAt: DateTime(2026, 9, 8, 8),
      alertEnabled: true,
      alertMessage: 'Mensagem original',
      alertTime: '08:00',
      actorId: actor,
    );
    final event =
        (await db
                .watchCalendarEvents(DateTime(2026, 9), DateTime(2026, 10))
                .first)
            .singleWhere((item) => item.id == eventId);

    await db.updateCalendarEventAlert(
      event: event,
      title: 'Alerta editado',
      startsAt: DateTime(2026, 9, 8, 14, 30),
      alertEnabled: false,
      alertMessage: 'Mensagem editada',
      alertTime: '14:30',
      recurrence: 'WEEKLY',
      repeatUntil: DateTime(2026, 9, 30),
      weekdays: '${DateTime.tuesday},${DateTime.thursday}',
      actorId: actor,
    );

    final edited =
        (await db
                .watchCalendarEvents(DateTime(2026, 9), DateTime(2026, 10))
                .first)
            .singleWhere((item) => item.id == eventId);
    expect(edited.title, 'Alerta editado');
    expect(edited.startsAt, DateTime(2026, 9, 8, 14, 30));
    expect(edited.alertEnabled, isFalse);
    expect(edited.alertMessage, 'Mensagem editada');
    expect(edited.alertTime, '14:30');
    expect(edited.recurrence, 'WEEKLY');
    expect(edited.weekdays, '${DateTime.tuesday},${DateTime.thursday}');
  });

  test(
    'calendar alert list includes recurring alerts already started',
    () async {
      await db.addCalendarEvent(
        title: 'Alerta semanal',
        type: 'ALERT',
        startsAt: DateTime(2026, 9, 1, 7),
        alertEnabled: true,
        alertTime: '07:00',
        recurrence: 'WEEKLY',
        repeatUntil: DateTime(2026, 9, 30),
        weekdays: '${DateTime.tuesday}',
        actorId: actor,
      );

      final alerts = await db
          .watchCalendarAlertEvents(DateTime(2026, 9, 8), DateTime(2026, 9, 15))
          .first;

      expect(alerts.map((event) => event.title), contains('Alerta semanal'));
    },
  );

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

  test('assembled tray sale consumes and restores ready tray stock', () async {
    await db.registerLotPurchase(
      name: 'Poedeiras',
      quantity: 30,
      receivedAt: DateTime(2026, 1, 1),
      arrivalAgeDays: 200,
      actorId: actor,
    );
    final lot = (await db.watchLotSummaries().first).single;
    await db.registerEggCollection(
      collectedOn: DateTime(2026, 9, 1),
      lotId: lot.lot.id,
      quantity: 120,
      brokenEggs: 2,
      discardedEggs: 2,
      actorId: actor,
    );

    final trayItemId = await db.addPackagingItem(
      type: 'TRAY',
      name: 'Bandeja 30 ovos',
      actorId: actor,
    );
    final labelItemId = await db.addPackagingItem(
      type: 'LABEL',
      name: 'Etiqueta branca',
      actorId: actor,
    );
    final trayLotId = await db.addPackagingLot(
      itemId: trayItemId,
      batchCode: 'B30-01',
      quantity: 10,
      unitCostCents: 80,
      purchasedAt: DateTime(2026, 9, 1),
      actorId: actor,
    );
    final labelLotId = await db.addPackagingLot(
      itemId: labelItemId,
      batchCode: 'ET-01',
      quantity: 10,
      unitCostCents: 15,
      purchasedAt: DateTime(2026, 9, 1),
      actorId: actor,
    );

    final batchId = await db.assembleEggTrays(
      trayLotId: trayLotId,
      labelLotId: labelLotId,
      quantity: 3,
      eggsPerTray: 30,
      assembledAt: DateTime(2026, 9, 2),
      actorId: actor,
    );

    expect(await db.eggStockBalance(), 26);
    expect(await db.packagingLotBalance(trayLotId), 7);
    expect(await db.packagingLotBalance(labelLotId), 7);
    expect(await db.eggTrayBatchBalance(batchId), 3);

    await db.createEggTraySale(
      trayBatchId: batchId,
      trayQuantity: 2,
      trayUnitPriceCents: 3000,
      paymentMethod: 'PIX',
      actorId: actor,
    );

    expect(await db.eggTrayBatchBalance(batchId), 1);
    expect(await db.eggStockBalance(), 26);
    final sale = (await db.watchSales().first).single;
    expect(sale.trayBatchId, batchId);
    expect(sale.trayQuantity, 2);
    expect(sale.dozens, 5);
    expect(sale.totalCents, 6000);

    await db.cancelSale(sale.id, actorId: actor);

    expect(await db.eggTrayBatchBalance(batchId), 3);
    expect(await db.eggStockBalance(), 26);
    expect((await db.watchFinance().first).single.status, 'CANCELLED');
  });

  test('tray assembly reversal restores eggs, trays and labels', () async {
    await db.registerLotPurchase(
      name: 'Poedeiras',
      quantity: 30,
      receivedAt: DateTime(2026, 1, 1),
      arrivalAgeDays: 200,
      actorId: actor,
    );
    final lot = (await db.watchLotSummaries().first).single;
    await db.registerEggCollection(
      collectedOn: DateTime(2026, 9, 1),
      lotId: lot.lot.id,
      quantity: 120,
      brokenEggs: 0,
      discardedEggs: 0,
      actorId: actor,
    );
    final trayItemId = await db.addPackagingItem(
      type: 'TRAY',
      name: 'Bandeja 30 ovos',
      actorId: actor,
    );
    final labelItemId = await db.addPackagingItem(
      type: 'LABEL',
      name: 'Etiqueta premium',
      actorId: actor,
    );
    final trayLotId = await db.addPackagingLot(
      itemId: trayItemId,
      quantity: 5,
      unitCostCents: 90,
      actorId: actor,
    );
    final labelLotId = await db.addPackagingLot(
      itemId: labelItemId,
      quantity: 5,
      unitCostCents: 20,
      actorId: actor,
    );

    final batchId = await db.assembleEggTrays(
      trayLotId: trayLotId,
      labelLotId: labelLotId,
      quantity: 2,
      eggsPerTray: 30,
      trayUnitCostCents: 95,
      labelUnitCostCents: 25,
      eggUnitCostCents: 60,
      finalUnitPriceCents: 2500,
      actorId: actor,
    );

    final batch = (await db.select(db.eggTrayBatches).get()).single;
    expect(batch.id, batchId);
    expect(batch.trayUnitCostCents, 95);
    expect(batch.labelUnitCostCents, 25);
    expect(batch.eggUnitCostCents, 60);
    expect(batch.unitPackagingCostCents, 120);
    expect(batch.finalUnitPriceCents, 2500);
    final overview = (await db.watchEggTrayBatchBalances().first).single;
    expect(overview.unitAssemblyCostCents, 1920);
    expect(overview.unitProfitCents, 580);
    expect(overview.profitPercent, closeTo(0.302, 0.001));
    expect(await db.eggStockBalance(), 60);
    expect(await db.packagingLotBalance(trayLotId), 3);
    expect(await db.packagingLotBalance(labelLotId), 3);
    expect(await db.eggTrayBatchBalance(batchId), 2);

    await db.reverseEggTrayAssembly(batchId: batchId, actorId: actor);

    expect(await db.eggStockBalance(), 120);
    expect(await db.packagingLotBalance(trayLotId), 5);
    expect(await db.packagingLotBalance(labelLotId), 5);
    expect(await db.eggTrayBatchBalance(batchId), 0);
  });

  test(
    'tray assembly estimates egg cost from monthly feed consumption',
    () async {
      await db.registerLotPurchase(
        name: 'Poedeiras',
        quantity: 30,
        receivedAt: DateTime(2026, 9, 1),
        arrivalAgeDays: 200,
        actorId: actor,
      );
      final lot = (await db.watchLotSummaries().first).single;
      await db.registerReadyFeedPurchase(
        name: 'Ração postura',
        phase: 'postura',
        quantityKg: 20,
        totalCostCents: 2400,
        date: DateTime(2026, 9, 1),
        actorId: actor,
      );
      final feed = (await db.watchFeedBatchBalances().first).single;
      await db.registerFeeding(
        lotId: lot.lot.id,
        batchId: feed.batch.id,
        quantityKg: 5,
        date: DateTime(2026, 9, 2),
        actorId: actor,
      );
      await db.registerEggCollection(
        collectedOn: DateTime(2026, 9, 2),
        lotId: lot.lot.id,
        quantity: 60,
        brokenEggs: 0,
        discardedEggs: 0,
        actorId: actor,
      );

      expect(
        await db.estimatedEggUnitCostCents(referenceDate: DateTime(2026, 9, 2)),
        10,
      );

      final trayItemId = await db.addPackagingItem(
        type: 'TRAY',
        name: 'Bandeja 30 ovos',
        actorId: actor,
      );
      final labelItemId = await db.addPackagingItem(
        type: 'LABEL',
        name: 'Etiqueta',
        actorId: actor,
      );
      final trayLotId = await db.addPackagingLot(
        itemId: trayItemId,
        quantity: 2,
        unitCostCents: 100,
        actorId: actor,
      );
      final labelLotId = await db.addPackagingLot(
        itemId: labelItemId,
        quantity: 2,
        unitCostCents: 50,
        actorId: actor,
      );

      await db.assembleEggTrays(
        trayLotId: trayLotId,
        labelLotId: labelLotId,
        quantity: 1,
        eggsPerTray: 30,
        finalUnitPriceCents: 1500,
        assembledAt: DateTime(2026, 9, 2),
        actorId: actor,
      );

      final overview = (await db.watchEggTrayBatchBalances().first).single;
      expect(overview.batch.eggUnitCostCents, 10);
      expect(overview.unitAssemblyCostCents, 450);
      expect(overview.unitProfitCents, 1050);
      expect(overview.profitPercent, closeTo(2.333, 0.001));
    },
  );

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

  test('tenant scope isolates operational data by user partnership', () async {
    final admin = await db.createFirstAdminAccount(
      username: 'admin',
      displayName: 'Admin SELETO',
      password: 'Seleto@2026',
    );
    await db.createTenant(name: 'Parceiro independente', actorId: admin.id);
    final partnerTenant = (await db.watchTenants().first).firstWhere(
      (tenant) => tenant.name == 'Parceiro independente',
    );
    await db.createUser(
      username: 'parceiro',
      displayName: 'Sócio parceiro',
      password: 'Seleto@2026',
      isSuperuser: false,
      permissions: const ['dashboard.view', 'lots.view', 'birds.purchase'],
      actorId: admin.id,
      tenantId: partnerTenant.id,
    );
    final partner = await db.userByUsername('parceiro');
    final adminLotId = await db.registerLotPurchase(
      name: 'Lote matriz',
      quantity: 20,
      receivedAt: DateTime(2026, 8, 1),
      arrivalAgeDays: 30,
      actorId: admin.id,
    );
    await db.registerLotPurchase(
      name: 'Lote parceiro',
      quantity: 10,
      receivedAt: DateTime(2026, 8, 2),
      arrivalAgeDays: 30,
      actorId: partner!.id,
    );

    final adminLots = await db
        .watchLotSummaries(tenantId: admin.tenantId)
        .first;
    final partnerLots = await db
        .watchLotSummaries(tenantId: partnerTenant.id)
        .first;
    final allLots = await db.watchLotSummaries().first;

    expect(adminLots.map((item) => item.lot.name), ['LOTE MATRIZ']);
    expect(partnerLots.map((item) => item.lot.name), ['LOTE PARCEIRO']);
    expect(allLots.map((item) => item.lot.name).toSet(), {
      'LOTE MATRIZ',
      'LOTE PARCEIRO',
    });
    await expectLater(
      db.registerBirdOutflow(
        lotId: adminLotId,
        type: 'MORTALITY',
        quantity: 1,
        occurredAt: DateTime(2026, 8, 3),
        actorId: partner.id,
      ),
      throwsStateError,
    );
  });
}
