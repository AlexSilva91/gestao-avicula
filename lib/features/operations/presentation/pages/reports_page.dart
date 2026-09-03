import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../egg_collection/application/egg_collection_controller.dart';
import '../../application/operations_controller.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardMetricsProvider).asData?.value;
    final eggs = ref.watch(eggMetricsProvider).asData?.value;
    final layingRate = dashboard == null || dashboard.activeBirds == 0
        ? 0.0
        : (eggs?.eggsToday ?? 0) / dashboard.activeBirds;
    final costPerEgg =
        dashboard == null ||
            dashboard.monthExpenseCents == 0 ||
            (eggs?.eggsThisMonth ?? 0) == 0
        ? 0
        : dashboard.monthExpenseCents / (eggs!.eggsThisMonth);
    return AppShell(
      title: 'Relatórios',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in [
                'Hoje',
                '7 dias',
                '30 dias',
                'Este mês',
                'Este ano',
                'Personalizado',
              ])
                FilterChip(
                  label: Text(f),
                  selected: f == '30 dias',
                  onSelected: (_) {},
                ),
            ],
          ),
          const SizedBox(height: 20),
          SeletoKpiGrid(
            children: [
              SeletoKpiCard(
                label: 'Taxa de postura hoje',
                value: percent(layingRate),
                icon: Icons.percent,
              ),
              SeletoKpiCard(
                label: 'Custo operacional/ovo',
                value: money(costPerEgg.round()),
                icon: Icons.egg_outlined,
              ),
              SeletoKpiCard(
                label: 'Custo operacional/dúzia',
                value: money((costPerEgg * 12).round()),
                icon: Icons.inventory_2,
              ),
              SeletoKpiCard(
                label: 'Ração consumida/mês',
                value: dashboard == null ? '—' : kg(dashboard.monthFeedKg),
                icon: Icons.restaurant,
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, box) => box.maxWidth > 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _EggChart(
                          points:
                              ref
                                  .watch(eggProductionSeriesProvider)
                                  .asData
                                  ?.value ??
                              [],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FinanceChart(
                          points:
                              ref.watch(financeSeriesProvider).asData?.value ??
                              [],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _EggChart(
                        points:
                            ref
                                .watch(eggProductionSeriesProvider)
                                .asData
                                ?.value ??
                            [],
                      ),
                      const SizedBox(height: 16),
                      _FinanceChart(
                        points:
                            ref.watch(financeSeriesProvider).asData?.value ??
                            [],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _LayingRateChart(
            entries: ref.watch(monthlyLayingRatesProvider).asData?.value ?? [],
          ),
          const SizedBox(height: 16),
          const SeletoEmptyState(
            icon: Icons.tips_and_updates_outlined,
            title: 'Leitura correta dos números',
            message:
                'Faturamento, despesas, resultado, margem após alimentação e custo operacional são indicadores distintos no SELETO.',
          ),
        ],
      ),
    );
  }
}

class _EggChart extends StatelessWidget {
  const _EggChart({required this.points});
  final List<ReportPoint> points;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final peak = points.fold<double>(
      0,
      (max, point) => point.value > max ? point.value : max,
    );
    return _ChartCard(
      title: 'Produção de ovos · 30 dias',
      child: points.isEmpty
          ? const Center(child: Text('Registre coletas para formar o gráfico.'))
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: peak == 0 ? 10 : peak * 1.18,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: scheme.outlineVariant.withValues(alpha: .36),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 42),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: (points.length / 5).ceilToDouble(),
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        return i >= 0 && i < points.length
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  points[i].label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
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
                    barWidth: 4,
                    preventCurveOverShooting: true,
                    gradient: LinearGradient(
                      colors: [scheme.primary, const Color(0xFFE59E2D)],
                    ),
                    dotData: FlDotData(
                      show: points.length <= 12,
                      getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                        radius: 3.5,
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
                          scheme.primary.withValues(alpha: .20),
                          scheme.primary.withValues(alpha: .02),
                        ],
                      ),
                    ),
                    spots: [
                      for (var i = 0; i < points.length; i++)
                        FlSpot(i.toDouble(), points[i].value),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _FinanceChart extends StatelessWidget {
  const _FinanceChart({required this.points});
  final List<ReportPoint> points;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final green = const Color(0xFF176B4D);
    final red = const Color(0xFFB94735);
    final peak = points.fold<double>(
      0,
      (max, point) =>
          [max, point.value, point.secondary].reduce((a, b) => a > b ? a : b),
    );
    return _ChartCard(
      title: 'Receitas × despesas',
      child: points.isEmpty
          ? const Center(
              child: Text('Os lançamentos formarão o gráfico financeiro.'),
            )
          : BarChart(
              BarChartData(
                maxY: peak == 0 ? 10 : peak * 1.22,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: scheme.outlineVariant.withValues(alpha: .32),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 48),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        return i >= 0 && i < points.length
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  points[i].label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => scheme.inverseSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0 ? 'Receita' : 'Despesa';
                      return BarTooltipItem(
                        '$label\n${money((rod.toY * 100).round())}',
                        TextStyle(
                          color: scheme.onInverseSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < points.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 5,
                      barRods: [
                        BarChartRodData(
                          toY: points[i].value,
                          width: 11,
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [green.withValues(alpha: .64), green],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                        ),
                        BarChartRodData(
                          toY: points[i].secondary,
                          width: 11,
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [red.withValues(alpha: .64), red],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

class _LayingRateChart extends StatelessWidget {
  const _LayingRateChart({required this.entries});
  final List<LayingRateHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = [...entries]
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));
    final visible = sorted.length > 10
        ? sorted.skip(sorted.length - 10).toList()
        : sorted;
    final bars = [
      for (var i = 0; i < visible.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (visible[i].layingRate * 100).clamp(0, 140).toDouble(),
              width: 18,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  scheme.tertiary.withValues(alpha: .62),
                  scheme.primary,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 100,
                color: scheme.surfaceContainerHighest.withValues(alpha: .62),
              ),
            ),
          ],
        ),
    ];
    final peak = visible.fold<double>(
      100,
      (max, entry) => math.max(max, entry.layingRate * 100),
    );
    return _ChartCard(
      title: 'Taxa de postura por lote',
      child: visible.isEmpty
          ? const Center(
              child: Text('Registre coletas para comparar a postura.'),
            )
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: math.max(110, peak * 1.14),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: value == 100
                        ? scheme.primary.withValues(alpha: .30)
                        : scheme.outlineVariant.withValues(alpha: .28),
                    strokeWidth: value == 100 ? 1.4 : 1,
                    dashArray: value == 100 ? [6, 4] : null,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= visible.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              Text(
                                DateFormat(
                                  'MM/yy',
                                  'pt_BR',
                                ).format(visible[i].periodStart),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                visible[i].lotName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => scheme.inverseSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = visible[group.x];
                      return BarTooltipItem(
                        '${entry.lotName}\n${percent(entry.layingRate)} · ${entry.totalEggs} ovos',
                        TextStyle(
                          color: scheme.onInverseSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: bars,
              ),
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: .10),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.query_stats,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(height: 280, child: child),
          ],
        ),
      ),
    ),
  );
}
