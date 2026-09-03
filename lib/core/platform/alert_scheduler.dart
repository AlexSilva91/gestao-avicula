import '../database/app_database.dart';
import '../database/operations_repository.dart';
import 'notification_service.dart';

Future<void> schedulePersistedAlerts(AppDatabase database) async {
  final service = NotificationService();
  if (!service.nativeSupported) return;
  if (!await service.prepareMessages()) return;

  final now = DateTime.now();
  final calendarEvents = await database.futureAlertCalendarEvents(
    now.subtract(const Duration(days: 1)),
    now.add(const Duration(days: 365)),
  );
  for (final event in calendarEvents) {
    final setting = await database.notificationSettingFor(event.type);
    final body = event.alertMessage?.trim().isNotEmpty == true
        ? event.alertMessage!.trim()
        : setting?.defaultMessage?.trim().isNotEmpty == true
        ? setting!.defaultMessage!.trim()
        : event.notes?.trim().isNotEmpty == true
        ? event.notes!.trim()
        : 'Evento operacional programado.';
    var index = 0;
    for (final occurrence in alertOccurrences(
      startsAt: event.startsAt,
      alertTime: event.alertTime,
      recurrence: event.recurrence,
      repeatUntil: event.repeatUntil,
      weekdays: parseWeekdays(event.weekdays),
    )) {
      final id = stableAlertId('calendar:${event.id}:$index');
      index++;
      if (!occurrence.isAfter(now)) continue;
      await service.scheduleMessage(
        id: id,
        title: 'GRANJA SELETO · ${event.title}',
        body: body,
        at: occurrence,
      );
    }
  }

  final phaseSetting = await database.notificationSettingFor('PHASE_CHANGE');
  if (!(phaseSetting?.isEnabled ?? false)) return;
  final lots = await database.currentLotSummaries();
  for (final summary in lots.where((lot) => lot.activeBirds > 0)) {
    for (final phase in phaseMilestones) {
      final phaseDate =
          DateTime(
                summary.lot.receivedAt.year,
                summary.lot.receivedAt.month,
                summary.lot.receivedAt.day,
              )
              .subtract(Duration(days: summary.lot.arrivalAgeDays))
              .add(Duration(days: phase.ageDays));
      final alert = atConfiguredTime(
        phaseDate,
        phaseSetting!.notificationTime,
      ).subtract(Duration(days: phaseSetting.daysBefore));
      if (!alert.isAfter(now)) continue;
      await service.scheduleMessage(
        id: stableAlertId('phase:${summary.lot.id}:${phase.ageDays}'),
        title: '${summary.lot.name} entrará em ${phase.name}',
        body: phaseSetting.defaultMessage?.trim().isNotEmpty == true
            ? phaseSetting.defaultMessage!.trim()
            : 'Prepare manejo, ração e iluminação para a nova fase.',
        at: alert,
      );
    }
  }
}

DateTime atConfiguredTime(DateTime date, String alertTime) {
  final parts = alertTime.split(':');
  final hour = int.tryParse(parts.first) ?? 8;
  final minute = int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0;
  return DateTime(date.year, date.month, date.day, hour, minute);
}

List<DateTime> alertOccurrences({
  required DateTime startsAt,
  required String alertTime,
  required String recurrence,
  required DateTime? repeatUntil,
  required Set<int> weekdays,
}) {
  final first = atConfiguredTime(startsAt, alertTime);
  final maxUntil = switch (recurrence) {
    'DAILY' => first.add(const Duration(days: 90)),
    'WEEKLY' => first.add(const Duration(days: 180)),
    'MONTHLY' => DateTime(
      first.year + 1,
      first.month,
      first.day,
      first.hour,
      first.minute,
    ),
    _ => first,
  };
  final until = repeatUntil == null || repeatUntil.isAfter(maxUntil)
      ? maxUntil
      : DateTime(repeatUntil.year, repeatUntil.month, repeatUntil.day, 23, 59);
  final occurrences = <DateTime>[];
  if (recurrence == 'ONCE') return [first];
  if (recurrence == 'DAILY') {
    for (
      var day = first;
      !day.isAfter(until) && occurrences.length < 64;
      day = day.add(const Duration(days: 1))
    ) {
      occurrences.add(day);
    }
    return occurrences;
  }
  if (recurrence == 'WEEKLY') {
    final selected = weekdays.isEmpty ? {first.weekday} : weekdays;
    for (
      var day = first;
      !day.isAfter(until) && occurrences.length < 64;
      day = day.add(const Duration(days: 1))
    ) {
      if (selected.contains(day.weekday)) occurrences.add(day);
    }
    return occurrences;
  }
  if (recurrence == 'MONTHLY') {
    for (var month = 0; occurrences.length < 24; month++) {
      final next = DateTime(
        first.year,
        first.month + month,
        first.day,
        first.hour,
        first.minute,
      );
      if (next.isAfter(until)) break;
      occurrences.add(next);
    }
  }
  return occurrences;
}

Set<int> parseWeekdays(String? weekdays) {
  if (weekdays == null || weekdays.trim().isEmpty) return {};
  return weekdays
      .split(',')
      .map((item) => int.tryParse(item.trim()))
      .whereType<int>()
      .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
      .toSet();
}

int stableAlertId(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash == 0 ? 1 : hash;
}

const phaseMilestones = [
  PhaseMilestone(49, 'RECRIA'),
  PhaseMilestone(112, 'PRÉ-POSTURA'),
  PhaseMilestone(154, 'PRODUÇÃO I'),
  PhaseMilestone(266, 'PRODUÇÃO II'),
  PhaseMilestone(462, 'PRODUÇÃO III'),
];

class PhaseMilestone {
  const PhaseMilestone(this.ageDays, this.name);
  final int ageDays;
  final String name;
}
