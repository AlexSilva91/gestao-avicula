import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../auth/application/auth_controller.dart';

final eggMetricsProvider = StreamProvider<EggMetrics>(
  (ref) => ref.watch(databaseProvider).watchEggMetrics(),
);

final recentEggCollectionsProvider = StreamProvider<List<EggCollection>>(
  (ref) => ref.watch(databaseProvider).watchRecentEggCollections(),
);

final dailyLayingRatesProvider = StreamProvider<List<LayingRateHistoryEntry>>(
  (ref) => ref.watch(databaseProvider).watchDailyLayingRates(),
);

final monthlyLayingRatesProvider = StreamProvider<List<LayingRateHistoryEntry>>(
  (ref) => ref.watch(databaseProvider).watchMonthlyLayingRates(),
);

class EggCollectionController {
  EggCollectionController(this.ref);
  final Ref ref;

  Future<void> register({
    required DateTime date,
    required String lotId,
    required int quantity,
    required int brokenEggs,
    required int discardedEggs,
    String? notes,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('egg_collection.create')) {
      throw StateError('Você não tem permissão para registrar coletas.');
    }
    await ref
        .read(databaseProvider)
        .registerEggCollection(
          collectedOn: date,
          lotId: lotId,
          quantity: quantity,
          brokenEggs: brokenEggs,
          discardedEggs: discardedEggs,
          notes: notes,
          actorId: session.userId,
        );
  }
}

final eggCollectionControllerProvider = Provider(EggCollectionController.new);
