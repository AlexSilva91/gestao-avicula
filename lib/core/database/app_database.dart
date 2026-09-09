import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../utils/password_hasher.dart';
import 'database_connection.dart';
import 'operations_tables.dart';

part 'app_database.g.dart';

const defaultTenantId = 'tenant-default';
const defaultTenantName = 'Granja Seleto';
const _globalUserPermissions = {
  'system.super_admin',
  'tenant.view_all',
  'tenants.create',
};

class Tenants extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId =>
      text().withDefault(const Constant(defaultTenantId))();
  TextColumn get username => text().unique()();
  TextColumn get displayName => text()();
  TextColumn get passwordHash => text()();
  BoolColumn get isSuperuser => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class UserPermissions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get permission => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {userId, permission},
  ];
}

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get description => text()();
  TextColumn get metadata => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A flock is deliberately kept separate from its balance. The latter is
/// derived from [BirdMovements], preserving the complete operational history.
class Lots extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get strain => text().nullable()();
  IntColumn get initialQuantity => integer()();
  DateTimeColumn get receivedAt => dateTime()();
  IntColumn get arrivalAgeDays => integer()();
  IntColumn get unitValueCents => integer().nullable()();
  TextColumn get supplier => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BirdMovements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get lotId => text()();
  TextColumn get relatedLotId => text().nullable()();
  IntColumn get quantity => integer()();
  IntColumn get unitValueCents => integer().nullable()();
  IntColumn get totalValueCents => integer().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class EggCollections extends Table {
  TextColumn get id => text()();
  DateTimeColumn get collectedOn => dateTime()();
  TextColumn get lotId => text()();
  IntColumn get quantity => integer()();
  IntColumn get cleanEggs => integer().withDefault(const Constant(0))();
  IntColumn get dirtyEggs => integer().withDefault(const Constant(0))();
  IntColumn get crackedEggs => integer().withDefault(const Constant(0))();
  IntColumn get brokenEggs => integer().withDefault(const Constant(0))();
  IntColumn get discardedEggs => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class EggStockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get quantity => integer()();
  TextColumn get collectionId => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LotSummary {
  const LotSummary({required this.lot, required this.activeBirds});
  final Lot lot;
  final int activeBirds;
}

class EggMetrics {
  const EggMetrics({
    required this.eggsToday,
    required this.eggsThisMonth,
    required this.stock,
  });
  final int eggsToday;
  final int eggsThisMonth;
  final int stock;
  double get dozensInStock => stock / 12;
}

class LayingRateHistoryEntry {
  const LayingRateHistoryEntry({
    required this.lotId,
    required this.lotName,
    required this.periodStart,
    required this.totalEggs,
    required this.stockEggs,
    required this.lostEggs,
    required this.activeBirdDays,
    required this.collectionDays,
  });

  final String lotId;
  final String lotName;
  final DateTime periodStart;
  final int totalEggs;
  final int stockEggs;
  final int lostEggs;
  final int activeBirdDays;
  final int collectionDays;

  double get layingRate => activeBirdDays <= 0 ? 0 : totalEggs / activeBirdDays;
}

@DriftDatabase(
  tables: [
    Tenants,
    Users,
    UserPermissions,
    AuditLogs,
    Lots,
    BirdMovements,
    EggCollections,
    EggStockMovements,
    Ingredients,
    IngredientPriceHistory,
    IngredientLots,
    IngredientStockMovements,
    FeedFormulas,
    FeedFormulaItems,
    FeedBatches,
    FeedBatchItems,
    FeedStockMovements,
    DailyFeedings,
    FeedConsumptionRecommendations,
    Customers,
    Orders,
    OrderItems,
    OrderStatusHistory,
    PackagingItems,
    PackagingLots,
    PackagingStockMovements,
    EggTrayBatches,
    EggTrayStockMovements,
    Sales,
    FinanceTransactions,
    Investments,
    LightingPrograms,
    LightingProgramSteps,
    LotLightingPrograms,
    CalendarEvents,
    NotificationSettings,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  static Future<AppDatabase> open({
    bool resetOnStart = false,
    bool testDatabase = false,
  }) async {
    final executor = await openSeletoDatabaseConnection(
      resetOnStart: resetOnStart,
      testDatabase: testDatabase,
    );
    return AppDatabase(executor);
  }

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createPerformanceIndexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(lots);
        await m.createTable(birdMovements);
      }
      if (from < 3) {
        await m.createTable(eggCollections);
        await m.createTable(eggStockMovements);
      }
      if (from < 4) {
        await _createPerformanceIndexes();
      }
      if (from < 5) {
        await m.createTable(ingredients);
        await m.createTable(ingredientPriceHistory);
        await m.createTable(feedFormulas);
        await m.createTable(feedFormulaItems);
        await m.createTable(feedBatches);
        await m.createTable(feedBatchItems);
        await m.createTable(feedStockMovements);
        await m.createTable(dailyFeedings);
        await m.createTable(customers);
        await m.createTable(orders);
        await m.createTable(orderItems);
        await m.createTable(orderStatusHistory);
        await m.createTable(sales);
        await m.createTable(financeTransactions);
        await m.createTable(investments);
        await m.createTable(lightingPrograms);
        await m.createTable(lightingProgramSteps);
        await m.createTable(lotLightingPrograms);
        await m.createTable(calendarEvents);
        await m.createTable(notificationSettings);
        await m.createTable(appSettings);
        await _createPerformanceIndexes();
      }
      if (from < 6) {
        await m.addColumn(calendarEvents, calendarEvents.alertEnabled);
        await m.addColumn(calendarEvents, calendarEvents.alertMessage);
        await m.addColumn(calendarEvents, calendarEvents.alertTime);
        await m.addColumn(calendarEvents, calendarEvents.recurrence);
        await m.addColumn(calendarEvents, calendarEvents.repeatUntil);
        await m.addColumn(calendarEvents, calendarEvents.weekdays);
        await m.addColumn(
          notificationSettings,
          notificationSettings.defaultMessage,
        );
        await m.addColumn(
          notificationSettings,
          notificationSettings.defaultRecurrence,
        );
      }
      if (from < 7) {
        await m.createTable(ingredientLots);
        await m.createTable(ingredientStockMovements);
        await _createPerformanceIndexes();
      }
      if (from < 8) {
        await m.createTable(feedConsumptionRecommendations);
        await _createPerformanceIndexes();
        await _seedFeedConsumptionRecommendations('system', DateTime.now());
      }
      if (from < 9) {
        await m.createTable(packagingItems);
        await m.createTable(packagingLots);
        await m.createTable(packagingStockMovements);
        await m.createTable(eggTrayBatches);
        await m.createTable(eggTrayStockMovements);
        await m.addColumn(sales, sales.trayBatchId);
        await m.addColumn(sales, sales.trayQuantity);
        await _createPerformanceIndexes();
      }
      if (from < 10) {
        await m.addColumn(eggTrayBatches, eggTrayBatches.trayUnitCostCents);
        await m.addColumn(eggTrayBatches, eggTrayBatches.labelUnitCostCents);
        await m.addColumn(eggTrayBatches, eggTrayBatches.eggUnitCostCents);
      }
      if (from < 11) {
        await m.addColumn(eggTrayBatches, eggTrayBatches.finalUnitPriceCents);
      }
      if (from < 12) {
        await m.addColumn(eggCollections, eggCollections.cleanEggs);
        await m.addColumn(eggCollections, eggCollections.dirtyEggs);
        await m.addColumn(eggCollections, eggCollections.crackedEggs);
        await customStatement('''
          UPDATE egg_collections
          SET
            clean_eggs = CASE
              WHEN quantity - broken_eggs - discarded_eggs > 0
              THEN quantity - broken_eggs - discarded_eggs
              ELSE 0
            END,
            dirty_eggs = 0,
            cracked_eggs = discarded_eggs
        ''');
      }
      if (from < 13) {
        await m.createTable(tenants);
        await m.addColumn(users, users.tenantId);
        await _ensureDefaultTenant();
        await _createPerformanceIndexes();
      }
    },
    beforeOpen: (_) async {
      await _ensureDefaultTenant();
      await _ensureInitialSuperAdminPermission();
    },
  );

  Future<void> _createPerformanceIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_bird_movements_lot_date ON bird_movements (lot_id, occurred_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_egg_collections_lot_date ON egg_collections (lot_id, collected_on)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_egg_stock_movements_date ON egg_stock_movements (occurred_at, type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_prices_ingredient_date ON ingredient_price_history (ingredient_id, effective_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ingredient_lots_fifo ON ingredient_lots (ingredient_id, entry_date, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ingredient_stock_lot_date ON ingredient_stock_movements (ingredient_lot_id, occurred_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_packaging_stock_lot_date ON packaging_stock_movements (lot_id, occurred_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_egg_tray_stock_batch_date ON egg_tray_stock_movements (batch_id, occurred_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_batches_phase_date ON feed_batches (phase, produced_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_feed_stock_batch_date ON feed_stock_movements (batch_id, occurred_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_feedings_lot_date ON daily_feedings (lot_id, feeding_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_feed_recommendations_age ON feed_consumption_recommendations (start_week, end_week)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_orders_status_date ON orders (status, requested_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_date ON sales (sold_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_finance_date_type ON finance_transactions (occurred_at, type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_events_date_type ON calendar_events (starts_at, type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_tenant ON users (tenant_id, is_active)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_audit_user_timestamp ON audit_logs (user_id, timestamp)',
    );
  }

  Future<void> _ensureDefaultTenant() async {
    await into(tenants).insert(
      TenantsCompanion.insert(
        id: defaultTenantId,
        name: defaultTenantName,
        createdAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> _ensureInitialSuperAdminPermission() async {
    final admin =
        await (select(users)
              ..where((u) => u.isSuperuser.equals(true))
              ..orderBy([(u) => OrderingTerm.asc(u.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (admin == null) return;
    final permissions = await permissionsOf(admin.id);
    if (permissions.contains('system.super_admin')) return;
    await into(userPermissions).insert(
      UserPermissionsCompanion.insert(
        id: const Uuid().v4(),
        userId: admin.id,
        permission: 'system.super_admin',
        createdAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> seedInitialData() async {
    await _seedOperationalDefaults('system');
  }

  Future<bool> hasUsers() async {
    final total = users.id.count();
    final count = await (selectOnly(
      users,
    )..addColumns([total])).map((row) => row.read(total) ?? 0).getSingle();
    return count > 0;
  }

  Future<void> seedDemoData(String actorId) async {
    for (final demo in const [
      ('LOTE 30', 30, 2600, 56, 7, 31),
      ('LOTE 4', 4, 1300, 5, 7, 2),
    ]) {
      final exists = await (select(
        lots,
      )..where((l) => l.name.equals(demo.$1))).getSingleOrNull();
      if (exists == null) {
        await registerLotPurchase(
          name: demo.$1,
          quantity: demo.$2,
          receivedAt: DateTime(2026, demo.$5, demo.$6),
          arrivalAgeDays: demo.$4,
          unitValueCents: demo.$3,
          actorId: actorId,
          notes: 'Dado opcional de demonstração',
        );
      }
    }
  }

  Future<void> _seedOperationalDefaults(String actorId) async {
    const ingredientSeeds = {
      'milho': 'Milho',
      'soja': 'Farelo de soja',
      'trigo': 'Farelo de trigo',
      'calcario': 'Calcário calcítico',
      'nucleo': 'Núcleo',
      'curcuma': 'Cúrcuma',
    };
    const recipes = <String, List<double>>{
      'CRIA': [63, 33, 0, 0, 4, 0],
      'RECRIA': [62, 20, 14, 0, 4, 0],
      'PRE_POSTURA': [62, 22, 7.5, 4, 4, .5],
      'PRODUCAO_I': [59.5, 23, 5, 8, 4, .5],
      'PRODUCAO_II': [60, 22.5, 5, 8, 4, .5],
      'PRODUCAO_III': [60.5, 22, 5, 8, 4, .5],
    };
    final now = DateTime.now();
    await transaction(() async {
      for (final entry in ingredientSeeds.entries) {
        await into(ingredients).insert(
          IngredientsCompanion.insert(
            id: 'ingredient-${entry.key}',
            name: entry.value,
            createdAt: now,
            createdBy: actorId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
      for (final recipe in recipes.entries) {
        final formulaId = 'formula-${recipe.key.toLowerCase()}-v1';
        await into(feedFormulas).insert(
          FeedFormulasCompanion.insert(
            id: formulaId,
            name: _defaultFeedFormulaName(recipe.key),
            phase: recipe.key,
            validFrom: DateTime(2026),
            createdBy: actorId,
            createdAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
        var index = 0;
        for (final ingredientId in ingredientSeeds.keys) {
          await into(feedFormulaItems).insert(
            FeedFormulaItemsCompanion.insert(
              id: '$formulaId-$ingredientId',
              formulaId: formulaId,
              ingredientId: 'ingredient-$ingredientId',
              baseQuantityKg: recipe.value[index++],
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
      await into(lightingPrograms).insert(
        LightingProgramsCompanion.insert(
          id: 'lighting-embrapa-051',
          name: 'Programa padrão Embrapa 051',
          description: const Value('Programa inicial editável para poedeiras.'),
          isDefault: const Value(true),
          createdBy: actorId,
          createdAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
      const steps = [
        (0, 0, 1440, 0, 'Primeiro dia: 24 horas de luz'),
        (1, 48, 720, -120, 'Redução progressiva até luz natural'),
        (49, 69, 720, 0, 'Luz natural'),
        (70, 125, 840, 0, 'Ajustar ao fotoperíodo local'),
        (126, null, 960, 30, 'Aumentar até 16 horas; máximo 30 min/semana'),
      ];
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        await into(lightingProgramSteps).insert(
          LightingProgramStepsCompanion.insert(
            id: 'lighting-embrapa-step-$i',
            programId: 'lighting-embrapa-051',
            startAgeDays: step.$1,
            endAgeDays: Value(step.$2),
            totalLightMinutes: step.$3,
            weeklyIncrementMinutes: Value(step.$4),
            notes: Value(step.$5),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
      await _seedFeedConsumptionRecommendations(actorId, now);
      for (final type in [
        'PHASE_CHANGE',
        'LIGHTING',
        'LOW_STOCK',
        'ORDER',
        'DELIVERY',
        'FEED',
        'LITTER_CHANGE',
        'SANITARY_TREATMENT',
        'VACCINATION',
      ]) {
        await into(notificationSettings).insert(
          NotificationSettingsCompanion.insert(
            id: 'notification-${type.toLowerCase()}',
            type: type,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
      await into(appSettings).insert(
        AppSettingsCompanion.insert(
          key: 'production_feed_grams_per_bird',
          value: '115',
          updatedAt: now,
          updatedBy: Value(actorId),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      await into(appSettings).insert(
        AppSettingsCompanion.insert(
          key: 'projected_laying_rate',
          value: '0.87',
          updatedAt: now,
          updatedBy: Value(actorId),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> _seedFeedConsumptionRecommendations(
    String actorId,
    DateTime now,
  ) async {
    const recommendations = [
      (0, 0, 12.0, 'CRIA'),
      (1, 1, 18.0, 'CRIA'),
      (2, 2, 24.0, 'CRIA'),
      (3, 3, 30.0, 'CRIA'),
      (4, 4, 36.0, 'CRIA'),
      (5, 5, 42.0, 'CRIA'),
      (6, 6, 48.0, 'CRIA'),
      (7, 7, 54.0, 'RECRIA'),
      (8, 8, 60.0, 'RECRIA'),
      (9, 9, 65.0, 'RECRIA'),
      (10, 10, 70.0, 'RECRIA'),
      (11, 11, 75.0, 'RECRIA'),
      (12, 12, 80.0, 'RECRIA'),
      (13, 13, 85.0, 'RECRIA'),
      (14, 14, 90.0, 'RECRIA'),
      (15, 15, 95.0, 'RECRIA'),
      (16, 16, 100.0, 'PRE_POSTURA'),
      (17, 17, 105.0, 'PRE_POSTURA'),
      (18, 18, 110.0, 'PRE_POSTURA'),
      (19, 19, 112.0, 'PRODUCAO_I'),
      (20, 20, 114.0, 'PRODUCAO_I'),
      (21, 21, 116.0, 'PRODUCAO_I'),
      (22, 22, 118.0, 'PRODUCAO_I'),
      (23, 23, 120.0, 'PRODUCAO_I'),
      (24, 24, 122.0, 'PRODUCAO_I'),
      (25, null, 125.0, 'PRODUCAO_II'),
    ];
    for (final item in recommendations) {
      await into(feedConsumptionRecommendations).insert(
        FeedConsumptionRecommendationsCompanion.insert(
          id: 'feed-consumption-${item.$1}-${item.$2 ?? 'plus'}',
          startWeek: item.$1,
          endWeek: Value(item.$2),
          gramsPerBirdDay: item.$3,
          phase: Value(item.$4),
          source: const Value('Tabela padrão editável'),
          createdBy: actorId,
          createdAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  String _defaultFeedFormulaName(String phase) => switch (phase) {
    'CRIA' => 'Cria',
    'RECRIA' => 'Recria',
    'PRE_POSTURA' => 'Pré-postura',
    'PRODUCAO_I' => 'Produção I',
    'PRODUCAO_II' => 'Produção II',
    'PRODUCAO_III' => 'Produção III',
    _ => phase,
  };

  Future<User?> authenticate(String username, String password) async {
    final user = await (select(
      users,
    )..where((u) => u.username.equals(username.trim()))).getSingleOrNull();
    if (user == null ||
        !user.isActive ||
        !PasswordHasher.verify(password, user.passwordHash)) {
      return null;
    }
    final now = DateTime.now();
    await (update(users)..where((u) => u.id.equals(user.id))).write(
      UsersCompanion(lastLoginAt: Value(now), updatedAt: Value(now)),
    );
    await addAudit(
      userId: user.id,
      action: 'auth.login',
      entityType: 'user',
      entityId: user.id,
      description: 'Entrada no sistema realizada.',
    );
    return (select(users)..where((u) => u.id.equals(user.id))).getSingle();
  }

  Future<User?> userByUsername(String username) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty) return null;
    return (select(
      users,
    )..where((u) => u.username.equals(normalizedUsername))).getSingleOrNull();
  }

  Future<User?> userById(String userId) async {
    if (userId.trim().isEmpty) return null;
    return (select(users)..where((u) => u.id.equals(userId))).getSingleOrNull();
  }

  Stream<List<Tenant>> watchTenants({bool includeInactive = false}) {
    final query = select(tenants)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeInactive) query.where((t) => t.isActive.equals(true));
    return query.watch();
  }

  Future<Tenant?> tenantById(String tenantId) async {
    if (tenantId.trim().isEmpty) return null;
    return (select(
      tenants,
    )..where((t) => t.id.equals(tenantId))).getSingleOrNull();
  }

  Future<String> tenantNameFor(String tenantId) async {
    final tenant = await tenantById(tenantId);
    return tenant?.name ?? defaultTenantName;
  }

  Future<String> tenantIdForUser(String userId) async {
    final user = await userById(userId);
    return user?.tenantId ?? defaultTenantId;
  }

  Future<bool> _isSuperAdminActor(String actorId) async {
    final permissions = await permissionsOf(actorId);
    return permissions.contains('system.super_admin');
  }

  Future<void> _assertSuperAdminActor(String actorId) async {
    if (!await _isSuperAdminActor(actorId)) {
      throw StateError(
        'Apenas o Super Admin pode gerenciar todas as parcerias.',
      );
    }
  }

  Future<void> _assertActorCanManageUser({
    required String targetUserId,
    required String actorId,
  }) async {
    if (targetUserId == actorId) return;
    final target = await userById(targetUserId);
    final actor = await userById(actorId);
    if (target == null || actor == null) return;
    if (target.tenantId == actor.tenantId) return;
    await _assertSuperAdminActor(actorId);
  }

  Future<void> _assertGrantablePermissions({
    required String actorId,
    required Iterable<String> permissions,
  }) async {
    if (!permissions.any(_globalUserPermissions.contains)) return;
    await _assertSuperAdminActor(actorId);
  }

  Future<void> createTenant({
    required String name,
    required String actorId,
  }) async {
    await _assertSuperAdminActor(actorId);
    final cleanName = name.trim();
    if (cleanName.length < 3) {
      throw ArgumentError(
        'Informe um nome de parceria com ao menos 3 caracteres.',
      );
    }
    final now = DateTime.now();
    final id = const Uuid().v4();
    await transaction(() async {
      await into(tenants).insert(
        TenantsCompanion.insert(
          id: id,
          name: cleanName,
          createdAt: now,
          createdBy: Value(actorId),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'tenants.create',
        entityType: 'tenant',
        entityId: id,
        description: 'Parceria $cleanName criada.',
      );
    });
  }

  Stream<List<User>> watchUsers({String? tenantId}) {
    final query = select(users)
      ..orderBy([(u) => OrderingTerm.asc(u.displayName)]);
    if (tenantId != null) query.where((u) => u.tenantId.equals(tenantId));
    return query.watch();
  }

  Future<List<String>> permissionsOf(String userId) async => (select(
    userPermissions,
  )..where((p) => p.userId.equals(userId))).map((p) => p.permission).get();

  Future<void> createUser({
    required String username,
    required String displayName,
    required String password,
    required bool isSuperuser,
    required List<String> permissions,
    required String actorId,
    String? tenantId,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.length < 3 ||
        displayName.trim().isEmpty ||
        password.length < 8) {
      throw ArgumentError(
        'Preencha os campos e use uma senha de ao menos 8 caracteres.',
      );
    }
    final now = DateTime.now();
    final id = const Uuid().v4();
    final resolvedTenantId = tenantId ?? await tenantIdForUser(actorId);
    if (resolvedTenantId != await tenantIdForUser(actorId)) {
      await _assertSuperAdminActor(actorId);
    }
    await _assertGrantablePermissions(
      actorId: actorId,
      permissions: permissions,
    );
    final tenant = await tenantById(resolvedTenantId);
    if (tenant == null || !tenant.isActive) {
      throw ArgumentError('Selecione uma parceria ativa para o usuário.');
    }
    await transaction(() async {
      await into(users).insert(
        UsersCompanion.insert(
          id: id,
          tenantId: Value(resolvedTenantId),
          username: normalizedUsername,
          displayName: displayName.trim(),
          passwordHash: PasswordHasher.hash(password),
          isSuperuser: Value(isSuperuser),
          createdAt: now,
          updatedAt: now,
        ),
      );
      for (final permission in permissions.toSet()) {
        await into(userPermissions).insert(
          UserPermissionsCompanion.insert(
            id: const Uuid().v4(),
            userId: id,
            permission: permission,
            createdAt: now,
          ),
        );
      }
      await addAudit(
        userId: actorId,
        action: 'users.create',
        entityType: 'user',
        entityId: id,
        description: 'Usuário $normalizedUsername criado.',
      );
    });
  }

  Future<User> createFirstAdminAccount({
    required String username,
    required String displayName,
    required String password,
  }) async {
    if (await hasUsers()) {
      throw StateError('A primeira conta já foi criada.');
    }
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.length < 3 ||
        displayName.trim().isEmpty ||
        password.length < 8) {
      throw ArgumentError(
        'Preencha os campos e use uma senha de ao menos 8 caracteres.',
      );
    }
    final now = DateTime.now();
    final id = const Uuid().v4();
    await transaction(() async {
      await into(users).insert(
        UsersCompanion.insert(
          id: id,
          tenantId: const Value(defaultTenantId),
          username: normalizedUsername,
          displayName: displayName.trim(),
          passwordHash: PasswordHasher.hash(password),
          isSuperuser: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await into(userPermissions).insert(
        UserPermissionsCompanion.insert(
          id: const Uuid().v4(),
          userId: id,
          permission: '*',
          createdAt: now,
        ),
      );
      await into(userPermissions).insert(
        UserPermissionsCompanion.insert(
          id: const Uuid().v4(),
          userId: id,
          permission: 'system.super_admin',
          createdAt: now,
        ),
      );
      await addAudit(
        userId: id,
        action: 'users.first_admin',
        entityType: 'user',
        entityId: id,
        description: 'Primeira conta administradora criada.',
      );
    });
    return (select(users)..where((u) => u.id.equals(id))).getSingle();
  }

  Future<User> createSelfServiceAccount({
    required String username,
    required String displayName,
    required String password,
  }) async {
    if (!await hasUsers()) {
      return createFirstAdminAccount(
        username: username,
        displayName: displayName,
        password: password,
      );
    }
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.length < 3 ||
        displayName.trim().isEmpty ||
        password.length < 8) {
      throw ArgumentError(
        'Preencha os campos e use uma senha de ao menos 8 caracteres.',
      );
    }
    if (await userByUsername(normalizedUsername) != null) {
      throw ArgumentError(
        'Esse usuário já existe. Escolha outro nome de usuário ou volte para o login.',
      );
    }
    final now = DateTime.now();
    final id = const Uuid().v4();
    await transaction(() async {
      await into(users).insert(
        UsersCompanion.insert(
          id: id,
          tenantId: const Value(defaultTenantId),
          username: normalizedUsername,
          displayName: displayName.trim(),
          passwordHash: PasswordHasher.hash(password),
          isSuperuser: const Value(false),
          isActive: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await addAudit(
        action: 'users.self_register',
        entityType: 'user',
        entityId: id,
        description:
            'Conta $normalizedUsername criada pelo login e aguardando ativação.',
      );
    });
    return (select(users)..where((u) => u.id.equals(id))).getSingle();
  }

  Future<void> setUserActive({
    required String userId,
    required bool isActive,
    required String actorId,
  }) async {
    await _assertActorCanManageUser(targetUserId: userId, actorId: actorId);
    await (update(users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await addAudit(
      userId: actorId,
      action: 'users.update',
      entityType: 'user',
      entityId: userId,
      description: isActive ? 'Usuário ativado.' : 'Usuário desativado.',
    );
  }

  Future<void> updateUserProfile({
    required String userId,
    required String username,
    required String displayName,
    required bool isActive,
    required String actorId,
    String? tenantId,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.length < 3 || displayName.trim().isEmpty) {
      throw ArgumentError('Informe nome e usuário com ao menos 3 caracteres.');
    }
    final existing = await userByUsername(normalizedUsername);
    if (existing != null && existing.id != userId) {
      throw ArgumentError('Esse nome de usuário já está em uso.');
    }
    await _assertActorCanManageUser(targetUserId: userId, actorId: actorId);
    if (tenantId != null && tenantId != await tenantIdForUser(userId)) {
      await _assertSuperAdminActor(actorId);
    }
    final tenantValue = tenantId == null ? null : await tenantById(tenantId);
    if (tenantId != null && (tenantValue == null || !tenantValue.isActive)) {
      throw ArgumentError('Selecione uma parceria ativa para o usuário.');
    }
    await (update(users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        username: Value(normalizedUsername),
        displayName: Value(displayName.trim()),
        isActive: Value(isActive),
        tenantId: tenantId == null ? const Value.absent() : Value(tenantId),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await addAudit(
      userId: actorId,
      action: 'users.update',
      entityType: 'user',
      entityId: userId,
      description: 'Dados do usuário $normalizedUsername atualizados.',
    );
  }

  Future<void> resetUserPassword({
    required String userId,
    required String password,
    required String actorId,
  }) async {
    await _assertActorCanManageUser(targetUserId: userId, actorId: actorId);
    if (password.length < 8) {
      throw ArgumentError('A senha deve possuir ao menos 8 caracteres.');
    }
    await (update(users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        passwordHash: Value(PasswordHasher.hash(password)),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await addAudit(
      userId: actorId,
      action: 'users.update',
      entityType: 'user',
      entityId: userId,
      description: 'Senha do usuário redefinida.',
    );
  }

  Future<void> replaceUserPermissions({
    required String userId,
    required List<String> permissions,
    required String actorId,
  }) async {
    await _assertActorCanManageUser(targetUserId: userId, actorId: actorId);
    await _assertGrantablePermissions(
      actorId: actorId,
      permissions: permissions,
    );
    await transaction(() async {
      await (delete(
        userPermissions,
      )..where((p) => p.userId.equals(userId))).go();
      for (final permission in permissions.toSet()) {
        await into(userPermissions).insert(
          UserPermissionsCompanion.insert(
            id: const Uuid().v4(),
            userId: userId,
            permission: permission,
            createdAt: DateTime.now(),
          ),
        );
      }
      await addAudit(
        userId: actorId,
        action: 'users.permissions',
        entityType: 'user',
        entityId: userId,
        description: 'Permissões do usuário atualizadas.',
      );
    });
  }

  Future<void> addAudit({
    String? userId,
    required String action,
    required String entityType,
    String? entityId,
    required String description,
    String? metadata,
  }) => into(auditLogs).insert(
    AuditLogsCompanion.insert(
      id: const Uuid().v4(),
      userId: Value(userId),
      action: action,
      entityType: entityType,
      entityId: Value(entityId),
      timestamp: DateTime.now(),
      description: description,
      metadata: Value(metadata),
    ),
  );

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
    final actorTenantId = await tenantIdForUser(actorId);
    final ownerTenantId = await tenantIdForUser(ownerId);
    if (ownerTenantId != actorTenantId) {
      throw StateError('Este registro pertence a outra parceria.');
    }
  }

  Stream<List<LotSummary>> watchLotSummaries({String? tenantId}) {
    final query = customSelect(
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
    );
    return query.watch().map(
      (rows) => rows
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
          .toList(),
    );
  }

  Future<String> registerLotPurchase({
    required String name,
    String? strain,
    required int quantity,
    required DateTime receivedAt,
    required int arrivalAgeDays,
    int? unitValueCents,
    String? supplier,
    String? notes,
    required String actorId,
  }) async {
    final normalizedName = name.trim().toUpperCase();
    if (normalizedName.isEmpty || quantity <= 0 || arrivalAgeDays < 0) {
      throw ArgumentError(
        'Informe um lote, quantidade válida e idade não negativa.',
      );
    }
    if (unitValueCents != null && unitValueCents < 0) {
      throw ArgumentError('O valor unitário não pode ser negativo.');
    }
    final now = DateTime.now();
    final lotId = const Uuid().v4();
    final total = unitValueCents == null ? null : unitValueCents * quantity;
    await transaction(() async {
      await into(lots).insert(
        LotsCompanion.insert(
          id: lotId,
          name: normalizedName,
          strain: Value(_clean(strain)),
          initialQuantity: quantity,
          receivedAt: receivedAt,
          arrivalAgeDays: arrivalAgeDays,
          unitValueCents: Value(unitValueCents),
          supplier: Value(_clean(supplier)),
          notes: Value(_clean(notes)),
          createdAt: now,
          createdBy: actorId,
        ),
      );
      await into(birdMovements).insert(
        BirdMovementsCompanion.insert(
          id: const Uuid().v4(),
          type: 'PURCHASE',
          occurredAt: receivedAt,
          lotId: lotId,
          quantity: quantity,
          unitValueCents: Value(unitValueCents),
          totalValueCents: Value(total),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      if (total != null && total > 0) {
        await into(financeTransactions).insert(
          FinanceTransactionsCompanion.insert(
            id: const Uuid().v4(),
            occurredAt: receivedAt,
            type: 'EXPENSE',
            category: 'Aves',
            description: 'Compra de $quantity aves — $normalizedName',
            amountCents: total,
            referenceType: const Value('LOT_PURCHASE'),
            referenceId: Value(lotId),
            createdBy: actorId,
            createdAt: now,
          ),
        );
      }
      await addAudit(
        userId: actorId,
        action: 'birds.purchase',
        entityType: 'lot',
        entityId: lotId,
        description: 'Lote $normalizedName cadastrado com $quantity aves.',
      );
    });
    return lotId;
  }

  Future<void> registerBirdOutflow({
    required String lotId,
    required String type,
    required int quantity,
    required DateTime occurredAt,
    required String actorId,
    int? unitValueCents,
    String? notes,
  }) async {
    if (!{
          'SALE',
          'MORTALITY',
          'ADJUSTMENT_OUT',
          'ADJUSTMENT_IN',
        }.contains(type) ||
        quantity <= 0) {
      throw ArgumentError('Movimentação de saída inválida.');
    }
    await _assertActorCanUseRecord(
      tableName: 'lots',
      recordId: lotId,
      actorId: actorId,
    );
    final now = DateTime.now();
    await transaction(() async {
      final activeBirds = await activeBirdsFor(lotId);
      if (type != 'ADJUSTMENT_IN' && quantity > activeBirds) {
        throw StateError(
          'A quantidade informada excede o saldo atual do lote ($activeBirds aves).',
        );
      }
      await into(birdMovements).insert(
        BirdMovementsCompanion.insert(
          id: const Uuid().v4(),
          type: type,
          occurredAt: occurredAt,
          lotId: lotId,
          quantity: quantity,
          unitValueCents: Value(unitValueCents),
          totalValueCents: Value(
            unitValueCents == null ? null : unitValueCents * quantity,
          ),
          notes: Value(_clean(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      final total = unitValueCents == null ? null : unitValueCents * quantity;
      if (type == 'SALE' && total != null && total > 0) {
        await into(financeTransactions).insert(
          FinanceTransactionsCompanion.insert(
            id: const Uuid().v4(),
            occurredAt: occurredAt,
            type: 'INCOME',
            category: 'Venda de aves',
            description: 'Venda de $quantity aves',
            amountCents: total,
            referenceType: const Value('BIRD_SALE'),
            referenceId: Value(lotId),
            createdBy: actorId,
            createdAt: now,
          ),
        );
      }
      await addAudit(
        userId: actorId,
        action: type == 'MORTALITY'
            ? 'birds.mortality'
            : 'birds.${type.toLowerCase()}',
        entityType: 'bird_movement',
        description:
            '$quantity aves registradas como ${type == 'MORTALITY' ? 'mortalidade' : 'saída'}.',
      );
    });
  }

  Future<void> updateLotDetails({
    required String lotId,
    required String name,
    String? strain,
    String? supplier,
    String? notes,
    required String status,
    required String actorId,
  }) async {
    if (name.trim().isEmpty || !{'ACTIVE', 'INACTIVE'}.contains(status)) {
      throw ArgumentError('Revise os dados do lote.');
    }
    await _assertActorCanUseRecord(
      tableName: 'lots',
      recordId: lotId,
      actorId: actorId,
    );
    await transaction(() async {
      await (update(lots)..where((l) => l.id.equals(lotId))).write(
        LotsCompanion(
          name: Value(name.trim().toUpperCase()),
          strain: Value(_clean(strain)),
          supplier: Value(_clean(supplier)),
          notes: Value(_clean(notes)),
          status: Value(status),
        ),
      );
      await addAudit(
        userId: actorId,
        action: 'lots.update',
        entityType: 'lot',
        entityId: lotId,
        description: 'Dados do lote ${name.trim().toUpperCase()} atualizados.',
      );
    });
  }

  Future<int> activeBirdsFor(String lotId) async {
    final row = await customSelect(
      '''SELECT COALESCE(SUM(CASE WHEN type IN ('PURCHASE', 'TRANSFER_IN', 'ADJUSTMENT_IN')
          THEN quantity ELSE -quantity END), 0) AS active_birds
         FROM bird_movements WHERE lot_id = ?''',
      variables: [Variable.withString(lotId)],
      readsFrom: {birdMovements},
    ).getSingle();
    return row.read<int>('active_birds');
  }

  Future<int> activeBirdsForDate(String lotId, DateTime date) async {
    final dayAfter = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(const Duration(days: 1));
    final row = await customSelect(
      '''SELECT COALESCE(SUM(CASE WHEN type IN ('PURCHASE', 'TRANSFER_IN', 'ADJUSTMENT_IN')
          THEN quantity ELSE -quantity END), 0) AS active_birds
         FROM bird_movements WHERE lot_id = ? AND occurred_at < ?''',
      variables: [Variable.withString(lotId), Variable.withDateTime(dayAfter)],
      readsFrom: {birdMovements},
    ).getSingle();
    return row.read<int>('active_birds');
  }

  Stream<EggMetrics> watchEggMetrics({String? tenantId}) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    final startOfMonth = DateTime(today.year, today.month);
    final query = customSelect(
      '''
      SELECT
        COALESCE((SELECT SUM(quantity - broken_eggs - discarded_eggs)
          FROM egg_collections WHERE collected_on >= ? AND collected_on < ?
            AND ${_tenantSql('egg_collections', tenantId)}), 0) AS eggs_today,
        COALESCE((SELECT SUM(quantity - broken_eggs - discarded_eggs)
          FROM egg_collections WHERE collected_on >= ?
            AND ${_tenantSql('egg_collections', tenantId)}), 0) AS eggs_month,
        COALESCE((SELECT SUM(CASE WHEN type IN ('COLLECTION_IN', 'ADJUSTMENT_IN')
          THEN quantity ELSE -quantity END) FROM egg_stock_movements
          WHERE ${_tenantSql('egg_stock_movements', tenantId)}), 0) AS stock
      ''',
      variables: [
        Variable.withDateTime(startOfToday),
        Variable.withDateTime(startOfTomorrow),
        ..._tenantVariables(tenantId),
        Variable.withDateTime(startOfMonth),
        ..._tenantVariables(tenantId),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {eggCollections, eggStockMovements},
    );
    return query.watchSingle().map(
      (row) => EggMetrics(
        eggsToday: row.read<int>('eggs_today'),
        eggsThisMonth: row.read<int>('eggs_month'),
        stock: row.read<int>('stock'),
      ),
    );
  }

  Stream<List<EggCollection>> watchRecentEggCollections({
    int limit = 30,
    String? tenantId,
  }) {
    final query = select(eggCollections)
      ..orderBy([(item) => OrderingTerm.desc(item.collectedOn)])
      ..limit(limit);
    if (tenantId != null) {
      query.where((item) => _tenantExpression(item.createdBy, tenantId));
    }
    return query.watch();
  }

  Stream<List<LayingRateHistoryEntry>> watchDailyLayingRates({
    int days = 60,
    String? tenantId,
  }) {
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days));
    final query = customSelect(
      '''
      SELECT
        e.lot_id,
        l.name AS lot_name,
        MIN(e.collected_on) AS period_start,
        SUM(e.quantity) AS total_eggs,
        SUM(e.quantity - e.broken_eggs - e.discarded_eggs) AS stock_eggs,
        SUM(e.broken_eggs + e.discarded_eggs) AS lost_eggs,
        COALESCE((
          SELECT SUM(CASE WHEN m.type IN ('PURCHASE', 'TRANSFER_IN', 'ADJUSTMENT_IN')
            THEN m.quantity ELSE -m.quantity END)
          FROM bird_movements m
          WHERE m.lot_id = e.lot_id
            AND date(m.occurred_at, 'unixepoch') <= date(e.collected_on, 'unixepoch')
        ), 0) AS active_bird_days,
        1 AS collection_days
      FROM egg_collections e
      INNER JOIN lots l ON l.id = e.lot_id
      WHERE e.collected_on >= ? AND ${_tenantSql('e', tenantId)}
      GROUP BY e.lot_id, date(e.collected_on, 'unixepoch')
      ORDER BY period_start DESC, l.name
      ''',
      variables: [Variable.withDateTime(start), ..._tenantVariables(tenantId)],
      readsFrom: {eggCollections, lots, birdMovements},
    );
    return query.watch().map(_mapLayingRateRows);
  }

  Stream<List<LayingRateHistoryEntry>> watchMonthlyLayingRates({
    int months = 12,
    DateTime? start,
    DateTime? end,
    String? tenantId,
  }) {
    final today = DateTime.now();
    final startDate = start ?? DateTime(today.year, today.month - months + 1);
    final endDate = end ?? today.add(const Duration(days: 1));
    final query = customSelect(
      '''
      WITH daily_rates AS (
        SELECT
          e.lot_id,
          l.name AS lot_name,
          MIN(e.collected_on) AS period_start,
          date(e.collected_on, 'unixepoch') AS collected_day,
          SUM(e.quantity) AS total_eggs,
          SUM(e.quantity - e.broken_eggs - e.discarded_eggs) AS stock_eggs,
          SUM(e.broken_eggs + e.discarded_eggs) AS lost_eggs,
          COALESCE((
            SELECT SUM(CASE WHEN m.type IN ('PURCHASE', 'TRANSFER_IN', 'ADJUSTMENT_IN')
              THEN m.quantity ELSE -m.quantity END)
            FROM bird_movements m
            WHERE m.lot_id = e.lot_id
              AND date(m.occurred_at, 'unixepoch') <= date(e.collected_on, 'unixepoch')
          ), 0) AS active_birds
        FROM egg_collections e
        INNER JOIN lots l ON l.id = e.lot_id
        WHERE e.collected_on >= ? AND e.collected_on < ?
          AND ${_tenantSql('e', tenantId)}
        GROUP BY e.lot_id, date(e.collected_on, 'unixepoch')
      )
      SELECT
        lot_id,
        lot_name,
        MIN(period_start) AS period_start,
        SUM(total_eggs) AS total_eggs,
        SUM(stock_eggs) AS stock_eggs,
        SUM(lost_eggs) AS lost_eggs,
        SUM(active_birds) AS active_bird_days,
        COUNT(*) AS collection_days
      FROM daily_rates
      GROUP BY lot_id, strftime('%Y-%m', collected_day)
      ORDER BY period_start DESC, lot_name
      ''',
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
        ..._tenantVariables(tenantId),
      ],
      readsFrom: {eggCollections, lots, birdMovements},
    );
    return query.watch().map(_mapLayingRateRows);
  }

  Future<void> registerEggCollection({
    required DateTime collectedOn,
    required String lotId,
    required int quantity,
    int? cleanEggs,
    int? dirtyEggs,
    int? crackedEggs,
    required int brokenEggs,
    required int discardedEggs,
    String? notes,
    required String actorId,
  }) async {
    final resolvedCleanEggs =
        cleanEggs ?? (quantity - brokenEggs - discardedEggs);
    final resolvedDirtyEggs = dirtyEggs ?? 0;
    final resolvedCrackedEggs = crackedEggs ?? discardedEggs;
    final resolvedDiscardedEggs = resolvedCrackedEggs;
    final calculatedTotal =
        resolvedCleanEggs +
        resolvedDirtyEggs +
        resolvedCrackedEggs +
        brokenEggs;
    if (quantity <= 0 ||
        resolvedCleanEggs < 0 ||
        resolvedDirtyEggs < 0 ||
        resolvedCrackedEggs < 0 ||
        brokenEggs < 0 ||
        discardedEggs < 0 ||
        calculatedTotal != quantity ||
        brokenEggs + resolvedDiscardedEggs > quantity) {
      throw ArgumentError('Revise as quantidades da coleta.');
    }
    await _assertActorCanUseRecord(
      tableName: 'lots',
      recordId: lotId,
      actorId: actorId,
    );
    final collectionDay = DateTime(
      collectedOn.year,
      collectedOn.month,
      collectedOn.day,
    );
    if (await activeBirdsForDate(lotId, collectionDay) <= 0) {
      throw StateError('Selecione um lote ativo para registrar a coleta.');
    }
    final now = DateTime.now();
    final collectionId = const Uuid().v4();
    final validEggs = resolvedCleanEggs + resolvedDirtyEggs;
    await transaction(() async {
      await into(eggCollections).insert(
        EggCollectionsCompanion.insert(
          id: collectionId,
          collectedOn: collectionDay,
          lotId: lotId,
          quantity: quantity,
          cleanEggs: Value(resolvedCleanEggs),
          dirtyEggs: Value(resolvedDirtyEggs),
          crackedEggs: Value(resolvedCrackedEggs),
          brokenEggs: Value(brokenEggs),
          discardedEggs: Value(resolvedDiscardedEggs),
          notes: Value(_clean(notes)),
          createdBy: actorId,
          createdAt: now,
        ),
      );
      if (validEggs > 0) {
        await into(eggStockMovements).insert(
          EggStockMovementsCompanion.insert(
            id: const Uuid().v4(),
            type: 'COLLECTION_IN',
            occurredAt: now,
            quantity: validEggs,
            collectionId: Value(collectionId),
            createdBy: actorId,
            createdAt: now,
          ),
        );
      }
      await addAudit(
        userId: actorId,
        action: 'egg_collection.create',
        entityType: 'egg_collection',
        entityId: collectionId,
        description:
            'Coleta de $quantity ovos registrada; $validEggs aptos para estoque.',
      );
    });
  }

  List<LayingRateHistoryEntry> _mapLayingRateRows(List<QueryRow> rows) => rows
      .map(
        (row) => LayingRateHistoryEntry(
          lotId: row.read<String>('lot_id'),
          lotName: row.read<String>('lot_name'),
          periodStart: row.read<DateTime>('period_start'),
          totalEggs: row.read<int>('total_eggs'),
          stockEggs: row.read<int>('stock_eggs'),
          lostEggs: row.read<int>('lost_eggs'),
          activeBirdDays: row.read<int>('active_bird_days'),
          collectionDays: row.read<int>('collection_days'),
        ),
      )
      .toList();

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

final databaseProvider = Provider<AppDatabase>(
  (_) => throw UnimplementedError('Banco não inicializado'),
);
