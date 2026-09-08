import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/core/platform/alert_scheduler.dart';

void main() {
  test('agenda alerta único para data específica no mesmo dia', () {
    final occurrences = alertOccurrences(
      startsAt: DateTime(2026, 9, 8),
      alertTime: '18:45',
      recurrence: 'ONCE',
      repeatUntil: null,
      weekdays: const {},
    );

    expect(occurrences, [DateTime(2026, 9, 8, 18, 45)]);
  });

  test('agenda alerta semanal apenas nos dias marcados', () {
    final occurrences = alertOccurrences(
      startsAt: DateTime(2026, 9, 8),
      alertTime: '07:30',
      recurrence: 'WEEKLY',
      repeatUntil: DateTime(2026, 9, 14),
      weekdays: const {DateTime.tuesday, DateTime.thursday},
    );

    expect(occurrences, [
      DateTime(2026, 9, 8, 7, 30),
      DateTime(2026, 9, 10, 7, 30),
    ]);
  });

  test('combina data escolhida com hora configurada', () {
    expect(
      dateWithConfiguredTime(DateTime(2026, 9, 8), '06:05'),
      DateTime(2026, 9, 8, 6, 5),
    );
  });
}
