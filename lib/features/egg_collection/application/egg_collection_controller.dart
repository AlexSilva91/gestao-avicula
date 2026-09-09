import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../auth/application/auth_controller.dart';

String? _tenantScope(Ref ref) {
  final session = ref.watch(authControllerProvider).session;
  return session?.allows('tenant.view_all') == true ? null : session?.tenantId;
}

final eggMetricsProvider = StreamProvider<EggMetrics>(
  (ref) =>
      ref.watch(databaseProvider).watchEggMetrics(tenantId: _tenantScope(ref)),
);

final recentEggCollectionsProvider = StreamProvider<List<EggCollection>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchRecentEggCollections(tenantId: _tenantScope(ref)),
);

final dailyLayingRatesProvider = StreamProvider<List<LayingRateHistoryEntry>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchDailyLayingRates(tenantId: _tenantScope(ref)),
);

final monthlyLayingRatesProvider = StreamProvider<List<LayingRateHistoryEntry>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchMonthlyLayingRates(tenantId: _tenantScope(ref)),
);
final monthlyLayingRatesRangeProvider =
    StreamProvider.family<
      List<LayingRateHistoryEntry>,
      ({DateTime start, DateTime end})
    >(
      (ref, range) => ref
          .watch(databaseProvider)
          .watchMonthlyLayingRates(
            start: range.start,
            end: range.end,
            tenantId: _tenantScope(ref),
          ),
    );

class EggCollectionController {
  EggCollectionController(this.ref);
  final Ref ref;

  Future<void> register({
    required DateTime date,
    required String lotId,
    required int quantity,
    required int cleanEggs,
    required int dirtyEggs,
    required int crackedEggs,
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
          cleanEggs: cleanEggs,
          dirtyEggs: dirtyEggs,
          crackedEggs: crackedEggs,
          brokenEggs: brokenEggs,
          discardedEggs: discardedEggs,
          notes: notes,
          actorId: session.userId,
        );
  }
}

final eggCollectionControllerProvider = Provider(EggCollectionController.new);
