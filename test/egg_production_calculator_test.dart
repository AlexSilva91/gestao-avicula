import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/features/egg_collection/domain/services/egg_production_calculator.dart';

void main() {
  test('calculates the requested egg and dozen projections dynamically', () {
    final projection = EggProductionCalculator.project(
      activeBirds: 34,
      layRate: .87,
    );

    expect(projection.eggsPerDay, closeTo(29.58, .001));
    expect(projection.eggsPerWeek, closeTo(207.06, .001));
    expect(projection.eggsPerMonth, closeTo(887.4, .001));
    expect(projection.dozensPerDay, closeTo(2.465, .001));
  });

  test('calculates real lay rate from an observed period', () {
    expect(
      EggProductionCalculator.actualLayRate(
        collectedEggs: 174,
        activeBirds: 30,
        days: 7,
      ),
      closeTo(.82857, .00001),
    );
  });
}
