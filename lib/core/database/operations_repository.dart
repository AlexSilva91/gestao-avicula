import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';
import 'operational_data_import.dart';
import '../utils/formatters.dart';

const _uuid = Uuid();

class IngredientOverview {
  const IngredientOverview({
    required this.ingredient,
    required this.stockKg,
    required this.activeLotCount,
    this.currentPriceCents,
    this.previousPriceCents,
    this.minimumPriceCents,
    this.maximumPriceCents,
    this.averagePriceCents,
  });
  final Ingredient ingredient;
  final double stockKg;
  final int activeLotCount;
  final int? currentPriceCents;
  final int? previousPriceCents;
  final int? minimumPriceCents;
  final int? maximumPriceCents;
  final double? averagePriceCents;
  double? get variationPercent =>
      currentPriceCents == null ||
          previousPriceCents == null ||
          previousPriceCents == 0
      ? null
      : (currentPriceCents! - previousPriceCents!) / previousPriceCents!;
}

class IngredientLotBalance {
  const IngredientLotBalance({
    required this.lot,
    required this.ingredientName,
    required this.balanceKg,
  });
  final IngredientLot lot;
  final String ingredientName;
  final double balanceKg;
  double get consumedKg => lot.initialQuantityKg - balanceKg;
}

class IngredientLotUsage {
  const IngredientLotUsage({
    required this.lot,
    required this.quantityKg,
    required this.costCents,
  });
  final IngredientLot lot;
  final double quantityKg;
  final int costCents;
}

class FormulaOverview {
  const FormulaOverview({required this.formula, required this.items});
  final FeedFormula formula;
  final List<FormulaIngredient> items;
}

class FormulaIngredient {
  const FormulaIngredient({
    required this.ingredientId,
    required this.name,
    required this.quantityKg,
  });
  final String ingredientId;
  final String name;
  final double quantityKg;
}

class FeedBatchBalance {
  const FeedBatchBalance({
    required this.batch,
    required this.balanceKg,
    this.formulaName,
  });
  final FeedBatche batch;
  final double balanceKg;
  final String? formulaName;
  double get consumedKg => batch.producedQuantityKg - balanceKg;
  bool get isReadyFeed => batch.formulaId.startsWith('ready-feed-');
  String get displayName =>
      isReadyFeed ? formulaName ?? batch.code : batch.code;
}

class FeedRecommendationImportResult {
  const FeedRecommendationImportResult({required this.rowCount});

  final int rowCount;
}

class FinanceMetrics {
  const FinanceMetrics({
    required this.incomeCents,
    required this.expenseCents,
    required this.investmentCents,
  });
  final int incomeCents;
  final int expenseCents;
  final int investmentCents;
  int get resultCents => incomeCents - expenseCents;
  double get margin => incomeCents == 0 ? 0 : resultCents / incomeCents;
  double? get paybackMonths =>
      resultCents <= 0 ? null : investmentCents / resultCents;
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.activeBirds,
    required this.activeLots,
    required this.eggStock,
    required this.feedStockKg,
    required this.pendingOrders,
    required this.monthIncomeCents,
    required this.monthExpenseCents,
    required this.monthFeedKg,
  });
  final int activeBirds;
  final int activeLots;
  final int eggStock;
  final double feedStockKg;
  final int pendingOrders;
  final int monthIncomeCents;
  final int monthExpenseCents;
  final double monthFeedKg;
}

class BirdMovementOverview {
  const BirdMovementOverview({
    required this.movement,
    required this.lotName,
    this.relatedLotName,
    required this.transferUndone,
  });
  final BirdMovement movement;
  final String lotName;
  final String? relatedLotName;
  final bool transferUndone;

  bool get isTransfer =>
      movement.type == 'TRANSFER_OUT' || movement.type == 'TRANSFER_IN';
  bool get canUndoTransfer =>
      movement.type == 'TRANSFER_OUT' &&
      movement.reference != null &&
      !movement.reference!.startsWith('undo:') &&
      !transferUndone;
}

class EggStockMetrics {
  const EggStockMetrics({
    required this.balance,
    required this.entries,
    required this.outputs,
    required this.losses,
  });
  final int balance;
  final int entries;
  final int outputs;
  final int losses;
}

class PackagingItemStock {
  const PackagingItemStock({
    required this.item,
    required this.balance,
    required this.activeLotCount,
  });
  final PackagingItem item;
  final int balance;
  final int activeLotCount;
}

class PackagingLotBalance {
  const PackagingLotBalance({
    required this.lot,
    required this.item,
    required this.balance,
  });
  final PackagingLot lot;
  final PackagingItem item;
  final int balance;
}

class EggTrayBatchBalance {
  const EggTrayBatchBalance({
    required this.batch,
    required this.balance,
    required this.trayName,
    required this.labelName,
  });
  final EggTrayBatch batch;
  final int balance;
  final String trayName;
  final String labelName;

  int get eggBalance => balance * batch.eggsPerTray;
  int get dozens => eggBalance ~/ 12;
  int get looseEggs => eggBalance % 12;
  int get unitAssemblyCostCents =>
      batch.trayUnitCostCents +
      batch.labelUnitCostCents +
      (batch.eggUnitCostCents * batch.eggsPerTray);
  int get totalAssemblyCostCents => unitAssemblyCostCents * batch.quantity;
  int get unitProfitCents => batch.finalUnitPriceCents - unitAssemblyCostCents;
  double get profitPercent =>
      unitAssemblyCostCents == 0 ? 0 : unitProfitCents / unitAssemblyCostCents;
}

class BirdMetrics {
  const BirdMetrics({
    required this.purchased,
    required this.active,
    required this.mortality,
  });
  final int purchased;
  final int active;
  final int mortality;
  double get mortalityRate => purchased == 0 ? 0 : mortality / purchased;
}

class ReportPoint {
  const ReportPoint(this.label, this.value, [this.secondary = 0]);
  final String label;
  final double value;
  final double secondary;
}

extension OperationsRepository on AppDatabase {
  String _tenantSql(String alias, String? tenantId) => tenantId == null
      ? '1=1'
      : '''($alias.created_by = 'system' OR EXISTS (
          SELECT 1 FROM users tenant_user
          WHERE tenant_user.id = $alias.created_by
            AND tenant_user.tenant_id = ?
        ) OR NOT EXISTS (
          SELECT 1 FROM users any_user
          WHERE any_user.id = $alias.created_by
        ))''';

  List<Variable<String>> _tenantVariables(String? tenantId, [int count = 1]) =>
      tenantId == null
      ? const []
      : List.generate(count, (_) => Variable.withString(tenantId));

  Expression<bool> _tenantExpression(
    GeneratedColumn<String> createdBy,
    String tenantId,
  ) {
    final tenantUsers = selectOnly(users)
      ..addColumns([users.id])
      ..where(users.tenantId.equals(tenantId));
    final knownUsers = selectOnly(users)..addColumns([users.id]);
    return createdBy.equals('system') |
        createdBy.isInQuery(tenantUsers) |
        createdBy.isNotInQuery(knownUsers);
  }

  Future<String> _actorTenantId(String actorId) => tenantIdForUser(actorId);

  Future<void> _assertGlobalWriteAllowed(String actorId) async {
    final actor = await userById(actorId);
    if (actor == null) return;
    final permissions = await permissionsOf(actorId);
    if (!permissions.contains('system.super_admin')) {
      throw StateError('Apenas o Super Admin pode alterar dados globais.');
    }
  }

  Future<void> _assertActorCanUseRecord({
    required String tableName,
    required String recordId,
    required String actorId,
  }) async {
    final row = await customSelect(
      'SELECT created_by FROM $tableName WHERE id = ? LIMIT 1',
      variables: [Variable.withString(recordId)],
    ).getSingleOrNull();
    final ownerId = row?.readNullable<String>('created_by');
    if (ownerId == null || ownerId == 'system') return;
    final actorTenantId = await _actorTenantId(actorId);
    final ownerTenantId = await tenantIdForUser(ownerId);
    if (ownerTenantId != actorTenantId) {
      throw StateError('Este registro pertence a outra parceria.');
    }
  }

  Future<OperationalImportResult> importOperationalData({
    required String filename,
    required Uint8List bytes,
    required String actorId,
  }) async {
    final parsed = parseOperationalImport(filename: filename, bytes: bytes);
    await restoreJson(parsed.backupJson, actorId: actorId);
    await addAudit(
      userId: actorId,
      action: 'data.import',
      entityType: 'database',
      description:
          'Importação operacional concluída: ${parsed.rowCount} linha(s) em ${parsed.sectionCount} seção(ões).',
    );
    return parsed;
  }

  Future<FeedRecommendationImportResult> importFeedConsumptionRecommendations({
    required String filename,
    required Uint8List bytes,
    required String actorId,
  }) async {
    await _assertGlobalWriteAllowed(actorId);
    final parsed = parseOperationalImport(filename: filename, bytes: bytes);
    final raw = jsonDecode(parsed.backupJson);
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Arquivo de consumo inválido.');
    }
    final sourceRows = (raw['feedRecommendations'] as List? ?? const [])
        .cast<Map>()
        .map((row) => row.cast<String, dynamic>())
        .toList();
    if (sourceRows.isEmpty) {
      throw const FormatException(
        'Nenhuma recomendação de consumo encontrada no arquivo.',
      );
    }
    final now = DateTime.now();
    final recommendations = <FeedConsumptionRecommendationsCompanion>[];
    for (var i = 0; i < sourceRows.length; i++) {
      recommendations.add(
        _feedConsumptionRecommendationFromImport(
          sourceRows[i],
          index: i,
          actorId: actorId,
          now: now,
          filename: filename,
        ),
      );
    }

    await transaction(() async {
      await delete(feedConsumptionRecommendations).go();
      for (final recommendation in recommendations) {
        await into(feedConsumptionRecommendations).insert(recommendation);
      }
      await addAudit(
        userId: actorId,
        action: 'feed_recommendations.import',
        entityType: 'feed_consumption_recommendations',
        description:
            'Importação de ${recommendations.length} recomendação(ões) de consumo de ração.',
      );
    });
    return FeedRecommendationImportResult(rowCount: recommendations.length);
  }

  Stream<BirdMetrics> watchBirdMetrics({String? tenantId}) =>
      customSelect(
        '''SELECT
    COALESCE(SUM(CASE WHEN type='PURCHASE' THEN quantity ELSE 0 END),0) purchased,
    COALESCE(SUM(CASE WHEN type IN ('PURCHASE','TRANSFER_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END),0) active,
    COALESCE(SUM(CASE WHEN type='MORTALITY' THEN quantity ELSE 0 END),0) mortality
    FROM bird_movements
    WHERE ${_tenantSql('bird_movements', tenantId)}''',
        variables: _tenantVariables(tenantId),
        readsFrom: {birdMovements},
      ).watchSingle().map(
        (r) => BirdMetrics(
          purchased: r.read<int>('purchased'),
          active: r.read<int>('active'),
          mortality: r.read<int>('mortality'),
        ),
      );
  Stream<List<ReportPoint>> watchEggProductionSeries({
    int days = 30,
    DateTime? start,
    DateTime? end,
    String? tenantId,
  }) {
    final now = DateTime.now();
    final startDate = start ?? now.subtract(Duration(days: days));
    final endDate = end ?? now.add(const Duration(days: 1));
    return customSelect(
      '''SELECT collected_on, SUM(quantity-broken_eggs-discarded_eggs) total
         FROM egg_collections
         WHERE collected_on>=? AND collected_on<?
           AND ${_tenantSql('egg_collections', tenantId)}
         GROUP BY date(collected_on) ORDER BY collected_on''',
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {eggCollections},
    ).watch().map(
      (rows) => rows
          .map(
            (r) => ReportPoint(
              '${r.read<DateTime>('collected_on').day}/${r.read<DateTime>('collected_on').month}',
              r.read<int>('total').toDouble(),
            ),
          )
          .toList(),
    );
  }

  Stream<List<ReportPoint>> watchFinanceSeries({
    int months = 6,
    DateTime? start,
    DateTime? end,
    String? tenantId,
  }) {
    final now = DateTime.now();
    final startDate = start ?? DateTime(now.year, now.month - months + 1);
    final endDate = end ?? now.add(const Duration(days: 1));
    return customSelect(
      '''SELECT strftime('%m/%Y', occurred_at, 'unixepoch') period,
         SUM(CASE WHEN type='INCOME' AND status='CONFIRMED' THEN amount_cents ELSE 0 END) income,
         SUM(CASE WHEN type='EXPENSE' AND status='CONFIRMED' THEN amount_cents ELSE 0 END) expense
         FROM finance_transactions
         WHERE occurred_at>=? AND occurred_at<?
           AND ${_tenantSql('finance_transactions', tenantId)}
         GROUP BY strftime('%Y-%m', occurred_at, 'unixepoch') ORDER BY occurred_at''',
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {financeTransactions},
    ).watch().map(
      (rows) => rows
          .map(
            (r) => ReportPoint(
              r.read<String>('period'),
              r.read<int>('income') / 100,
              r.read<int>('expense') / 100,
            ),
          )
          .toList(),
    );
  }

  Stream<List<IngredientOverview>> watchIngredientOverviews({
    String? tenantId,
    bool includeInactive = false,
  }) {
    final query = customSelect(
      '''
      SELECT i.*,
        (SELECT price_per_kg_cents FROM ingredient_price_history p WHERE p.ingredient_id=i.id AND ${_tenantSql('p', tenantId)} ORDER BY effective_date DESC, created_at DESC LIMIT 1) current_price,
        (SELECT price_per_kg_cents FROM ingredient_price_history p WHERE p.ingredient_id=i.id AND ${_tenantSql('p', tenantId)} ORDER BY effective_date DESC, created_at DESC LIMIT 1 OFFSET 1) previous_price,
        (SELECT MIN(price_per_kg_cents) FROM ingredient_price_history p WHERE p.ingredient_id=i.id AND ${_tenantSql('p', tenantId)}) minimum_price,
        (SELECT MAX(price_per_kg_cents) FROM ingredient_price_history p WHERE p.ingredient_id=i.id AND ${_tenantSql('p', tenantId)}) maximum_price,
        (SELECT AVG(price_per_kg_cents) FROM ingredient_price_history p WHERE p.ingredient_id=i.id AND ${_tenantSql('p', tenantId)}) average_price,
        COALESCE((SELECT SUM(CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END) FROM ingredient_stock_movements m WHERE m.ingredient_id=i.id AND ${_tenantSql('m', tenantId)}),0) stock_kg,
        COALESCE((SELECT COUNT(*) FROM ingredient_lots l WHERE l.ingredient_id=i.id AND (SELECT COALESCE(SUM(CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END),0) FROM ingredient_stock_movements m WHERE m.ingredient_lot_id=l.id) > 0.0001),0) active_lot_count
      FROM ingredients i
      WHERE ${_tenantSql('i', tenantId)}
        ${includeInactive ? '' : 'AND i.is_active = 1'}
      ORDER BY is_active DESC, name
    ''',
      variables: _tenantVariables(tenantId, 7),
      readsFrom: {
        ingredients,
        ingredientPriceHistory,
        ingredientLots,
        ingredientStockMovements,
      },
    );
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => IngredientOverview(
              ingredient: Ingredient(
                id: row.read<String>('id'),
                name: row.read<String>('name'),
                unit: row.read<String>('unit'),
                isActive: row.read<bool>('is_active'),
                notes: row.readNullable<String>('notes'),
                createdAt: row.read<DateTime>('created_at'),
                createdBy: row.read<String>('created_by'),
              ),
              stockKg: row.read<double>('stock_kg'),
              activeLotCount: row.read<int>('active_lot_count'),
              currentPriceCents: row.readNullable<int>('current_price'),
              previousPriceCents: row.readNullable<int>('previous_price'),
              minimumPriceCents: row.readNullable<int>('minimum_price'),
              maximumPriceCents: row.readNullable<int>('maximum_price'),
              averagePriceCents: row.readNullable<double>('average_price'),
            ),
          )
          .toList(),
    );
  }

  Stream<List<IngredientPriceHistoryData>> watchIngredientPrices(
    String ingredientId, {
    String? tenantId,
  }) {
    final query = select(ingredientPriceHistory)
      ..where((p) => p.ingredientId.equals(ingredientId))
      ..orderBy([(p) => OrderingTerm.desc(p.effectiveDate)])
      ..limit(100);
    if (tenantId != null) {
      query.where((p) => _tenantExpression(p.createdBy, tenantId));
    }
    return query.watch();
  }

  Stream<List<IngredientLotBalance>> watchIngredientLotBalances({
    String? ingredientId,
    String? tenantId,
    bool includeInactiveIngredients = false,
  }) {
    final filters = [
      if (ingredientId != null) 'l.ingredient_id = ?',
      _tenantSql('l', tenantId),
      if (!includeInactiveIngredients) 'i.is_active = 1',
    ];
    final where = 'WHERE ${filters.join(' AND ')}';
    final query = customSelect(
      '''
      SELECT l.*, i.name ingredient_name,
        COALESCE(SUM(CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END),0) balance_kg
      FROM ingredient_lots l
      JOIN ingredients i ON i.id = l.ingredient_id
      LEFT JOIN ingredient_stock_movements m ON m.ingredient_lot_id = l.id
      $where
      GROUP BY l.id
      ORDER BY l.entry_date DESC, l.created_at DESC
    ''',
      variables: [
        if (ingredientId != null) Variable.withString(ingredientId),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {ingredientLots, ingredients, ingredientStockMovements},
    );
    return query.watch().map(
      (rows) => rows
          .map(
            (r) => IngredientLotBalance(
              lot: IngredientLot(
                id: r.read<String>('id'),
                ingredientId: r.read<String>('ingredient_id'),
                code: r.read<String>('code'),
                entryDate: r.read<DateTime>('entry_date'),
                initialQuantityKg: r.read<double>('initial_quantity_kg'),
                packageUnit: r.read<String>('package_unit'),
                packageQuantity: r.read<double>('package_quantity'),
                packageWeightKg: r.read<double>('package_weight_kg'),
                totalCostCents: r.read<int>('total_cost_cents'),
                pricePerKgCents: r.read<int>('price_per_kg_cents'),
                supplier: r.readNullable<String>('supplier'),
                notes: r.readNullable<String>('notes'),
                createdBy: r.read<String>('created_by'),
                createdAt: r.read<DateTime>('created_at'),
              ),
              ingredientName: r.read<String>('ingredient_name'),
              balanceKg: r.read<double>('balance_kg'),
            ),
          )
          .toList(),
    );
  }

  Future<void> registerIngredientStockEntry({
    required String ingredientId,
    required DateTime entryDate,
    required String packageUnit,
    required double packageQuantity,
    required double packageWeightKg,
    required int totalCostCents,
    String? supplier,
    String? notes,
    required String actorId,
  }) async {
    if (packageQuantity <= 0 || packageWeightKg <= 0 || totalCostCents <= 0) {
      throw ArgumentError('Informe quantidade, peso e valor válidos.');
    }
    await _assertActorCanUseRecord(
      tableName: 'ingredients',
      recordId: ingredientId,
      actorId: actorId,
    );
    final normalizedUnit = packageUnit.trim().toUpperCase();
    if (normalizedUnit != 'KG' && normalizedUnit != 'SACO') {
      throw ArgumentError('Use KG ou SACO como unidade do lote.');
    }
    final quantityKg = normalizedUnit == 'SACO'
        ? packageQuantity * packageWeightKg
        : packageQuantity;
    final pricePerKgCents = (totalCostCents / quantityKg).round();
    final now = DateTime.now();
    final lotId = _uuid.v4();
    final code =
        'I${entryDate.millisecondsSinceEpoch.toString().substring(5)}-${lotId.substring(0, 4)}';
    await transaction(() async {
      await into(ingredientLots).insert(
        IngredientLotsCompanion.insert(
          id: lotId,
          ingredientId: ingredientId,
          code: code,
          entryDate: entryDate,
          initialQuantityKg: quantityKg,
          packageUnit: Value(normalizedUnit),
          packageQuantity: Value(packageQuantity),
          packageWeightKg: Value(packageWeightKg),
          totalCostCents: totalCostCents,
          pricePerKgCents: pricePerKgCents,
          supplier: Value(_cleanValue(supplier)),
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(ingredientStockMovements).insert(
        IngredientStockMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'PURCHASE_IN',
          occurredAt: entryDate,
          ingredientId: ingredientId,
          ingredientLotId: lotId,
          quantityKg: quantityKg,
          pricePerKgCentsSnapshot: pricePerKgCents,
          totalCostCents: totalCostCents,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(ingredientPriceHistory).insert(
        IngredientPriceHistoryCompanion.insert(
          id: _uuid.v4(),
          ingredientId: ingredientId,
          pricePerKgCents: pricePerKgCents,
          effectiveDate: entryDate,
          supplier: Value(_cleanValue(supplier)),
          notes: Value('Entrada $code'),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'ingredients.stock_in',
        entityType: 'ingredient_lot',
        entityId: lotId,
        description: 'Entrada de ${kg(quantityKg)} de insumo registrada.',
      );
    });
  }

  Future<void> adjustIngredientLotStock({
    required String ingredientLotId,
    required double quantityKg,
    required bool input,
    DateTime? occurredAt,
    String? notes,
    required String actorId,
  }) async {
    if (quantityKg <= 0) throw ArgumentError('Informe uma quantidade válida.');
    await _assertActorCanUseRecord(
      tableName: 'ingredient_lots',
      recordId: ingredientLotId,
      actorId: actorId,
    );
    final lot = await (select(
      ingredientLots,
    )..where((l) => l.id.equals(ingredientLotId))).getSingle();
    if (!input) {
      final balance = await ingredientLotBalanceFor(ingredientLotId);
      if (quantityKg > balance + .0001) {
        throw StateError('A correção deixaria o lote de insumo negativo.');
      }
    }
    final unitCost = lot.pricePerKgCents;
    final total = (quantityKg * unitCost).round();
    final id = _uuid.v4();
    final now = DateTime.now();
    await transaction(() async {
      await into(ingredientStockMovements).insert(
        IngredientStockMovementsCompanion.insert(
          id: id,
          type: input ? 'ADJUSTMENT_IN' : 'ADJUSTMENT_OUT',
          occurredAt: occurredAt ?? now,
          ingredientId: lot.ingredientId,
          ingredientLotId: lot.id,
          quantityKg: quantityKg,
          pricePerKgCentsSnapshot: unitCost,
          totalCostCents: total,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'ingredients.stock_adjust',
        entityType: 'ingredient_stock_movement',
        entityId: id,
        description: 'Correção de ${kg(quantityKg)} no lote ${lot.code}.',
      );
    });
  }

  Future<void> addIngredient({
    required String name,
    String unit = 'kg',
    String? notes,
    required String actorId,
  }) async {
    if (name.trim().isEmpty || unit.trim().isEmpty) {
      throw ArgumentError('Informe nome e unidade do insumo.');
    }
    final id = _uuid.v4();
    await transaction(() async {
      await into(ingredients).insert(
        IngredientsCompanion.insert(
          id: id,
          name: name.trim(),
          unit: Value(unit.trim()),
          notes: Value(_cleanValue(notes)),
          createdAt: DateTime.now(),
          createdBy: actorId,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'ingredients.manage',
        entityType: 'ingredient',
        entityId: id,
        description: 'Insumo ${name.trim()} cadastrado.',
      );
    });
  }

  Future<void> updateIngredient({
    required String ingredientId,
    required String name,
    required String unit,
    required bool isActive,
    String? notes,
    required String actorId,
  }) async {
    if (name.trim().isEmpty || unit.trim().isEmpty) {
      throw ArgumentError('Informe nome e unidade do insumo.');
    }
    await _assertActorCanUseRecord(
      tableName: 'ingredients',
      recordId: ingredientId,
      actorId: actorId,
    );
    await transaction(() async {
      await (update(
        ingredients,
      )..where((i) => i.id.equals(ingredientId))).write(
        IngredientsCompanion(
          name: Value(name.trim()),
          unit: Value(unit.trim()),
          isActive: Value(isActive),
          notes: Value(_cleanValue(notes)),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'ingredients.update',
        entityType: 'ingredient',
        entityId: ingredientId,
        description: 'Insumo ${name.trim()} atualizado.',
      );
    });
  }

  Future<void> registerIngredientPrice({
    required String ingredientId,
    required int priceCents,
    required DateTime effectiveDate,
    String? supplier,
    String? notes,
    required String actorId,
  }) async {
    if (priceCents <= 0) {
      throw ArgumentError('O preço deve ser maior que zero.');
    }
    await _assertActorCanUseRecord(
      tableName: 'ingredients',
      recordId: ingredientId,
      actorId: actorId,
    );
    final id = _uuid.v4();
    await transaction(() async {
      await into(ingredientPriceHistory).insert(
        IngredientPriceHistoryCompanion.insert(
          id: id,
          ingredientId: ingredientId,
          pricePerKgCents: priceCents,
          effectiveDate: effectiveDate,
          supplier: Value(_cleanValue(supplier)),
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: DateTime.now(),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'ingredients.price_register',
        entityType: 'ingredient_price',
        entityId: id,
        description: 'Novo preço de insumo registrado.',
      );
    });
  }

  Stream<List<FormulaOverview>> watchFormulaOverviews({
    String? tenantId,
    bool includeInactive = false,
    bool includeInactiveIngredients = false,
  }) {
    final query = customSelect(
      '''
      SELECT f.*, fi.ingredient_id, i.name ingredient_name,
        SUM(fi.base_quantity_kg) base_quantity_kg
      FROM feed_formulas f JOIN feed_formula_items fi ON fi.formula_id=f.id
      JOIN ingredients i ON i.id=fi.ingredient_id
      WHERE ${_tenantSql('f', tenantId)}
        ${includeInactive ? '' : 'AND f.is_active = 1'}
        ${includeInactiveIngredients ? '' : '''
        AND NOT EXISTS (
          SELECT 1
          FROM feed_formula_items hidden_fi
          JOIN ingredients hidden_i ON hidden_i.id = hidden_fi.ingredient_id
          WHERE hidden_fi.formula_id = f.id
            AND hidden_i.is_active = 0
        )
        '''}
      GROUP BY f.id, fi.ingredient_id
      ORDER BY f.phase, f.version DESC, i.name
    ''',
      variables: _tenantVariables(tenantId),
      readsFrom: {feedFormulas, feedFormulaItems, ingredients},
    );
    return query.watch().map((rows) {
      final result = <String, FormulaOverview>{};
      for (final row in rows) {
        final id = row.read<String>('id');
        final current = result[id];
        final item = FormulaIngredient(
          ingredientId: row.read<String>('ingredient_id'),
          name: row.read<String>('ingredient_name'),
          quantityKg: row.read<double>('base_quantity_kg'),
        );
        if (current == null) {
          result[id] = FormulaOverview(
            formula: FeedFormula(
              id: id,
              name: row.read<String>('name'),
              phase: row.read<String>('phase'),
              version: row.read<int>('version'),
              isActive: row.read<bool>('is_active'),
              validFrom: row.read<DateTime>('valid_from'),
              notes: row.readNullable<String>('notes'),
              createdBy: row.read<String>('created_by'),
              createdAt: row.read<DateTime>('created_at'),
            ),
            items: [item],
          );
        } else {
          current.items.add(item);
        }
      }
      return result.values.toList();
    });
  }

  Future<void> createFormulaVersion({
    required FormulaOverview source,
    required Map<String, double> quantities,
    String? notes,
    required String actorId,
  }) async {
    await _assertActorCanUseRecord(
      tableName: 'feed_formulas',
      recordId: source.formula.id,
      actorId: actorId,
    );
    final total = quantities.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    if ((total - 100).abs() > .01 ||
        quantities.values.any((value) => value < 0)) {
      throw ArgumentError(
        'A formulação base deve totalizar exatamente 100 kg.',
      );
    }
    final id = _uuid.v4();
    final now = DateTime.now();
    final actorTenantId = await _actorTenantId(actorId);
    await transaction(() async {
      await customStatement(
        '''
        UPDATE feed_formulas
        SET is_active = 0
        WHERE phase = ?
          AND created_by != 'system'
          AND EXISTS (
            SELECT 1 FROM users tenant_user
            WHERE tenant_user.id = feed_formulas.created_by
              AND tenant_user.tenant_id = ?
          )
        ''',
        [
          Variable.withString(source.formula.phase),
          Variable.withString(actorTenantId),
        ],
      );
      await into(feedFormulas).insert(
        FeedFormulasCompanion.insert(
          id: id,
          name: source.formula.name,
          phase: source.formula.phase,
          version: Value(source.formula.version + 1),
          validFrom: now,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      for (final entry in quantities.entries) {
        await into(feedFormulaItems).insert(
          FeedFormulaItemsCompanion.insert(
            id: _uuid.v4(),
            formulaId: id,
            ingredientId: entry.key,
            baseQuantityKg: entry.value,
          ),
        );
      }
      await addAudit(
        userId: actorId,
        action: 'feed_formulas.update',
        entityType: 'feed_formula',
        entityId: id,
        description: 'Nova versão da formulação ${source.formula.name} criada.',
      );
    });
  }

  Future<void> updateFormula({
    required FormulaOverview source,
    required String name,
    required String phase,
    required bool isActive,
    required Map<String, double> quantities,
    String? notes,
    required String actorId,
  }) async {
    await _assertActorCanUseRecord(
      tableName: 'feed_formulas',
      recordId: source.formula.id,
      actorId: actorId,
    );
    if (source.formula.createdBy == 'system' &&
        await userById(actorId) != null) {
      throw StateError(
        'Crie uma nova versão antes de alterar uma formulação padrão do sistema.',
      );
    }
    if (name.trim().isEmpty || phase.trim().isEmpty) {
      throw ArgumentError('Informe nome e fase da fórmula.');
    }
    final total = quantities.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    if ((total - 100).abs() > .01 ||
        quantities.values.any((value) => value < 0)) {
      throw ArgumentError(
        'A formulação base deve totalizar exatamente 100 kg.',
      );
    }
    await transaction(() async {
      await (update(
        feedFormulas,
      )..where((f) => f.id.equals(source.formula.id))).write(
        FeedFormulasCompanion(
          name: Value(name.trim()),
          phase: Value(phase.trim().toUpperCase()),
          isActive: Value(isActive),
          notes: Value(_cleanValue(notes)),
        ),
      );
      await (delete(
        feedFormulaItems,
      )..where((i) => i.formulaId.equals(source.formula.id))).go();
      for (final entry in quantities.entries) {
        await into(feedFormulaItems).insert(
          FeedFormulaItemsCompanion.insert(
            id: _uuid.v4(),
            formulaId: source.formula.id,
            ingredientId: entry.key,
            baseQuantityKg: entry.value,
          ),
        );
      }
      await addAudit(
        userId: actorId,
        action: 'feed_formulas.update',
        entityType: 'feed_formula',
        entityId: source.formula.id,
        description: 'Formulação ${name.trim()} atualizada.',
      );
    });
  }

  Future<double> ingredientLotBalanceFor(String ingredientLotId) async {
    final row = await customSelect(
      '''
      SELECT COALESCE(SUM(CASE WHEN type IN ('PURCHASE_IN','ADJUSTMENT_IN') THEN quantity_kg ELSE -quantity_kg END),0) balance
      FROM ingredient_stock_movements WHERE ingredient_lot_id=?
    ''',
      variables: [Variable.withString(ingredientLotId)],
      readsFrom: {ingredientStockMovements},
    ).getSingle();
    return row.read<double>('balance');
  }

  Future<List<IngredientLotUsage>> _planIngredientUsage({
    required String ingredientId,
    required double quantityKg,
    required DateTime producedAt,
    String? tenantId,
  }) async {
    final rows = await customSelect(
      '''
      SELECT l.*,
        COALESCE(SUM(CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END),0) balance_kg
      FROM ingredient_lots l
      LEFT JOIN ingredient_stock_movements m ON m.ingredient_lot_id = l.id
      WHERE l.ingredient_id = ? AND l.entry_date <= ?
        AND ${_tenantSql('l', tenantId)}
      GROUP BY l.id
      HAVING balance_kg > 0.0001
      ORDER BY l.entry_date ASC, l.created_at ASC
    ''',
      variables: [
        Variable.withString(ingredientId),
        Variable.withDateTime(producedAt),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {ingredientLots, ingredientStockMovements},
    ).get();
    var remaining = quantityKg;
    final usages = <IngredientLotUsage>[];
    for (final r in rows) {
      if (remaining <= .0001) break;
      final balance = r.read<double>('balance_kg');
      final consumed = balance < remaining ? balance : remaining;
      final lot = IngredientLot(
        id: r.read<String>('id'),
        ingredientId: r.read<String>('ingredient_id'),
        code: r.read<String>('code'),
        entryDate: r.read<DateTime>('entry_date'),
        initialQuantityKg: r.read<double>('initial_quantity_kg'),
        packageUnit: r.read<String>('package_unit'),
        packageQuantity: r.read<double>('package_quantity'),
        packageWeightKg: r.read<double>('package_weight_kg'),
        totalCostCents: r.read<int>('total_cost_cents'),
        pricePerKgCents: r.read<int>('price_per_kg_cents'),
        supplier: r.readNullable<String>('supplier'),
        notes: r.readNullable<String>('notes'),
        createdBy: r.read<String>('created_by'),
        createdAt: r.read<DateTime>('created_at'),
      );
      usages.add(
        IngredientLotUsage(
          lot: lot,
          quantityKg: consumed,
          costCents: (consumed * lot.pricePerKgCents).round(),
        ),
      );
      remaining -= consumed;
    }
    if (remaining > .0001) {
      final ingredient = await (select(
        ingredients,
      )..where((i) => i.id.equals(ingredientId))).getSingleOrNull();
      throw StateError(
        'Estoque insuficiente de ${ingredient?.name ?? 'insumo'}. Faltam ${kg(remaining)}.',
      );
    }
    return usages;
  }

  Future<void> manufactureFeed({
    required FormulaOverview formula,
    required double quantityKg,
    DateTime? date,
    String? notes,
    required String actorId,
  }) async {
    if (quantityKg <= 0) {
      throw ArgumentError('A quantidade produzida deve ser maior que zero.');
    }
    await _assertActorCanUseRecord(
      tableName: 'feed_formulas',
      recordId: formula.formula.id,
      actorId: actorId,
    );
    final now = DateTime.now();
    final producedAt = date ?? now;
    final actorTenantId = await _actorTenantId(actorId);
    final snapshots =
        <
          ({
            FormulaIngredient ingredient,
            double quantity,
            int price,
            int cost,
            List<IngredientLotUsage> usages,
          })
        >[];
    for (final item in formula.items.where((item) => item.quantityKg > 0)) {
      final scaled = item.quantityKg * quantityKg / 100;
      final usages = await _planIngredientUsage(
        ingredientId: item.ingredientId,
        quantityKg: scaled,
        producedAt: producedAt,
        tenantId: actorTenantId,
      );
      final cost = usages.fold<int>(0, (sum, item) => sum + item.costCents);
      snapshots.add((
        ingredient: item,
        quantity: scaled,
        price: (cost / scaled).round(),
        cost: cost,
        usages: usages,
      ));
    }
    final total = snapshots.fold<int>(0, (sum, item) => sum + item.cost);
    final id = _uuid.v4();
    final code =
        'R${producedAt.millisecondsSinceEpoch.toString().substring(5)}';
    await transaction(() async {
      await into(feedBatches).insert(
        FeedBatchesCompanion.insert(
          id: id,
          code: code,
          phase: formula.formula.phase,
          formulaId: formula.formula.id,
          producedAt: producedAt,
          producedQuantityKg: quantityKg,
          totalCostCents: total,
          costPerKgCents: total / quantityKg,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      for (final item in snapshots) {
        await into(feedBatchItems).insert(
          FeedBatchItemsCompanion.insert(
            id: _uuid.v4(),
            batchId: id,
            ingredientId: item.ingredient.ingredientId,
            quantityKg: item.quantity,
            pricePerKgCentsSnapshot: item.price,
            itemCostCents: item.cost,
          ),
        );
        for (final usage in item.usages) {
          await into(ingredientStockMovements).insert(
            IngredientStockMovementsCompanion.insert(
              id: _uuid.v4(),
              type: 'PRODUCTION_OUT',
              occurredAt: producedAt,
              ingredientId: item.ingredient.ingredientId,
              ingredientLotId: usage.lot.id,
              quantityKg: usage.quantityKg,
              pricePerKgCentsSnapshot: usage.lot.pricePerKgCents,
              totalCostCents: usage.costCents,
              referenceType: const Value('feed_batch'),
              referenceId: Value(id),
              notes: Value('Fabricação $code'),
              createdBy: actorId,
              createdAt: now,
            ),
          );
        }
      }
      await into(feedStockMovements).insert(
        FeedStockMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'PRODUCTION_IN',
          occurredAt: producedAt,
          batchId: id,
          quantityKg: quantityKg,
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'feed_batches.create',
        entityType: 'feed_batch',
        entityId: id,
        description: 'Fabricação $code de ${kg(quantityKg)} registrada.',
      );
    });
  }

  Future<void> registerReadyFeedPurchase({
    required String name,
    required String phase,
    required double quantityKg,
    required int totalCostCents,
    required DateTime date,
    String? supplier,
    String? notes,
    required String actorId,
  }) async {
    if (name.trim().isEmpty || phase.trim().isEmpty) {
      throw ArgumentError('Informe nome e fase da ração.');
    }
    if (quantityKg <= 0 || totalCostCents <= 0) {
      throw ArgumentError('Informe quantidade e valor válidos.');
    }
    final now = DateTime.now();
    final batchId = _uuid.v4();
    final formulaId = 'ready-feed-${_uuid.v4()}';
    final code =
        'RP${date.millisecondsSinceEpoch.toString().substring(5)}-${batchId.substring(0, 4)}';
    final cleanSupplier = _cleanValue(supplier);
    final cleanNotes = _cleanValue(notes);
    final batchNotes = [
      if (cleanSupplier != null) 'Fornecedor: $cleanSupplier',
      ?cleanNotes,
    ].join('\n');
    await transaction(() async {
      await into(feedFormulas).insert(
        FeedFormulasCompanion.insert(
          id: formulaId,
          name: name.trim(),
          phase: phase.trim().toUpperCase(),
          version: const Value(1),
          isActive: const Value(false),
          validFrom: date,
          notes: Value(cleanNotes),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(feedBatches).insert(
        FeedBatchesCompanion.insert(
          id: batchId,
          code: code,
          phase: phase.trim().toUpperCase(),
          formulaId: formulaId,
          producedAt: date,
          producedQuantityKg: quantityKg,
          totalCostCents: totalCostCents,
          costPerKgCents: totalCostCents / quantityKg,
          notes: Value(batchNotes.isEmpty ? null : batchNotes),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(feedStockMovements).insert(
        FeedStockMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'PRODUCTION_IN',
          occurredAt: date,
          batchId: batchId,
          quantityKg: quantityKg,
          notes: Value(cleanNotes),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(financeTransactions).insert(
        FinanceTransactionsCompanion.insert(
          id: _uuid.v4(),
          occurredAt: date,
          type: 'EXPENSE',
          category: 'Ração',
          description: 'Compra de ração pronta ${name.trim()}',
          amountCents: totalCostCents,
          referenceType: const Value('feed_batch'),
          referenceId: Value(batchId),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'feed_batches.ready_purchase',
        entityType: 'feed_batch',
        entityId: batchId,
        description: 'Compra de ${kg(quantityKg)} de ração pronta registrada.',
      );
    });
  }

  Stream<List<FeedBatchBalance>> watchFeedBatchBalances({String? tenantId}) {
    final query = customSelect(
      '''
      SELECT b.*, f.name formula_name,
        COALESCE(SUM(CASE WHEN m.type IN ('PRODUCTION_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END),0) balance_kg
      FROM feed_batches b
      LEFT JOIN feed_formulas f ON f.id=b.formula_id
      LEFT JOIN feed_stock_movements m ON m.batch_id=b.id
      WHERE ${_tenantSql('b', tenantId)}
      GROUP BY b.id
      ORDER BY b.produced_at DESC
    ''',
      variables: _tenantVariables(tenantId),
      readsFrom: {feedBatches, feedFormulas, feedStockMovements},
    );
    return query.watch().map(
      (rows) => rows
          .map(
            (r) => FeedBatchBalance(
              batch: FeedBatche(
                id: r.read<String>('id'),
                code: r.read<String>('code'),
                phase: r.read<String>('phase'),
                formulaId: r.read<String>('formula_id'),
                producedAt: r.read<DateTime>('produced_at'),
                producedQuantityKg: r.read<double>('produced_quantity_kg'),
                totalCostCents: r.read<int>('total_cost_cents'),
                costPerKgCents: r.read<double>('cost_per_kg_cents'),
                notes: r.readNullable<String>('notes'),
                createdBy: r.read<String>('created_by'),
                createdAt: r.read<DateTime>('created_at'),
              ),
              balanceKg: r.read<double>('balance_kg'),
              formulaName: r.readNullable<String>('formula_name'),
            ),
          )
          .toList(),
    );
  }

  Stream<List<DailyFeeding>> watchFeedings({
    int limit = 100,
    String? tenantId,
  }) {
    final query = select(dailyFeedings)
      ..orderBy([(f) => OrderingTerm.desc(f.feedingDate)])
      ..limit(limit);
    if (tenantId != null) {
      query.where((f) => _tenantExpression(f.createdBy, tenantId));
    }
    return query.watch();
  }

  Stream<List<FeedConsumptionRecommendation>>
  watchFeedConsumptionRecommendations() =>
      (select(feedConsumptionRecommendations)..orderBy([
            (r) => OrderingTerm.asc(r.startWeek),
            (r) => OrderingTerm.asc(r.endWeek),
          ]))
          .watch();

  Future<void> registerFeeding({
    required String lotId,
    required String batchId,
    required double quantityKg,
    required DateTime date,
    String? notes,
    required String actorId,
  }) async {
    if (quantityKg <= 0) throw ArgumentError('Informe uma quantidade válida.');
    await _assertActorCanUseRecord(
      tableName: 'lots',
      recordId: lotId,
      actorId: actorId,
    );
    await _assertActorCanUseRecord(
      tableName: 'feed_batches',
      recordId: batchId,
      actorId: actorId,
    );
    if (await activeBirdsFor(lotId) <= 0) {
      throw StateError('O lote não possui aves ativas.');
    }
    final balance = await feedBalanceFor(batchId);
    if (quantityKg > balance + .0001) {
      throw StateError('Saldo insuficiente. Disponível: ${kg(balance)}.');
    }
    final id = _uuid.v4();
    final now = DateTime.now();
    await transaction(() async {
      await into(dailyFeedings).insert(
        DailyFeedingsCompanion.insert(
          id: id,
          feedingDate: date,
          lotId: lotId,
          batchId: batchId,
          quantityKg: quantityKg,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(feedStockMovements).insert(
        FeedStockMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'FEEDING_OUT',
          occurredAt: date,
          batchId: batchId,
          quantityKg: quantityKg,
          feedingId: Value(id),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'feeding.register',
        entityType: 'daily_feeding',
        entityId: id,
        description: 'Alimentação de ${kg(quantityKg)} registrada.',
      );
    });
  }

  Future<double> feedBalanceFor(String batchId) async {
    final row = await customSelect(
      "SELECT COALESCE(SUM(CASE WHEN type IN ('PRODUCTION_IN','ADJUSTMENT_IN') THEN quantity_kg ELSE -quantity_kg END),0) balance FROM feed_stock_movements WHERE batch_id=?",
      variables: [Variable.withString(batchId)],
      readsFrom: {feedStockMovements},
    ).getSingle();
    return row.read<double>('balance');
  }

  Future<void> adjustFeedStock({
    required String batchId,
    required double quantityKg,
    required bool input,
    String? notes,
    required String actorId,
  }) async {
    if (quantityKg <= 0) throw ArgumentError('Informe uma quantidade válida.');
    await _assertActorCanUseRecord(
      tableName: 'feed_batches',
      recordId: batchId,
      actorId: actorId,
    );
    if (!input && quantityKg > await feedBalanceFor(batchId)) {
      throw StateError('O ajuste deixaria o estoque negativo.');
    }
    await transaction(() async {
      final id = _uuid.v4();
      await into(feedStockMovements).insert(
        FeedStockMovementsCompanion.insert(
          id: id,
          type: input ? 'ADJUSTMENT_IN' : 'ADJUSTMENT_OUT',
          occurredAt: DateTime.now(),
          batchId: batchId,
          quantityKg: quantityKg,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: DateTime.now(),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'feed_stock.adjust',
        entityType: 'feed_stock_movement',
        entityId: id,
        description: 'Ajuste de ${kg(quantityKg)} no estoque de ração.',
      );
    });
  }

  Stream<List<PackagingItemStock>> watchPackagingItemStocks({
    String? tenantId,
  }) {
    return customSelect(
      '''
      SELECT i.*,
        COALESCE(SUM(
          CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN')
          THEN m.quantity ELSE -m.quantity END
        ), 0) AS balance,
        COALESCE((
          SELECT COUNT(*) FROM packaging_lots l
          WHERE l.item_id = i.id AND (
            SELECT COALESCE(SUM(
              CASE WHEN lm.type IN ('PURCHASE_IN','ADJUSTMENT_IN')
              THEN lm.quantity ELSE -lm.quantity END
            ), 0)
            FROM packaging_stock_movements lm
            WHERE lm.lot_id = l.id
          ) > 0
        ), 0) AS active_lot_count
      FROM packaging_items i
      LEFT JOIN packaging_stock_movements m ON m.item_id = i.id
      WHERE ${_tenantSql('i', tenantId)}
      GROUP BY i.id
      ORDER BY i.type, i.name
      ''',
      variables: _tenantVariables(tenantId),
      readsFrom: {packagingItems, packagingLots, packagingStockMovements},
    ).watch().map(
      (rows) => rows
          .map(
            (row) => PackagingItemStock(
              item: PackagingItem(
                id: row.read<String>('id'),
                type: row.read<String>('type'),
                name: row.read<String>('name'),
                notes: row.readNullable<String>('notes'),
                isActive: row.read<bool>('is_active'),
                createdBy: row.read<String>('created_by'),
                createdAt: row.read<DateTime>('created_at'),
              ),
              balance: row.read<int>('balance'),
              activeLotCount: row.read<int>('active_lot_count'),
            ),
          )
          .toList(),
    );
  }

  Stream<List<PackagingLotBalance>> watchPackagingLotBalances({
    String? type,
    String? tenantId,
  }) {
    final filters = [if (type != null) 'i.type = ?', _tenantSql('l', tenantId)];
    final typeFilter = 'WHERE ${filters.join(' AND ')}';
    return customSelect(
      '''
      SELECT l.id AS lot_id, l.item_id, l.batch_code, l.initial_quantity,
        l.unit_cost_cents, l.total_cost_cents, l.purchased_at, l.supplier,
        l.notes AS lot_notes, l.created_by AS lot_created_by,
        l.created_at AS lot_created_at,
        i.id AS item_id_value, i.type AS item_type, i.name AS item_name,
        i.notes AS item_notes, i.is_active, i.created_by AS item_created_by,
        i.created_at AS item_created_at,
        COALESCE(SUM(
          CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN')
          THEN m.quantity ELSE -m.quantity END
        ), 0) AS balance
      FROM packaging_lots l
      JOIN packaging_items i ON i.id = l.item_id
      LEFT JOIN packaging_stock_movements m ON m.lot_id = l.id
      $typeFilter
      GROUP BY l.id
      ORDER BY l.purchased_at, l.created_at
      ''',
      variables: [
        if (type != null) Variable.withString(type),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {packagingItems, packagingLots, packagingStockMovements},
    ).watch().map(
      (rows) => rows
          .map(
            (row) => PackagingLotBalance(
              lot: PackagingLot(
                id: row.read<String>('lot_id'),
                itemId: row.read<String>('item_id'),
                batchCode: row.readNullable<String>('batch_code'),
                initialQuantity: row.read<int>('initial_quantity'),
                unitCostCents: row.read<int>('unit_cost_cents'),
                totalCostCents: row.read<int>('total_cost_cents'),
                purchasedAt: row.read<DateTime>('purchased_at'),
                supplier: row.readNullable<String>('supplier'),
                notes: row.readNullable<String>('lot_notes'),
                createdBy: row.read<String>('lot_created_by'),
                createdAt: row.read<DateTime>('lot_created_at'),
              ),
              item: PackagingItem(
                id: row.read<String>('item_id_value'),
                type: row.read<String>('item_type'),
                name: row.read<String>('item_name'),
                notes: row.readNullable<String>('item_notes'),
                isActive: row.read<bool>('is_active'),
                createdBy: row.read<String>('item_created_by'),
                createdAt: row.read<DateTime>('item_created_at'),
              ),
              balance: row.read<int>('balance'),
            ),
          )
          .toList(),
    );
  }

  Stream<List<EggTrayBatchBalance>> watchEggTrayBatchBalances({
    String? tenantId,
  }) {
    return customSelect(
      '''
      SELECT b.*, ti.name AS tray_name, li.name AS label_name,
        COALESCE(SUM(
          CASE WHEN m.type IN ('ASSEMBLY_IN','ADJUSTMENT_IN')
          THEN m.quantity ELSE -m.quantity END
        ), 0) AS balance
      FROM egg_tray_batches b
      JOIN packaging_lots tl ON tl.id = b.tray_lot_id
      JOIN packaging_items ti ON ti.id = tl.item_id
      JOIN packaging_lots ll ON ll.id = b.label_lot_id
      JOIN packaging_items li ON li.id = ll.item_id
      LEFT JOIN egg_tray_stock_movements m ON m.batch_id = b.id
      WHERE ${_tenantSql('b', tenantId)}
      GROUP BY b.id
      ORDER BY b.assembled_at DESC, b.created_at DESC
      ''',
      variables: _tenantVariables(tenantId),
      readsFrom: {
        eggTrayBatches,
        eggTrayStockMovements,
        packagingLots,
        packagingItems,
      },
    ).watch().map(
      (rows) => rows
          .map(
            (row) => EggTrayBatchBalance(
              batch: EggTrayBatch(
                id: row.read<String>('id'),
                trayLotId: row.read<String>('tray_lot_id'),
                labelLotId: row.read<String>('label_lot_id'),
                quantity: row.read<int>('quantity'),
                eggsPerTray: row.read<int>('eggs_per_tray'),
                assembledAt: row.read<DateTime>('assembled_at'),
                trayUnitCostCents: row.read<int>('tray_unit_cost_cents'),
                labelUnitCostCents: row.read<int>('label_unit_cost_cents'),
                eggUnitCostCents: row.read<int>('egg_unit_cost_cents'),
                unitPackagingCostCents: row.read<int>(
                  'unit_packaging_cost_cents',
                ),
                finalUnitPriceCents: row.read<int>('final_unit_price_cents'),
                notes: row.readNullable<String>('notes'),
                createdBy: row.read<String>('created_by'),
                createdAt: row.read<DateTime>('created_at'),
              ),
              balance: row.read<int>('balance'),
              trayName: row.read<String>('tray_name'),
              labelName: row.read<String>('label_name'),
            ),
          )
          .toList(),
    );
  }

  Future<int> packagingLotBalance(String lotId) async {
    final row = await customSelect(
      '''
      SELECT COALESCE(SUM(
        CASE WHEN type IN ('PURCHASE_IN','ADJUSTMENT_IN')
        THEN quantity ELSE -quantity END
      ), 0) AS balance
      FROM packaging_stock_movements
      WHERE lot_id = ?
      ''',
      variables: [Variable.withString(lotId)],
      readsFrom: {packagingStockMovements},
    ).getSingle();
    return row.read<int>('balance');
  }

  Future<int> eggTrayBatchBalance(String batchId) async {
    final row = await customSelect(
      '''
      SELECT COALESCE(SUM(
        CASE WHEN type IN ('ASSEMBLY_IN','ADJUSTMENT_IN')
        THEN quantity ELSE -quantity END
      ), 0) AS balance
      FROM egg_tray_stock_movements
      WHERE batch_id = ?
      ''',
      variables: [Variable.withString(batchId)],
      readsFrom: {eggTrayStockMovements},
    ).getSingle();
    return row.read<int>('balance');
  }

  Stream<int> watchEstimatedEggUnitCostCents({String? tenantId}) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    return customSelect(
      '''
      SELECT
        COALESCE((
          SELECT SUM(d.quantity_kg * b.cost_per_kg_cents)
          FROM daily_feedings d
          JOIN feed_batches b ON b.id = d.batch_id
          WHERE d.feeding_date >= ? AND d.feeding_date < ?
            AND ${_tenantSql('d', tenantId)}
        ), 0.0) AS feed_cost,
        COALESCE((
          SELECT SUM(quantity - broken_eggs - discarded_eggs)
          FROM egg_collections
          WHERE collected_on >= ? AND collected_on < ?
            AND ${_tenantSql('egg_collections', tenantId)}
        ), 0) AS eggs
      ''',
      variables: [
        Variable.withDateTime(month),
        Variable.withDateTime(nextMonth),
        ..._tenantVariables(tenantId),
        Variable.withDateTime(month),
        Variable.withDateTime(nextMonth),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {dailyFeedings, feedBatches, eggCollections},
    ).watchSingle().map((row) {
      final eggs = row.read<int>('eggs');
      if (eggs <= 0) return 0;
      return (row.read<double>('feed_cost') / eggs).round();
    });
  }

  Future<int> estimatedEggUnitCostCents({DateTime? referenceDate}) async {
    final reference = referenceDate ?? DateTime.now();
    final month = DateTime(reference.year, reference.month);
    final nextMonth = DateTime(reference.year, reference.month + 1);
    final row = await customSelect(
      '''
      SELECT
        COALESCE((
          SELECT SUM(d.quantity_kg * b.cost_per_kg_cents)
          FROM daily_feedings d
          JOIN feed_batches b ON b.id = d.batch_id
          WHERE d.feeding_date >= ? AND d.feeding_date < ?
        ), 0.0) AS feed_cost,
        COALESCE((
          SELECT SUM(quantity - broken_eggs - discarded_eggs)
          FROM egg_collections
          WHERE collected_on >= ? AND collected_on < ?
        ), 0) AS eggs
      ''',
      variables: [
        Variable.withDateTime(month),
        Variable.withDateTime(nextMonth),
        Variable.withDateTime(month),
        Variable.withDateTime(nextMonth),
      ],
      readsFrom: {dailyFeedings, feedBatches, eggCollections},
    ).getSingle();
    final eggs = row.read<int>('eggs');
    if (eggs <= 0) return 0;
    return (row.read<double>('feed_cost') / eggs).round();
  }

  Future<String> addPackagingItem({
    required String type,
    required String name,
    String? notes,
    required String actorId,
  }) async {
    if (!{'TRAY', 'LABEL'}.contains(type)) {
      throw ArgumentError('Tipo de material inválido.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('Informe o nome do material.');
    }
    final id = _uuid.v4();
    await transaction(() async {
      await into(packagingItems).insert(
        PackagingItemsCompanion.insert(
          id: id,
          type: type,
          name: name.trim(),
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: DateTime.now(),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'packaging.item_create',
        entityType: 'packaging_item',
        entityId: id,
        description: '${_packagingTypeLabel(type)} ${name.trim()} cadastrada.',
      );
    });
    return id;
  }

  Future<String> addPackagingLot({
    required String itemId,
    String? batchCode,
    required int quantity,
    required int unitCostCents,
    DateTime? purchasedAt,
    String? supplier,
    String? notes,
    required String actorId,
  }) async {
    if (quantity <= 0 || unitCostCents < 0) {
      throw ArgumentError('Informe quantidade e valor válidos.');
    }
    await _assertActorCanUseRecord(
      tableName: 'packaging_items',
      recordId: itemId,
      actorId: actorId,
    );
    final item = await (select(
      packagingItems,
    )..where((i) => i.id.equals(itemId))).getSingle();
    final id = _uuid.v4();
    final now = DateTime.now();
    final total = quantity * unitCostCents;
    await transaction(() async {
      await into(packagingLots).insert(
        PackagingLotsCompanion.insert(
          id: id,
          itemId: itemId,
          batchCode: Value(_cleanValue(batchCode)),
          initialQuantity: quantity,
          unitCostCents: Value(unitCostCents),
          totalCostCents: Value(total),
          purchasedAt: purchasedAt ?? now,
          supplier: Value(_cleanValue(supplier)),
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(packagingStockMovements).insert(
        PackagingStockMovementsCompanion.insert(
          id: _uuid.v4(),
          itemId: itemId,
          lotId: id,
          type: 'PURCHASE_IN',
          occurredAt: purchasedAt ?? now,
          quantity: quantity,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'packaging.lot_create',
        entityType: 'packaging_lot',
        entityId: id,
        description:
            'Lote de ${_packagingTypeLabel(item.type).toLowerCase()} ${item.name} cadastrado.',
      );
    });
    return id;
  }

  Future<String> assembleEggTrays({
    required String trayLotId,
    required String labelLotId,
    required int quantity,
    required int eggsPerTray,
    int? trayUnitCostCents,
    int? labelUnitCostCents,
    int? eggUnitCostCents,
    int? finalUnitPriceCents,
    DateTime? assembledAt,
    String? notes,
    required String actorId,
  }) async {
    if (quantity <= 0 || eggsPerTray < 12) {
      throw ArgumentError('Monte ao menos uma bandeja com 12 ovos ou mais.');
    }
    await _assertActorCanUseRecord(
      tableName: 'packaging_lots',
      recordId: trayLotId,
      actorId: actorId,
    );
    await _assertActorCanUseRecord(
      tableName: 'packaging_lots',
      recordId: labelLotId,
      actorId: actorId,
    );
    final trayLot = await _packagingLotWithItem(trayLotId, 'TRAY');
    final labelLot = await _packagingLotWithItem(labelLotId, 'LABEL');
    final trayBalance = await packagingLotBalance(trayLot.lot.id);
    final labelBalance = await packagingLotBalance(labelLot.lot.id);
    if (quantity > trayBalance) {
      throw StateError('Estoque de bandejas insuficiente.');
    }
    if (quantity > labelBalance) {
      throw StateError('Estoque de etiquetas insuficiente.');
    }
    final eggs = quantity * eggsPerTray;
    final actorTenantId = await _actorTenantId(actorId);
    final eggBalance = await eggStockBalance(tenantId: actorTenantId);
    if (eggs > eggBalance) {
      throw StateError('Estoque insuficiente. Disponível: $eggBalance ovos.');
    }
    final id = _uuid.v4();
    final now = DateTime.now();
    final occurredAt = assembledAt ?? now;
    final trayUnitCost = trayUnitCostCents ?? trayLot.lot.unitCostCents;
    final labelUnitCost = labelUnitCostCents ?? labelLot.lot.unitCostCents;
    final eggUnitCost =
        eggUnitCostCents ??
        await estimatedEggUnitCostCents(referenceDate: occurredAt);
    final finalUnitPrice = finalUnitPriceCents ?? 0;
    if (trayUnitCost < 0 ||
        labelUnitCost < 0 ||
        eggUnitCost < 0 ||
        finalUnitPrice < 0) {
      throw ArgumentError('Informe valores unitários válidos.');
    }
    final unitPackagingCost = trayUnitCost + labelUnitCost;
    await transaction(() async {
      await into(eggTrayBatches).insert(
        EggTrayBatchesCompanion.insert(
          id: id,
          trayLotId: trayLotId,
          labelLotId: labelLotId,
          quantity: quantity,
          eggsPerTray: eggsPerTray,
          assembledAt: occurredAt,
          trayUnitCostCents: Value(trayUnitCost),
          labelUnitCostCents: Value(labelUnitCost),
          eggUnitCostCents: Value(eggUnitCost),
          unitPackagingCostCents: Value(unitPackagingCost),
          finalUnitPriceCents: Value(finalUnitPrice),
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(packagingStockMovements).insert(
        PackagingStockMovementsCompanion.insert(
          id: _uuid.v4(),
          itemId: trayLot.item.id,
          lotId: trayLot.lot.id,
          type: 'ASSEMBLY_OUT',
          occurredAt: occurredAt,
          quantity: quantity,
          reference: Value(id),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(packagingStockMovements).insert(
        PackagingStockMovementsCompanion.insert(
          id: _uuid.v4(),
          itemId: labelLot.item.id,
          lotId: labelLot.lot.id,
          type: 'ASSEMBLY_OUT',
          occurredAt: occurredAt,
          quantity: quantity,
          reference: Value(id),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(eggStockMovements).insert(
        EggStockMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'ASSEMBLY_OUT',
          occurredAt: occurredAt,
          quantity: eggs,
          reference: Value(id),
          notes: Value('Montagem de $quantity bandeja(s).'),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(eggTrayStockMovements).insert(
        EggTrayStockMovementsCompanion.insert(
          id: _uuid.v4(),
          batchId: id,
          type: 'ASSEMBLY_IN',
          occurredAt: occurredAt,
          quantity: quantity,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'egg_trays.assemble',
        entityType: 'egg_tray_batch',
        entityId: id,
        description: '$quantity bandeja(s) com $eggsPerTray ovos montada(s).',
      );
    });
    return id;
  }

  Future<void> reverseEggTrayAssembly({
    required String batchId,
    required String actorId,
  }) async {
    await _assertActorCanUseRecord(
      tableName: 'egg_tray_batches',
      recordId: batchId,
      actorId: actorId,
    );
    final batch = await (select(
      eggTrayBatches,
    )..where((b) => b.id.equals(batchId))).getSingle();
    final balance = await eggTrayBatchBalance(batchId);
    if (balance <= 0) {
      throw StateError('Esta montagem já foi revertida ou não tem saldo.');
    }
    if (balance != batch.quantity) {
      throw StateError(
        'Só é possível reverter a montagem inteira quando nenhuma bandeja deste lote foi vendida.',
      );
    }
    final trayLot = await _packagingLotWithItem(batch.trayLotId, 'TRAY');
    final labelLot = await _packagingLotWithItem(batch.labelLotId, 'LABEL');
    final now = DateTime.now();
    final eggs = batch.quantity * batch.eggsPerTray;
    await transaction(() async {
      await into(eggTrayStockMovements).insert(
        EggTrayStockMovementsCompanion.insert(
          id: _uuid.v4(),
          batchId: batch.id,
          type: 'ADJUSTMENT_OUT',
          occurredAt: now,
          quantity: batch.quantity,
          reference: Value('REVERSAL:$batchId'),
          notes: const Value('Reversão de montagem'),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(packagingStockMovements).insert(
        PackagingStockMovementsCompanion.insert(
          id: _uuid.v4(),
          itemId: trayLot.item.id,
          lotId: trayLot.lot.id,
          type: 'ADJUSTMENT_IN',
          occurredAt: now,
          quantity: batch.quantity,
          reference: Value('REVERSAL:$batchId'),
          notes: const Value('Reversão de montagem de bandeja'),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(packagingStockMovements).insert(
        PackagingStockMovementsCompanion.insert(
          id: _uuid.v4(),
          itemId: labelLot.item.id,
          lotId: labelLot.lot.id,
          type: 'ADJUSTMENT_IN',
          occurredAt: now,
          quantity: batch.quantity,
          reference: Value('REVERSAL:$batchId'),
          notes: const Value('Reversão de montagem de bandeja'),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(eggStockMovements).insert(
        EggStockMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'ADJUSTMENT_IN',
          occurredAt: now,
          quantity: eggs,
          reference: Value('REVERSAL:$batchId'),
          notes: const Value('Reversão de montagem de bandeja'),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'egg_trays.reverse',
        entityType: 'egg_tray_batch',
        entityId: batchId,
        description:
            'Montagem de ${batch.quantity} bandeja(s) revertida e itens devolvidos ao estoque.',
      );
    });
  }

  Future<void> createEggTraySale({
    String? customerId,
    required String trayBatchId,
    required int trayQuantity,
    int? trayUnitPriceCents,
    int? dozenPriceCents,
    required String paymentMethod,
    DateTime? date,
    String? notes,
    required String actorId,
  }) async {
    final hasTrayPrice = trayUnitPriceCents != null && trayUnitPriceCents > 0;
    final hasDozenPrice = dozenPriceCents != null && dozenPriceCents > 0;
    if (trayQuantity <= 0 || (!hasTrayPrice && !hasDozenPrice)) {
      throw ArgumentError('Revise quantidade e valor da venda.');
    }
    await _assertActorCanUseRecord(
      tableName: 'egg_tray_batches',
      recordId: trayBatchId,
      actorId: actorId,
    );
    final batch = await (select(
      eggTrayBatches,
    )..where((b) => b.id.equals(trayBatchId))).getSingle();
    final balance = await eggTrayBatchBalance(trayBatchId);
    if (trayQuantity > balance) {
      throw StateError('Estoque de bandejas montadas insuficiente.');
    }
    final id = _uuid.v4();
    final now = DateTime.now();
    final soldAt = date ?? now;
    final eggs = trayQuantity * batch.eggsPerTray;
    final dozens = eggs ~/ 12;
    final looseEggs = eggs % 12;
    final trayPriceInput = trayUnitPriceCents ?? 0;
    final dozenPriceInput = dozenPriceCents ?? 0;
    final trayUnitPrice = hasTrayPrice
        ? trayPriceInput
        : (batch.eggsPerTray * dozenPriceInput / 12).round();
    final dozenPrice = hasDozenPrice
        ? dozenPriceInput
        : (trayUnitPrice * 12 / batch.eggsPerTray).round();
    final total = trayQuantity * trayUnitPrice;
    await transaction(() async {
      await into(sales).insert(
        SalesCompanion.insert(
          id: id,
          soldAt: soldAt,
          customerId: Value(customerId),
          trayBatchId: Value(trayBatchId),
          trayQuantity: Value(trayQuantity),
          dozens: Value(dozens),
          looseEggs: Value(looseEggs),
          dozenPriceCents: dozenPrice,
          totalCents: total,
          paymentMethod: paymentMethod,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(eggTrayStockMovements).insert(
        EggTrayStockMovementsCompanion.insert(
          id: _uuid.v4(),
          batchId: trayBatchId,
          type: 'SALE_OUT',
          occurredAt: soldAt,
          quantity: trayQuantity,
          reference: Value(id),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(financeTransactions).insert(
        FinanceTransactionsCompanion.insert(
          id: _uuid.v4(),
          occurredAt: soldAt,
          type: 'INCOME',
          category: 'Venda de ovos',
          description: 'Venda de $trayQuantity bandeja(s)',
          amountCents: total,
          referenceType: const Value('SALE'),
          referenceId: Value(id),
          paymentMethod: Value(paymentMethod),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'sales.create',
        entityType: 'sale',
        entityId: id,
        description:
            'Venda de bandejas no valor de $total centavos registrada.',
      );
    });
  }

  Future<PackagingLotBalance> _packagingLotWithItem(
    String lotId,
    String expectedType,
  ) async {
    final row = await customSelect(
      '''
      SELECT l.id AS lot_id, l.item_id, l.batch_code, l.initial_quantity,
        l.unit_cost_cents, l.total_cost_cents, l.purchased_at, l.supplier,
        l.notes AS lot_notes, l.created_by AS lot_created_by,
        l.created_at AS lot_created_at,
        i.id AS item_id_value, i.type AS item_type, i.name AS item_name,
        i.notes AS item_notes, i.is_active, i.created_by AS item_created_by,
        i.created_at AS item_created_at
      FROM packaging_lots l
      JOIN packaging_items i ON i.id = l.item_id
      WHERE l.id = ? AND i.type = ?
      ''',
      variables: [
        Variable.withString(lotId),
        Variable.withString(expectedType),
      ],
      readsFrom: {packagingItems, packagingLots},
    ).getSingleOrNull();
    if (row == null) {
      throw ArgumentError(
        expectedType == 'TRAY'
            ? 'Escolha um lote de bandejas válido.'
            : 'Escolha um lote de etiquetas válido.',
      );
    }
    return PackagingLotBalance(
      lot: PackagingLot(
        id: row.read<String>('lot_id'),
        itemId: row.read<String>('item_id'),
        batchCode: row.readNullable<String>('batch_code'),
        initialQuantity: row.read<int>('initial_quantity'),
        unitCostCents: row.read<int>('unit_cost_cents'),
        totalCostCents: row.read<int>('total_cost_cents'),
        purchasedAt: row.read<DateTime>('purchased_at'),
        supplier: row.readNullable<String>('supplier'),
        notes: row.readNullable<String>('lot_notes'),
        createdBy: row.read<String>('lot_created_by'),
        createdAt: row.read<DateTime>('lot_created_at'),
      ),
      item: PackagingItem(
        id: row.read<String>('item_id_value'),
        type: row.read<String>('item_type'),
        name: row.read<String>('item_name'),
        notes: row.readNullable<String>('item_notes'),
        isActive: row.read<bool>('is_active'),
        createdBy: row.read<String>('item_created_by'),
        createdAt: row.read<DateTime>('item_created_at'),
      ),
      balance: 0,
    );
  }

  Stream<List<Customer>> watchCustomers({
    String search = '',
    String? tenantId,
  }) {
    final query = select(customers)
      ..orderBy([(c) => OrderingTerm.asc(c.name)])
      ..limit(100);
    if (tenantId != null) {
      query.where((c) => _tenantExpression(c.createdBy, tenantId));
    }
    if (search.trim().isNotEmpty) {
      query.where(
        (c) => c.name.lower().like('%${search.trim().toLowerCase()}%'),
      );
    }
    return query.watch();
  }

  Future<void> addCustomer({
    required String name,
    String? phone,
    String? address,
    String? notes,
    required String actorId,
  }) async {
    if (name.trim().isEmpty) throw ArgumentError('Informe o nome do cliente.');
    final id = _uuid.v4();
    await transaction(() async {
      await into(customers).insert(
        CustomersCompanion.insert(
          id: id,
          name: name.trim(),
          phone: Value(_cleanValue(phone)),
          address: Value(_cleanValue(address)),
          notes: Value(_cleanValue(notes)),
          createdAt: DateTime.now(),
          createdBy: actorId,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'customers.create',
        entityType: 'customer',
        entityId: id,
        description: 'Cliente ${name.trim()} cadastrado.',
      );
    });
  }

  Stream<List<Order>> watchOrders({
    String? status,
    int limit = 100,
    String? tenantId,
  }) {
    final query = select(orders)
      ..orderBy([(o) => OrderingTerm.desc(o.createdAt)])
      ..limit(limit);
    if (tenantId != null) {
      query.where((o) => _tenantExpression(o.createdBy, tenantId));
    }
    if (status != null) query.where((o) => o.status.equals(status));
    return query.watch();
  }

  Future<void> createOrder({
    String? customerId,
    required String productType,
    required double quantity,
    required int unitPriceCents,
    required DateTime requestedDate,
    DateTime? deliveryDate,
    String? notes,
    required String actorId,
  }) async {
    if (quantity <= 0 || unitPriceCents <= 0) {
      throw ArgumentError('Informe quantidade e preço válidos.');
    }
    if (!{'DOZEN', 'EGG', 'BIRD'}.contains(productType)) {
      throw ArgumentError('Produto inválido.');
    }
    if (customerId != null) {
      await _assertActorCanUseRecord(
        tableName: 'customers',
        recordId: customerId,
        actorId: actorId,
      );
    }
    final numberRow = await customSelect(
      'SELECT COALESCE(MAX(order_number),100)+1 number FROM orders',
      readsFrom: {orders},
    ).getSingle();
    final number = numberRow.read<int>('number');
    final total = (quantity * unitPriceCents).round();
    final id = _uuid.v4();
    final now = DateTime.now();
    await transaction(() async {
      await into(orders).insert(
        OrdersCompanion.insert(
          id: id,
          orderNumber: number,
          customerId: Value(customerId),
          requestedDate: requestedDate,
          expectedDeliveryDate: Value(deliveryDate),
          status: const Value('PENDING'),
          subtotalCents: total,
          totalCents: total,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          updatedBy: actorId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await into(orderItems).insert(
        OrderItemsCompanion.insert(
          id: _uuid.v4(),
          orderId: id,
          productType: productType,
          quantity: quantity,
          unitPriceCents: unitPriceCents,
          totalCents: total,
        ),
      );
      await into(orderStatusHistory).insert(
        OrderStatusHistoryCompanion.insert(
          id: _uuid.v4(),
          orderId: id,
          newStatus: 'PENDING',
          changedAt: now,
          changedBy: actorId,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'orders.create',
        entityType: 'order',
        entityId: id,
        description: 'Pedido #$number criado.',
      );
    });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? notes,
    required String actorId,
  }) async {
    const allowed = {
      'DRAFT',
      'PENDING',
      'CONFIRMED',
      'IN_PROCESS',
      'READY',
      'DELIVERED',
      'CANCELLED',
    };
    if (!allowed.contains(newStatus)) throw ArgumentError('Status inválido.');
    await _assertActorCanUseRecord(
      tableName: 'orders',
      recordId: orderId,
      actorId: actorId,
    );
    await transaction(() async {
      final order = await (select(
        orders,
      )..where((o) => o.id.equals(orderId))).getSingle();
      if (order.status == newStatus) return;
      if (order.status == 'DELIVERED' || order.status == 'CANCELLED') {
        throw StateError('Este pedido já foi finalizado.');
      }
      if (newStatus == 'DELIVERED') await _deliverOrder(order, actorId);
      await (update(orders)..where((o) => o.id.equals(orderId))).write(
        OrdersCompanion(
          status: Value(newStatus),
          updatedAt: Value(DateTime.now()),
          updatedBy: Value(actorId),
        ),
      );
      await into(orderStatusHistory).insert(
        OrderStatusHistoryCompanion.insert(
          id: _uuid.v4(),
          orderId: orderId,
          oldStatus: Value(order.status),
          newStatus: newStatus,
          changedAt: DateTime.now(),
          changedBy: actorId,
          notes: Value(_cleanValue(notes)),
        ),
      );
      await addAudit(
        userId: actorId,
        action: newStatus == 'CANCELLED' ? 'orders.cancel' : 'orders.update',
        entityType: 'order',
        entityId: orderId,
        description:
            'Pedido #${order.orderNumber}: ${order.status} → $newStatus.',
      );
    });
  }

  Future<void> _deliverOrder(Order order, String actorId) async {
    final existing = await (select(
      sales,
    )..where((s) => s.orderId.equals(order.id))).getSingleOrNull();
    if (existing != null) return;
    final items = await (select(
      orderItems,
    )..where((i) => i.orderId.equals(order.id))).get();
    final eggs = items.fold<int>(
      0,
      (sum, i) =>
          sum +
          (i.productType == 'DOZEN'
              ? (i.quantity * 12).round()
              : i.productType == 'EGG'
              ? i.quantity.round()
              : 0),
    );
    final actorTenantId = await _actorTenantId(actorId);
    if (eggs > await eggStockBalance(tenantId: actorTenantId)) {
      throw StateError('Estoque de ovos insuficiente para entregar o pedido.');
    }
    final saleId = _uuid.v4();
    final now = DateTime.now();
    final dozens = items
        .where((i) => i.productType == 'DOZEN')
        .fold<int>(0, (s, i) => s + i.quantity.round());
    final loose = items
        .where((i) => i.productType == 'EGG')
        .fold<int>(0, (s, i) => s + i.quantity.round());
    await into(sales).insert(
      SalesCompanion.insert(
        id: saleId,
        soldAt: now,
        customerId: Value(order.customerId),
        orderId: Value(order.id),
        dozens: Value(dozens),
        looseEggs: Value(loose),
        dozenPriceCents: dozens == 0
            ? order.totalCents
            : (order.totalCents / dozens).round(),
        totalCents: order.totalCents,
        paymentMethod: 'A DEFINIR',
        createdBy: actorId,
        createdAt: now,
      ),
    );
    if (eggs > 0) {
      await into(eggStockMovements).insert(
        EggStockMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'SALE_OUT',
          occurredAt: now,
          quantity: eggs,
          reference: Value(saleId),
          createdBy: actorId,
          createdAt: now,
        ),
      );
    }
    await into(financeTransactions).insert(
      FinanceTransactionsCompanion.insert(
        id: _uuid.v4(),
        occurredAt: now,
        type: 'INCOME',
        category: 'Venda de ovos',
        description: 'Pedido #${order.orderNumber}',
        amountCents: order.totalCents,
        referenceType: const Value('SALE'),
        referenceId: Value(saleId),
        createdBy: actorId,
        createdAt: now,
      ),
    );
  }

  Stream<List<Sale>> watchSales({int limit = 100, String? tenantId}) {
    final query = select(sales)
      ..orderBy([(s) => OrderingTerm.desc(s.soldAt)])
      ..limit(limit);
    if (tenantId != null) {
      query.where((s) => _tenantExpression(s.createdBy, tenantId));
    }
    return query.watch();
  }

  Future<void> createEggSale({
    String? customerId,
    required int dozens,
    required int looseEggs,
    required int dozenPriceCents,
    required String paymentMethod,
    DateTime? date,
    String? notes,
    required String actorId,
  }) async {
    if (dozens < 0 ||
        looseEggs < 0 ||
        dozens * 12 + looseEggs <= 0 ||
        dozenPriceCents <= 0) {
      throw ArgumentError('Revise quantidade e valor da venda.');
    }
    if (customerId != null) {
      await _assertActorCanUseRecord(
        tableName: 'customers',
        recordId: customerId,
        actorId: actorId,
      );
    }
    final eggs = dozens * 12 + looseEggs;
    final actorTenantId = await _actorTenantId(actorId);
    final balance = await eggStockBalance(tenantId: actorTenantId);
    if (eggs > balance) {
      throw StateError('Estoque insuficiente. Disponível: $balance ovos.');
    }
    final id = _uuid.v4();
    final now = DateTime.now();
    final total = (dozens * dozenPriceCents + looseEggs * dozenPriceCents / 12)
        .round();
    await transaction(() async {
      await into(sales).insert(
        SalesCompanion.insert(
          id: id,
          soldAt: date ?? now,
          customerId: Value(customerId),
          dozens: Value(dozens),
          looseEggs: Value(looseEggs),
          dozenPriceCents: dozenPriceCents,
          totalCents: total,
          paymentMethod: paymentMethod,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(eggStockMovements).insert(
        EggStockMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'SALE_OUT',
          occurredAt: date ?? now,
          quantity: eggs,
          reference: Value(id),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(financeTransactions).insert(
        FinanceTransactionsCompanion.insert(
          id: _uuid.v4(),
          occurredAt: date ?? now,
          type: 'INCOME',
          category: 'Venda de ovos',
          description: 'Venda de $dozens dúzias e $looseEggs ovos',
          amountCents: total,
          referenceType: const Value('SALE'),
          referenceId: Value(id),
          paymentMethod: Value(paymentMethod),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'sales.create',
        entityType: 'sale',
        entityId: id,
        description: 'Venda de ovos no valor de $total centavos registrada.',
      );
    });
  }

  Future<void> cancelSale(String saleId, {required String actorId}) async {
    await _assertActorCanUseRecord(
      tableName: 'sales',
      recordId: saleId,
      actorId: actorId,
    );
    await transaction(() async {
      final sale = await (select(
        sales,
      )..where((s) => s.id.equals(saleId))).getSingle();
      if (sale.status == 'CANCELLED') return;
      if (sale.status != 'CONFIRMED') {
        throw StateError('A venda não pode ser cancelada neste estado.');
      }
      await (update(sales)..where((s) => s.id.equals(saleId))).write(
        const SalesCompanion(status: Value('CANCELLED')),
      );
      if (sale.trayBatchId != null && sale.trayQuantity > 0) {
        await into(eggTrayStockMovements).insert(
          EggTrayStockMovementsCompanion.insert(
            id: _uuid.v4(),
            batchId: sale.trayBatchId!,
            type: 'ADJUSTMENT_IN',
            occurredAt: DateTime.now(),
            quantity: sale.trayQuantity,
            reference: Value('REVERSAL:$saleId'),
            notes: const Value('Estorno de venda cancelada'),
            createdBy: actorId,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        final eggs = sale.dozens * 12 + sale.looseEggs;
        if (eggs > 0) {
          await into(eggStockMovements).insert(
            EggStockMovementsCompanion.insert(
              id: _uuid.v4(),
              type: 'ADJUSTMENT_IN',
              occurredAt: DateTime.now(),
              quantity: eggs,
              reference: Value('REVERSAL:$saleId'),
              notes: const Value('Estorno de venda cancelada'),
              createdBy: actorId,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
      await (update(financeTransactions)..where(
            (f) =>
                f.referenceType.equals('SALE') & f.referenceId.equals(saleId),
          ))
          .write(
            const FinanceTransactionsCompanion(status: Value('CANCELLED')),
          );
      await addAudit(
        userId: actorId,
        action: 'sales.cancel',
        entityType: 'sale',
        entityId: saleId,
        description: 'Venda cancelada e estoque estornado.',
      );
    });
  }

  Future<int> eggStockBalance({String? tenantId}) async {
    final row = await customSelect(
      '''SELECT COALESCE(SUM(CASE WHEN type IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END),0) balance
         FROM egg_stock_movements
         WHERE ${_tenantSql('egg_stock_movements', tenantId)}''',
      variables: _tenantVariables(tenantId),
      readsFrom: {eggStockMovements},
    ).getSingle();
    return row.read<int>('balance');
  }

  Stream<EggStockMetrics> watchEggStockMetrics({String? tenantId}) =>
      customSelect(
        '''SELECT
    COALESCE(SUM(CASE WHEN type IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END),0) balance,
    COALESCE(SUM(CASE WHEN type IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE 0 END),0) entries,
    COALESCE(SUM(CASE WHEN type NOT IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE 0 END),0) outputs,
    COALESCE(SUM(CASE WHEN type='LOSS_OUT' THEN quantity ELSE 0 END),0) losses
    FROM egg_stock_movements
    WHERE ${_tenantSql('egg_stock_movements', tenantId)}''',
        variables: _tenantVariables(tenantId),
        readsFrom: {eggStockMovements},
      ).watchSingle().map(
        (r) => EggStockMetrics(
          balance: r.read<int>('balance'),
          entries: r.read<int>('entries'),
          outputs: r.read<int>('outputs'),
          losses: r.read<int>('losses'),
        ),
      );

  Future<void> adjustEggStock({
    required int quantity,
    required String type,
    String? notes,
    required String actorId,
  }) async {
    if (quantity <= 0 ||
        !{'LOSS_OUT', 'ADJUSTMENT_IN', 'ADJUSTMENT_OUT'}.contains(type)) {
      throw ArgumentError('Ajuste inválido.');
    }
    if (type != 'ADJUSTMENT_IN') {
      final actorTenantId = await _actorTenantId(actorId);
      final balance = await eggStockBalance(tenantId: actorTenantId);
      if (quantity > balance) {
        throw StateError('O ajuste deixaria o estoque negativo.');
      }
    }
    final id = _uuid.v4();
    await transaction(() async {
      await into(eggStockMovements).insert(
        EggStockMovementsCompanion.insert(
          id: id,
          type: type,
          occurredAt: DateTime.now(),
          quantity: quantity,
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: DateTime.now(),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'egg_stock.adjust',
        entityType: 'egg_stock_movement',
        entityId: id,
        description: 'Ajuste de $quantity ovos registrado.',
      );
    });
  }

  Stream<List<FinanceTransaction>> watchFinance({
    int limit = 200,
    String? tenantId,
  }) {
    final query = select(financeTransactions)
      ..orderBy([(f) => OrderingTerm.desc(f.occurredAt)])
      ..limit(limit);
    if (tenantId != null) {
      query.where((f) => _tenantExpression(f.createdBy, tenantId));
    }
    return query.watch();
  }

  Stream<FinanceMetrics> watchFinanceMetrics({String? tenantId}) =>
      customSelect(
        '''SELECT
    COALESCE(SUM(CASE WHEN type='INCOME' AND status='CONFIRMED' THEN amount_cents ELSE 0 END),0) income,
    COALESCE(SUM(CASE WHEN type='EXPENSE' AND status='CONFIRMED' THEN amount_cents ELSE 0 END),0) expense,
    COALESCE((SELECT SUM(amount_cents) FROM investments WHERE ${_tenantSql('investments', tenantId)}),0) investment
    FROM finance_transactions
    WHERE ${_tenantSql('finance_transactions', tenantId)}''',
        variables: [
          ..._tenantVariables(tenantId),
          ..._tenantVariables(tenantId),
        ],
        readsFrom: {financeTransactions, investments},
      ).watchSingle().map(
        (r) => FinanceMetrics(
          incomeCents: r.read<int>('income'),
          expenseCents: r.read<int>('expense'),
          investmentCents: r.read<int>('investment'),
        ),
      );

  Future<void> addFinance({
    required String type,
    required String category,
    required String description,
    required int amountCents,
    DateTime? date,
    String? paymentMethod,
    String? notes,
    required String actorId,
  }) async {
    if (!{'INCOME', 'EXPENSE'}.contains(type) ||
        category.trim().isEmpty ||
        description.trim().isEmpty ||
        amountCents <= 0) {
      throw ArgumentError('Revise os dados do lançamento.');
    }
    final id = _uuid.v4();
    await transaction(() async {
      await into(financeTransactions).insert(
        FinanceTransactionsCompanion.insert(
          id: id,
          occurredAt: date ?? DateTime.now(),
          type: type,
          category: category,
          description: description.trim(),
          amountCents: amountCents,
          paymentMethod: Value(_cleanValue(paymentMethod)),
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: DateTime.now(),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'finance.create',
        entityType: 'finance_transaction',
        entityId: id,
        description: 'Lançamento financeiro registrado.',
      );
    });
  }

  Future<void> cancelFinance(String id, {required String actorId}) async {
    await _assertActorCanUseRecord(
      tableName: 'finance_transactions',
      recordId: id,
      actorId: actorId,
    );
    await transaction(() async {
      final item = await (select(
        financeTransactions,
      )..where((f) => f.id.equals(id))).getSingle();
      if (item.referenceType != null) {
        throw StateError(
          'Lançamentos automáticos devem ser cancelados no módulo de origem.',
        );
      }
      if (item.status == 'CANCELLED') return;
      await (update(financeTransactions)..where((f) => f.id.equals(id))).write(
        const FinanceTransactionsCompanion(status: Value('CANCELLED')),
      );
      await addAudit(
        userId: actorId,
        action: 'finance.cancel',
        entityType: 'finance_transaction',
        entityId: id,
        description: 'Lançamento financeiro cancelado.',
      );
    });
  }

  Stream<List<Investment>> watchInvestments({String? tenantId}) {
    final query = select(investments)
      ..orderBy([(i) => OrderingTerm.desc(i.investmentDate)]);
    if (tenantId != null) {
      query.where((i) => _tenantExpression(i.createdBy, tenantId));
    }
    return query.watch();
  }

  Future<void> addInvestment({
    required String description,
    required String category,
    required int amountCents,
    DateTime? date,
    String? lotId,
    required String actorId,
  }) async {
    if (description.trim().isEmpty ||
        category.trim().isEmpty ||
        amountCents <= 0) {
      throw ArgumentError('Revise os dados do investimento.');
    }
    if (lotId != null) {
      await _assertActorCanUseRecord(
        tableName: 'lots',
        recordId: lotId,
        actorId: actorId,
      );
    }
    final id = _uuid.v4();
    final now = DateTime.now();
    await transaction(() async {
      await into(investments).insert(
        InvestmentsCompanion.insert(
          id: id,
          description: description.trim(),
          category: category,
          investmentDate: date ?? now,
          amountCents: amountCents,
          lotId: Value(lotId),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(financeTransactions).insert(
        FinanceTransactionsCompanion.insert(
          id: _uuid.v4(),
          occurredAt: date ?? now,
          type: 'EXPENSE',
          category: 'Investimentos',
          description: description.trim(),
          amountCents: amountCents,
          referenceType: const Value('INVESTMENT'),
          referenceId: Value(id),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'investments.create',
        entityType: 'investment',
        entityId: id,
        description: 'Investimento registrado.',
      );
    });
  }

  Stream<List<LightingProgram>> watchLightingPrograms() =>
      (select(lightingPrograms)
            ..where((p) => p.isActive.equals(true))
            ..orderBy([
              (p) => OrderingTerm.desc(p.isDefault),
              (p) => OrderingTerm.asc(p.name),
            ]))
          .watch();
  Stream<List<LightingProgramStep>> watchLightingSteps(String programId) =>
      (select(lightingProgramSteps)
            ..where((s) => s.programId.equals(programId))
            ..orderBy([(s) => OrderingTerm.asc(s.startAgeDays)]))
          .watch();
  Stream<List<CalendarEvent>> watchCalendarEvents(
    DateTime first,
    DateTime last, {
    String? tenantId,
  }) {
    final query = select(calendarEvents)
      ..where(
        (e) =>
            e.startsAt.isBiggerOrEqualValue(first) &
            e.startsAt.isSmallerThanValue(last),
      )
      ..orderBy([(e) => OrderingTerm.asc(e.startsAt)]);
    if (tenantId != null) {
      query.where((e) => _tenantExpression(e.createdBy, tenantId));
    }
    return query.watch();
  }

  Stream<List<CalendarEvent>> watchCalendarAlertEvents(
    DateTime first,
    DateTime last, {
    String? tenantId,
  }) {
    final query = select(calendarEvents)
      ..where(
        (e) =>
            e.startsAt.isSmallerOrEqualValue(last) &
            (e.startsAt.isBiggerOrEqualValue(first) |
                e.repeatUntil.isBiggerOrEqualValue(first)),
      )
      ..orderBy([(e) => OrderingTerm.asc(e.startsAt)]);
    if (tenantId != null) {
      query.where((e) => _tenantExpression(e.createdBy, tenantId));
    }
    return query.watch();
  }

  Future<List<CalendarEvent>> futureAlertCalendarEvents(
    DateTime first,
    DateTime last, {
    String? tenantId,
  }) {
    final query = select(calendarEvents)
      ..where(
        (e) =>
            e.alertEnabled.equals(true) &
            e.startsAt.isSmallerOrEqualValue(last) &
            (e.repeatUntil.isNull() |
                e.repeatUntil.isBiggerOrEqualValue(first)),
      )
      ..orderBy([(e) => OrderingTerm.asc(e.startsAt)]);
    if (tenantId != null) {
      query.where((e) => _tenantExpression(e.createdBy, tenantId));
    }
    return query.get();
  }

  Future<List<LotSummary>> currentLotSummaries({String? tenantId}) async {
    final rows = await customSelect(
      '''
        SELECT l.*, COALESCE(SUM(
          CASE WHEN m.type IN ('PURCHASE', 'TRANSFER_IN', 'ADJUSTMENT_IN')
          THEN m.quantity ELSE -m.quantity END
        ), 0) AS active_birds
        FROM lots l
        LEFT JOIN bird_movements m ON m.lot_id = l.id
        WHERE ${_tenantSql('l', tenantId)}
        GROUP BY l.id
        ORDER BY CASE l.status WHEN 'ACTIVE' THEN 0 ELSE 1 END, l.received_at DESC
      ''',
      variables: _tenantVariables(tenantId),
      readsFrom: {lots, birdMovements},
    ).get();
    return rows
        .map(
          (row) => LotSummary(
            lot: Lot(
              id: row.read<String>('id'),
              name: row.read<String>('name'),
              strain: row.readNullable<String>('strain'),
              initialQuantity: row.read<int>('initial_quantity'),
              receivedAt: row.read<DateTime>('received_at'),
              arrivalAgeDays: row.read<int>('arrival_age_days'),
              unitValueCents: row.readNullable<int>('unit_value_cents'),
              supplier: row.readNullable<String>('supplier'),
              notes: row.readNullable<String>('notes'),
              status: row.read<String>('status'),
              createdAt: row.read<DateTime>('created_at'),
              createdBy: row.read<String>('created_by'),
            ),
            activeBirds: row.read<int>('active_birds'),
          ),
        )
        .toList();
  }

  Future<String> addCalendarEvent({
    required String title,
    required String type,
    required DateTime startsAt,
    DateTime? endsAt,
    String? lotId,
    String? notes,
    bool alertEnabled = true,
    String? alertMessage,
    String alertTime = '08:00',
    String recurrence = 'ONCE',
    DateTime? repeatUntil,
    String? weekdays,
    required String actorId,
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Informe o título do evento.');
    }
    if (lotId != null) {
      await _assertActorCanUseRecord(
        tableName: 'lots',
        recordId: lotId,
        actorId: actorId,
      );
    }
    _validateAlertRecurrence(
      alertTime: alertTime,
      recurrence: recurrence,
      weekdays: weekdays,
      repeatUntil: repeatUntil,
    );
    final id = _uuid.v4();
    await transaction(() async {
      await into(calendarEvents).insert(
        CalendarEventsCompanion.insert(
          id: id,
          title: title.trim(),
          type: type,
          startsAt: startsAt,
          endsAt: Value(endsAt),
          lotId: Value(lotId),
          notes: Value(_cleanValue(notes)),
          alertEnabled: Value(alertEnabled),
          alertMessage: Value(_cleanValue(alertMessage)),
          alertTime: Value(alertTime),
          recurrence: Value(recurrence),
          repeatUntil: Value(repeatUntil),
          weekdays: Value(_cleanValue(weekdays)),
          createdBy: actorId,
          createdAt: DateTime.now(),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'calendar.create',
        entityType: 'calendar_event',
        entityId: id,
        description: 'Evento ${title.trim()} criado.',
      );
    });
    return id;
  }

  Future<void> updateCalendarEventAlert({
    required CalendarEvent event,
    required String title,
    required DateTime startsAt,
    required bool alertEnabled,
    String? alertMessage,
    required String alertTime,
    required String recurrence,
    DateTime? repeatUntil,
    String? weekdays,
    required String actorId,
  }) async {
    if (event.createdBy == 'system') {
      throw ArgumentError(
        'Alertas automáticos do sistema não podem ser editados.',
      );
    }
    if (title.trim().isEmpty) {
      throw ArgumentError('Informe o título do alerta.');
    }
    await _assertActorCanUseRecord(
      tableName: 'calendar_events',
      recordId: event.id,
      actorId: actorId,
    );
    _validateAlertRecurrence(
      alertTime: alertTime,
      recurrence: recurrence,
      weekdays: weekdays,
      repeatUntil: repeatUntil,
    );
    await transaction(() async {
      await (update(calendarEvents)..where((e) => e.id.equals(event.id))).write(
        CalendarEventsCompanion(
          title: Value(title.trim()),
          startsAt: Value(startsAt),
          alertEnabled: Value(alertEnabled),
          alertMessage: Value(_cleanValue(alertMessage)),
          alertTime: Value(alertTime),
          recurrence: Value(recurrence),
          repeatUntil: Value(repeatUntil),
          weekdays: Value(_cleanValue(weekdays)),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'calendar.update_alert',
        entityType: 'calendar_event',
        entityId: event.id,
        description: alertEnabled
            ? 'Alerta ${title.trim()} atualizado.'
            : 'Alerta ${title.trim()} desativado.',
      );
    });
  }

  Future<void> assignLightingProgram({
    required String lotId,
    required String programId,
    required String actorId,
  }) async {
    await _assertActorCanUseRecord(
      tableName: 'lots',
      recordId: lotId,
      actorId: actorId,
    );
    await into(lotLightingPrograms).insertOnConflictUpdate(
      LotLightingProgramsCompanion.insert(
        id: _uuid.v4(),
        lotId: lotId,
        programId: programId,
        assignedAt: DateTime.now(),
        createdBy: actorId,
      ),
    );
    await addAudit(
      userId: actorId,
      action: 'lighting.manage',
      entityType: 'lot_lighting_program',
      entityId: lotId,
      description: 'Programa de luz atribuído ao lote.',
    );
  }

  Stream<List<NotificationSetting>> watchNotificationSettings() =>
      select(notificationSettings).watch();
  Future<NotificationSetting?> notificationSettingFor(String type) => (select(
    notificationSettings,
  )..where((s) => s.type.equals(type))).getSingleOrNull();

  Stream<List<AppSetting>> watchAppSettings() => select(appSettings).watch();

  Future<void> saveAppSetting(String key, String value, String actorId) async {
    await _assertGlobalWriteAllowed(actorId);
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
        updatedBy: Value(actorId),
      ),
    );
    await addAudit(
      userId: actorId,
      action: 'settings.update',
      entityType: 'app_setting',
      entityId: key,
      description: 'Configuração $key atualizada.',
    );
  }

  Future<void> updateNotificationSetting(
    NotificationSetting setting, {
    required bool enabled,
    required int daysBefore,
    required String time,
    String? message,
    String recurrence = 'ONCE',
    required String actorId,
  }) async {
    await _assertGlobalWriteAllowed(actorId);
    if (daysBefore < 0 ||
        !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time)) {
      throw ArgumentError('Use dias não negativos e horário no formato HH:mm.');
    }
    _validateAlertRecurrence(
      alertTime: time,
      recurrence: recurrence,
      weekdays: null,
      repeatUntil: null,
    );
    await (update(
      notificationSettings,
    )..where((s) => s.id.equals(setting.id))).write(
      NotificationSettingsCompanion(
        isEnabled: Value(enabled),
        daysBefore: Value(daysBefore),
        notificationTime: Value(time),
        defaultMessage: Value(_cleanValue(message)),
        defaultRecurrence: Value(recurrence),
      ),
    );
    await addAudit(
      userId: actorId,
      action: 'settings.update',
      entityType: 'notification_setting',
      entityId: setting.id,
      description: 'Alerta ${setting.type} atualizado.',
    );
  }

  Stream<List<AuditLog>> watchAuditLogs({int limit = 200, String? tenantId}) {
    final query = select(auditLogs)
      ..orderBy([(a) => OrderingTerm.desc(a.timestamp)])
      ..limit(limit);
    if (tenantId != null) {
      final tenantUsers = selectOnly(users)
        ..addColumns([users.id])
        ..where(users.tenantId.equals(tenantId));
      query.where((a) => a.userId.isNull() | a.userId.isInQuery(tenantUsers));
    }
    return query.watch();
  }

  Stream<List<BirdMovement>> watchBirdMovements({
    int limit = 200,
    String? tenantId,
  }) {
    final query = select(birdMovements)
      ..orderBy([(m) => OrderingTerm.desc(m.occurredAt)])
      ..limit(limit);
    if (tenantId != null) {
      query.where((m) => _tenantExpression(m.createdBy, tenantId));
    }
    return query.watch();
  }

  Stream<List<BirdMovementOverview>> watchBirdMovementOverviews({
    int limit = 200,
    String? tenantId,
  }) {
    final query = customSelect(
      '''
      SELECT m.*, l.name lot_name, rl.name related_lot_name,
        EXISTS(
          SELECT 1 FROM bird_movements undo
          WHERE undo.reference = 'undo:' || m.reference
        ) transfer_undone
      FROM bird_movements m
      LEFT JOIN lots l ON l.id = m.lot_id
      LEFT JOIN lots rl ON rl.id = m.related_lot_id
      WHERE ${_tenantSql('m', tenantId)}
      ORDER BY m.occurred_at DESC, m.created_at DESC
      LIMIT ?
    ''',
      variables: [..._tenantVariables(tenantId), Variable.withInt(limit)],
      readsFrom: {birdMovements, lots},
    );
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => BirdMovementOverview(
              movement: BirdMovement(
                id: row.read<String>('id'),
                type: row.read<String>('type'),
                occurredAt: row.read<DateTime>('occurred_at'),
                lotId: row.read<String>('lot_id'),
                relatedLotId: row.readNullable<String>('related_lot_id'),
                quantity: row.read<int>('quantity'),
                unitValueCents: row.readNullable<int>('unit_value_cents'),
                totalValueCents: row.readNullable<int>('total_value_cents'),
                reference: row.readNullable<String>('reference'),
                notes: row.readNullable<String>('notes'),
                createdBy: row.read<String>('created_by'),
                createdAt: row.read<DateTime>('created_at'),
              ),
              lotName: row.readNullable<String>('lot_name') ?? 'Lote removido',
              relatedLotName: row.readNullable<String>('related_lot_name'),
              transferUndone: row.read<int>('transfer_undone') == 1,
            ),
          )
          .toList(),
    );
  }

  Future<void> transferBirds({
    required String fromLotId,
    required String toLotId,
    required int quantity,
    required DateTime date,
    String? notes,
    bool deactivateFromLot = false,
    required String actorId,
  }) async {
    if (fromLotId == toLotId || quantity <= 0) {
      throw ArgumentError(
        'Selecione lotes diferentes e uma quantidade válida.',
      );
    }
    await _assertActorCanUseRecord(
      tableName: 'lots',
      recordId: fromLotId,
      actorId: actorId,
    );
    await _assertActorCanUseRecord(
      tableName: 'lots',
      recordId: toLotId,
      actorId: actorId,
    );
    final activeFrom = await activeBirdsFor(fromLotId);
    if (quantity > activeFrom) {
      throw StateError('Saldo insuficiente no lote de origem.');
    }
    if (deactivateFromLot && quantity != activeFrom) {
      throw StateError('Para unificar, transfira todo o saldo do lote.');
    }
    final reference = _uuid.v4();
    final now = DateTime.now();
    await transaction(() async {
      await into(birdMovements).insert(
        BirdMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'TRANSFER_OUT',
          occurredAt: date,
          lotId: fromLotId,
          relatedLotId: Value(toLotId),
          quantity: quantity,
          reference: Value(reference),
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(birdMovements).insert(
        BirdMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'TRANSFER_IN',
          occurredAt: date,
          lotId: toLotId,
          relatedLotId: Value(fromLotId),
          quantity: quantity,
          reference: Value(reference),
          notes: Value(_cleanValue(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      if (deactivateFromLot) {
        await (update(lots)..where((l) => l.id.equals(fromLotId))).write(
          const LotsCompanion(status: Value('INACTIVE')),
        );
      }
      await addAudit(
        userId: actorId,
        action: 'birds.transfer',
        entityType: 'bird_transfer',
        entityId: reference,
        description: deactivateFromLot
            ? 'Unificação de $quantity aves entre lotes.'
            : 'Transferência de $quantity aves entre lotes.',
      );
    });
  }

  Future<void> undoBirdTransfer({
    required String reference,
    String? notes,
    required String actorId,
  }) async {
    if (reference.trim().isEmpty || reference.startsWith('undo:')) {
      throw ArgumentError('Transferência inválida para desfazer.');
    }
    final undoReference = 'undo:$reference';
    final existingUndo = await (select(
      birdMovements,
    )..where((m) => m.reference.equals(undoReference))).get();
    if (existingUndo.isNotEmpty) {
      throw StateError('Esta transferência já foi desfeita.');
    }
    final movements = await (select(
      birdMovements,
    )..where((m) => m.reference.equals(reference))).get();
    final out = movements
        .where((movement) => movement.type == 'TRANSFER_OUT')
        .firstOrNull;
    final input = movements
        .where((movement) => movement.type == 'TRANSFER_IN')
        .firstOrNull;
    if (out == null || input == null || out.quantity != input.quantity) {
      throw StateError('Histórico da transferência está incompleto.');
    }
    final destinationBalance = await activeBirdsFor(input.lotId);
    if (out.quantity > destinationBalance) {
      throw StateError(
        'Não há saldo suficiente no lote de destino para desfazer.',
      );
    }
    final now = DateTime.now();
    final cleanNotes = _cleanValue(notes);
    await transaction(() async {
      await into(birdMovements).insert(
        BirdMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'TRANSFER_OUT',
          occurredAt: now,
          lotId: input.lotId,
          relatedLotId: Value(out.lotId),
          quantity: out.quantity,
          reference: Value(undoReference),
          notes: Value(cleanNotes ?? 'Desfaz transferência $reference'),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await into(birdMovements).insert(
        BirdMovementsCompanion.insert(
          id: _uuid.v4(),
          type: 'TRANSFER_IN',
          occurredAt: now,
          lotId: out.lotId,
          relatedLotId: Value(input.lotId),
          quantity: out.quantity,
          reference: Value(undoReference),
          notes: Value(cleanNotes ?? 'Desfaz transferência $reference'),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      await (update(lots)..where((l) => l.id.equals(out.lotId))).write(
        const LotsCompanion(status: Value('ACTIVE')),
      );
      await addAudit(
        userId: actorId,
        action: 'birds.transfer.undo',
        entityType: 'bird_transfer',
        entityId: reference,
        description: 'Transferência de ${out.quantity} aves desfeita.',
      );
    });
  }

  Stream<DashboardMetrics> watchDashboardMetrics({String? tenantId}) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final query = customSelect(
      '''SELECT
      COALESCE((SELECT SUM(CASE WHEN type IN ('PURCHASE','TRANSFER_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END) FROM bird_movements WHERE ${_tenantSql('bird_movements', tenantId)}),0) birds,
      COALESCE((SELECT COUNT(*) FROM lots WHERE status='ACTIVE' AND ${_tenantSql('lots', tenantId)}),0) lots,
      COALESCE((SELECT SUM(CASE WHEN type IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END) FROM egg_stock_movements WHERE ${_tenantSql('egg_stock_movements', tenantId)}),0) eggs,
      COALESCE((SELECT SUM(CASE WHEN type IN ('PRODUCTION_IN','ADJUSTMENT_IN') THEN quantity_kg ELSE -quantity_kg END) FROM feed_stock_movements WHERE ${_tenantSql('feed_stock_movements', tenantId)}),0) feed,
      COALESCE((SELECT COUNT(*) FROM orders WHERE status NOT IN ('DELIVERED','CANCELLED') AND ${_tenantSql('orders', tenantId)}),0) pending,
      COALESCE((SELECT SUM(amount_cents) FROM finance_transactions WHERE type='INCOME' AND status='CONFIRMED' AND occurred_at>=? AND ${_tenantSql('finance_transactions', tenantId)}),0) income,
      COALESCE((SELECT SUM(amount_cents) FROM finance_transactions WHERE type='EXPENSE' AND status='CONFIRMED' AND occurred_at>=? AND ${_tenantSql('finance_transactions', tenantId)}),0) expense,
      COALESCE((SELECT SUM(quantity_kg) FROM daily_feedings WHERE feeding_date>=? AND ${_tenantSql('daily_feedings', tenantId)}),0) month_feed
    ''',
      variables: [
        ..._tenantVariables(tenantId),
        ..._tenantVariables(tenantId),
        ..._tenantVariables(tenantId),
        ..._tenantVariables(tenantId),
        ..._tenantVariables(tenantId),
        Variable.withDateTime(month),
        ..._tenantVariables(tenantId),
        Variable.withDateTime(month),
        ..._tenantVariables(tenantId),
        Variable.withDateTime(month),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {
        birdMovements,
        lots,
        eggStockMovements,
        feedStockMovements,
        orders,
        financeTransactions,
        dailyFeedings,
      },
    );
    return query.watchSingle().map(
      (r) => DashboardMetrics(
        activeBirds: r.read<int>('birds'),
        activeLots: r.read<int>('lots'),
        eggStock: r.read<int>('eggs'),
        feedStockKg: r.read<double>('feed'),
        pendingOrders: r.read<int>('pending'),
        monthIncomeCents: r.read<int>('income'),
        monthExpenseCents: r.read<int>('expense'),
        monthFeedKg: r.read<double>('month_feed'),
      ),
    );
  }

  Future<String> exportJson({String? tenantId}) async {
    final lotsQuery = select(lots);
    final birdMovementsQuery = select(birdMovements);
    final eggCollectionsQuery = select(eggCollections);
    final eggStockMovementsQuery = select(eggStockMovements);
    final ingredientsQuery = select(ingredients);
    final pricesQuery = select(ingredientPriceHistory);
    final ingredientLotsQuery = select(ingredientLots);
    final ingredientStockMovementsQuery = select(ingredientStockMovements);
    final formulasQuery = select(feedFormulas);
    final feedBatchesQuery = select(feedBatches);
    final feedStockQuery = select(feedStockMovements);
    final feedingsQuery = select(dailyFeedings);
    final customersQuery = select(customers);
    final ordersQuery = select(orders);
    final packagingItemsQuery = select(packagingItems);
    final packagingLotsQuery = select(packagingLots);
    final packagingStockMovementsQuery = select(packagingStockMovements);
    final eggTrayBatchesQuery = select(eggTrayBatches);
    final eggTrayStockMovementsQuery = select(eggTrayStockMovements);
    final salesQuery = select(sales);
    final financeQuery = select(financeTransactions);
    final investmentsQuery = select(investments);
    final lightingProgramsQuery = select(lightingPrograms);
    final lotLightingQuery = select(lotLightingPrograms);
    final calendarEventsQuery = select(calendarEvents);
    if (tenantId != null) {
      lotsQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      birdMovementsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      eggCollectionsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      eggStockMovementsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      ingredientsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      pricesQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      ingredientLotsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      ingredientStockMovementsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      formulasQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      feedBatchesQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      feedStockQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      feedingsQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      customersQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      ordersQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      packagingItemsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      packagingLotsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      packagingStockMovementsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      eggTrayBatchesQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      eggTrayStockMovementsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      salesQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      financeQuery.where((row) => _tenantExpression(row.createdBy, tenantId));
      investmentsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      lightingProgramsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      lotLightingQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
      calendarEventsQuery.where(
        (row) => _tenantExpression(row.createdBy, tenantId),
      );
    }
    final lotRows = await lotsQuery.get();
    final ingredientRows = await ingredientsQuery.get();
    final ingredientLotRows = await ingredientLotsQuery.get();
    final formulaRows = await formulasQuery.get();
    final feedBatchRows = await feedBatchesQuery.get();
    final customerRows = await customersQuery.get();
    final orderRows = await ordersQuery.get();
    final packagingItemRows = await packagingItemsQuery.get();
    final packagingLotRows = await packagingLotsQuery.get();
    final eggTrayBatchRows = await eggTrayBatchesQuery.get();
    final lightingProgramRows = await lightingProgramsQuery.get();
    final lotIds = lotRows.map((row) => row.id).toSet();
    final ingredientIds = ingredientRows.map((row) => row.id).toSet();
    final ingredientLotIds = ingredientLotRows.map((row) => row.id).toSet();
    final formulaIds = formulaRows.map((row) => row.id).toSet();
    final feedBatchIds = feedBatchRows.map((row) => row.id).toSet();
    final orderIds = orderRows.map((row) => row.id).toSet();
    final packagingItemIds = packagingItemRows.map((row) => row.id).toSet();
    final packagingLotIds = packagingLotRows.map((row) => row.id).toSet();
    final eggTrayBatchIds = eggTrayBatchRows.map((row) => row.id).toSet();
    final lightingProgramIds = lightingProgramRows.map((row) => row.id).toSet();
    final formulaItemRows = formulaIds.isEmpty
        ? const <FeedFormulaItem>[]
        : await (select(
            feedFormulaItems,
          )..where((row) => row.formulaId.isIn(formulaIds))).get();
    final feedBatchItemRows = feedBatchIds.isEmpty
        ? const <FeedBatchItem>[]
        : await (select(
            feedBatchItems,
          )..where((row) => row.batchId.isIn(feedBatchIds))).get();
    final orderItemRows = orderIds.isEmpty
        ? const <OrderItem>[]
        : await (select(
            orderItems,
          )..where((row) => row.orderId.isIn(orderIds))).get();
    final orderStatusRows = orderIds.isEmpty
        ? const <OrderStatusHistoryData>[]
        : await (select(
            orderStatusHistory,
          )..where((row) => row.orderId.isIn(orderIds))).get();
    final lightingStepRows = lightingProgramIds.isEmpty
        ? const <LightingProgramStep>[]
        : await (select(
            lightingProgramSteps,
          )..where((row) => row.programId.isIn(lightingProgramIds))).get();
    final lotLightingRows = (tenantId == null || lotIds.isEmpty)
        ? await lotLightingQuery.get()
        : await (lotLightingQuery
                ..where((row) => row.lotId.isIn(lotIds))
                ..where((row) => row.programId.isIn(lightingProgramIds)))
              .get();
    final prices = ingredientIds.isEmpty
        ? const <IngredientPriceHistoryData>[]
        : await (pricesQuery
                ..where((row) => row.ingredientId.isIn(ingredientIds)))
              .get();
    final ingredientStockRows = ingredientLotIds.isEmpty
        ? const <IngredientStockMovement>[]
        : await (ingredientStockMovementsQuery
                ..where((row) => row.ingredientLotId.isIn(ingredientLotIds)))
              .get();
    final feedStockRows = feedBatchIds.isEmpty
        ? const <FeedStockMovement>[]
        : await (feedStockQuery..where((row) => row.batchId.isIn(feedBatchIds)))
              .get();
    final packagingStockRows = packagingLotIds.isEmpty
        ? const <PackagingStockMovement>[]
        : await (packagingStockMovementsQuery
                ..where((row) => row.lotId.isIn(packagingLotIds))
                ..where((row) => row.itemId.isIn(packagingItemIds)))
              .get();
    final eggTrayStockRows = eggTrayBatchIds.isEmpty
        ? const <EggTrayStockMovement>[]
        : await (eggTrayStockMovementsQuery
                ..where((row) => row.batchId.isIn(eggTrayBatchIds)))
              .get();
    final birdMovementRows = lotIds.isEmpty
        ? const <BirdMovement>[]
        : await (birdMovementsQuery..where((row) => row.lotId.isIn(lotIds)))
              .get();
    final eggCollectionRows = lotIds.isEmpty
        ? const <EggCollection>[]
        : await (eggCollectionsQuery..where((row) => row.lotId.isIn(lotIds)))
              .get();
    final payload = <String, dynamic>{
      'format': 'SELETO_BACKUP_V1',
      'exportedAt': DateTime.now().toIso8601String(),
      'lots': lotRows.map((e) => e.toJson()).toList(),
      'birdMovements': birdMovementRows.map((e) => e.toJson()).toList(),
      'eggCollections': eggCollectionRows.map((e) => e.toJson()).toList(),
      'eggStockMovements': (await eggStockMovementsQuery.get())
          .map((e) => e.toJson())
          .toList(),
      'ingredients': ingredientRows.map((e) => e.toJson()).toList(),
      'prices': prices.map((e) => e.toJson()).toList(),
      'ingredientLots': ingredientLotRows.map((e) => e.toJson()).toList(),
      'ingredientStockMovements': ingredientStockRows
          .map((e) => e.toJson())
          .toList(),
      'formulas': formulaRows.map((e) => e.toJson()).toList(),
      'formulaItems': formulaItemRows.map((e) => e.toJson()).toList(),
      'feedBatches': feedBatchRows.map((e) => e.toJson()).toList(),
      'feedBatchItems': feedBatchItemRows.map((e) => e.toJson()).toList(),
      'feedStock': feedStockRows.map((e) => e.toJson()).toList(),
      'feedings': (await feedingsQuery.get()).map((e) => e.toJson()).toList(),
      'feedRecommendations': (await select(
        feedConsumptionRecommendations,
      ).get()).map((e) => e.toJson()).toList(),
      'customers': customerRows.map((e) => e.toJson()).toList(),
      'orders': orderRows.map((e) => e.toJson()).toList(),
      'orderItems': orderItemRows.map((e) => e.toJson()).toList(),
      'orderStatusHistory': orderStatusRows.map((e) => e.toJson()).toList(),
      'packagingItems': packagingItemRows.map((e) => e.toJson()).toList(),
      'packagingLots': packagingLotRows.map((e) => e.toJson()).toList(),
      'packagingStockMovements': packagingStockRows
          .map((e) => e.toJson())
          .toList(),
      'eggTrayBatches': eggTrayBatchRows.map((e) => e.toJson()).toList(),
      'eggTrayStockMovements': eggTrayStockRows.map((e) => e.toJson()).toList(),
      'sales': (await salesQuery.get()).map((e) => e.toJson()).toList(),
      'finance': (await financeQuery.get()).map((e) => e.toJson()).toList(),
      'investments': (await investmentsQuery.get())
          .map((e) => e.toJson())
          .toList(),
      'lightingPrograms': lightingProgramRows.map((e) => e.toJson()).toList(),
      'lightingSteps': lightingStepRows.map((e) => e.toJson()).toList(),
      'lotLighting': lotLightingRows.map((e) => e.toJson()).toList(),
      'calendarEvents': (await calendarEventsQuery.get())
          .map((e) => e.toJson())
          .toList(),
      'notificationSettings': (await select(
        notificationSettings,
      ).get()).map((e) => e.toJson()).toList(),
      'appSettings': (await select(
        appSettings,
      ).get()).map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> restoreJson(
    String content, {
    required String actorId,
    bool writeAudit = true,
  }) async {
    await _assertGlobalWriteAllowed(actorId);
    final raw = jsonDecode(content);
    if (raw is! Map<String, dynamic> || raw['format'] != 'SELETO_BACKUP_V1') {
      throw const FormatException(
        'Arquivo de cópia de segurança SELETO inválido.',
      );
    }
    List<Map<String, dynamic>> rows(String key) =>
        (raw[key] as List? ?? const [])
            .cast<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
    Map<String, dynamic> normalizeEggCollection(Map<String, dynamic> row) {
      if (row.containsKey('cleanEggs') &&
          row.containsKey('dirtyEggs') &&
          row.containsKey('crackedEggs')) {
        return row;
      }
      final quantity = row['quantity'] as int? ?? 0;
      final broken = row['brokenEggs'] as int? ?? 0;
      final discarded = row['discardedEggs'] as int? ?? 0;
      return {
        ...row,
        'cleanEggs': (quantity - broken - discarded).clamp(0, quantity),
        'dirtyEggs': 0,
        'crackedEggs': discarded,
      };
    }

    await transaction(() async {
      await delete(notificationSettings).go();
      await delete(appSettings).go();
      await delete(lotLightingPrograms).go();
      await delete(lightingProgramSteps).go();
      await delete(lightingPrograms).go();
      await delete(calendarEvents).go();
      await delete(orderStatusHistory).go();
      await delete(orderItems).go();
      await delete(orders).go();
      await delete(sales).go();
      await delete(eggTrayStockMovements).go();
      await delete(eggTrayBatches).go();
      await delete(packagingStockMovements).go();
      await delete(packagingLots).go();
      await delete(packagingItems).go();
      await delete(investments).go();
      await delete(financeTransactions).go();
      await delete(dailyFeedings).go();
      await delete(feedConsumptionRecommendations).go();
      await delete(feedStockMovements).go();
      await delete(feedBatchItems).go();
      await delete(feedBatches).go();
      await delete(feedFormulaItems).go();
      await delete(feedFormulas).go();
      await delete(ingredientStockMovements).go();
      await delete(ingredientLots).go();
      await delete(ingredientPriceHistory).go();
      await delete(ingredients).go();
      await delete(eggStockMovements).go();
      await delete(eggCollections).go();
      await delete(birdMovements).go();
      await delete(lots).go();
      for (final e in rows('lots')) {
        await into(lots).insert(Lot.fromJson(e));
      }
      for (final e in rows('birdMovements')) {
        await into(birdMovements).insert(BirdMovement.fromJson(e));
      }
      for (final e in rows('eggCollections')) {
        await into(
          eggCollections,
        ).insert(EggCollection.fromJson(normalizeEggCollection(e)));
      }
      for (final e in rows('eggStockMovements')) {
        await into(eggStockMovements).insert(EggStockMovement.fromJson(e));
      }
      for (final e in rows('ingredients')) {
        await into(ingredients).insert(Ingredient.fromJson(e));
      }
      for (final e in rows('prices')) {
        await into(
          ingredientPriceHistory,
        ).insert(IngredientPriceHistoryData.fromJson(e));
      }
      for (final e in rows('ingredientLots')) {
        await into(ingredientLots).insert(IngredientLot.fromJson(e));
      }
      for (final e in rows('ingredientStockMovements')) {
        await into(
          ingredientStockMovements,
        ).insert(IngredientStockMovement.fromJson(e));
      }
      for (final e in rows('formulas')) {
        await into(feedFormulas).insert(FeedFormula.fromJson(e));
      }
      for (final e in rows('formulaItems')) {
        await into(feedFormulaItems).insert(FeedFormulaItem.fromJson(e));
      }
      for (final e in rows('feedBatches')) {
        await into(feedBatches).insert(FeedBatche.fromJson(e));
      }
      for (final e in rows('feedBatchItems')) {
        await into(feedBatchItems).insert(FeedBatchItem.fromJson(e));
      }
      for (final e in rows('feedStock')) {
        await into(feedStockMovements).insert(FeedStockMovement.fromJson(e));
      }
      for (final e in rows('feedings')) {
        await into(dailyFeedings).insert(DailyFeeding.fromJson(e));
      }
      for (final e in rows('feedRecommendations')) {
        await into(
          feedConsumptionRecommendations,
        ).insert(FeedConsumptionRecommendation.fromJson(e));
      }
      for (final e in rows('customers')) {
        await into(customers).insert(Customer.fromJson(e));
      }
      for (final e in rows('orders')) {
        await into(orders).insert(Order.fromJson(e));
      }
      for (final e in rows('orderItems')) {
        await into(orderItems).insert(OrderItem.fromJson(e));
      }
      for (final e in rows('orderStatusHistory')) {
        await into(
          orderStatusHistory,
        ).insert(OrderStatusHistoryData.fromJson(e));
      }
      for (final e in rows('packagingItems')) {
        await into(packagingItems).insert(PackagingItem.fromJson(e));
      }
      for (final e in rows('packagingLots')) {
        await into(packagingLots).insert(PackagingLot.fromJson(e));
      }
      for (final e in rows('packagingStockMovements')) {
        await into(
          packagingStockMovements,
        ).insert(PackagingStockMovement.fromJson(e));
      }
      for (final e in rows('eggTrayBatches')) {
        await into(eggTrayBatches).insert(EggTrayBatch.fromJson(_trayJson(e)));
      }
      for (final e in rows('eggTrayStockMovements')) {
        await into(
          eggTrayStockMovements,
        ).insert(EggTrayStockMovement.fromJson(e));
      }
      for (final e in rows('sales')) {
        await into(sales).insert(Sale.fromJson(_saleJson(e)));
      }
      for (final e in rows('finance')) {
        await into(financeTransactions).insert(FinanceTransaction.fromJson(e));
      }
      for (final e in rows('investments')) {
        await into(investments).insert(Investment.fromJson(e));
      }
      for (final e in rows('lightingPrograms')) {
        await into(lightingPrograms).insert(LightingProgram.fromJson(e));
      }
      for (final e in rows('lightingSteps')) {
        await into(
          lightingProgramSteps,
        ).insert(LightingProgramStep.fromJson(e));
      }
      for (final e in rows('lotLighting')) {
        await into(lotLightingPrograms).insert(LotLightingProgram.fromJson(e));
      }
      for (final e in rows('calendarEvents')) {
        await into(
          calendarEvents,
        ).insert(CalendarEvent.fromJson(_eventJson(e)));
      }
      for (final e in rows('notificationSettings')) {
        await into(
          notificationSettings,
        ).insert(NotificationSetting.fromJson(_notificationJson(e)));
      }
      for (final e in rows('appSettings')) {
        await into(appSettings).insert(AppSetting.fromJson(e));
      }
      if (writeAudit) {
        await addAudit(
          userId: actorId,
          action: 'backup.restore',
          entityType: 'database',
          description: 'Cópia de segurança local restaurada.',
        );
      }
    });
  }
}

String? _cleanValue(String? value) {
  final result = value?.trim();
  return result == null || result.isEmpty ? null : result;
}

Map<String, dynamic> _eventJson(Map<String, dynamic> json) => {
  ...json,
  'alertEnabled': json['alertEnabled'] ?? true,
  'alertMessage': json['alertMessage'],
  'alertTime': json['alertTime'] ?? '08:00',
  'recurrence': json['recurrence'] ?? 'ONCE',
  'repeatUntil': json['repeatUntil'],
  'weekdays': json['weekdays'],
};

Map<String, dynamic> _notificationJson(Map<String, dynamic> json) => {
  ...json,
  'defaultMessage': json['defaultMessage'],
  'defaultRecurrence': json['defaultRecurrence'] ?? 'ONCE',
};

Map<String, dynamic> _saleJson(Map<String, dynamic> json) => {
  ...json,
  'trayBatchId': json['trayBatchId'],
  'trayQuantity': json['trayQuantity'] ?? 0,
};

Map<String, dynamic> _trayJson(Map<String, dynamic> json) => {
  ...json,
  'trayUnitCostCents': json['trayUnitCostCents'] ?? 0,
  'labelUnitCostCents': json['labelUnitCostCents'] ?? 0,
  'eggUnitCostCents': json['eggUnitCostCents'] ?? 0,
  'finalUnitPriceCents': json['finalUnitPriceCents'] ?? 0,
};

FeedConsumptionRecommendationsCompanion
_feedConsumptionRecommendationFromImport(
  Map<String, dynamic> row, {
  required int index,
  required String actorId,
  required DateTime now,
  required String filename,
}) {
  final singleWeek = _importInt(row, const [
    'ageWeek',
    'ageWeeks',
    'week',
    'semana',
    'idadeSemana',
    'idadeSemanas',
  ]);
  final startWeek =
      _importInt(row, const [
        'startWeek',
        'weekStart',
        'semanaInicial',
        'inicioSemana',
        'idadeSemanaInicial',
        'idadeSemanasInicial',
      ]) ??
      singleWeek;
  if (startWeek == null || startWeek < 0) {
    throw FormatException(
      'Linha ${index + 1}: informe uma semana inicial válida.',
    );
  }
  final endWeek =
      _importInt(row, const [
        'endWeek',
        'weekEnd',
        'semanaFinal',
        'fimSemana',
        'idadeSemanaFinal',
        'idadeSemanasFinal',
      ]) ??
      singleWeek;
  if (endWeek != null && endWeek < startWeek) {
    throw FormatException(
      'Linha ${index + 1}: semana final não pode ser menor que a inicial.',
    );
  }
  final grams = _importDouble(row, const [
    'gramsPerBirdDay',
    'gramsBirdDay',
    'gramasPorAveDia',
    'gramasAveDia',
    'consumoGramasPorAveDia',
    'consumoPorAveDia',
    'consumoAveDia',
    'gAveDia',
  ]);
  if (grams == null || grams <= 0) {
    throw FormatException(
      'Linha ${index + 1}: informe o consumo em gramas por ave/dia.',
    );
  }
  final id =
      _importText(row, const ['id']) ??
      'feed-consumption-import-$startWeek-${endWeek ?? 'plus'}-$index';
  final createdAt =
      _importDate(row, const ['createdAt', 'criadoEm', 'dataCadastro']) ?? now;
  return FeedConsumptionRecommendationsCompanion.insert(
    id: id,
    startWeek: startWeek,
    endWeek: Value(endWeek),
    gramsPerBirdDay: grams,
    phase: Value(
      _cleanValue(
        _importText(row, const ['phase', 'fase', 'feedingPhase', 'faseRacao']),
      ),
    ),
    source: Value(
      _cleanValue(
            _importText(row, const ['source', 'fonte', 'manual', 'origem']),
          ) ??
          'Importado de $filename',
    ),
    notes: Value(
      _cleanValue(
        _importText(row, const ['notes', 'observacao', 'observacoes']),
      ),
    ),
    createdBy: _importText(row, const ['createdBy', 'criadoPor']) ?? actorId,
    createdAt: createdAt,
  );
}

dynamic _importValue(Map<String, dynamic> row, Iterable<String> keys) {
  final wanted = keys.map(_normalImportKey).toSet();
  for (final entry in row.entries) {
    if (wanted.contains(_normalImportKey(entry.key))) return entry.value;
  }
  return null;
}

String? _importText(Map<String, dynamic> row, Iterable<String> keys) {
  final value = _importValue(row, keys);
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _importInt(Map<String, dynamic> row, Iterable<String> keys) {
  final value = _importValue(row, keys);
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return int.tryParse(text.replaceAll(',', '.').split('.').first);
}

double? _importDouble(Map<String, dynamic> row, Iterable<String> keys) {
  final value = _importValue(row, keys);
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final normalized = value
      .toString()
      .trim()
      .replaceAll(',', '.')
      .replaceAll(RegExp(r'[^0-9.\-]'), '');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

DateTime? _importDate(Map<String, dynamic> row, Iterable<String> keys) {
  final text = _importText(row, keys);
  return text == null ? null : DateTime.tryParse(text);
}

String _normalImportKey(String value) {
  const accents = {
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'é': 'e',
    'ê': 'e',
    'í': 'i',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ç': 'c',
  };
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(accents[char] ?? char);
  }
  return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

void _validateAlertRecurrence({
  required String alertTime,
  required String recurrence,
  required String? weekdays,
  required DateTime? repeatUntil,
}) {
  if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(alertTime)) {
    throw ArgumentError('Use horário no formato HH:mm.');
  }
  if (!{'ONCE', 'DAILY', 'WEEKLY', 'MONTHLY'}.contains(recurrence)) {
    throw ArgumentError('Recorrência de alerta inválida.');
  }
  if (recurrence == 'WEEKLY') {
    final selectedDays = _parseWeekdays(weekdays);
    if (selectedDays.isEmpty) {
      throw ArgumentError('Escolha ao menos um dia da semana para o alerta.');
    }
  }
  if (repeatUntil != null && repeatUntil.isBefore(DateTime(2020))) {
    throw ArgumentError('Data final do alerta inválida.');
  }
}

Set<int> _parseWeekdays(String? value) => (value ?? '')
    .split(',')
    .map((item) => int.tryParse(item.trim()))
    .whereType<int>()
    .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
    .toSet();

String _packagingTypeLabel(String type) => switch (type) {
  'TRAY' => 'Bandeja',
  'LABEL' => 'Etiqueta',
  _ => 'Material',
};
