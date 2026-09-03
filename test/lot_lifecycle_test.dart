import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/features/lots/domain/value_objects/lot_lifecycle.dart';

void main() {
  test('calculates age, estimated birth and phase from the reception data', () {
    final receivedAt = DateTime(2026, 7, 31);
    final age = LotLifecycle.ageInDays(
      receivedAt: receivedAt,
      arrivalAgeDays: 56,
      on: DateTime(2026, 9, 2),
    );

    expect(age, 89);
    expect(
      LotLifecycle.estimatedBirthDate(
        receivedAt: receivedAt,
        arrivalAgeDays: 56,
      ),
      DateTime(2026, 6, 5),
    );
    expect(LotLifecycle.phaseForAge(age), FeedingPhase.recria);
    expect(LotLifecycle.ageLabel(age), '89 dias · 12 semanas e 5 dias');
  });

  test('moves through all feeding phases at their specified boundaries', () {
    expect(LotLifecycle.phaseForAge(48), FeedingPhase.cria);
    expect(LotLifecycle.phaseForAge(49), FeedingPhase.recria);
    expect(LotLifecycle.phaseForAge(112), FeedingPhase.prePostura);
    expect(LotLifecycle.phaseForAge(154), FeedingPhase.producaoI);
    expect(LotLifecycle.phaseForAge(266), FeedingPhase.producaoII);
    expect(LotLifecycle.phaseForAge(462), FeedingPhase.producaoIII);
  });
}
