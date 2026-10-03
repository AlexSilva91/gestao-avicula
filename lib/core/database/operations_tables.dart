import 'package:drift/drift.dart';

class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get unit => text().withDefault(const Constant('kg'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class IngredientPriceHistory extends Table {
  TextColumn get id => text()();
  TextColumn get ingredientId => text()();
  IntColumn get pricePerKgCents => integer()();
  DateTimeColumn get effectiveDate => dateTime()();
  TextColumn get supplier => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class IngredientLots extends Table {
  TextColumn get id => text()();
  TextColumn get ingredientId => text()();
  TextColumn get code => text().unique()();
  DateTimeColumn get entryDate => dateTime()();
  RealColumn get initialQuantityKg => real()();
  TextColumn get packageUnit => text().withDefault(const Constant('KG'))();
  RealColumn get packageQuantity => real().withDefault(const Constant(0))();
  RealColumn get packageWeightKg => real().withDefault(const Constant(1))();
  IntColumn get totalCostCents => integer()();
  IntColumn get pricePerKgCents => integer()();
  TextColumn get supplier => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class IngredientStockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get ingredientId => text()();
  TextColumn get ingredientLotId => text()();
  RealColumn get quantityKg => real()();
  IntColumn get pricePerKgCentsSnapshot => integer()();
  IntColumn get totalCostCents => integer()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FeedFormulas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phase => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get validFrom => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FeedFormulaItems extends Table {
  TextColumn get id => text()();
  TextColumn get formulaId => text()();
  TextColumn get ingredientId => text()();
  RealColumn get baseQuantityKg => real()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FeedBatches extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get phase => text()();
  TextColumn get formulaId => text()();
  DateTimeColumn get producedAt => dateTime()();
  RealColumn get producedQuantityKg => real()();
  IntColumn get totalCostCents => integer()();
  RealColumn get costPerKgCents => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FeedBatchItems extends Table {
  TextColumn get id => text()();
  TextColumn get batchId => text()();
  TextColumn get ingredientId => text()();
  RealColumn get quantityKg => real()();
  IntColumn get pricePerKgCentsSnapshot => integer()();
  IntColumn get itemCostCents => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FeedStockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get batchId => text()();
  RealColumn get quantityKg => real()();
  TextColumn get feedingId => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class DailyFeedings extends Table {
  TextColumn get id => text()();
  DateTimeColumn get feedingDate => dateTime()();
  TextColumn get lotId => text()();
  TextColumn get batchId => text()();
  RealColumn get quantityKg => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FeedConsumptionRecommendations extends Table {
  TextColumn get id => text()();
  IntColumn get startWeek => integer()();
  IntColumn get endWeek => integer().nullable()();
  RealColumn get gramsPerBirdDay => real()();
  TextColumn get phase => text().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  IntColumn get orderNumber => integer().unique()();
  TextColumn get customerId => text().nullable()();
  DateTimeColumn get requestedDate => dateTime()();
  DateTimeColumn get expectedDeliveryDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('DRAFT'))();
  IntColumn get subtotalCents => integer()();
  IntColumn get discountCents => integer().withDefault(const Constant(0))();
  IntColumn get totalCents => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  TextColumn get updatedBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get productType => text()();
  RealColumn get quantity => real()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get totalCents => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OrderStatusHistory extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get oldStatus => text().nullable()();
  TextColumn get newStatus => text()();
  DateTimeColumn get changedAt => dateTime()();
  TextColumn get changedBy => text()();
  TextColumn get notes => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PackagingItems extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PackagingLots extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get batchCode => text().nullable()();
  IntColumn get initialQuantity => integer()();
  IntColumn get unitCostCents => integer().withDefault(const Constant(0))();
  IntColumn get totalCostCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get purchasedAt => dateTime()();
  TextColumn get supplier => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PackagingStockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get lotId => text()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get quantity => integer()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('EggTrayBatch')
class EggTrayBatches extends Table {
  TextColumn get id => text()();
  TextColumn get trayLotId => text()();
  TextColumn get labelLotId => text()();
  IntColumn get quantity => integer()();
  IntColumn get eggsPerTray => integer()();
  DateTimeColumn get assembledAt => dateTime()();
  IntColumn get trayUnitCostCents => integer().withDefault(const Constant(0))();
  IntColumn get labelUnitCostCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get eggUnitCostCents => integer().withDefault(const Constant(0))();
  IntColumn get unitPackagingCostCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get finalUnitPriceCents =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class EggTrayStockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get batchId => text()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get quantity => integer()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text()();
  DateTimeColumn get soldAt => dateTime()();
  TextColumn get customerId => text().nullable()();
  TextColumn get orderId => text().nullable().unique()();
  TextColumn get trayBatchId => text().nullable()();
  IntColumn get trayQuantity => integer().withDefault(const Constant(0))();
  IntColumn get dozens => integer().withDefault(const Constant(0))();
  IntColumn get looseEggs => integer().withDefault(const Constant(0))();
  IntColumn get dozenPriceCents => integer()();
  IntColumn get totalCents => integer()();
  TextColumn get paymentMethod => text()();
  TextColumn get status => text().withDefault(const Constant('CONFIRMED'))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FinanceTransactions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  IntColumn get amountCents => integer()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('CONFIRMED'))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Investments extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  DateTimeColumn get investmentDate => dateTime()();
  IntColumn get amountCents => integer()();
  TextColumn get lotId => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FinancialEstablishments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get contact => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PersonalFinanceTransactions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  IntColumn get amountCents => integer()();
  TextColumn get establishmentId => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('CONFIRMED'))();
  TextColumn get notes => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FinancialReserves extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmountCents => integer()();
  IntColumn get currentAmountCents => integer()();
  TextColumn get account => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PersonalInvestments extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  TextColumn get institution => text().nullable()();
  IntColumn get amountCents => integer()();
  RealColumn get allocationPercent => real().withDefault(const Constant(0))();
  DateTimeColumn get investmentDate => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PersonalDebts extends Table {
  TextColumn get id => text()();
  TextColumn get creditor => text()();
  TextColumn get debtType => text()();
  IntColumn get totalAmountCents => integer()();
  IntColumn get paidAmountCents => integer().withDefault(const Constant(0))();
  IntColumn get installmentAmountCents => integer().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get expectedPayoffDate => dateTime().nullable()();
  BoolColumn get alertEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('OPEN'))();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LightingPrograms extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LightingProgramSteps extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text()();
  IntColumn get startAgeDays => integer()();
  IntColumn get endAgeDays => integer().nullable()();
  IntColumn get totalLightMinutes => integer()();
  TextColumn get startTime => text().nullable()();
  TextColumn get endTime => text().nullable()();
  IntColumn get weeklyIncrementMinutes =>
      integer().withDefault(const Constant(0))();
  TextColumn get relatedPhase => text().nullable()();
  TextColumn get notes => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LotLightingPrograms extends Table {
  TextColumn get id => text()();
  TextColumn get lotId => text().unique()();
  TextColumn get programId => text()();
  DateTimeColumn get assignedAt => dateTime()();
  TextColumn get createdBy => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CalendarEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => text()();
  DateTimeColumn get startsAt => dateTime()();
  DateTimeColumn get endsAt => dateTime().nullable()();
  TextColumn get lotId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get alertEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get alertMessage => text().nullable()();
  TextColumn get alertTime => text().withDefault(const Constant('08:00'))();
  TextColumn get recurrence => text().withDefault(const Constant('ONCE'))();
  DateTimeColumn get repeatUntil => dateTime().nullable()();
  TextColumn get weekdays => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class NotificationSettings extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().unique()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get daysBefore => integer().withDefault(const Constant(1))();
  TextColumn get notificationTime =>
      text().withDefault(const Constant('08:00'))();
  TextColumn get defaultMessage => text().nullable()();
  TextColumn get defaultRecurrence =>
      text().withDefault(const Constant('ONCE'))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get updatedBy => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {key};
}

class SensorReadings extends Table {
  TextColumn get id => text()();
  TextColumn get source => text()();
  TextColumn get metric => text()();
  RealColumn get value => real()();
  TextColumn get unit => text().nullable()();
  TextColumn get zone => text().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get transport => text().nullable()();
  TextColumn get payloadJson => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AutomationEvents extends Table {
  TextColumn get id => text()();
  TextColumn get severity => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get source => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('OPEN'))();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get payloadJson => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class VaccinationRecords extends Table {
  TextColumn get id => text()();
  TextColumn get lotId => text().nullable()();
  TextColumn get vaccineName => text()();
  TextColumn get disease => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get appliedAt => dateTime().nullable()();
  TextColumn get dose => text().nullable()();
  TextColumn get route => text().nullable()();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get responsible => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('SCHEDULED'))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
