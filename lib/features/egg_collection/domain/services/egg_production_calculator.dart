class EggProductionProjection {
  const EggProductionProjection({
    required this.eggsPerDay,
    required this.eggsPerWeek,
    required this.eggsPerMonth,
    required this.eggsPerYear,
  });

  final double eggsPerDay;
  final double eggsPerWeek;
  final double eggsPerMonth;
  final double eggsPerYear;
  double get dozensPerDay => eggsPerDay / 12;
  double get dozensPerWeek => eggsPerWeek / 12;
  double get dozensPerMonth => eggsPerMonth / 12;
  double get dozensPerYear => eggsPerYear / 12;
}

class EggProductionCalculator {
  const EggProductionCalculator._();

  static EggProductionProjection project({
    required int activeBirds,
    required double layRate,
  }) {
    if (activeBirds < 0 || layRate < 0 || layRate > 1) {
      throw ArgumentError('Aves e taxa de postura inválidas.');
    }
    final day = activeBirds * layRate;
    return EggProductionProjection(
      eggsPerDay: day,
      eggsPerWeek: day * 7,
      eggsPerMonth: day * 30,
      eggsPerYear: day * 365,
    );
  }

  static double actualLayRate({
    required int collectedEggs,
    required int activeBirds,
    required int days,
  }) {
    if (collectedEggs < 0 || activeBirds <= 0 || days <= 0) {
      throw ArgumentError('Dados insuficientes para calcular a taxa real.');
    }
    return collectedEggs / (activeBirds * days);
  }
}
