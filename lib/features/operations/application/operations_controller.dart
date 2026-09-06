import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/operational_data_import.dart';
import '../../../core/database/operations_repository.dart';
import '../../../core/platform/alert_scheduler.dart';
import '../../../core/platform/notification_service.dart';
import '../../auth/application/auth_controller.dart';

final ingredientsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchIngredientOverviews(),
);
final ingredientLotsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchIngredientLotBalances(),
);
final formulasProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchFormulaOverviews(),
);
final feedBatchesProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchFeedBatchBalances(),
);
final feedingsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchFeedings(),
);
final customersProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchCustomers(),
);
final ordersProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchOrders(),
);
final salesProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchSales(),
);
final financeProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchFinance(),
);
final financeMetricsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchFinanceMetrics(),
);
final investmentsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchInvestments(),
);
final eggStockProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchEggStockMetrics(),
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
  (ref) => ref.watch(databaseProvider).watchAuditLogs(),
);
final birdMovementsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchBirdMovementOverviews(),
);
final birdMetricsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchBirdMetrics(),
);
final dashboardMetricsProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchDashboardMetrics(),
);
final eggProductionSeriesProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchEggProductionSeries(),
);
final financeSeriesProvider = StreamProvider(
  (ref) => ref.watch(databaseProvider).watchFinanceSeries(),
);
final calendarEventsProvider =
    StreamProvider.family<
      List<CalendarEvent>,
      ({DateTime first, DateTime last})
    >(
      (ref, range) => ref
          .watch(databaseProvider)
          .watchCalendarEvents(range.first, range.last),
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
    final occurrences = alertOccurrences(
      startsAt: date,
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
      final enabled = await NotificationService().prepareMessages();
      if (!enabled) {
        throw StateError('Permita notificações para o GRANJA SELETO.');
      }
    }
    final eventId = await _db.addCalendarEvent(
      title: title,
      type: type,
      startsAt: date,
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
        await NotificationService().scheduleMessage(
          id: stableAlertId('calendar:$eventId:$index'),
          title: 'GRANJA SELETO · $title',
          body: body,
          at: occurrence,
        );
        index++;
      }
    }
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
  Future<void> seedDemo() => _db.seedDemoData(_actor('settings.update'));
  Future<void> updateNotification(
    NotificationSetting setting,
    bool enabled,
    int days,
    String time,
    String? message,
    String recurrence,
  ) {
    return _db.updateNotificationSetting(
      setting,
      enabled: enabled,
      daysBefore: days,
      time: time,
      message: message,
      recurrence: recurrence,
      actorId: _actor('settings.update'),
    );
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
