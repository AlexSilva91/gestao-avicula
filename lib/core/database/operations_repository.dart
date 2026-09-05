import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';
import 'operational_data_import.dart';

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
  const FeedBatchBalance({required this.batch, required this.balanceKg});
  final FeedBatche batch;
  final double balanceKg;
  double get consumedKg => batch.producedQuantityKg - balanceKg;
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

  Stream<BirdMetrics> watchBirdMetrics() =>
      customSelect(
        '''SELECT
    COALESCE(SUM(CASE WHEN type='PURCHASE' THEN quantity ELSE 0 END),0) purchased,
    COALESCE(SUM(CASE WHEN type IN ('PURCHASE','TRANSFER_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END),0) active,
    COALESCE(SUM(CASE WHEN type='MORTALITY' THEN quantity ELSE 0 END),0) mortality FROM bird_movements''',
        readsFrom: {birdMovements},
      ).watchSingle().map(
        (r) => BirdMetrics(
          purchased: r.read<int>('purchased'),
          active: r.read<int>('active'),
          mortality: r.read<int>('mortality'),
        ),
      );
  Stream<List<ReportPoint>> watchEggProductionSeries({int days = 30}) {
    final start = DateTime.now().subtract(Duration(days: days));
    return customSelect(
      '''SELECT collected_on, SUM(quantity-broken_eggs-discarded_eggs) total
         FROM egg_collections WHERE collected_on>=? GROUP BY date(collected_on) ORDER BY collected_on''',
      variables: [Variable.withDateTime(start)],
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

  Stream<List<ReportPoint>> watchFinanceSeries({int months = 6}) {
    final start = DateTime(
      DateTime.now().year,
      DateTime.now().month - months + 1,
    );
    return customSelect(
      '''SELECT strftime('%m/%Y', occurred_at, 'unixepoch') period,
         SUM(CASE WHEN type='INCOME' AND status='CONFIRMED' THEN amount_cents ELSE 0 END) income,
         SUM(CASE WHEN type='EXPENSE' AND status='CONFIRMED' THEN amount_cents ELSE 0 END) expense
         FROM finance_transactions WHERE occurred_at>=? GROUP BY strftime('%Y-%m', occurred_at, 'unixepoch') ORDER BY occurred_at''',
      variables: [Variable.withDateTime(start)],
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

  Stream<List<IngredientOverview>> watchIngredientOverviews() {
    final query = customSelect(
      '''
      SELECT i.*,
        (SELECT price_per_kg_cents FROM ingredient_price_history p WHERE p.ingredient_id=i.id ORDER BY effective_date DESC, created_at DESC LIMIT 1) current_price,
        (SELECT price_per_kg_cents FROM ingredient_price_history p WHERE p.ingredient_id=i.id ORDER BY effective_date DESC, created_at DESC LIMIT 1 OFFSET 1) previous_price,
        (SELECT MIN(price_per_kg_cents) FROM ingredient_price_history p WHERE p.ingredient_id=i.id) minimum_price,
        (SELECT MAX(price_per_kg_cents) FROM ingredient_price_history p WHERE p.ingredient_id=i.id) maximum_price,
        (SELECT AVG(price_per_kg_cents) FROM ingredient_price_history p WHERE p.ingredient_id=i.id) average_price,
        COALESCE((SELECT SUM(CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END) FROM ingredient_stock_movements m WHERE m.ingredient_id=i.id),0) stock_kg,
        COALESCE((SELECT COUNT(*) FROM ingredient_lots l WHERE l.ingredient_id=i.id AND (SELECT COALESCE(SUM(CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END),0) FROM ingredient_stock_movements m WHERE m.ingredient_lot_id=l.id) > 0.0001),0) active_lot_count
      FROM ingredients i ORDER BY is_active DESC, name
    ''',
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
    String ingredientId,
  ) =>
      (select(ingredientPriceHistory)
            ..where((p) => p.ingredientId.equals(ingredientId))
            ..orderBy([(p) => OrderingTerm.desc(p.effectiveDate)])
            ..limit(100))
          .watch();

  Stream<List<IngredientLotBalance>> watchIngredientLotBalances({
    String? ingredientId,
  }) {
    final where = ingredientId == null ? '' : 'WHERE l.ingredient_id = ?';
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
      variables: [if (ingredientId != null) Variable.withString(ingredientId)],
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
        description:
            'Entrada de ${quantityKg.toStringAsFixed(2)} kg de insumo registrada.',
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
        description:
            'Correção de ${quantityKg.toStringAsFixed(2)} kg no lote ${lot.code}.',
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

  Stream<List<FormulaOverview>> watchFormulaOverviews() {
    final query = customSelect(
      '''
      SELECT f.*, fi.ingredient_id, i.name ingredient_name, fi.base_quantity_kg
      FROM feed_formulas f JOIN feed_formula_items fi ON fi.formula_id=f.id
      JOIN ingredients i ON i.id=fi.ingredient_id
      ORDER BY f.phase, f.version DESC, i.name
    ''',
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
    await transaction(() async {
      await (update(feedFormulas)
            ..where((f) => f.phase.equals(source.formula.phase)))
          .write(const FeedFormulasCompanion(isActive: Value(false)));
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
  }) async {
    final rows = await customSelect(
      '''
      SELECT l.*,
        COALESCE(SUM(CASE WHEN m.type IN ('PURCHASE_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END),0) balance_kg
      FROM ingredient_lots l
      LEFT JOIN ingredient_stock_movements m ON m.ingredient_lot_id = l.id
      WHERE l.ingredient_id = ? AND l.entry_date <= ?
      GROUP BY l.id
      HAVING balance_kg > 0.0001
      ORDER BY l.entry_date ASC, l.created_at ASC
    ''',
      variables: [
        Variable.withString(ingredientId),
        Variable.withDateTime(producedAt),
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
        'Estoque insuficiente de ${ingredient?.name ?? 'insumo'}. Faltam ${remaining.toStringAsFixed(2)} kg.',
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
    final now = DateTime.now();
    final producedAt = date ?? now;
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
        description:
            'Fabricação $code de ${quantityKg.toStringAsFixed(2)} kg registrada.',
      );
    });
  }

  Stream<List<FeedBatchBalance>> watchFeedBatchBalances() {
    final query = customSelect(
      '''
      SELECT b.*, COALESCE(SUM(CASE WHEN m.type IN ('PRODUCTION_IN','ADJUSTMENT_IN') THEN m.quantity_kg ELSE -m.quantity_kg END),0) balance_kg
      FROM feed_batches b LEFT JOIN feed_stock_movements m ON m.batch_id=b.id GROUP BY b.id ORDER BY b.produced_at DESC
    ''',
      readsFrom: {feedBatches, feedStockMovements},
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
            ),
          )
          .toList(),
    );
  }

  Stream<List<DailyFeeding>> watchFeedings({int limit = 100}) =>
      (select(dailyFeedings)
            ..orderBy([(f) => OrderingTerm.desc(f.feedingDate)])
            ..limit(limit))
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
    if (await activeBirdsFor(lotId) <= 0) {
      throw StateError('O lote não possui aves ativas.');
    }
    final balance = await feedBalanceFor(batchId);
    if (quantityKg > balance + .0001) {
      throw StateError(
        'Saldo insuficiente. Disponível: ${balance.toStringAsFixed(2)} kg.',
      );
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
        description:
            'Alimentação de ${quantityKg.toStringAsFixed(2)} kg registrada.',
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
        description:
            'Ajuste de ${quantityKg.toStringAsFixed(2)} kg no estoque de ração.',
      );
    });
  }

  Stream<List<Customer>> watchCustomers({String search = ''}) {
    final query = select(customers)
      ..orderBy([(c) => OrderingTerm.asc(c.name)])
      ..limit(100);
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

  Stream<List<Order>> watchOrders({String? status, int limit = 100}) {
    final query = select(orders)
      ..orderBy([(o) => OrderingTerm.desc(o.createdAt)])
      ..limit(limit);
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
    if (eggs > await eggStockBalance()) {
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

  Stream<List<Sale>> watchSales({int limit = 100}) =>
      (select(sales)
            ..orderBy([(s) => OrderingTerm.desc(s.soldAt)])
            ..limit(limit))
          .watch();

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
    final eggs = dozens * 12 + looseEggs;
    if (eggs > await eggStockBalance()) {
      throw StateError(
        'Estoque insuficiente. Disponível: ${await eggStockBalance()} ovos.',
      );
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

  Future<int> eggStockBalance() async {
    final row = await customSelect(
      "SELECT COALESCE(SUM(CASE WHEN type IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END),0) balance FROM egg_stock_movements",
      readsFrom: {eggStockMovements},
    ).getSingle();
    return row.read<int>('balance');
  }

  Stream<EggStockMetrics> watchEggStockMetrics() =>
      customSelect(
        '''SELECT
    COALESCE(SUM(CASE WHEN type IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END),0) balance,
    COALESCE(SUM(CASE WHEN type IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE 0 END),0) entries,
    COALESCE(SUM(CASE WHEN type NOT IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE 0 END),0) outputs,
    COALESCE(SUM(CASE WHEN type='LOSS_OUT' THEN quantity ELSE 0 END),0) losses FROM egg_stock_movements''',
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
    if (type != 'ADJUSTMENT_IN' && quantity > await eggStockBalance()) {
      throw StateError('O ajuste deixaria o estoque negativo.');
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

  Stream<List<FinanceTransaction>> watchFinance({int limit = 200}) =>
      (select(financeTransactions)
            ..orderBy([(f) => OrderingTerm.desc(f.occurredAt)])
            ..limit(limit))
          .watch();
  Stream<FinanceMetrics> watchFinanceMetrics() =>
      customSelect(
        '''SELECT
    COALESCE(SUM(CASE WHEN type='INCOME' AND status='CONFIRMED' THEN amount_cents ELSE 0 END),0) income,
    COALESCE(SUM(CASE WHEN type='EXPENSE' AND status='CONFIRMED' THEN amount_cents ELSE 0 END),0) expense,
    COALESCE((SELECT SUM(amount_cents) FROM investments),0) investment FROM finance_transactions''',
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

  Stream<List<Investment>> watchInvestments() => (select(
    investments,
  )..orderBy([(i) => OrderingTerm.desc(i.investmentDate)])).watch();
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
    DateTime last,
  ) =>
      (select(calendarEvents)
            ..where(
              (e) =>
                  e.startsAt.isBiggerOrEqualValue(first) &
                  e.startsAt.isSmallerThanValue(last),
            )
            ..orderBy([(e) => OrderingTerm.asc(e.startsAt)]))
          .watch();

  Future<List<CalendarEvent>> futureAlertCalendarEvents(
    DateTime first,
    DateTime last,
  ) =>
      (select(calendarEvents)
            ..where(
              (e) =>
                  e.alertEnabled.equals(true) &
                  e.startsAt.isSmallerOrEqualValue(last) &
                  (e.repeatUntil.isNull() |
                      e.repeatUntil.isBiggerOrEqualValue(first)),
            )
            ..orderBy([(e) => OrderingTerm.asc(e.startsAt)]))
          .get();

  Future<List<LotSummary>> currentLotSummaries() async {
    final rows = await customSelect(
      '''
        SELECT l.*, COALESCE(SUM(
          CASE WHEN m.type IN ('PURCHASE', 'TRANSFER_IN', 'ADJUSTMENT_IN')
          THEN m.quantity ELSE -m.quantity END
        ), 0) AS active_birds
        FROM lots l
        LEFT JOIN bird_movements m ON m.lot_id = l.id
        GROUP BY l.id
        ORDER BY CASE l.status WHEN 'ACTIVE' THEN 0 ELSE 1 END, l.received_at DESC
      ''',
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

  Future<void> assignLightingProgram({
    required String lotId,
    required String programId,
    required String actorId,
  }) async {
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

  Stream<List<AuditLog>> watchAuditLogs({int limit = 200}) =>
      (select(auditLogs)
            ..orderBy([(a) => OrderingTerm.desc(a.timestamp)])
            ..limit(limit))
          .watch();
  Stream<List<BirdMovement>> watchBirdMovements({int limit = 200}) =>
      (select(birdMovements)
            ..orderBy([(m) => OrderingTerm.desc(m.occurredAt)])
            ..limit(limit))
          .watch();

  Future<void> transferBirds({
    required String fromLotId,
    required String toLotId,
    required int quantity,
    required DateTime date,
    String? notes,
    required String actorId,
  }) async {
    if (fromLotId == toLotId || quantity <= 0) {
      throw ArgumentError(
        'Selecione lotes diferentes e uma quantidade válida.',
      );
    }
    if (quantity > await activeBirdsFor(fromLotId)) {
      throw StateError('Saldo insuficiente no lote de origem.');
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
      await addAudit(
        userId: actorId,
        action: 'birds.transfer',
        entityType: 'bird_transfer',
        entityId: reference,
        description: 'Transferência de $quantity aves entre lotes.',
      );
    });
  }

  Stream<DashboardMetrics> watchDashboardMetrics() {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final query = customSelect(
      '''SELECT
      COALESCE((SELECT SUM(CASE WHEN type IN ('PURCHASE','TRANSFER_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END) FROM bird_movements),0) birds,
      COALESCE((SELECT COUNT(*) FROM lots WHERE status='ACTIVE'),0) lots,
      COALESCE((SELECT SUM(CASE WHEN type IN ('COLLECTION_IN','ADJUSTMENT_IN') THEN quantity ELSE -quantity END) FROM egg_stock_movements),0) eggs,
      COALESCE((SELECT SUM(CASE WHEN type IN ('PRODUCTION_IN','ADJUSTMENT_IN') THEN quantity_kg ELSE -quantity_kg END) FROM feed_stock_movements),0) feed,
      COALESCE((SELECT COUNT(*) FROM orders WHERE status NOT IN ('DELIVERED','CANCELLED')),0) pending,
      COALESCE((SELECT SUM(amount_cents) FROM finance_transactions WHERE type='INCOME' AND status='CONFIRMED' AND occurred_at>=?),0) income,
      COALESCE((SELECT SUM(amount_cents) FROM finance_transactions WHERE type='EXPENSE' AND status='CONFIRMED' AND occurred_at>=?),0) expense,
      COALESCE((SELECT SUM(quantity_kg) FROM daily_feedings WHERE feeding_date>=?),0) month_feed
    ''',
      variables: [
        Variable.withDateTime(month),
        Variable.withDateTime(month),
        Variable.withDateTime(month),
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

  Future<String> exportJson() async {
    final payload = <String, dynamic>{
      'format': 'SELETO_BACKUP_V1',
      'exportedAt': DateTime.now().toIso8601String(),
      'lots': (await select(lots).get()).map((e) => e.toJson()).toList(),
      'birdMovements': (await select(
        birdMovements,
      ).get()).map((e) => e.toJson()).toList(),
      'eggCollections': (await select(
        eggCollections,
      ).get()).map((e) => e.toJson()).toList(),
      'eggStockMovements': (await select(
        eggStockMovements,
      ).get()).map((e) => e.toJson()).toList(),
      'ingredients': (await select(
        ingredients,
      ).get()).map((e) => e.toJson()).toList(),
      'prices': (await select(
        ingredientPriceHistory,
      ).get()).map((e) => e.toJson()).toList(),
      'ingredientLots': (await select(
        ingredientLots,
      ).get()).map((e) => e.toJson()).toList(),
      'ingredientStockMovements': (await select(
        ingredientStockMovements,
      ).get()).map((e) => e.toJson()).toList(),
      'formulas': (await select(
        feedFormulas,
      ).get()).map((e) => e.toJson()).toList(),
      'formulaItems': (await select(
        feedFormulaItems,
      ).get()).map((e) => e.toJson()).toList(),
      'feedBatches': (await select(
        feedBatches,
      ).get()).map((e) => e.toJson()).toList(),
      'feedBatchItems': (await select(
        feedBatchItems,
      ).get()).map((e) => e.toJson()).toList(),
      'feedStock': (await select(
        feedStockMovements,
      ).get()).map((e) => e.toJson()).toList(),
      'feedings': (await select(
        dailyFeedings,
      ).get()).map((e) => e.toJson()).toList(),
      'customers': (await select(
        customers,
      ).get()).map((e) => e.toJson()).toList(),
      'orders': (await select(orders).get()).map((e) => e.toJson()).toList(),
      'orderItems': (await select(
        orderItems,
      ).get()).map((e) => e.toJson()).toList(),
      'orderStatusHistory': (await select(
        orderStatusHistory,
      ).get()).map((e) => e.toJson()).toList(),
      'sales': (await select(sales).get()).map((e) => e.toJson()).toList(),
      'finance': (await select(
        financeTransactions,
      ).get()).map((e) => e.toJson()).toList(),
      'investments': (await select(
        investments,
      ).get()).map((e) => e.toJson()).toList(),
      'lightingPrograms': (await select(
        lightingPrograms,
      ).get()).map((e) => e.toJson()).toList(),
      'lightingSteps': (await select(
        lightingProgramSteps,
      ).get()).map((e) => e.toJson()).toList(),
      'lotLighting': (await select(
        lotLightingPrograms,
      ).get()).map((e) => e.toJson()).toList(),
      'calendarEvents': (await select(
        calendarEvents,
      ).get()).map((e) => e.toJson()).toList(),
      'notificationSettings': (await select(
        notificationSettings,
      ).get()).map((e) => e.toJson()).toList(),
      'appSettings': (await select(
        appSettings,
      ).get()).map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> restoreJson(String content, {required String actorId}) async {
    final raw = jsonDecode(content);
    if (raw is! Map<String, dynamic> || raw['format'] != 'SELETO_BACKUP_V1') {
      throw const FormatException('Arquivo de backup SELETO inválido.');
    }
    List<Map<String, dynamic>> rows(String key) =>
        (raw[key] as List? ?? const [])
            .cast<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
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
      await delete(investments).go();
      await delete(financeTransactions).go();
      await delete(dailyFeedings).go();
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
        await into(eggCollections).insert(EggCollection.fromJson(e));
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
      for (final e in rows('sales')) {
        await into(sales).insert(Sale.fromJson(e));
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
      await addAudit(
        userId: actorId,
        action: 'backup.restore',
        entityType: 'database',
        description: 'Backup local restaurado.',
      );
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
