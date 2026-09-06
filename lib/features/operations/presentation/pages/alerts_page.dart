import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/platform/alert_scheduler.dart';
import '../../../../core/platform/notification_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../application/operations_controller.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppShell(
      title: 'Alertas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _CreateAlertDialog(ref: ref),
              ),
              icon: const Icon(Icons.add_alert_outlined),
              label: const Text('Novo alerta'),
            ),
          ),
          const SizedBox(height: 24),
          _ScheduledAlertsCard(ref: ref),
          const SizedBox(height: 16),
          _AlertsCard(ref: ref),
          const SizedBox(height: 16),
          _AlertInfoCard(ref: ref),
        ],
      ),
    );
  }
}

class _ScheduledAlertsCard extends StatelessWidget {
  const _ScheduledAlertsCard({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final first = DateTime(today.year, today.month, today.day);
    final last = first.add(const Duration(days: 90));
    return ref
        .watch(calendarEventsProvider((first: first, last: last)))
        .when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, _) => const SeletoAsyncError(),
          data: (events) {
            final alerts = events.where((event) => event.alertEnabled).toList();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      children: [
                        const Icon(Icons.event_available_outlined),
                        Text(
                          'Alertas agendados',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (alerts.isEmpty)
                      const SeletoEmptyState(
                        icon: Icons.notifications_none_outlined,
                        title: 'Nenhum alerta agendado',
                        message:
                            'Crie alertas para luz, alimentação ou fases de criação.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: alerts.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final event = alerts[index];
                          final nextTrigger = _nextAlertTrigger(event);
                          return ListTile(
                            leading: const Icon(Icons.notifications_active),
                            title: Text(event.title),
                            subtitle: Text(
                              nextTrigger == null
                                  ? 'Sem próximo disparo futuro'
                                  : 'Próximo disparo: ${shortDate.format(nextTrigger)} · ${shortTime.format(nextTrigger)} · ${_AlertTile.recurrenceLabel(event.recurrence)}',
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
  }
}

DateTime? _nextAlertTrigger(CalendarEvent event) {
  final now = DateTime.now();
  for (final occurrence in alertOccurrences(
    startsAt: event.startsAt,
    alertTime: event.alertTime,
    recurrence: event.recurrence,
    repeatUntil: event.repeatUntil,
    weekdays: parseWeekdays(event.weekdays),
  )) {
    if (occurrence.isAfter(now)) return occurrence;
  }
  return null;
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(notificationSettingsProvider)
        .when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, _) => const SeletoAsyncError(),
          data: (items) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      const Icon(Icons.notifications_active_outlined),
                      Text(
                        'Alertas configurados',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque no lápis para definir horário, mensagem e recorrência de cada alerta.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final item in items) _AlertTile(ref: ref, item: item),
                ],
              ),
            ),
          ),
        );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.ref, required this.item});

  final WidgetRef ref;
  final NotificationSetting item;

  static String _label(String type) =>
      const {
        'PHASE_CHANGE': 'Mudança de fase de criação',
        'LIGHTING': 'Programa de iluminação',
        'LOW_STOCK': 'Estoque baixo',
        'ORDER': 'Pedidos',
        'DELIVERY': 'Entregas',
        'FEED': 'Programa de alimentação',
        'LITTER_CHANGE': 'Troca de cama',
        'SANITARY_TREATMENT': 'Tratamento sanitário',
        'VACCINATION': 'Vacinação',
      }[type] ??
      type;

  static IconData _icon(String type) => switch (type) {
    'PHASE_CHANGE' => Icons.timeline,
    'LIGHTING' => Icons.light_mode_outlined,
    'LOW_STOCK' => Icons.inventory_2_outlined,
    'ORDER' => Icons.receipt_long_outlined,
    'DELIVERY' => Icons.local_shipping_outlined,
    'FEED' => Icons.restaurant_outlined,
    'LITTER_CHANGE' => Icons.cleaning_services_outlined,
    'SANITARY_TREATMENT' => Icons.medical_services_outlined,
    'VACCINATION' => Icons.vaccines_outlined,
    _ => Icons.notifications_active_outlined,
  };

  static String recurrenceLabel(String recurrence) =>
      const {
        'ONCE': 'Uma vez',
        'DAILY': 'Diário',
        'WEEKLY': 'Semanal',
        'MONTHLY': 'Mensal',
      }[recurrence] ??
      recurrence;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: item.isEnabled
          ? scheme.primaryContainer.withValues(alpha: .18)
          : scheme.surfaceContainerHighest.withValues(alpha: .5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.isEnabled
                      ? scheme.primary.withValues(alpha: .14)
                      : scheme.onSurface.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.isEnabled
                      ? _icon(item.type)
                      : Icons.notifications_off_outlined,
                  color: item.isEnabled
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
              ),
              title: Text(
                _label(item.type),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Text(
                '${item.daysBefore} dia(s) antes · '
                '${item.notificationTime} · '
                '${recurrenceLabel(item.defaultRecurrence)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              trailing: IconButton(
                tooltip: 'Editar alerta',
                icon: const Icon(Icons.edit_notifications_outlined),
                onPressed: () => _edit(context, item),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 56, top: 4),
              child: Row(
                children: [
                  const Expanded(child: Text('Alerta ativo')),
                  Switch(
                    value: item.isEnabled,
                    onChanged: (value) async {
                      try {
                        await ref
                            .read(operationsControllerProvider)
                            .updateNotification(
                              item,
                              value,
                              item.daysBefore,
                              item.notificationTime,
                              item.defaultMessage,
                              item.defaultRecurrence,
                            );
                      } catch (e) {
                        if (!context.mounted) {
                          return;
                        }

                        await showOperationError(context, e);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, NotificationSetting item) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          _AlertEditDialog(ref: ref, item: item, label: _label(item.type)),
    );
  }
}

class _AlertEditDialog extends StatefulWidget {
  const _AlertEditDialog({
    required this.ref,
    required this.item,
    required this.label,
  });

  final WidgetRef ref;
  final NotificationSetting item;
  final String label;

  @override
  State<_AlertEditDialog> createState() => _AlertEditDialogState();
}

class _AlertEditDialogState extends State<_AlertEditDialog> {
  late final TextEditingController _daysController;
  late final TextEditingController _timeController;
  late final TextEditingController _messageController;

  late String _recurrence;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _daysController = TextEditingController(text: '${widget.item.daysBefore}');

    _timeController = TextEditingController(text: widget.item.notificationTime);

    _messageController = TextEditingController(
      text: widget.item.defaultMessage ?? '',
    );

    _recurrence = widget.item.defaultRecurrence;
  }

  @override
  void dispose() {
    _daysController.dispose();
    _timeController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.ref
          .read(operationsControllerProvider)
          .updateNotification(
            widget.item,
            widget.item.isEnabled,
            int.tryParse(_daysController.text.trim()) ?? 0,
            _timeController.text.trim(),
            _messageController.text.trim(),
            _recurrence,
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      await showOperationError(context, e);

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(widget.label),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _timeController,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          labelText: 'Horário do alerta',
                          hintText: '08:00',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _daysController,
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Dias de antecedência',
                          prefixIcon: Icon(Icons.event),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _recurrence,
                  decoration: const InputDecoration(
                    labelText: 'Recorrência',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ONCE', child: Text('Uma vez')),
                    DropdownMenuItem(value: 'DAILY', child: Text('Diário')),
                    DropdownMenuItem(value: 'WEEKLY', child: Text('Semanal')),
                    DropdownMenuItem(value: 'MONTHLY', child: Text('Mensal')),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _recurrence = value;
                          });
                        },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  enabled: !_saving,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mensagem do alerta',
                    prefixIcon: Icon(Icons.message_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: 20,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Este alerta reproduz som e vibração mesmo com o celular no silencioso.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSecondaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_saving ? 'Salvando...' : 'Salvar'),
          ),
        ],
      ),
    );
  }
}

class _CreateAlertDialog extends StatefulWidget {
  const _CreateAlertDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<_CreateAlertDialog> {
  final title = TextEditingController();
  final message = TextEditingController();
  final time = TextEditingController(text: '08:00');
  String type = 'FEED';
  String recurrence = 'ONCE';
  String? lotId;
  DateTime date = DateTime.now();
  DateTime? repeatUntil;
  final weekdays = <int>{DateTime.monday};
  bool saving = false;

  @override
  void dispose() {
    title.dispose();
    message.dispose();
    time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots =
        widget.ref.watch(lotSummariesProvider).asData?.value ?? <LotSummary>[];
    return AlertDialog(
      title: const Text('Novo alerta'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(
                    value: 'FEED',
                    child: Text('Programa de alimentação'),
                  ),
                  DropdownMenuItem(
                    value: 'LITTER_CHANGE',
                    child: Text('Troca de cama'),
                  ),
                  DropdownMenuItem(
                    value: 'SANITARY_TREATMENT',
                    child: Text('Tratamento sanitário'),
                  ),
                  DropdownMenuItem(
                    value: 'VACCINATION',
                    child: Text('Vacinação'),
                  ),
                  DropdownMenuItem(
                    value: 'LIGHTING',
                    child: Text('Programa de luz'),
                  ),
                  DropdownMenuItem(
                    value: 'PHASE_CHANGE',
                    child: Text('Fase de criação'),
                  ),
                  DropdownMenuItem(value: 'ALERT', child: Text('Geral')),
                ],
                onChanged: saving
                    ? null
                    : (value) => setState(() => type = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: lotId,
                decoration: const InputDecoration(labelText: 'Lote'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Geral')),
                  for (final lot in lots)
                    DropdownMenuItem(
                      value: lot.lot.id,
                      child: Text(lot.lot.name),
                    ),
                ],
                onChanged: saving
                    ? null
                    : (value) => setState(() => lotId = value),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data inicial'),
                subtitle: Text(shortDate.format(date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: saving
                    ? null
                    : () async {
                        final picked = await pickSeletoDate(context, date);
                        if (picked != null) setState(() => date = picked);
                      },
              ),
              TextField(
                controller: time,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  hintText: '08:00',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: recurrence,
                decoration: const InputDecoration(labelText: 'Repetição'),
                items: const [
                  DropdownMenuItem(value: 'ONCE', child: Text('Uma vez')),
                  DropdownMenuItem(value: 'DAILY', child: Text('Diário')),
                  DropdownMenuItem(value: 'WEEKLY', child: Text('Semanal')),
                  DropdownMenuItem(value: 'MONTHLY', child: Text('Mensal')),
                ],
                onChanged: saving
                    ? null
                    : (value) => setState(() => recurrence = value!),
              ),
              if (recurrence == 'WEEKLY') ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final item in const [
                        (DateTime.monday, 'Seg'),
                        (DateTime.tuesday, 'Ter'),
                        (DateTime.wednesday, 'Qua'),
                        (DateTime.thursday, 'Qui'),
                        (DateTime.friday, 'Sex'),
                        (DateTime.saturday, 'Sáb'),
                        (DateTime.sunday, 'Dom'),
                      ])
                        FilterChip(
                          label: Text(item.$2),
                          selected: weekdays.contains(item.$1),
                          onSelected: saving
                              ? null
                              : (selected) => setState(() {
                                  selected
                                      ? weekdays.add(item.$1)
                                      : weekdays.remove(item.$1);
                                }),
                        ),
                    ],
                  ),
                ),
              ],
              if (recurrence != 'ONCE')
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Repetir até'),
                  subtitle: Text(
                    repeatUntil == null
                        ? 'Limite automático'
                        : shortDate.format(repeatUntil!),
                  ),
                  trailing: const Icon(Icons.event_repeat),
                  onTap: saving
                      ? null
                      : () async {
                          final picked = await pickSeletoDate(
                            context,
                            repeatUntil ?? date,
                          );
                          if (picked != null) {
                            setState(() => repeatUntil = picked);
                          }
                        },
                ),
              const SizedBox(height: 12),
              TextField(
                controller: message,
                enabled: !saving,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Mensagem'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: saving
              ? null
              : () async {
                  setState(() => saving = true);
                  try {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .addEvent(
                          title.text,
                          type,
                          date,
                          lotId,
                          null,
                          alertEnabled: true,
                          alertMessage: message.text,
                          alertTime: time.text,
                          recurrence: recurrence,
                          repeatUntil: repeatUntil,
                          weekdays: weekdays,
                        );
                    await NotificationService().testMessage(
                      title: 'GRANJA SELETO · Teste: ${title.text.trim()}',
                      body: message.text.trim().isEmpty
                          ? 'Teste do alerta criado.'
                          : message.text.trim(),
                    );
                    if (context.mounted) {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Alerta criado. Teste agendado para daqui a 5 segundos.',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    await showOperationError(context, e);
                    if (mounted) setState(() => saving = false);
                  }
                },
          icon: const Icon(Icons.notifications_active_outlined),
          label: const Text('Criar alerta'),
        ),
      ],
    );
  }
}

class _AlertInfoCard extends StatefulWidget {
  const _AlertInfoCard({required this.ref});
  final WidgetRef ref;

  @override
  State<_AlertInfoCard> createState() => _AlertInfoCardState();
}

class _AlertInfoCardState extends State<_AlertInfoCard> {
  late Future<NotificationReadiness> readiness = NotificationService()
      .readiness();
  bool preparing = false;

  Future<void> _prepare() async {
    setState(() => preparing = true);
    try {
      final enabled = await NotificationService().prepareMessages();
      final status = await NotificationService().readiness();
      if (!mounted) return;
      setState(() {
        readiness = Future.value(status);
      });
      if (!enabled) {
        await showOperationError(
          context,
          StateError('Permita notificações para o GRANJA SELETO.'),
        );
      } else {
        await schedulePersistedAlerts(widget.ref.read(databaseProvider));
      }
    } catch (e) {
      if (mounted) await showOperationError(context, e);
    } finally {
      if (mounted) setState(() => preparing = false);
    }
  }

  Future<void> _test() async {
    try {
      await NotificationService().testMessage(
        title: 'GRANJA SELETO · Teste de mensagem',
        body: 'Mensagem de teste dos alertas agendados.',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensagem de teste agendada para daqui a 5 segundos.'),
        ),
      );
      setState(() {
        readiness = NotificationService().readiness();
      });
    } catch (e) {
      if (mounted) await showOperationError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  'Como funcionam os alertas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<NotificationReadiness>(
              future: readiness,
              builder: (context, snapshot) {
                final status = snapshot.data;
                final ready =
                    (status?.nativeSupported ?? false) &&
                    (status?.notificationsEnabled ?? false);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        ready
                            ? Icons.verified_outlined
                            : Icons.warning_amber_outlined,
                        color: ready
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        ready
                            ? 'Android pronto para mensagens'
                            : 'Android precisa liberar notificações',
                      ),
                      subtitle: Text(
                        status == null
                            ? 'Verificando permissões do aparelho.'
                            : status.nativeSupported
                            ? ready
                                  ? 'Mensagens agendadas liberadas no aparelho.'
                                  : 'Permita notificações para o GRANJA SELETO.'
                            : 'No navegador os alertas agendados não têm garantia. Use o app instalado no Android.',
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: preparing ? null : _prepare,
                          icon: preparing
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.security_update_good),
                          label: const Text('Preparar Android'),
                        ),
                        OutlinedButton.icon(
                          onPressed: ready ? _test : null,
                          icon: const Icon(Icons.mark_email_unread_outlined),
                          label: const Text('Testar mensagem'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 28),
            for (final item in [
              (
                Icons.notifications_active_outlined,
                'Mensagens agendadas',
                'Os alertas programados aparecem como notificações do Android no horário definido.',
              ),
              (
                Icons.security_update_good,
                'Permissão obrigatória',
                'O Android precisa permitir notificações para o GRANJA SELETO.',
              ),
              (
                Icons.repeat,
                'Recorrências',
                'Configure alertas diários, semanais ou mensais. Use "Uma vez" para datas específicas.',
              ),
              (
                Icons.calendar_month,
                'Eventos no calendário',
                'Crie eventos na página Calendário e luz para alertas ligados a fases ou datas específicas de lotes.',
              ),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.$1,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            item.$3,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
