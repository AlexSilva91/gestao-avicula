import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../egg_collection/application/egg_collection_controller.dart';
import '../../../lots/application/lots_controller.dart';
import '../../../lots/domain/value_objects/lot_lifecycle.dart';
import '../../../operations/application/operations_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(dashboardMetricsProvider).asData?.value;
    final eggs = ref.watch(eggMetricsProvider).asData?.value;
    final lots = ref.watch(lotSummariesProvider).asData?.value ?? [];
    final series = ref.watch(eggProductionSeriesProvider).asData?.value ?? [];
    return AppShell(
      title: 'Visão geral',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeletoKpiGrid(
            children: [
              SeletoKpiCard(
                label: 'Aves ativas',
                value: m?.activeBirds.toString() ?? '—',
                icon: Icons.egg_alt_outlined,
                color: const Color(0xFF176B4D),
              ),
              SeletoKpiCard(
                label: 'Ovos hoje',
                value: eggs?.eggsToday.toString() ?? '—',
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFFE59E2D),
              ),
              SeletoKpiCard(
                label: 'Estoque de ovos',
                value: m?.eggStock.toString() ?? '—',
                icon: Icons.egg_outlined,
              ),
              SeletoKpiCard(
                label: 'Estoque de ração',
                value: m == null ? '—' : kg(m.feedStockKg),
                icon: Icons.agriculture_outlined,
              ),
              SeletoKpiCard(
                label: 'Pedidos pendentes',
                value: m?.pendingOrders.toString() ?? '—',
                icon: Icons.receipt_long_outlined,
              ),
              SeletoKpiCard(
                label: 'Faturamento do mês',
                value: m == null ? '—' : money(m.monthIncomeCents),
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              SeletoKpiCard(
                label: 'Despesas do mês',
                value: m == null ? '—' : money(m.monthExpenseCents),
                icon: Icons.trending_down,
                color: Colors.red,
              ),
              SeletoKpiCard(
                label: 'Resultado do mês',
                value: m == null
                    ? '—'
                    : money(m.monthIncomeCents - m.monthExpenseCents),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, box) => box.maxWidth > 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _ProductionChart(series: series),
                      ),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _AlertsCard(lots: lots)),
                    ],
                  )
                : Column(
                    children: [
                      _ProductionChart(series: series),
                      const SizedBox(height: 16),
                      _AlertsCard(lots: lots),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          _QuickActions(ref: ref),
        ],
      ),
    );
  }
}

class _ProductionChart extends StatelessWidget {
  const _ProductionChart({required this.series});
  final List<dynamic> series;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spots = [
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].value),
    ];
    final peak = spots.fold<double>(
      0,
      (max, spot) => spot.y > max ? spot.y : max,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surface,
                scheme.primaryContainer.withValues(alpha: .10),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Produção recente',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 240,
                  child: series.isEmpty
                      ? const Center(
                          child: Text(
                            'As coletas formarão o gráfico de produção.',
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: peak == 0 ? 10 : peak * 1.18,
                            clipData: const FlClipData.all(),
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: scheme.outlineVariant.withValues(
                                  alpha: .36,
                                ),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: series.length > 1,
                                  reservedSize: 30,
                                  interval: (series.length / 4)
                                      .ceil()
                                      .clamp(1, 99)
                                      .toDouble(),
                                  getTitlesWidget: (v, meta) {
                                    final i = v.toInt();
                                    if (i < 0 || i >= series.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        series[i].label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 38,
                                ),
                              ),
                            ),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (_) => scheme.inverseSurface,
                                getTooltipItems: (items) => [
                                  for (final item in items)
                                    LineTooltipItem(
                                      '${item.y.toStringAsFixed(0)} ovos',
                                      TextStyle(
                                        color: scheme.onInverseSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                preventCurveOverShooting: true,
                                barWidth: 4,
                                gradient: LinearGradient(
                                  colors: [
                                    scheme.primary,
                                    const Color(0xFFE59E2D),
                                  ],
                                ),
                                dotData: FlDotData(
                                  show: series.length <= 12,
                                  getDotPainter: (_, _, _, _) =>
                                      FlDotCirclePainter(
                                        radius: 3,
                                        color: scheme.surface,
                                        strokeWidth: 2,
                                        strokeColor: scheme.primary,
                                      ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      scheme.primary.withValues(alpha: .22),
                                      scheme.primary.withValues(alpha: .02),
                                    ],
                                  ),
                                ),
                                spots: spots,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.lots});
  final List<dynamic> lots;
  @override
  Widget build(BuildContext context) {
    final upcoming = <({String name, String phase, int days})>[];
    for (final s in lots) {
      final birth = LotLifecycle.estimatedBirthDate(
        receivedAt: s.lot.receivedAt,
        arrivalAgeDays: s.lot.arrivalAgeDays,
      );
      final age = LotLifecycle.ageInDays(
        receivedAt: s.lot.receivedAt,
        arrivalAgeDays: s.lot.arrivalAgeDays,
      );
      final phase = LotLifecycle.phaseForAge(age);
      final date = LotLifecycle.nextPhaseDate(
        birthDate: birth,
        currentPhase: phase,
      );
      if (date != null) {
        final days = date.difference(DateTime.now()).inDays;
        if (days <= 30) {
          upcoming.add((
            name: s.lot.name,
            phase: LotLifecycle.nextPhase(phase)!.label,
            days: days,
          ));
        }
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas e próximas tarefas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Nenhuma mudança de fase nos próximos 30 dias'),
              )
            else
              for (final item in upcoming)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_available),
                  title: Text('${item.name}: ${item.phase}'),
                  subtitle: Text(
                    item.days <= 0
                        ? 'Mudança prevista hoje'
                        : 'Em ${item.days} dia(s)',
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).session;
    final actions = [
      ('/lots', Icons.addchart, 'Novo lote', 'birds.purchase'),
      (
        '/egg-collection',
        Icons.egg_alt_outlined,
        'Registrar coleta',
        'egg_collection.create',
      ),
      ('/feed', Icons.restaurant, 'Alimentação', 'feeding.register'),
      ('/commercial', Icons.point_of_sale, 'Nova venda', 'sales.create'),
    ].where((a) => session?.allows(a.$4) ?? false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final action in actions)
                  FilledButton.tonalIcon(
                    onPressed: () => context.go(action.$1),
                    icon: Icon(action.$2),
                    label: Text(action.$3),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
