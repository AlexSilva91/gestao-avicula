import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/platform/notification_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../../lots/domain/value_objects/lot_lifecycle.dart';
import '../../application/operations_controller.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime focused = DateTime.now();
  DateTime selected = DateTime.now();
  CalendarFormat format = CalendarFormat.month;
  @override
  Widget build(BuildContext context) {
    final first = DateTime(focused.year, focused.month - 1);
    final last = DateTime(focused.year, focused.month + 2);
    final saved =
        ref
            .watch(calendarEventsProvider((first: first, last: last)))
            .asData
            ?.value ??
        <CalendarEvent>[];
    final lots =
        ref.watch(lotSummariesProvider).asData?.value ?? <LotSummary>[];
    final generated = _phaseEvents(lots);
    final events = [...saved, ...generated];
    List<CalendarEvent> forDay(DateTime day) =>
        events.where((e) => isSameDay(e.startsAt, day)).toList();
    return AppShell(
      title: 'Calendário e luz',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _EventDialog(
                      ref: ref,
                      initial: selected,
                      initialType: 'LITTER_CHANGE',
                      initialTitle: 'Troca de cama',
                      initialAlertEnabled: false,
                    ),
                  ),
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: const Text('Troca de cama'),
                ),
                OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _EventDialog(
                      ref: ref,
                      initial: selected,
                      initialType: 'SANITARY_TREATMENT',
                      initialTitle: 'Tratamento sanitário',
                      initialAlertEnabled: false,
                    ),
                  ),
                  icon: const Icon(Icons.medical_services_outlined),
                  label: const Text('Tratamento'),
                ),
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _EventDialog(ref: ref, initial: selected),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Novo evento'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, box) => box.maxWidth > 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _calendar(events, forDay)),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _Agenda(
                          date: selected,
                          events: forDay(selected),
                          lots: lots,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _calendar(events, forDay),
                      const SizedBox(height: 16),
                      _Agenda(
                        date: selected,
                        events: forDay(selected),
                        lots: lots,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 22),
          _LightingSection(ref: ref, lots: lots),
        ],
      ),
    );
  }

  Widget _calendar(
    List<CalendarEvent> events,
    List<CalendarEvent> Function(DateTime) loader,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: TableCalendar<CalendarEvent>(
        locale: 'pt_BR',
        firstDay: DateTime(2020),
        lastDay: DateTime(2100),
        focusedDay: focused,
        selectedDayPredicate: (d) => isSameDay(selected, d),
        calendarFormat: format,
        eventLoader: loader,
        onDaySelected: (d, f) => setState(() {
          selected = d;
          focused = f;
        }),
        onPageChanged: (d) => setState(() => focused = d),
        onFormatChanged: (f) => setState(() => format = f),
        calendarStyle: const CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Color(0xFFE59E2D),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFF8CBFA8),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFF176B4D),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );

  List<CalendarEvent> _phaseEvents(List<LotSummary> lots) {
    final result = <CalendarEvent>[];
    for (final summary in lots) {
      final birth = LotLifecycle.estimatedBirthDate(
        receivedAt: summary.lot.receivedAt,
        arrivalAgeDays: summary.lot.arrivalAgeDays,
      );
      for (final entry in [
        (49, 'Entrada em RECRIA'),
        (112, 'Entrada em PRÉ-POSTURA'),
        (154, 'Entrada em PRODUÇÃO I'),
        (266, 'Entrada em PRODUÇÃO II'),
        (462, 'Entrada em PRODUÇÃO III'),
      ]) {
        result.add(
          CalendarEvent(
            id: 'phase-${summary.lot.id}-${entry.$1}',
            title: '${summary.lot.name}: ${entry.$2}',
            type: 'PHASE_CHANGE',
            startsAt: birth.add(Duration(days: entry.$1)),
            lotId: summary.lot.id,
            alertEnabled: true,
            alertTime: '08:00',
            recurrence: 'ONCE',
            createdBy: 'system',
            createdAt: DateTime.now(),
          ),
        );
      }
    }
    return result;
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.date, required this.events, required this.lots});
  final DateTime date;
  final List<CalendarEvent> events;
  final List<LotSummary> lots;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agenda · ${shortDate.format(date)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            Text(
              'Nenhum evento para este dia.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (final e in events)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_eventIcon(e.type), color: _eventColor(e.type)),
                title: Text(e.title),
                subtitle: Text(_subtitle(e)),
              ),
        ],
      ),
    ),
  );

  String _subtitle(CalendarEvent event) {
    final lotName = lots
        .where((summary) => summary.lot.id == event.lotId)
        .firstOrNull
        ?.lot
        .name;
    final parts = [
      _eventTypeLabel(event.type),
      ?lotName,
      if (event.alertEnabled)
        '${_recurrenceLabel(event.recurrence)} às ${event.alertTime}',
      if ((event.notes ?? '').trim().isNotEmpty) event.notes!.trim(),
    ];
    return parts.join(' · ');
  }

  IconData _eventIcon(String type) => switch (type) {
    'PHASE_CHANGE' => Icons.timeline,
    'LIGHTING' => Icons.light_mode_outlined,
    'ORDER' => Icons.receipt_long,
    'DELIVERY' => Icons.local_shipping_outlined,
    'FEED' => Icons.restaurant,
    'LITTER_CHANGE' => Icons.cleaning_services_outlined,
    'SANITARY_TREATMENT' => Icons.medical_services_outlined,
    _ => Icons.event,
  };
  Color _eventColor(String type) => switch (type) {
    'LITTER_CHANGE' => Colors.brown,
    'SANITARY_TREATMENT' => Colors.teal,
    _ => const Color(0xFF176B4D),
  };
  String _eventTypeLabel(String type) => switch (type) {
    'PHASE_CHANGE' => 'Fase de criação',
    'LIGHTING' => 'Iluminação',
    'ORDER' => 'Pedido',
    'DELIVERY' => 'Entrega',
    'FEED' => 'Ração',
    'LITTER_CHANGE' => 'Troca de cama',
    'SANITARY_TREATMENT' => 'Tratamento sanitário',
    'ALERT' => 'Alerta',
    _ => 'Evento',
  };
  String _recurrenceLabel(String recurrence) => switch (recurrence) {
    'DAILY' => 'diário',
    'WEEKLY' => 'semanal',
    'MONTHLY' => 'mensal',
    _ => 'uma vez',
  };
}

class _LightingSection extends StatelessWidget {
  const _LightingSection({required this.ref, required this.lots});
  final WidgetRef ref;
  final List<LotSummary> lots;
  @override
  Widget build(BuildContext context) => ref
      .watch(lightingProgramsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (programs) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.light_mode_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Programas de iluminação',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: programs.isEmpty
                          ? null
                          : () => showDialog<void>(
                              context: context,
                              builder: (_) => _AssignLightDialog(
                                ref: ref,
                                lots: lots,
                                programs: programs,
                              ),
                            ),
                      icon: const Icon(Icons.link),
                      label: const Text('Atribuir ao lote'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final p in programs)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(p.name),
                    subtitle: Text(p.description ?? ''),
                    trailing: p.isDefault
                        ? const Chip(label: Text('Padrão'))
                        : null,
                    children: [_LightSteps(ref: ref, program: p)],
                  ),
              ],
            ),
          ),
        ),
      );
}

class _LightSteps extends StatelessWidget {
  const _LightSteps({required this.ref, required this.program});
  final WidgetRef ref;
  final LightingProgram program;
  @override
  Widget build(BuildContext context) => ref
      .watch(lightingStepsProvider(program.id))
      .when(
        loading: () => const Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
        error: (_, _) => const Text('Falha ao carregar etapas.'),
        data: (steps) => Column(
          children: [
            for (final s in steps)
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(
                  '${s.startAgeDays}–${s.endAgeDays?.toString() ?? '∞'} dias · ${(s.totalLightMinutes / 60).toStringAsFixed(1)} h de luz',
                ),
                subtitle: Text(
                  '${s.notes ?? ''}${s.weeklyIncrementMinutes == 0 ? '' : ' · incremento ${s.weeklyIncrementMinutes} min/semana'}',
                ),
              ),
          ],
        ),
      );
}

class _EventDialog extends StatefulWidget {
  const _EventDialog({
    required this.ref,
    required this.initial,
    this.initialType = 'EVENT',
    this.initialTitle,
    this.initialAlertEnabled = true,
  });
  final WidgetRef ref;
  final DateTime initial;
  final String initialType;
  final String? initialTitle;
  final bool initialAlertEnabled;
  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  final title = TextEditingController();
  final notes = TextEditingController();
  final alertTime = TextEditingController(text: '08:00');
  final alertMessage = TextEditingController();
  late String type = widget.initialType;
  String? lot;
  late DateTime date = widget.initial;
  DateTime? repeatUntil;
  late bool alertEnabled = widget.initialAlertEnabled;
  String recurrence = 'ONCE';
  final weekdays = <int>{DateTime.monday};

  @override
  void initState() {
    super.initState();
    title.text = widget.initialTitle ?? '';
  }

  @override
  void dispose() {
    title.dispose();
    notes.dispose();
    alertTime.dispose();
    alertMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots =
        widget.ref.watch(lotSummariesProvider).asData?.value ?? <LotSummary>[];
    return AlertDialog(
      title: Text(widget.initialTitle ?? 'Novo evento'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: [
                  for (final item in const {
                    'EVENT': 'Evento',
                    'ALERT': 'Alerta',
                    'LITTER_CHANGE': 'Troca de cama',
                    'SANITARY_TREATMENT': 'Tratamento sanitário',
                    'FEED': 'Ração',
                    'LIGHTING': 'Iluminação',
                    'PHASE_CHANGE': 'Fase de criação',
                    'ORDER': 'Pedido',
                    'DELIVERY': 'Entrega',
                  }.entries)
                    DropdownMenuItem(value: item.key, child: Text(item.value)),
                ],
                onChanged: (v) => setState(() => type = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: lot,
                decoration: const InputDecoration(labelText: 'Lote (opcional)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Geral')),
                  for (final l in lots)
                    DropdownMenuItem(value: l.lot.id, child: Text(l.lot.name)),
                ],
                onChanged: (v) => setState(() => lot = v),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data'),
                subtitle: Text(shortDate.format(date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await pickSeletoDate(context, date);
                  if (d != null) setState(() => date = d);
                },
              ),
              TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'Observações'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alerta sonoro e vibração'),
                value: alertEnabled,
                onChanged: (v) => setState(() => alertEnabled = v),
              ),
              TextField(
                controller: alertTime,
                enabled: alertEnabled,
                decoration: const InputDecoration(
                  labelText: 'Hora do alerta',
                  hintText: '08:00',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alertMessage,
                enabled: alertEnabled,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mensagem do alerta',
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
                onChanged: alertEnabled
                    ? (v) => setState(() => recurrence = v!)
                    : null,
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
                          onSelected: alertEnabled
                              ? (selected) => setState(() {
                                  selected
                                      ? weekdays.add(item.$1)
                                      : weekdays.remove(item.$1);
                                })
                              : null,
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
                  onTap: alertEnabled
                      ? () async {
                          final d = await pickSeletoDate(
                            context,
                            repeatUntil ?? date,
                          );
                          if (d != null) setState(() => repeatUntil = d);
                        }
                      : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await widget.ref
                  .read(operationsControllerProvider)
                  .addEvent(
                    title.text,
                    type,
                    date,
                    lot,
                    notes.text,
                    alertEnabled: alertEnabled,
                    alertMessage: alertMessage.text,
                    alertTime: alertTime.text,
                    recurrence: recurrence,
                    repeatUntil: repeatUntil,
                    weekdays: weekdays,
                  );
              if (alertEnabled) {
                await NotificationService().testMessage(
                  title: 'GRANJA SELETO · Teste: ${title.text.trim()}',
                  body: alertMessage.text.trim().isEmpty
                      ? 'Teste do alerta criado.'
                      : alertMessage.text.trim(),
                );
              }
              if (context.mounted) {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                if (alertEnabled) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Alerta criado. Teste agendado para daqui a 5 segundos.',
                      ),
                    ),
                  );
                }
              }
            } catch (e) {
              await showOperationError(context, e);
            }
          },
          child: const Text('Criar'),
        ),
      ],
    );
  }
}

class _AssignLightDialog extends StatefulWidget {
  const _AssignLightDialog({
    required this.ref,
    required this.lots,
    required this.programs,
  });
  final WidgetRef ref;
  final List<LotSummary> lots;
  final List<LightingProgram> programs;
  @override
  State<_AssignLightDialog> createState() => _AssignLightDialogState();
}

class _AssignLightDialogState extends State<_AssignLightDialog> {
  String? lot;
  String? program;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Programa de luz do lote'),
    content: SizedBox(
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: lot,
            decoration: const InputDecoration(labelText: 'Lote'),
            items: [
              for (final l in widget.lots)
                DropdownMenuItem(
                  value: l.lot.id,
                  child: Text(l.lot.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => lot = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: program,
            decoration: const InputDecoration(labelText: 'Programa'),
            items: [
              for (final p in widget.programs)
                DropdownMenuItem(
                  value: p.id,
                  child: Text(p.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => program = v),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: lot == null || program == null
            ? null
            : () async {
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .assignLight(lot!, program!);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                }
              },
        child: const Text('Atribuir'),
      ),
    ],
  );
}
