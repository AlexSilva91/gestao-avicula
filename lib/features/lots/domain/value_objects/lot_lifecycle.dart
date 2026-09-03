enum FeedingPhase {
  cria('Cria', 0, 48),
  recria('Recria', 49, 111),
  prePostura('Pré-postura', 112, 153),
  producaoI('Produção I', 154, 265),
  producaoII('Produção II', 266, 461),
  producaoIII('Produção III', 462, null);

  const FeedingPhase(this.label, this.startDay, this.endDay);
  final String label;
  final int startDay;
  final int? endDay;
}

class LotLifecycle {
  const LotLifecycle._();

  static int ageInDays({
    required DateTime receivedAt,
    required int arrivalAgeDays,
    DateTime? on,
  }) {
    final received = DateUtils.dateOnly(receivedAt);
    final date = DateUtils.dateOnly(on ?? DateTime.now());
    return (date.difference(received).inDays + arrivalAgeDays).clamp(0, 100000);
  }

  static DateTime estimatedBirthDate({
    required DateTime receivedAt,
    required int arrivalAgeDays,
  }) => DateUtils.dateOnly(receivedAt).subtract(Duration(days: arrivalAgeDays));

  static FeedingPhase phaseForAge(int ageInDays) =>
      FeedingPhase.values.firstWhere(
        (phase) =>
            ageInDays >= phase.startDay &&
            (phase.endDay == null || ageInDays <= phase.endDay!),
      );

  static FeedingPhase? nextPhase(FeedingPhase phase) {
    final index = FeedingPhase.values.indexOf(phase);
    return index == FeedingPhase.values.length - 1
        ? null
        : FeedingPhase.values[index + 1];
  }

  static DateTime? nextPhaseDate({
    required DateTime birthDate,
    required FeedingPhase currentPhase,
  }) {
    final next = nextPhase(currentPhase);
    return next == null ? null : birthDate.add(Duration(days: next.startDay));
  }

  static String ageLabel(int days) {
    final weeks = days ~/ 7;
    final extraDays = days % 7;
    return '$days dias · $weeks semanas e $extraDays dias';
  }
}

/// Kept framework-free so lifecycle rules can be exercised in unit tests.
class DateUtils {
  const DateUtils._();
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
