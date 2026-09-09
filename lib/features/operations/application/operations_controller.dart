import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/operational_data_import.dart';
import '../../../core/database/operations_repository.dart';
import '../../../core/platform/alert_scheduler.dart';
import '../../../core/platform/notification_service.dart';
import '../../auth/application/auth_controller.dart';

String? _tenantScope(Ref ref) {
  final session = ref.watch(authControllerProvider).session;
  return session?.allows('tenant.view_all') == true ? null : session?.tenantId;
}

final ingredientsProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchIngredientOverviews(tenantId: _tenantScope(ref)),
);
final ingredientLotsProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchIngredientLotBalances(tenantId: _tenantScope(ref)),
);
final formulasProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchFormulaOverviews(tenantId: _tenantScope(ref)),
);
final feedBatchesProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchFeedBatchBalances(tenantId: _tenantScope(ref)),
);
final feedingsProvider = StreamProvider(
  (ref) =>
      ref.watch(databaseProvider).watchFeedings(tenantId: _tenantScope(ref)),
);
final feedRecommendationsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchFeedConsumptionRecommendations(),
);
final customersProvider = StreamProvider(
  (ref) =>
      ref.watch(databaseProvider).watchCustomers(tenantId: _tenantScope(ref)),
);
final ordersProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchOrders(tenantId: _tenantScope(ref)),
);
final salesProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchSales(tenantId: _tenantScope(ref)),
);
final packagingItemsProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchPackagingItemStocks(tenantId: _tenantScope(ref)),
);
final packagingLotsProvider =
    StreamProvider.family<List<PackagingLotBalance>, String?>(
      (ref, type) => ref
          .watch(databaseProvider)
          .watchPackagingLotBalances(type: type, tenantId: _tenantScope(ref)),
    );
final eggTrayBatchesProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchEggTrayBatchBalances(tenantId: _tenantScope(ref)),
);
final estimatedEggUnitCostProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchEstimatedEggUnitCostCents(tenantId: _tenantScope(ref)),
);
final financeProvider = StreamProvider(
  (ref) =>
      ref.watch(databaseProvider).watchFinance(tenantId: _tenantScope(ref)),
);
final financeMetricsProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchFinanceMetrics(tenantId: _tenantScope(ref)),
);
final investmentsProvider = StreamProvider(
  (ref) =>
      ref.watch(databaseProvider).watchInvestments(tenantId: _tenantScope(ref)),
);
final eggStockProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchEggStockMetrics(tenantId: _tenantScope(ref)),
);
final lightingProgramsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchLightingPrograms(),
);
final notificationSettingsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchNotificationSettings(),
);
final appSettingsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchAppSettings(),
);
final auditLogsProvider = StreamProvider(
  (ref) =>
      ref.watch(databaseProvider).watchAuditLogs(tenantId: _tenantScope(ref)),
);
final birdMovementsProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchBirdMovementOverviews(tenantId: _tenantScope(ref)),
);
final birdMetricsProvider = StreamProvider(
  (ref) =>
      ref.watch(databaseProvider).watchBirdMetrics(tenantId: _tenantScope(ref)),
);
final dashboardMetricsProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchDashboardMetrics(tenantId: _tenantScope(ref)),
);
final eggProductionSeriesProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchEggProductionSeries(tenantId: _tenantScope(ref)),
);
final eggProductionSeriesRangeProvider =
    StreamProvider.family<List<ReportPoint>, ({DateTime start, DateTime end})>(
      (ref, range) => ref
          .watch(databaseProvider)
          .watchEggProductionSeries(
            start: range.start,
            end: range.end,
            tenantId: _tenantScope(ref),
          ),
    );
final financeSeriesProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .watchFinanceSeries(tenantId: _tenantScope(ref)),
);
final financeSeriesRangeProvider =
    StreamProvider.family<List<ReportPoint>, ({DateTime start, DateTime end})>(
      (ref, range) => ref
          .watch(databaseProvider)
          .watchFinanceSeries(
            start: range.start,
            end: range.end,
            tenantId: _tenantScope(ref),
          ),
    );
final calendarEventsProvider =
    StreamProvider.family<
      List<CalendarEvent>,
      ({DateTime first, DateTime last})
    >(
      (ref, range) => ref
          .watch(databaseProvider)
          .watchCalendarEvents(
            range.first,
            range.last,
            tenantId: _tenantScope(ref),
          ),
    );
final calendarAlertEventsProvider =
    StreamProvider.family<
      List<CalendarEvent>,
      ({DateTime first, DateTime last})
    >(
      (ref, range) => ref
          .watch(databaseProvider)
          .watchCalendarAlertEvents(
            range.first,
            range.last,
            tenantId: _tenantScope(ref),
          ),
    );
final lightingStepsProvider =
    StreamProvider.family<List<LightingProgramStep>, String>(
      (ref, id) => ref.watch(databaseProvider).watchLightingSteps(id),
    );

class OperationsController {
  OperationsController(this.ref);
  final Ref ref;

  AppDatabase get _db => ref.read(databaseProvider);
  String _actor(String permission) {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows(permission)) {
      throw StateError('Você não tem permissão para realizar esta operação.');
    }
    return session.userId;
  }

  Future<void> addIngredient(String name, String unit, String? notes) =>
      _db.addIngredient(
        name: name,
        unit: unit,
        notes: notes,
        actorId: _actor('ingredients.manage'),
      );
  Future<void> updateIngredient({
    required String ingredientId,
    required String name,
    required String unit,
    required bool isActive,
    String? notes,
  }) => _db.updateIngredient(
    ingredientId: ingredientId,
    name: name,
    unit: unit,
    isActive: isActive,
    notes: notes,
    actorId: _actor('ingredients.manage'),
  );
  Future<void> addPrice(
    String ingredientId,
    int cents,
    DateTime date,
    String? supplier,
    String? notes,
  ) => _db.registerIngredientPrice(
    ingredientId: ingredientId,
    priceCents: cents,
    effectiveDate: date,
    supplier: supplier,
    notes: notes,
    actorId: _actor('ingredients.price_register'),
  );
  Future<void> addIngredientEntry({
    required String ingredientId,
    required DateTime entryDate,
    required String packageUnit,
    required double packageQuantity,
    required double packageWeightKg,
    required int totalCost,
    String? supplier,
    String? notes,
  }) => _db.registerIngredientStockEntry(
    ingredientId: ingredientId,
    entryDate: entryDate,
    packageUnit: packageUnit,
    packageQuantity: packageQuantity,
    packageWeightKg: packageWeightKg,
    totalCostCents: totalCost,
    supplier: supplier,
    notes: notes,
    actorId: _actor('ingredients.manage'),
  );
  Future<void> correctIngredientLot({
    required String ingredientLotId,
    required double quantityKg,
    required bool input,
    String? notes,
  }) => _db.adjustIngredientLotStock(
    ingredientLotId: ingredientLotId,
    quantityKg: quantityKg,
    input: input,
    notes: notes,
    actorId: _actor('ingredients.manage'),
  );
  Future<void> manufacture(
    FormulaOverview formula,
    double kg,
    DateTime date,
    String? notes,
  ) => _db.manufactureFeed(
    formula: formula,
    quantityKg: kg,
    date: date,
    notes: notes,
    actorId: _actor('feed_batches.create'),
  );
  Future<void> addReadyFeed({
    required String name,
    required String phase,
    required double quantityKg,
    required int totalCost,
    required DateTime date,
    String? supplier,
    String? notes,
  }) => _db.registerReadyFeedPurchase(
    name: name,
    phase: phase,
    quantityKg: quantityKg,
    totalCostCents: totalCost,
    date: date,
    supplier: supplier,
    notes: notes,
    actorId: _actor('feed_batches.create'),
  );
  Future<void> saveFormula(
    FormulaOverview source,
    Map<String, double> values,
    String? notes,
  ) => _db.createFormulaVersion(
    source: source,
    quantities: values,
    notes: notes,
    actorId: _actor('feed_formulas.manage'),
  );
  Future<void> updateFormula({
    required FormulaOverview source,
    required String name,
    required String phase,
    required bool isActive,
    required Map<String, double> values,
    String? notes,
  }) => _db.updateFormula(
    source: source,
    name: name,
    phase: phase,
    isActive: isActive,
    quantities: values,
    notes: notes,
    actorId: _actor('feed_formulas.manage'),
  );
  Future<void> feed(
    String lotId,
    String batchId,
    double kg,
    DateTime date,
    String? notes,
  ) => _db.registerFeeding(
    lotId: lotId,
    batchId: batchId,
    quantityKg: kg,
    date: date,
    notes: notes,
    actorId: _actor('feeding.register'),
  );
  Future<void> adjustFeed(
    String batchId,
    double kg,
    bool input,
    String? notes,
  ) => _db.adjustFeedStock(
    batchId: batchId,
    quantityKg: kg,
    input: input,
    notes: notes,
    actorId: _actor('feed_stock.adjust'),
  );
  Future<void> addCustomer(
    String name,
    String? phone,
    String? address,
    String? notes,
  ) => _db.addCustomer(
    name: name,
    phone: phone,
    address: address,
    notes: notes,
    actorId: _actor('customers.create'),
  );
  Future<void> addOrder({
    String? customerId,
    required String productType,
    required double quantity,
    required int unitPrice,
    required DateTime date,
    DateTime? delivery,
    String? notes,
  }) => _db.createOrder(
    customerId: customerId,
    productType: productType,
    quantity: quantity,
    unitPriceCents: unitPrice,
    requestedDate: date,
    deliveryDate: delivery,
    notes: notes,
    actorId: _actor('orders.create'),
  );
  Future<void> setOrderStatus(String id, String status, [String? notes]) =>
      _db.updateOrderStatus(
        orderId: id,
        newStatus: status,
        notes: notes,
        actorId: _actor(
          status == 'CANCELLED' ? 'orders.cancel' : 'orders.update',
        ),
      );
  Future<void> sellEggs({
    String? customerId,
    required int dozens,
    required int loose,
    required int dozenPrice,
    required String payment,
    String? notes,
  }) => _db.createEggSale(
    customerId: customerId,
    dozens: dozens,
    looseEggs: loose,
    dozenPriceCents: dozenPrice,
    paymentMethod: payment,
    notes: notes,
    actorId: _actor('sales.create'),
  );
  Future<void> addPackagingItem(String type, String name, String? notes) =>
      _db.addPackagingItem(
        type: type,
        name: name,
        notes: notes,
        actorId: _actor('sales.create'),
      );
  Future<void> addPackagingLot({
    required String itemId,
    String? batchCode,
    required int quantity,
    required int unitCost,
    DateTime? purchasedAt,
    String? supplier,
    String? notes,
  }) => _db.addPackagingLot(
    itemId: itemId,
    batchCode: batchCode,
    quantity: quantity,
    unitCostCents: unitCost,
    purchasedAt: purchasedAt,
    supplier: supplier,
    notes: notes,
    actorId: _actor('sales.create'),
  );
  Future<void> assembleEggTrays({
    required String trayLotId,
    required String labelLotId,
    required int quantity,
    required int eggsPerTray,
    int? trayUnitCost,
    int? labelUnitCost,
    int? eggUnitCost,
    int? finalUnitPrice,
    DateTime? assembledAt,
    String? notes,
  }) => _db.assembleEggTrays(
    trayLotId: trayLotId,
    labelLotId: labelLotId,
    quantity: quantity,
    eggsPerTray: eggsPerTray,
    trayUnitCostCents: trayUnitCost,
    labelUnitCostCents: labelUnitCost,
    eggUnitCostCents: eggUnitCost,
    finalUnitPriceCents: finalUnitPrice,
    assembledAt: assembledAt,
    notes: notes,
    actorId: _actor('sales.create'),
  );
  Future<void> reverseEggTrayAssembly(String batchId) =>
      _db.reverseEggTrayAssembly(
        batchId: batchId,
        actorId: _actor('sales.cancel'),
      );
  Future<void> sellEggTrays({
    String? customerId,
    required String trayBatchId,
    required int trayQuantity,
    required int trayUnitPrice,
    required String payment,
    String? notes,
  }) => _db.createEggTraySale(
    customerId: customerId,
    trayBatchId: trayBatchId,
    trayQuantity: trayQuantity,
    trayUnitPriceCents: trayUnitPrice,
    paymentMethod: payment,
    notes: notes,
    actorId: _actor('sales.create'),
  );
  Future<void> cancelSale(String id) =>
      _db.cancelSale(id, actorId: _actor('sales.cancel'));
  Future<void> adjustEggs(int quantity, String type, String? notes) =>
      _db.adjustEggStock(
        quantity: quantity,
        type: type,
        notes: notes,
        actorId: _actor('egg_stock.adjust'),
      );
  Future<void> addFinance({
    required String type,
    required String category,
    required String description,
    required int amount,
    String? payment,
    String? notes,
  }) => _db.addFinance(
    type: type,
    category: category,
    description: description,
    amountCents: amount,
    paymentMethod: payment,
    notes: notes,
    actorId: _actor('finance.create'),
  );
  Future<void> cancelFinance(String id) =>
      _db.cancelFinance(id, actorId: _actor('finance.update'));
  Future<void> addInvestment(
    String description,
    String category,
    int amount,
    String? lotId,
  ) => _db.addInvestment(
    description: description,
    category: category,
    amountCents: amount,
    lotId: lotId,
    actorId: _actor('finance.create'),
  );
  Future<void> addEvent(
    String title,
    String type,
    DateTime date,
    String? lotId,
    String? notes, {
    bool alertEnabled = true,
    String? alertMessage,
    String alertTime = '08:00',
    String recurrence = 'ONCE',
    DateTime? repeatUntil,
    Set<int> weekdays = const {},
  }) async {
    final actor = _actor('calendar.manage');
    final setting = await _db.notificationSettingFor(type);
    final startsAt = dateWithConfiguredTime(date, alertTime);
    final occurrences = alertOccurrences(
      startsAt: startsAt,
      alertTime: alertTime,
      recurrence: recurrence,
      repeatUntil: repeatUntil,
      weekdays: weekdays,
    );
    final alertTimes = occurrences
        .where((occurrence) => occurrence.isAfter(DateTime.now()))
        .toList();
    if (alertEnabled && alertTimes.isEmpty) {
      throw ArgumentError('Informe uma data e hora futura para o alerta.');
    }
    if (alertEnabled && NotificationService().nativeSupported) {
      final status = await NotificationService().prepareCriticalAlerts();
      if (!status.canDeliverCriticalAlerts) {
        throw StateError(
          'O Android ainda precisa liberar os alertas sonoros: ${status.missingItems.join(' ')}',
        );
      }
    }
    final eventId = await _db.addCalendarEvent(
      title: title,
      type: type,
      startsAt: startsAt,
      lotId: lotId,
      notes: notes,
      alertEnabled: alertEnabled,
      alertMessage: alertMessage,
      alertTime: alertTime,
      recurrence: recurrence,
      repeatUntil: repeatUntil,
      weekdays: _weekdayText(weekdays),
      actorId: actor,
    );
    if (alertEnabled) {
      final body = alertMessage?.trim().isNotEmpty == true
          ? alertMessage!.trim()
          : setting?.defaultMessage?.trim().isNotEmpty == true
          ? setting!.defaultMessage!
          : notes?.trim().isNotEmpty == true
          ? notes!.trim()
          : 'Evento operacional programado.';
      var index = 0;
      for (final occurrence in occurrences) {
        if (!occurrence.isAfter(DateTime.now())) {
          index++;
          continue;
        }
        await NotificationService().schedule(
          id: stableAlertId('calendar:$eventId:$index'),
          title: 'GRANJA SELETO · $title',
          body: body,
          at: occurrence,
          urgent: true,
        );
        index++;
      }
    }
  }

  Future<void> updateCalendarAlert({
    required CalendarEvent event,
    required String title,
    required DateTime date,
    required bool alertEnabled,
    String? alertMessage,
    required String alertTime,
    required String recurrence,
    DateTime? repeatUntil,
    Set<int> weekdays = const {},
  }) async {
    final actor = _actor('calendar.manage');
    final startsAt = dateWithConfiguredTime(date, alertTime);
    final occurrences = alertOccurrences(
      startsAt: startsAt,
      alertTime: alertTime,
      recurrence: recurrence,
      repeatUntil: repeatUntil,
      weekdays: weekdays,
    );
    final alertTimes = occurrences
        .where((occurrence) => occurrence.isAfter(DateTime.now()))
        .toList();
    if (alertEnabled && alertTimes.isEmpty) {
      throw ArgumentError('Informe uma data e hora futura para o alerta.');
    }
    if (alertEnabled && NotificationService().nativeSupported) {
      final status = await NotificationService().prepareCriticalAlerts();
      if (!status.canDeliverCriticalAlerts) {
        throw StateError(
          'O Android ainda precisa liberar os alertas sonoros: ${status.missingItems.join(' ')}',
        );
      }
    }
    await _db.updateCalendarEventAlert(
      event: event,
      title: title,
      startsAt: startsAt,
      alertEnabled: alertEnabled,
      alertMessage: alertMessage,
      alertTime: alertTime,
      recurrence: recurrence,
      repeatUntil: repeatUntil,
      weekdays: _weekdayText(weekdays),
      actorId: actor,
    );
    await cancelCalendarEventAlerts(event);
    if (alertEnabled) {
      await schedulePersistedAlerts(_db, tenantId: _tenantScope(ref));
    }
  }

  Future<void> setCalendarAlertEnabled(
    CalendarEvent event,
    bool enabled,
  ) async {
    await updateCalendarAlert(
      event: event,
      title: event.title,
      date: event.startsAt,
      alertEnabled: enabled,
      alertMessage: event.alertMessage,
      alertTime: event.alertTime,
      recurrence: event.recurrence,
      repeatUntil: event.repeatUntil,
      weekdays: parseWeekdays(event.weekdays),
    );
  }

  Future<void> assignLight(String lotId, String programId) =>
      _db.assignLightingProgram(
        lotId: lotId,
        programId: programId,
        actorId: _actor('lighting.manage'),
      );
  Future<void> saveSetting(String key, String value) =>
      _db.saveAppSetting(key, value, _actor('settings.update'));
  Future<void> restoreBackup(String content) =>
      _db.restoreJson(content, actorId: _actor('settings.update'));
  Future<OperationalImportResult> importOperationalData(
    String filename,
    List<int> bytes,
  ) => _db.importOperationalData(
    filename: filename,
    bytes: Uint8List.fromList(bytes),
    actorId: _actor('settings.update'),
  );
  Future<FeedRecommendationImportResult> importFeedRecommendations(
    String filename,
    List<int> bytes,
  ) => _db.importFeedConsumptionRecommendations(
    filename: filename,
    bytes: Uint8List.fromList(bytes),
    actorId: _actor('feed_formulas.manage'),
  );
  Future<void> seedDemo() => _db.seedDemoData(_actor('settings.update'));
  Future<void> updateNotification(
    NotificationSetting setting,
    bool enabled,
    int days,
    String time,
    String? message,
    String recurrence,
  ) async {
    await _db.updateNotificationSetting(
      setting,
      enabled: enabled,
      daysBefore: days,
      time: time,
      message: message,
      recurrence: recurrence,
      actorId: _actor('settings.update'),
    );
    await schedulePersistedAlerts(_db, tenantId: _tenantScope(ref));
  }

  Future<void> transfer(
    String from,
    String to,
    int quantity,
    DateTime date,
    String? notes,
    bool deactivateFromLot,
  ) => _db.transferBirds(
    fromLotId: from,
    toLotId: to,
    quantity: quantity,
    date: date,
    notes: notes,
    deactivateFromLot: deactivateFromLot,
    actorId: _actor('birds.transfer'),
  );

  Future<void> undoTransfer(String reference, String? notes) =>
      _db.undoBirdTransfer(
        reference: reference,
        notes: notes,
        actorId: _actor('birds.transfer'),
      );
}

final operationsControllerProvider = Provider(OperationsController.new);

String? _weekdayText(Set<int> weekdays) {
  if (weekdays.isEmpty) return null;
  final sorted = weekdays.toList()..sort();
  return sorted.join(',');
}
