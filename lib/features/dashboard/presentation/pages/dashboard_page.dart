import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/design_tokens.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../egg_collection/application/egg_collection_controller.dart';
import '../../../lots/application/lots_controller.dart';
import '../../../lots/domain/value_objects/lot_lifecycle.dart';
import '../../../operations/application/operations_controller.dart';

const _chartColors = [
  Color(0xFF176B4D),
  Color(0xFFE59E2D),
  Color(0xFF2F5F8F),
  Color(0xFFC84C3A),
  Color(0xFF4F7C6B),
  Color(0xFF7A5C9E),
];

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider).asData?.value;
    final eggs = ref.watch(eggMetricsProvider).asData?.value;
    final lots = ref.watch(lotSummariesProvider).asData?.value ?? const [];
    final lotPerformance =
        ref.watch(dashboardLotPerformanceProvider).asData?.value ?? const [];
    final dailySeries =
        ref.watch(dashboardDailySeriesProvider).asData?.value ?? const [];
    final phaseLots = lots
        .where((summary) => summary.lot.status == 'ACTIVE')
        .map(_LotPhaseSnapshot.fromSummary)
        .toList();

    return AppShell(
      title: 'Visão geral',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FarmPulsePanel(metrics: metrics, eggs: eggs),
          const SizedBox(height: 14),
          _DashboardChartGrid(
            children: [
              _LotPerformanceChart(points: lotPerformance),
              _DailyFeedChart(points: dailySeries),
              _SalesChart(points: dailySeries),
              _PostureRateChart(
                points: dailySeries,
                activeBirds: metrics?.activeBirds ?? 0,
              ),
              _LotPhaseAgeChart(lots: phaseLots),
              _MortalityChart(points: lotPerformance),
            ],
          ),
          const SizedBox(height: 14),
          _QuickActions(ref: ref),
        ],
      ),
    );
  }
}

class _FarmPulsePanel extends StatelessWidget {
  const _FarmPulsePanel({required this.metrics, required this.eggs});

  final DashboardMetrics? metrics;
  final EggMetrics? eggs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final result = metrics == null
        ? null
        : metrics!.monthIncomeCents - metrics!.monthExpenseCents;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: .94),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .72)),
        borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.query_stats, color: scheme.primary),
              Text(
                'Painel operacional da granja',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MetricGrid(
            children: [
              _MetricPill(
                icon: Icons.egg_alt_outlined,
                label: 'Aves ativas',
                value: metrics?.activeBirds.toString() ?? '-',
                color: _chartColors[0],
              ),
              _MetricPill(
                icon: Icons.inventory_2_outlined,
                label: 'Ovos hoje',
                value: eggs?.eggsToday.toString() ?? '-',
                color: _chartColors[1],
              ),
              _MetricPill(
                icon: Icons.egg_outlined,
                label: 'Estoque de ovos',
                value: metrics?.eggStock.toString() ?? '-',
                color: _chartColors[2],
              ),
              _MetricPill(
                icon: Icons.agriculture_outlined,
                label: 'Ração',
                value: metrics == null ? '-' : kg(metrics!.feedStockKg),
                color: _chartColors[4],
              ),
              _MetricPill(
                icon: Icons.point_of_sale,
                label: 'Resultado mês',
                value: result == null ? '-' : money(result),
                color: result == null || result >= 0
                    ? _chartColors[0]
                    : _chartColors[3],
              ),
              _MetricPill(
                icon: Icons.receipt_long_outlined,
                label: 'Pedidos pendentes',
                value: metrics?.pendingOrders.toString() ?? '-',
                color: _chartColors[5],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        border: Border.all(color: color.withValues(alpha: .24)),
        borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 10.0;
      const columns = 2;
      final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _DashboardChartGrid extends StatelessWidget {
  const _DashboardChartGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760 ? 2 : 1;
      const gap = 12.0;
      final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _LotPerformanceChart extends StatelessWidget {
  const _LotPerformanceChart({required this.points});

  final List<LotPerformancePoint> points;

  @override
  Widget build(BuildContext context) {
    final visible = points.take(8).toList();
    return _ChartPanel(
      title: 'Desempenho por lote',
      subtitle: 'Taxa de postura nos últimos 30 dias',
      icon: Icons.bar_chart,
      child: visible.isEmpty
          ? const _EmptyChart(message: 'Os lotes ativos aparecerão aqui.')
          : _BarChart(
              labels: [for (final point in visible) _shortLabel(point.lotName)],
              values: [for (final point in visible) point.layingRate * 100],
              colorForIndex: (index) =>
                  _chartColors[index % _chartColors.length],
              suffix: '%',
            ),
    );
  }
}

class _DailyFeedChart extends StatelessWidget {
  const _DailyFeedChart({required this.points});

  final List<DailyDashboardPoint> points;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final feedPoints = points
        .where(
          (point) =>
              point.date.year == now.year &&
              point.date.month == now.month &&
              point.feedKg > 0,
        )
        .toList();
    return _ChartPanel(
      title: 'Alimentação diária',
      subtitle: 'Ração registrada no mês atual',
      icon: Icons.restaurant,
      child: feedPoints.isEmpty
          ? const _EmptyChart(
              message: 'Registre alimentação neste mês para formar a série.',
            )
          : _LineChart(
              labels: [for (final point in feedPoints) _dayLabel(point.date)],
              values: [for (final point in feedPoints) point.feedKg],
              color: _chartColors[4],
              unitSuffix: ' kg',
            ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.points});

  final List<DailyDashboardPoint> points;

  @override
  Widget build(BuildContext context) {
    return _ChartPanel(
      title: 'Desempenho de vendas',
      subtitle: 'Faturamento diário confirmado',
      icon: Icons.point_of_sale,
      child: points.where((point) => point.salesCents > 0).isEmpty
          ? const _EmptyChart(message: 'As vendas confirmadas aparecerão aqui.')
          : _LineChart(
              labels: [for (final point in points) point.label],
              values: [for (final point in points) point.salesCents / 100],
              color: _chartColors[2],
              unitPrefix: 'R\$ ',
            ),
    );
  }
}

class _PostureRateChart extends StatelessWidget {
  const _PostureRateChart({required this.points, required this.activeBirds});

  final List<DailyDashboardPoint> points;
  final int activeBirds;

  @override
  Widget build(BuildContext context) {
    final rates = [
      for (final point in points)
        activeBirds <= 0 ? 0.0 : (point.eggs / activeBirds) * 100,
    ];
    return _ChartPanel(
      title: 'Taxa de postura diária',
      subtitle: 'Calculada conforme as coletas',
      icon: Icons.insights,
      child: points.isEmpty || activeBirds <= 0
          ? const _EmptyChart(message: 'Coletas e aves ativas formarão a taxa.')
          : _LineChart(
              labels: [for (final point in points) point.label],
              values: rates,
              color: _chartColors[1],
              unitSuffix: '%',
            ),
    );
  }
}

class _LotPhaseAgeChart extends StatelessWidget {
  const _LotPhaseAgeChart({required this.lots});

  final List<_LotPhaseSnapshot> lots;

  @override
  Widget build(BuildContext context) {
    final visible = lots.take(8).toList();
    return _ChartPanel(
      title: 'Fase e idade dos lotes',
      subtitle: 'Idade em dias por lote ativo',
      icon: Icons.timeline,
      child: visible.isEmpty
          ? const _EmptyChart(
              message: 'Cadastre lotes para acompanhar as fases.',
            )
          : Column(
              children: [
                Expanded(
                  child: _BarChart(
                    labels: [for (final lot in visible) _shortLabel(lot.name)],
                    values: [for (final lot in visible) lot.ageDays.toDouble()],
                    colorForIndex: (index) => visible[index].color,
                    suffix: ' dias',
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) =>
                        _PhaseChip(snapshot: visible[index]),
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemCount: visible.length,
                  ),
                ),
              ],
            ),
    );
  }
}

class _MortalityChart extends StatelessWidget {
  const _MortalityChart({required this.points});

  final List<LotPerformancePoint> points;

  @override
  Widget build(BuildContext context) {
    final visible = [...points]
      ..sort((a, b) => b.mortality.compareTo(a.mortality));
    final top = visible.take(8).toList();
    return _ChartPanel(
      title: 'Mortalidade por lote',
      subtitle: 'Total registrado e comparável entre lotes',
      icon: Icons.monitor_heart_outlined,
      child: top.isEmpty
          ? const _EmptyChart(
              message: 'Registros de mortalidade aparecerão aqui.',
            )
          : _BarChart(
              labels: [for (final point in top) _shortLabel(point.lotName)],
              values: [for (final point in top) point.mortality.toDouble()],
              colorForIndex: (_) => _chartColors[3],
              suffix: ' aves',
            ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.labels,
    required this.values,
    required this.colorForIndex,
    required this.suffix,
  });

  final List<String> labels;
  final List<double> values;
  final Color Function(int index) colorForIndex;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final peak = values.fold<double>(0, math.max);
    final labelStep = values.length <= 5 ? 1 : (values.length / 4).ceil();
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: peak <= 0 ? 10 : peak * 1.22,
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: colorForIndex(i),
                  width: values.length > 10 ? 10 : 15,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: .38),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) => Text(
                _compactNumber(value),
                style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 ||
                    index >= labels.length ||
                    index % labelStep != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  '${labels[group.x]}\n${_formatValue(rod.toY)}$suffix',
                  TextStyle(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.labels,
    required this.values,
    required this.color,
    this.unitPrefix = '',
    this.unitSuffix = '',
  });

  final List<String> labels;
  final List<double> values;
  final Color color;
  final String unitPrefix;
  final String unitSuffix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];
    final peak = values.fold<double>(0, math.max);
    final labelStep = labels.length <= 6 ? 1 : (labels.length / 5).ceil();
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: peak <= 0 ? 10 : peak * 1.2,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: .38),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) => Text(
                _compactNumber(value),
                style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: labels.length > 1,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 ||
                    index >= labels.length ||
                    index % labelStep != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
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
                  '$unitPrefix${_formatValue(item.y)}$unitSuffix',
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
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(show: values.length <= 14),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: .20),
                  color.withValues(alpha: .02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.snapshot});

  final _LotPhaseSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: snapshot.color.withValues(alpha: .10),
        border: Border.all(color: snapshot.color.withValues(alpha: .24)),
        borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: snapshot.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${_shortLabel(snapshot.name)} · ${snapshot.phase} · ${snapshot.activeBirds}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    ].where((action) => session?.allows(action.$4) ?? false);
    if (actions.isEmpty) return const SizedBox.shrink();
    return _ActionGrid(
      children: [
        for (final action in actions)
          SizedBox(
            height: SeletoTokens.touchTargetMinimum,
            child: FilledButton.tonalIcon(
              onPressed: () => context.go(action.$1),
              icon: Icon(action.$2),
              label: Text(action.$3, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 10.0;
      final columns = constraints.maxWidth >= 360 ? 2 : 1;
      final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _LotPhaseSnapshot {
  const _LotPhaseSnapshot({
    required this.name,
    required this.phase,
    required this.ageDays,
    required this.activeBirds,
    required this.color,
  });

  factory _LotPhaseSnapshot.fromSummary(LotSummary summary) {
    final age = LotLifecycle.ageInDays(
      receivedAt: summary.lot.receivedAt,
      arrivalAgeDays: summary.lot.arrivalAgeDays,
    );
    final phase = LotLifecycle.phaseForAge(age);
    return _LotPhaseSnapshot(
      name: summary.lot.name,
      phase: phase.label,
      ageDays: age,
      activeBirds: summary.activeBirds,
      color: _phaseColor(phase),
    );
  }

  final String name;
  final String phase;
  final int ageDays;
  final int activeBirds;
  final Color color;
}

Color _phaseColor(FeedingPhase phase) => switch (phase) {
  FeedingPhase.cria => _chartColors[2],
  FeedingPhase.recria => _chartColors[4],
  FeedingPhase.prePostura => _chartColors[1],
  FeedingPhase.producaoI => _chartColors[0],
  FeedingPhase.producaoII => _chartColors[5],
  FeedingPhase.producaoIII => _chartColors[3],
};

String _shortLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.length <= 11) return trimmed;
  return '${trimmed.substring(0, 10)}.';
}

String _compactNumber(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}

String _formatValue(double value) =>
    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);

String _dayLabel(DateTime date) => date.day.toString().padLeft(2, '0');
