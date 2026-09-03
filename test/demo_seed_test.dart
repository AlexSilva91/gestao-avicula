import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/core/database/app_database.dart';
import 'package:seleto/core/database/demo_seed.dart';
import 'package:seleto/core/database/operations_repository.dart';

void main() {
  test('demo seed creates a ready-to-test database', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedDemoDatabase(db);

    final admin = await db.userByUsername(demoUsername);
    expect(admin, isNotNull);
    expect(admin!.isSuperuser, isTrue);

    final lots = await db.watchLotSummaries().first;
    expect(lots.length, greaterThanOrEqualTo(3));
    expect(lots.where((lot) => lot.activeBirds > 0), isNotEmpty);

    final dailyRates = await db.watchDailyLayingRates(days: 90).first;
    final monthlyRates = await db.watchMonthlyLayingRates(months: 3).first;
    expect(dailyRates, isNotEmpty);
    expect(monthlyRates, isNotEmpty);
    expect(dailyRates.first.layingRate, greaterThan(0));

    expect(await db.eggStockBalance(), greaterThan(0));
    expect(await db.watchCustomers().first, isNotEmpty);
    expect(await db.watchSales().first, isNotEmpty);
    expect(await db.watchFinance().first, isNotEmpty);
  });
}
