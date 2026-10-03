import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/operations_controller.dart';

class AutomationCenterPage extends ConsumerWidget {
  const AutomationCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(automationOverviewProvider);
    final alerts = ref.watch(openAutomationEventsProvider).asData?.value ?? [];
    return AppShell(
      title: 'Central da Automação',
      child: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (overview) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AutomationHeader(overview: overview),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/integrations'),
                  icon: const Icon(Icons.settings_input_component_outlined),
                  label: const Text('Integrações'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/hardware-environment'),
                  icon: const Icon(Icons.thermostat_outlined),
                  label: const Text('Ambiente'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/hardware-water'),
                  icon: const Icon(Icons.water_outlined),
                  label: const Text('Água'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricGrid(
              children: [
                _AutomationMetric(
                  icon: Icons.thermostat_outlined,
                  label: 'Temperatura',
                  value: overview.temperatureC == null
                      ? '-'
                      : '${decimal.format(overview.temperatureC)} °C',
                  active: overview.temperatureC != null,
                ),
                _AutomationMetric(
                  icon: Icons.water_drop_outlined,
                  label: 'Umidade',
                  value: overview.humidityPercent == null
                      ? '-'
                      : '${decimal.format(overview.humidityPercent)}%',
                  active: overview.humidityPercent != null,
                ),
                _AutomationMetric(
                  icon: Icons.water_outlined,
                  label: 'Água',
                  value: overview.waterLevelPercent == null
                      ? '-'
                      : '${decimal.format(overview.waterLevelPercent)}%',
                  active: (overview.waterLevelPercent ?? 0) > 25,
                ),
                _AutomationMetric(
                  icon: Icons.science_outlined,
                  label: 'pH / TDS',
                  value:
                      '${overview.waterPh == null ? '-' : decimal.format(overview.waterPh)} / ${overview.waterTdsPpm == null ? '-' : decimal.format(overview.waterTdsPpm)}',
                  active:
                      overview.waterPh != null || overview.waterTdsPpm != null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RelayPanel(states: overview.relayStates),
            const SizedBox(height: 12),
            _AlertsPanel(alerts: alerts),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, box) {
                final charts = [
                  _SensorChart(
                    title: 'Temperatura 7 dias',
                    metric: 'air_temperature_c',
                    unit: '°C',
                  ),
                  _SensorChart(
                    title: 'Nível de água 7 dias',
                    metric: 'water_level_percent',
                    unit: '%',
                  ),
                ];
                if (box.maxWidth > 760) {
                  return Row(
                    children: [
                      Expanded(child: charts[0]),
                      const SizedBox(width: 12),
                      Expanded(child: charts[1]),
                    ],
                  );
                }
                return Column(
                  children: [charts[0], const SizedBox(height: 12), charts[1]],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomationHeader extends StatelessWidget {
  const _AutomationHeader({required this.overview});

  final AutomationOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: overview.espOnline
            ? colors.primaryContainer.withValues(alpha: .55)
            : colors.errorContainer.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: overview.espOnline
              ? colors.primary.withValues(alpha: .25)
              : colors.error.withValues(alpha: .25),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            overview.espOnline ? Icons.hub : Icons.hub_outlined,
            color: overview.espOnline ? colors.primary : colors.error,
          ),
          Text(
            overview.espOnline ? 'ESP32 online' : 'ESP32 offline',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(overview.espIp.isEmpty ? 'IP não informado' : overview.espIp),
          Text(
            overview.scheduleSynced
                ? 'Agenda sincronizada'
                : 'Agenda pendente/antiga',
          ),
          Text('${overview.openAlerts} alerta(s) aberto(s)'),
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
    builder: (context, box) {
      final columns = box.maxWidth > 760 ? 4 : 2;
      const gap = 8.0;
      final width = (box.maxWidth - gap * (columns - 1)) / columns;
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

class _AutomationMetric extends StatelessWidget {
  const _AutomationMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? colors.primary : colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelayPanel extends StatelessWidget {
  const _RelayPanel({required this.states});

  final List<bool> states;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Relés de iluminação',
    icon: Icons.lightbulb_outline,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < states.length; i++)
          Chip(
            avatar: Icon(states[i] ? Icons.power : Icons.power_off, size: 18),
            label: Text('Canal ${i + 1}: ${states[i] ? 'ON' : 'OFF'}'),
          ),
      ],
    ),
  );
}

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({required this.alerts});

  final List<AutomationEvent> alerts;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Alertas inteligentes',
    icon: Icons.warning_amber_outlined,
    child: alerts.isEmpty
        ? const Text('Nenhum alerta automático aberto.')
        : Column(
            children: [
              for (final alert in alerts.take(6))
                ListTile(
                  dense: true,
                  leading: Icon(
                    alert.severity == 'CRITICAL'
                        ? Icons.error_outline
                        : Icons.warning_amber_outlined,
                  ),
                  title: Text(alert.title),
                  subtitle: Text(alert.message),
                ),
            ],
          ),
  );
}

class _SensorChart extends ConsumerWidget {
  const _SensorChart({
    required this.title,
    required this.metric,
    required this.unit,
  });

  final String title;
  final String metric;
  final String unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(sensorSeriesProvider(metric)).asData?.value ?? [];
    return _Panel(
      title: title,
      icon: Icons.show_chart,
      child: SizedBox(
        height: 180,
        child: points.length < 2
            ? const Center(child: Text('Sem histórico suficiente.'))
            : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (var i = 0; i < points.length; i++)
                          FlSpot(i.toDouble(), points[i].value),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
