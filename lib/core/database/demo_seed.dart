import 'app_database.dart';
import 'operations_repository.dart';

const demoUsername = 'admin';
const demoPassword = 'Seleto@2026';

Future<void> seedDemoDatabase(AppDatabase db) async {
  final marker = await (db.select(
    db.appSettings,
  )..where((s) => s.key.equals('demo_seed_version'))).getSingleOrNull();
  if (marker != null) return;

  await db.seedInitialData();

  final admin = await db.hasUsers()
      ? await db.userByUsername(demoUsername)
      : await db.createFirstAdminAccount(
          username: demoUsername,
          displayName: 'Administrador Demo',
          password: demoPassword,
        );
  final actorId = admin?.id ?? 'system';
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);

  await _seedLots(db, actorId, startOfToday);
  await _seedFeed(db, actorId, startOfToday);
  await _seedCustomersAndSales(db, actorId, startOfToday);
  await _seedCalendarAndFinance(db, actorId, startOfToday);
  await db.saveAppSetting('demo_seed_version', '2026-09-02', actorId);
}

Future<void> _seedLots(AppDatabase db, String actorId, DateTime today) async {
  await db.registerLotPurchase(
    name: 'Lote 30 - Poedeiras',
    strain: 'Caipira pescoço pelado',
    quantity: 30,
    receivedAt: today.subtract(const Duration(days: 172)),
    arrivalAgeDays: 49,
    unitValueCents: 2600,
    supplier: 'Sítio Boa Vista',
    notes: 'Lote em produção com postura estável.',
    actorId: actorId,
  );
  await db.registerLotPurchase(
    name: 'Lote 04 - Recria',
    strain: 'Caipira melhorada',
    quantity: 42,
    receivedAt: today.subtract(const Duration(days: 84)),
    arrivalAgeDays: 21,
    unitValueCents: 1800,
    supplier: 'Granja Santa Luzia',
    notes: 'Acompanhamento de recria e consumo de ração.',
    actorId: actorId,
  );
  await db.registerLotPurchase(
    name: 'Lote 18 - Pré-postura',
    strain: 'Embrapa 051',
    quantity: 26,
    receivedAt: today.subtract(const Duration(days: 124)),
    arrivalAgeDays: 32,
    unitValueCents: 2300,
    supplier: 'Incubatório Sertão',
    notes: 'Entrando em produção, observar ganho de postura.',
    actorId: actorId,
  );

  final lots = await db.watchLotSummaries().first;
  final posture = lots.firstWhere((l) => l.lot.name.startsWith('LOTE 30'));
  final prePosture = lots.firstWhere((l) => l.lot.name.startsWith('LOTE 18'));

  await db.registerBirdOutflow(
    lotId: posture.lot.id,
    type: 'MORTALITY',
    quantity: 1,
    occurredAt: today.subtract(const Duration(days: 18)),
    notes: 'Baixa sanitária registrada no manejo.',
    actorId: actorId,
  );
  await db.registerBirdOutflow(
    lotId: prePosture.lot.id,
    type: 'ADJUSTMENT_OUT',
    quantity: 1,
    occurredAt: today.subtract(const Duration(days: 9)),
    notes: 'Ajuste de conferência do lote.',
    actorId: actorId,
  );

  for (var offset = 36; offset >= 0; offset--) {
    final date = today.subtract(Duration(days: offset));
    final weekdayWave = date.weekday % 3;
    await db.registerEggCollection(
      collectedOn: date,
      lotId: posture.lot.id,
      quantity: 23 + weekdayWave + (offset % 5 == 0 ? 2 : 0),
      brokenEggs: offset % 11 == 0 ? 1 : 0,
      discardedEggs: offset % 17 == 0 ? 1 : 0,
      notes: offset % 7 == 0 ? 'Coleta da manhã e tarde.' : null,
      actorId: actorId,
    );

    if (offset <= 21) {
      await db.registerEggCollection(
        collectedOn: date,
        lotId: prePosture.lot.id,
        quantity: 9 + (offset % 4),
        brokenEggs: offset % 13 == 0 ? 1 : 0,
        discardedEggs: 0,
        notes: 'Postura inicial em acompanhamento.',
        actorId: actorId,
      );
    }
  }
}

Future<void> _seedFeed(AppDatabase db, String actorId, DateTime today) async {
  final ingredients = await db.watchIngredientOverviews().first;
  const prices = {
    'Milho': 185,
    'Farelo de soja': 310,
    'Farelo de trigo': 155,
    'Calcário calcítico': 95,
    'Núcleo': 720,
    'Cúrcuma': 1680,
  };
  for (final item in ingredients) {
    final price = prices[item.ingredient.name] ?? 200;
    await db.registerIngredientPrice(
      ingredientId: item.ingredient.id,
      priceCents: (price * .96).round(),
      effectiveDate: today.subtract(const Duration(days: 40)),
      supplier: 'Cotação demo',
      actorId: actorId,
    );
    await db.registerIngredientStockEntry(
      ingredientId: item.ingredient.id,
      entryDate: today.subtract(const Duration(days: 16)),
      packageUnit: item.ingredient.name == 'Núcleo' ? 'KG' : 'SACO',
      packageQuantity: item.ingredient.name == 'Núcleo' ? 30 : 5,
      packageWeightKg: item.ingredient.name == 'Núcleo' ? 1 : 50,
      totalCostCents: item.ingredient.name == 'Núcleo'
          ? price * 30
          : price * 250,
      supplier: 'Estoque demo',
      notes: 'Entrada demo por movimentação.',
      actorId: actorId,
    );
  }

  final formulas = await db.watchFormulaOverviews().first;
  final productionFormula = formulas.firstWhere(
    (f) => f.formula.phase == 'PRODUCAO_I',
  );
  await db.manufactureFeed(
    formula: productionFormula,
    quantityKg: 180,
    date: today.subtract(const Duration(days: 12)),
    notes: 'Lote de ração com milho selecionado e cúrcuma.',
    actorId: actorId,
  );

  final batch = (await db.watchFeedBatchBalances().first).first;
  final lots = await db.watchLotSummaries().first;
  for (final lot in lots.where((l) => l.activeBirds > 0).take(2)) {
    await db.registerFeeding(
      lotId: lot.lot.id,
      batchId: batch.batch.id,
      quantityKg: lot.activeBirds * 0.115,
      date: today.subtract(const Duration(days: 1)),
      notes: 'Consumo diário estimado para teste.',
      actorId: actorId,
    );
  }
}

Future<void> _seedCustomersAndSales(
  AppDatabase db,
  String actorId,
  DateTime today,
) async {
  await db.addCustomer(
    name: 'Mercadinho São José',
    phone: '(81) 98888-1001',
    address: 'Centro',
    notes: 'Cliente semanal de ovos caipiras.',
    actorId: actorId,
  );
  await db.addCustomer(
    name: 'Dona Maria Bolos',
    phone: '(81) 97777-2002',
    address: 'Bairro Novo',
    notes: 'Prefere ovos de gema mais alaranjada.',
    actorId: actorId,
  );

  final customers = await db.watchCustomers().first;
  final market = customers.firstWhere((c) => c.name == 'Mercadinho São José');
  await db.createEggSale(
    customerId: market.id,
    dozens: 8,
    looseEggs: 6,
    dozenPriceCents: 1500,
    paymentMethod: 'PIX',
    date: today.subtract(const Duration(days: 1)),
    notes: 'Venda demo para validar estoque e financeiro.',
    actorId: actorId,
  );
  await db.createOrder(
    customerId: customers.firstWhere((c) => c.name == 'Dona Maria Bolos').id,
    productType: 'DOZEN',
    quantity: 5,
    unitPriceCents: 1550,
    requestedDate: today,
    deliveryDate: today.add(const Duration(days: 2)),
    notes: 'Pedido em aberto para teste do comercial.',
    actorId: actorId,
  );
}

Future<void> _seedCalendarAndFinance(
  AppDatabase db,
  String actorId,
  DateTime today,
) async {
  final lots = await db.watchLotSummaries().first;
  final lightingProgram = (await db.watchLightingPrograms().first).first;
  for (final lot in lots.take(2)) {
    await db.assignLightingProgram(
      lotId: lot.lot.id,
      programId: lightingProgram.id,
      actorId: actorId,
    );
  }
  await db.addCalendarEvent(
    title: 'Vacinação preventiva',
    type: 'MANEJO',
    startsAt: today.add(const Duration(days: 5, hours: 8)),
    lotId: lots.first.lot.id,
    notes: 'Evento demo para visualizar o calendário.',
    actorId: actorId,
  );
  await db.addFinance(
    type: 'EXPENSE',
    category: 'Sanidade',
    description: 'Vitaminas e vermífugo',
    amountCents: 12850,
    date: today.subtract(const Duration(days: 6)),
    paymentMethod: 'Cartão',
    actorId: actorId,
  );
  await db.addInvestment(
    description: 'Ninho coletivo e comedouros',
    category: 'Infraestrutura',
    amountCents: 68000,
    date: today.subtract(const Duration(days: 25)),
    lotId: lots.first.lot.id,
    actorId: actorId,
  );
}
