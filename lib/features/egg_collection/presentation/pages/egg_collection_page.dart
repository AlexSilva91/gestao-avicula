import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/design_tokens.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../application/egg_collection_controller.dart';

class EggCollectionPage extends ConsumerWidget {
  const EggCollectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Coleta de ovos',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _openForm(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Registrar coleta'),
          ),
        ),
        const SizedBox(height: 16),
        ref
            .watch(eggMetricsProvider)
            .when(
              loading: () => const _MetricsLoading(),
              error: (_, _) => const _MetricsError(),
              data: (metrics) => _EggMetrics(metrics: metrics),
            ),
        const SizedBox(height: 16),
        const _LayingRateHistorySection(),
        const SizedBox(height: 16),
        Text('Coletas recentes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ref
            .watch(recentEggCollectionsProvider)
            .when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) =>
                  const Text('Não foi possível carregar as coletas.'),
              data: (collections) => collections.isEmpty
                  ? const _NoCollections()
                  : _CollectionList(collections: collections),
            ),
      ],
    ),
  );

  void _openForm(BuildContext context, WidgetRef ref) => showDialog<void>(
    context: context,
    builder: (_) => _CollectionDialog(ref: ref),
  );
}

class _LayingRateHistorySection extends ConsumerWidget {
  const _LayingRateHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyLayingRatesProvider);
    final monthly = ref.watch(monthlyLayingRatesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico de postura',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, box) {
            final dailyCard = _LayingRateCard(
              title: 'Taxa diária por lote',
              entries: daily,
              periodLabel: (entry) => shortDate.format(entry.periodStart),
              detailLabel: (entry) =>
                  '${entry.totalEggs} ovos · ${entry.activeBirdDays} aves',
            );
            final monthlyCard = _LayingRateCard(
              title: 'Taxa mensal por lote',
              entries: monthly,
              periodLabel: (entry) =>
                  DateFormat('MM/yyyy', 'pt_BR').format(entry.periodStart),
              detailLabel: (entry) =>
                  '${entry.collectionDays} dias · ${entry.totalEggs} ovos · ${entry.activeBirdDays} ave-dia',
            );
            if (box.maxWidth >= 860) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: dailyCard),
                  const SizedBox(width: 12),
                  Expanded(child: monthlyCard),
                ],
              );
            }
            return Column(
              children: [dailyCard, const SizedBox(height: 12), monthlyCard],
            );
          },
        ),
      ],
    );
  }
}

class _LayingRateCard extends StatelessWidget {
  const _LayingRateCard({
    required this.title,
    required this.entries,
    required this.periodLabel,
    required this.detailLabel,
  });

  final String title;
  final AsyncValue<List<LayingRateHistoryEntry>> entries;
  final String Function(LayingRateHistoryEntry entry) periodLabel;
  final String Function(LayingRateHistoryEntry entry) detailLabel;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          entries.when(
            loading: () => const SizedBox(
              height: 144,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Não foi possível calcular a taxa de postura.'),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Registre coletas para formar o histórico.'),
                );
              }
              final visible = items.take(8).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final entry = visible[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text('${entry.totalEggs.clamp(0, 999)}'),
                    ),
                    title: Text(
                      entry.lotName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${periodLabel(entry)} · ${detailLabel(entry)} · ${entry.stockEggs} aptos',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 72,
                      child: Text(
                        percent(entry.layingRate),
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _EggMetrics extends StatelessWidget {
  const _EggMetrics({required this.metrics});
  final EggMetrics metrics;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final count = box.maxWidth >= 850
          ? 3
          : box.maxWidth >= 520
          ? 2
          : 1;
      return GridView.count(
        crossAxisCount: count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: count == 1 ? 2.8 : 1.85,
        children: [
          _Metric('Ovos hoje', '${metrics.eggsToday}', Icons.egg_alt_outlined),
          _Metric(
            'Ovos no mês',
            '${metrics.eggsThisMonth}',
            Icons.calendar_month_outlined,
          ),
          _Metric(
            'Estoque',
            '${metrics.stock} · ${metrics.dozensInStock.toStringAsFixed(1)} dúzias',
            Icons.inventory_2_outlined,
          ),
        ],
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 5),
                Text(value, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MetricsLoading extends StatelessWidget {
  const _MetricsLoading();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 120,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _MetricsError extends StatelessWidget {
  const _MetricsError();
  @override
  Widget build(BuildContext context) =>
      const Text('Não foi possível calcular os indicadores de ovos.');
}

class _NoCollections extends StatelessWidget {
  const _NoCollections();
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.egg_alt_outlined, size: 44),
            const SizedBox(height: 12),
            const Text('Nenhuma coleta registrada ainda.'),
          ],
        ),
      ),
    ),
  );
}

class _CollectionList extends ConsumerWidget {
  const _CollectionList({required this.collections});
  final List<EggCollection> collections;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lots = ref.watch(lotSummariesProvider).asData?.value ?? const [];
    final names = {for (final lot in lots) lot.lot.id: lot.lot.name};
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: collections.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final item = collections[index];
          final usable = item.cleanEggs + item.dirtyEggs;
          final losses = item.crackedEggs + item.brokenEggs;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 7,
            ),
            leading: CircleAvatar(child: Text('${item.quantity}')),
            title: Text(names[item.lotId] ?? 'Lote removido'),
            subtitle: Text(
              '${DateFormat('dd/MM/yyyy').format(item.collectedOn)} · '
              '$usable no estoque · ${item.cleanEggs} limpos · ${item.dirtyEggs} sujos',
            ),
            trailing: losses > 0
                ? Text('$losses perda(s)')
                : const Icon(Icons.check_circle_outline),
          );
        },
      ),
    );
  }
}

class _CollectionDialog extends ConsumerStatefulWidget {
  const _CollectionDialog({required this.ref});
  final WidgetRef ref;
  @override
  ConsumerState<_CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends ConsumerState<_CollectionDialog> {
  final _form = GlobalKey<FormState>();
  final _clean = TextEditingController(text: '0');
  final _dirty = TextEditingController(text: '0');
  final _cracked = TextEditingController(text: '0');
  final _broken = TextEditingController(text: '0');
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  String? _lotId;
  bool _saving = false;
  @override
  void dispose() {
    _clean.dispose();
    _dirty.dispose();
    _cracked.dispose();
    _broken.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots = (ref.watch(lotSummariesProvider).asData?.value ?? const [])
        .where((lot) => lot.activeBirds > 0)
        .toList();
    final clean = _readEggCount(_clean);
    final dirty = _readEggCount(_dirty);
    final cracked = _readEggCount(_cracked);
    final broken = _readEggCount(_broken);
    final total = clean + dirty + cracked + broken;
    final stock = clean + dirty;
    final losses = cracked + broken;
    return AlertDialog(
      title: const Text('Registrar coleta'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _lotId,
                  decoration: const InputDecoration(labelText: 'Lote *'),
                  items: [
                    for (final lot in lots)
                      DropdownMenuItem(
                        value: lot.lot.id,
                        child: Text(lot.lot.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _lotId = value),
                  validator: (value) =>
                      value == null ? 'Selecione o lote.' : null,
                ),
                const SizedBox(height: 12),
                _DateSelector(
                  date: _date,
                  onChanged: (value) => setState(() => _date = value),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, box) {
                    final fields = [
                      TextFormField(
                        controller: _clean,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Limpos'),
                        validator: _nonNegative,
                        onChanged: (_) => setState(() {}),
                      ),
                      TextFormField(
                        controller: _dirty,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Sujos'),
                        validator: _nonNegative,
                        onChanged: (_) => setState(() {}),
                      ),
                      TextFormField(
                        controller: _cracked,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Trincados',
                        ),
                        validator: _nonNegative,
                        onChanged: (_) => setState(() {}),
                      ),
                      TextFormField(
                        controller: _broken,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quebrados',
                        ),
                        validator: _nonNegative,
                        onChanged: (_) => setState(() {}),
                      ),
                    ];
                    if (box.maxWidth > 460) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: fields[0]),
                              const SizedBox(width: 12),
                              Expanded(child: fields[1]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: fields[2]),
                              const SizedBox(width: 12),
                              Expanded(child: fields[3]),
                            ],
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < fields.length; i++) ...[
                          fields[i],
                          if (i < fields.length - 1) const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Material(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: .56),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _CollectionTotal(
                            label: 'Total coletado',
                            value: total,
                          ),
                        ),
                        Expanded(
                          child: _CollectionTotal(
                            label: 'Vai ao estoque',
                            value: stock,
                          ),
                        ),
                        Expanded(
                          child: _CollectionTotal(
                            label: 'Perdas',
                            value: losses,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Observações'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Salvando...' : 'Salvar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final clean = _readEggCount(_clean);
    final dirty = _readEggCount(_dirty);
    final cracked = _readEggCount(_cracked);
    final broken = _readEggCount(_broken);
    final total = clean + dirty + cracked + broken;
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe ao menos um ovo coletado.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.ref
          .read(eggCollectionControllerProvider)
          .register(
            date: _date,
            lotId: _lotId!,
            quantity: total,
            cleanEggs: clean,
            dirtyEggs: dirty,
            crackedEggs: cracked,
            brokenEggs: broken,
            discardedEggs: cracked,
            notes: _notes.text,
          );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error
                  .toString()
                  .replaceFirst('Bad state: ', '')
                  .replaceFirst('Invalid argument(s): ', '')
                  .replaceFirst('Invalid argument: ', '')
                  .replaceFirst('FormatException: ', ''),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _readEggCount(TextEditingController controller) =>
      int.tryParse(controller.text.trim()) ?? 0;
}

class _CollectionTotal extends StatelessWidget {
  const _CollectionTotal({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        '$value',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
    onTap: () async {
      final picked = await pickSeletoDate(
        context,
        date,
        firstDate: DateTime(2010),
        lastDate: DateTime.now(),
      );
      if (picked != null) onChanged(picked);
    },
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Data da coleta',
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
      child: Text(DateFormat('dd/MM/yyyy').format(date)),
    ),
  );
}

String? _nonNegative(String? value) =>
    (int.tryParse(value ?? '') ?? -1) < 0 ? 'Informe um número válido.' : null;
