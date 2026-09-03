import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/operations_repository.dart';
import '../../../core/platform/alert_scheduler.dart';
import '../../../core/platform/notification_service.dart';
import '../../auth/application/auth_controller.dart';

final lotSummariesProvider = StreamProvider<List<LotSummary>>(
  (ref) => ref.watch(databaseProvider).watchLotSummaries(),
);

class LotsController {
  LotsController(this.ref);
  final Ref ref;

  Future<void> purchase({
    required String name,
    String? strain,
    required int quantity,
    required DateTime receivedAt,
    required int arrivalAgeDays,
    int? unitValueCents,
    String? supplier,
    String? notes,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('birds.purchase')) {
      throw StateError('Você não tem permissão para comprar aves.');
    }
    final setting = await ref
        .read(databaseProvider)
        .notificationSettingFor('PHASE_CHANGE');
    if ((setting?.isEnabled ?? false) &&
        NotificationService().nativeSupported) {
      final enabled = await NotificationService().prepareMessages();
      if (!enabled) {
        throw StateError('Permita notificações para o GRANJA SELETO.');
      }
    }
    final lotId = await ref
        .read(databaseProvider)
        .registerLotPurchase(
          name: name,
          strain: strain,
          quantity: quantity,
          receivedAt: receivedAt,
          arrivalAgeDays: arrivalAgeDays,
          unitValueCents: unitValueCents,
          supplier: supplier,
          notes: notes,
          actorId: session.userId,
        );
    if (setting?.isEnabled ?? false) {
      final birth = DateTime(
        receivedAt.year,
        receivedAt.month,
        receivedAt.day,
      ).subtract(Duration(days: arrivalAgeDays));
      for (final phase in phaseMilestones) {
        final date = birth.add(Duration(days: phase.ageDays));
        final alert = atConfiguredTime(
          date,
          setting!.notificationTime,
        ).subtract(Duration(days: setting.daysBefore));
        await NotificationService().scheduleMessage(
          id: stableAlertId('phase:$lotId:${phase.ageDays}'),
          title: '$name entrará em ${phase.name}',
          body: setting.defaultMessage?.trim().isNotEmpty == true
              ? setting.defaultMessage!.trim()
              : 'Prepare manejo, ração e iluminação para a nova fase.',
          at: alert,
        );
      }
    }
  }

  Future<void> outflow({
    required LotSummary lot,
    required String type,
    required int quantity,
    required DateTime occurredAt,
    int? unitValueCents,
    String? notes,
  }) async {
    final session = ref.read(authControllerProvider).session;
    final permission = switch (type) {
      'MORTALITY' => 'birds.mortality',
      'SALE' => 'birds.sell',
      _ => 'birds.adjust',
    };
    if (session == null || !session.allows(permission)) {
      throw StateError('Você não tem permissão para esta movimentação.');
    }
    await ref
        .read(databaseProvider)
        .registerBirdOutflow(
          lotId: lot.lot.id,
          type: type,
          quantity: quantity,
          occurredAt: occurredAt,
          unitValueCents: unitValueCents,
          notes: notes,
          actorId: session.userId,
        );
  }

  Future<void> update({
    required Lot lot,
    required String name,
    String? strain,
    String? supplier,
    String? notes,
    required String status,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('lots.update')) {
      throw StateError('Você não tem permissão para alterar lotes.');
    }
    await ref
        .read(databaseProvider)
        .updateLotDetails(
          lotId: lot.id,
          name: name,
          strain: strain,
          supplier: supplier,
          notes: notes,
          status: status,
          actorId: session.userId,
        );
  }
}

final lotsControllerProvider = Provider(LotsController.new);
