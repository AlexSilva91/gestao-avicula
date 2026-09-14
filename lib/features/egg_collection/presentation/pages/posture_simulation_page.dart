import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../application/egg_collection_controller.dart';

class PostureSimulationPage extends ConsumerStatefulWidget {
  const PostureSimulationPage({super.key});

  @override
  ConsumerState<PostureSimulationPage> createState() =>
      _PostureSimulationPageState();
}

class _PostureSimulationPageState extends ConsumerState<PostureSimulationPage> {
  final _rate = TextEditingController(text: '80');

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots = ref.watch(lotSummariesProvider).asData?.value ?? const [];
    final activeLots = lots.where((lot) => lot.activeBirds > 0).toList();
    final activeBirds = activeLots.fold<int>(
      0,
      (total, lot) => total + lot.activeBirds,
    );
    final ratePercent = _parsePercent(_rate.text);
    final rate = ratePercent / 100;
    final eggsPerDay = activeBirds * rate;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final monthEnd = DateTime(today.year, today.month + 1);
    final remainingMonthDays = monthEnd.difference(todayStart).inDays;
    final daysInMonth = monthEnd
        .difference(DateTime(today.year, today.month))
        .inDays;

    return AppShell(
      title: 'Simulação de postura',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SeletoPageHeader(
            title: 'Simulação de postura',
            subtitle:
                'Compare a taxa registrada nas coletas e projete a produção com a taxa desejada.',
          ),
          const SizedBox(height: 14),
          ref
              .watch(monthlyPostureComparisonProvider)
              .when(
                loading: () => const _LoadingPanel(),
                error: (_, _) => const SeletoAsyncError(
                  message: 'Não foi possível comparar a taxa de postura.',
                ),
                data: (comparison) =>
                    _MonthlyComparison(comparison: comparison),
              ),
          const SizedBox(height: 16),
          _SimulationInputs(
            rate: _rate,
            activeBirds: activeBirds,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 16),
          SeletoKpiGrid(
            children: [
              SeletoKpiCard(
                label: 'Ovos por dia',
                value: _eggs(eggsPerDay),
                icon: Icons.today_outlined,
              ),
              SeletoKpiCard(
                label: 'Projeção 7 dias',
                value: _eggs(eggsPerDay * 7),
                icon: Icons.view_week_outlined,
              ),
              SeletoKpiCard(
                label: 'Projeção 30 dias',
                value: _eggs(eggsPerDay * 30),
                icon: Icons.calendar_view_month_outlined,
              ),
              SeletoKpiCard(
                label: 'Restante do mês',
                value: _eggs(eggsPerDay * remainingMonthDays),
                icon: Icons.event_available_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProjectionBreakdown(
            activeLots: activeLots,
            rate: rate,
            daysInMonth: daysInMonth,
            remainingMonthDays: remainingMonthDays,
          ),
        ],
      ),
    );
  }
}

class _MonthlyComparison extends StatelessWidget {
  const _MonthlyComparison({required this.comparison});
  final MonthlyPostureComparison comparison;

  @override
  Widget build(BuildContext context) {
    final current = comparison.current;
    final previous = comparison.previous;
    final delta = comparison.rateDelta;
    final deltaColor = delta >= 0
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SeletoSectionHeader(title: 'Comparativo mensal'),
        SeletoKpiGrid(
          children: [
            SeletoKpiCard(
              label: 'Mês anterior',
              value: _rateValue(previous),
              icon: Icons.history_outlined,
            ),
            SeletoKpiCard(
              label: 'Mês atual',
              value: _rateValue(current),
              icon: Icons.query_stats_outlined,
            ),
            SeletoKpiCard(
              label: 'Variação',
              value: _signedPercent(delta),
              icon: delta >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: deltaColor,
            ),
            SeletoKpiCard(
              label: 'Ovos no mês atual',
              value: decimal.format(current.totalEggs),
              icon: Icons.egg_alt_outlined,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ComparisonDetails(current: current, previous: previous),
      ],
    );
  }
}

class _ComparisonDetails extends StatelessWidget {
  const _ComparisonDetails({required this.current, required this.previous});
  final MonthlyPosturePeriod current;
  final MonthlyPosturePeriod previous;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final cards = [
        _PeriodCard(title: _periodLabel(previous), period: previous),
        _PeriodCard(title: _periodLabel(current), period: current),
      ];
      if (box.maxWidth >= 820) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        );
      }
      return Column(children: [cards[0], const SizedBox(height: 12), cards[1]]);
    },
  );
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.title, required this.period});
  final String title;
  final MonthlyPosturePeriod period;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          _DetailRow('Taxa', _rateValue(period)),
          _DetailRow('Ovos coletados', decimal.format(period.totalEggs)),
          _DetailRow('Ovos aptos', decimal.format(period.stockEggs)),
          _DetailRow('Perdas', decimal.format(period.lostEggs)),
          _DetailRow('Dias com coleta', decimal.format(period.collectionDays)),
          _DetailRow('Ave-dia', decimal.format(period.activeBirdDays)),
        ],
      ),
    ),
  );
}

class _SimulationInputs extends StatelessWidget {
  const _SimulationInputs({
    required this.rate,
    required this.activeBirds,
    required this.onChanged,
  });

  final TextEditingController rate;
  final int activeBirds;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, box) {
          final rateField = TextFormField(
            controller: rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Taxa simulada (%)',
              prefixIcon: Icon(Icons.percent_rounded),
              hintText: 'Ex.: 82,5',
            ),
            onChanged: (_) => onChanged(),
          );
          final birds = _ReadonlyMetric(
            label: 'Aves ativas',
            value: decimal.format(activeBirds),
            icon: Icons.groups_2_outlined,
          );
          if (box.maxWidth >= 720) {
            return Row(
              children: [
                Expanded(child: rateField),
                const SizedBox(width: 12),
                Expanded(child: birds),
              ],
            );
          }
          return Column(
            children: [rateField, const SizedBox(height: 12), birds],
          );
        },
      ),
    ),
  );
}

class _ReadonlyMetric extends StatelessWidget {
  const _ReadonlyMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .52),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
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

class _ProjectionBreakdown extends StatelessWidget {
  const _ProjectionBreakdown({
    required this.activeLots,
    required this.rate,
    required this.daysInMonth,
    required this.remainingMonthDays,
  });

  final List<LotSummary> activeLots;
  final double rate;
  final int daysInMonth;
  final int remainingMonthDays;

  @override
  Widget build(BuildContext context) {
    if (activeLots.isEmpty) {
      return const SeletoEmptyState(
        icon: Icons.groups_2_outlined,
        title: 'Nenhum lote ativo',
        message: 'Cadastre aves ativas para projetar a postura.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SeletoSectionHeader(title: 'Projeção por lote'),
        SeletoListCard(
          children: [
            for (final lot in activeLots)
              ListTile(
                leading: CircleAvatar(child: Text('${lot.activeBirds}')),
                title: Text(
                  lot.lot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_eggs(lot.activeBirds * rate)} ovos/dia · '
                  '${_eggs(lot.activeBirds * rate * remainingMonthDays)} restantes',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: SizedBox(
                  width: 92,
                  child: Text(
                    '${_eggs(lot.activeBirds * rate * daysInMonth)} / mês',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 120,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    ),
  );
}

double _parsePercent(String value) {
  final cleaned = value
      .replaceAll(RegExp(r'[^0-9,.-]'), '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
  return (double.tryParse(cleaned) ?? 0).clamp(0, 150).toDouble();
}

String _rateValue(MonthlyPosturePeriod period) =>
    period.activeBirdDays <= 0 ? 'Sem dados' : percent(period.layingRate);

String _signedPercent(double value) {
  final formatted = percent(value.abs());
  if (value == 0) return formatted;
  return value > 0 ? '+$formatted' : '-$formatted';
}

String _eggs(double value) => decimal.format(value.round());

String _periodLabel(MonthlyPosturePeriod period) =>
    DateFormat('MMM/yyyy', 'pt_BR').format(period.periodStart);
