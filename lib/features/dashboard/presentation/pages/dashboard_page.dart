import 'dart:async';
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
import '../../../auth/domain/entities/auth_session.dart';
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
    final session = ref.watch(authControllerProvider).session;
    final canSeeFarmPulse =
        (_allows(session, 'home.production.view') &&
            (_allows(session, 'lots.view') ||
                _allows(session, 'egg_collection.view') ||
                _allows(session, 'egg_stock.view') ||
                _allows(session, 'feed_stock.view'))) ||
        (_allows(session, 'home.finance.view') &&
            _allows(session, 'finance.business.view')) ||
        (_allows(session, 'home.commercial.view') &&
            _allows(session, 'orders.view'));
    final canSeeAutomation =
        _allows(session, 'home.automation.view') &&
        _allows(session, 'hardware.automation.view');
    final canSeeSensors =
        _allows(session, 'home.sensors.view') &&
        (_allows(session, 'hardware.lighting.view') ||
            _allows(session, 'hardware.environment.view') ||
            _allows(session, 'hardware.ventilation.view') ||
            _allows(session, 'hardware.water.view'));
    final canSeeCharts = _allows(session, 'home.charts.view');
    final canSeeShortcuts = _allows(session, 'home.shortcuts.view');
    final metrics = canSeeFarmPulse || canSeeCharts
        ? ref.watch(dashboardMetricsProvider).asData?.value
        : null;
    final eggs = canSeeFarmPulse
        ? ref.watch(eggMetricsProvider).asData?.value
        : null;
    final lots = canSeeCharts
        ? ref.watch(lotSummariesProvider).asData?.value ?? const <LotSummary>[]
        : const <LotSummary>[];
    final lotPerformance = canSeeCharts
        ? ref.watch(dashboardLotPerformanceProvider).asData?.value ??
              const <LotPerformancePoint>[]
        : const <LotPerformancePoint>[];
    final dailySeries = canSeeCharts
        ? ref.watch(dashboardDailySeriesProvider).asData?.value ??
              const <DailyDashboardPoint>[]
        : const <DailyDashboardPoint>[];
    final appSettings = canSeeSensors
        ? ref.watch(appSettingsProvider).asData?.value ?? const <AppSetting>[]
        : const <AppSetting>[];
    final automation = canSeeAutomation
        ? ref.watch(automationOverviewProvider).asData?.value
        : null;
    final sensorSnapshot = canSeeSensors
        ? _HomeSensorSnapshot.fromSettings(appSettings).withLightingRelayStates(
            automation?.espOnline == true ? automation?.relayStates : null,
          )
        : null;
    if (metrics != null || eggs != null || automation != null) {
      unawaited(
        ref
            .read(databaseProvider)
            .ensureOperationalAutomationAlerts(
              dashboard: metrics,
              eggsToday: eggs?.eggsToday,
              automation: automation,
            ),
      );
    }
    final phaseLots = lots
        .where((summary) => summary.lot.status == 'ACTIVE')
        .map(_LotPhaseSnapshot.fromSummary)
        .toList();

    return AppShell(
      title: 'Visão geral',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canSeeFarmPulse) ...[
            _FarmPulsePanel(metrics: metrics, eggs: eggs, session: session),
            const SizedBox(height: 14),
          ],
          if (automation != null) ...[
            _AutomationPulsePanel(overview: automation),
            const SizedBox(height: 14),
          ],
          if (sensorSnapshot != null) ...[
            _HomeSensorDeck(snapshot: sensorSnapshot, session: session),
            const SizedBox(height: 14),
          ],
          if (canSeeCharts) ...[
            _DashboardChartGrid(
              children: [
                if (_allows(session, 'lots.view'))
                  _LotPerformanceChart(points: lotPerformance),
                if (_allows(session, 'feeding.view'))
                  _DailyFeedChart(points: dailySeries),
                if (_allows(session, 'sales.view'))
                  _SalesChart(points: dailySeries),
                if (_allows(session, 'egg_collection.view'))
                  _PostureRateChart(
                    points: dailySeries,
                    activeBirds: metrics?.activeBirds ?? 0,
                  ),
                if (_allows(session, 'lots.view'))
                  _LotPhaseAgeChart(lots: phaseLots),
                if (_allows(session, 'birds.mortality'))
                  _MortalityChart(points: lotPerformance),
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (canSeeShortcuts) _QuickActions(ref: ref),
          if (!canSeeFarmPulse &&
              automation == null &&
              sensorSnapshot == null &&
              !canSeeCharts &&
              !canSeeShortcuts)
            const _DashboardEmptyState(),
        ],
      ),
    );
  }
}

bool _allows(AuthSession? session, String permission) =>
    session?.allows(permission) ?? false;

class _FarmPulsePanel extends StatelessWidget {
  const _FarmPulsePanel({
    required this.metrics,
    required this.eggs,
    required this.session,
  });

  final DashboardMetrics? metrics;
  final EggMetrics? eggs;
  final AuthSession? session;

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
              if (_allows(session, 'home.production.view') &&
                  _allows(session, 'lots.view'))
                _MetricPill(
                  icon: Icons.egg_alt_outlined,
                  label: 'Aves ativas',
                  value: metrics?.activeBirds.toString() ?? '-',
                  color: _chartColors[0],
                ),
              if (_allows(session, 'home.production.view') &&
                  _allows(session, 'egg_collection.view'))
                _MetricPill(
                  icon: Icons.inventory_2_outlined,
                  label: 'Ovos hoje',
                  value: eggs?.eggsToday.toString() ?? '-',
                  color: _chartColors[1],
                ),
              if (_allows(session, 'home.production.view') &&
                  _allows(session, 'egg_stock.view'))
                _MetricPill(
                  icon: Icons.egg_outlined,
                  label: 'Estoque de ovos',
                  value: metrics?.eggStock.toString() ?? '-',
                  color: _chartColors[2],
                ),
              if (_allows(session, 'home.production.view') &&
                  _allows(session, 'feed_stock.view'))
                _MetricPill(
                  icon: Icons.agriculture_outlined,
                  label: 'Ração',
                  value: metrics == null ? '-' : kg(metrics!.feedStockKg),
                  color: _chartColors[4],
                ),
              if (_allows(session, 'home.finance.view') &&
                  _allows(session, 'finance.business.view'))
                _MetricPill(
                  icon: Icons.point_of_sale,
                  label: 'Resultado mês',
                  value: result == null ? '-' : money(result),
                  color: result == null || result >= 0
                      ? _chartColors[0]
                      : _chartColors[3],
                ),
              if (_allows(session, 'home.commercial.view') &&
                  _allows(session, 'orders.view'))
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

class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: .94),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .72)),
        borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'Nenhum bloco liberado na home',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Peça a um administrador para ajustar as permissões deste usuário.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
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

class _AutomationPulsePanel extends StatelessWidget {
  const _AutomationPulsePanel({required this.overview});

  final AutomationOverview overview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: .92),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .72)),
        borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                overview.espOnline ? Icons.hub : Icons.hub_outlined,
                color: overview.espOnline ? scheme.primary : scheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Status da automação',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MetricGrid(
            children: [
              _MetricPill(
                icon: overview.espOnline ? Icons.wifi : Icons.wifi_off,
                label: 'ESP32',
                value: overview.espOnline ? 'Online' : 'Offline',
                color: overview.espOnline ? _chartColors[0] : _chartColors[3],
              ),
              _MetricPill(
                icon: Icons.water_outlined,
                label: 'Água',
                value: overview.waterLevelPercent == null
                    ? '-'
                    : '${decimal.format(overview.waterLevelPercent)}%',
                color: (overview.waterLevelPercent ?? 100) <= 25
                    ? _chartColors[3]
                    : _chartColors[2],
              ),
              _MetricPill(
                icon: Icons.notifications_active_outlined,
                label: 'Alertas críticos',
                value: overview.openAlerts.toString(),
                color: overview.openAlerts == 0
                    ? _chartColors[0]
                    : _chartColors[3],
              ),
              _MetricPill(
                icon: Icons.event_available_outlined,
                label: 'Agenda luz',
                value: overview.scheduleSynced ? 'OK' : 'Pendente',
                color: overview.scheduleSynced
                    ? _chartColors[0]
                    : _chartColors[1],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeSensorSnapshot {
  const _HomeSensorSnapshot({
    required this.environmentTemperatureC,
    required this.environmentHumidityPercent,
    required this.environmentReady,
    required this.waterLevelPercent,
    required this.waterTemperatureC,
    required this.waterPh,
    required this.waterTdsPpm,
    required this.waterReady,
    required this.lightingEnabled,
    required this.lightingReady,
    required this.lightingEnabledCount,
    required this.lightingOnCount,
    required this.lightingChannelOn,
    required this.ventilationEnabled,
    required this.ventilationReady,
    required this.ventilationEnabledCount,
    required this.ventilationOnCount,
    required this.ventilationChannelOn,
  });

  final double? environmentTemperatureC;
  final double? environmentHumidityPercent;
  final bool environmentReady;
  final double? waterLevelPercent;
  final double? waterTemperatureC;
  final double? waterPh;
  final double? waterTdsPpm;
  final bool waterReady;
  final bool lightingEnabled;
  final bool lightingReady;
  final int lightingEnabledCount;
  final int lightingOnCount;
  final List<bool> lightingChannelOn;
  final bool ventilationEnabled;
  final bool ventilationReady;
  final int ventilationEnabledCount;
  final int ventilationOnCount;
  final List<bool> ventilationChannelOn;

  factory _HomeSensorSnapshot.fromSettings(List<AppSetting> settings) {
    final values = {for (final setting in settings) setting.key: setting.value};
    final lightingEnabled = values['hardware_lighting_enabled'] == 'true';
    var enabledCount = 0;
    var onCount = 0;
    final lightingChannelOn = <bool>[];
    for (var i = 1; i <= 4; i++) {
      final channelEnabled =
          values['hardware_lighting_channel_${i}_enabled'] != 'false';
      if (channelEnabled) {
        enabledCount++;
      }
      final isOn =
          channelEnabled &&
          values['hardware_lighting_channel_${i}_last_test_state'] == 'ON';
      lightingChannelOn.add(isOn);
      if (isOn) {
        onCount++;
      }
    }
    final ventilationEnabled = values['hardware_ventilation_enabled'] == 'true';
    var ventilationEnabledCount = 0;
    var ventilationOnCount = 0;
    final ventilationChannelOn = <bool>[];
    for (var i = 1; i <= 8; i++) {
      final channelEnabled =
          values['hardware_ventilation_channel_${i}_enabled'] != 'false';
      if (channelEnabled) {
        ventilationEnabledCount++;
      }
      final isOn =
          channelEnabled &&
          values['hardware_ventilation_channel_${i}_last_test_state'] == 'ON';
      ventilationChannelOn.add(isOn);
      if (isOn) {
        ventilationOnCount++;
      }
    }
    return _HomeSensorSnapshot(
      environmentTemperatureC: _settingDouble(
        values,
        'hardware_environment_last_temperature_c',
      ),
      environmentHumidityPercent: _settingDouble(
        values,
        'hardware_environment_last_humidity_percent',
      ),
      environmentReady: (values['hardware_environment_endpoint'] ?? '')
          .trim()
          .isNotEmpty,
      waterLevelPercent: _settingDouble(
        values,
        'hardware_water_last_level_percent',
      ),
      waterTemperatureC: _settingDouble(
        values,
        'hardware_water_last_temperature_c',
      ),
      waterPh: _settingDouble(values, 'hardware_water_last_ph'),
      waterTdsPpm: _settingDouble(values, 'hardware_water_last_tds_ppm'),
      waterReady: (values['hardware_water_endpoint'] ?? '').trim().isNotEmpty,
      lightingEnabled: lightingEnabled,
      lightingReady:
          lightingEnabled &&
          (values['hardware_lighting_endpoint'] ?? '').trim().isNotEmpty,
      lightingEnabledCount: enabledCount,
      lightingOnCount: onCount,
      lightingChannelOn: lightingChannelOn,
      ventilationEnabled: ventilationEnabled,
      ventilationReady:
          ventilationEnabled &&
          ((values['hardware_ventilation_endpoint'] ??
                  values['hardware_lighting_endpoint'] ??
                  '')
              .trim()
              .isNotEmpty),
      ventilationEnabledCount: ventilationEnabledCount,
      ventilationOnCount: ventilationOnCount,
      ventilationChannelOn: ventilationChannelOn,
    );
  }

  _HomeSensorSnapshot withLightingRelayStates(List<bool>? relayStates) {
    if (relayStates == null || relayStates.isEmpty) return this;
    final channelOn = <bool>[];
    var onCount = 0;
    for (var i = 0; i < 4; i++) {
      final enabled =
          i < lightingEnabledCount ||
          (i < lightingChannelOn.length && lightingChannelOn[i]);
      final on = enabled && i < relayStates.length && relayStates[i];
      channelOn.add(on);
      if (on) onCount++;
    }
    return _HomeSensorSnapshot(
      environmentTemperatureC: environmentTemperatureC,
      environmentHumidityPercent: environmentHumidityPercent,
      environmentReady: environmentReady,
      waterLevelPercent: waterLevelPercent,
      waterTemperatureC: waterTemperatureC,
      waterPh: waterPh,
      waterTdsPpm: waterTdsPpm,
      waterReady: waterReady,
      lightingEnabled: lightingEnabled,
      lightingReady: lightingReady,
      lightingEnabledCount: lightingEnabledCount,
      lightingOnCount: onCount,
      lightingChannelOn: channelOn,
      ventilationEnabled: ventilationEnabled,
      ventilationReady: ventilationReady,
      ventilationEnabledCount: ventilationEnabledCount,
      ventilationOnCount: ventilationOnCount,
      ventilationChannelOn: ventilationChannelOn,
    );
  }
}

double? _settingDouble(Map<String, String> values, String key) {
  final raw = values[key]?.trim() ?? '';
  if (raw.isEmpty) return null;
  return parseDecimal(raw);
}

class _HomeSensorDeck extends StatelessWidget {
  const _HomeSensorDeck({required this.snapshot, required this.session});

  final _HomeSensorSnapshot snapshot;
  final AuthSession? session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: .94),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .72)),
        borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sensores e automações',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 920 ? 4 : 2;
              const gap = 10.0;
              final width =
                  (constraints.maxWidth - (gap * (columns - 1))) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  if (_allows(session, 'hardware.lighting.view'))
                    SizedBox(
                      width: width,
                      child: _HomeSensorCard(
                        title: 'Iluminação',
                        subtitle: snapshot.lightingReady
                            ? '${snapshot.lightingOnCount}/4 ligados'
                            : 'Pendente',
                        icon: Icons.lightbulb_outline,
                        active: snapshot.lightingReady,
                        route: '/integrations',
                        child: _HomeLightingPreview(snapshot: snapshot),
                      ),
                    ),
                  if (_allows(session, 'hardware.environment.view'))
                    SizedBox(
                      width: width,
                      child: _HomeSensorCard(
                        title: 'Ambiente',
                        subtitle: snapshot.environmentTemperatureC == null
                            ? 'Sem leitura'
                            : '${decimal.format(snapshot.environmentTemperatureC!)} °C',
                        icon: Icons.thermostat_outlined,
                        active:
                            snapshot.environmentTemperatureC != null ||
                            snapshot.environmentHumidityPercent != null,
                        route: '/hardware-environment',
                        child: _HomeEnvironmentPreview(snapshot: snapshot),
                      ),
                    ),
                  if (_allows(session, 'hardware.ventilation.view'))
                    SizedBox(
                      width: width,
                      child: _HomeSensorCard(
                        title: 'Ventilação',
                        subtitle: snapshot.ventilationReady
                            ? '${snapshot.ventilationOnCount}/8 ligados'
                            : 'Pendente',
                        icon: Icons.air_outlined,
                        active: snapshot.ventilationReady,
                        route: '/hardware-ventilation',
                        child: _HomeVentilationPreview(snapshot: snapshot),
                      ),
                    ),
                  if (_allows(session, 'hardware.water.view'))
                    SizedBox(
                      width: width,
                      child: _HomeSensorCard(
                        title: 'Água',
                        subtitle: snapshot.waterLevelPercent == null
                            ? 'Sem leitura'
                            : '${decimal.format(snapshot.waterLevelPercent!)}%',
                        icon: Icons.water_outlined,
                        active:
                            snapshot.waterLevelPercent != null ||
                            snapshot.waterPh != null,
                        route: '/hardware-water',
                        child: _HomeWaterPreview(snapshot: snapshot),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeSensorCard extends StatelessWidget {
  const _HomeSensorCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.route,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;
  final String route;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = active ? scheme.primary : scheme.onSurfaceVariant;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: .30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: active
              ? scheme.primary.withValues(alpha: .32)
              : scheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: SizedBox(
            height: 174,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeLightingPreview extends StatelessWidget {
  const _HomeLightingPreview({required this.snapshot});

  final _HomeSensorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _HomeLightingPainter(
        color: scheme.primary,
        outline: scheme.outlineVariant,
        enabled: snapshot.lightingEnabled,
        channelOn: snapshot.lightingChannelOn,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _HomeMiniBadge(
          icon: Icons.tungsten_outlined,
          label:
              '${snapshot.lightingEnabledCount}/4 ativos  ${snapshot.lightingOnCount}/4 ON',
        ),
      ),
    );
  }
}

class _HomeEnvironmentPreview extends StatelessWidget {
  const _HomeEnvironmentPreview({required this.snapshot});

  final _HomeSensorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _HomeHousePainter(
        color: scheme.primary,
        outline: scheme.outlineVariant,
        temperatureC: snapshot.environmentTemperatureC,
        humidityPercent: snapshot.environmentHumidityPercent,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _HomeMiniBadge(
          icon: Icons.water_drop_outlined,
          label: snapshot.environmentHumidityPercent == null
              ? 'Umidade --'
              : '${decimal.format(snapshot.environmentHumidityPercent!)}%',
        ),
      ),
    );
  }
}

class _HomeWaterPreview extends StatelessWidget {
  const _HomeWaterPreview({required this.snapshot});

  final _HomeSensorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final level = ((snapshot.waterLevelPercent ?? 0) / 100).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: level),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedLevel, _) => CustomPaint(
        painter: _HomeWaterPainter(
          color: scheme.primary,
          outline: scheme.outlineVariant,
          level: animatedLevel,
          active: snapshot.waterLevelPercent != null,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _HomeMiniBadge(
            icon: Icons.science_outlined,
            label: snapshot.waterPh == null
                ? 'pH --'
                : 'pH ${decimal.format(snapshot.waterPh!)}',
          ),
        ),
      ),
    );
  }
}

class _HomeVentilationPreview extends StatefulWidget {
  const _HomeVentilationPreview({required this.snapshot});

  final _HomeSensorSnapshot snapshot;

  @override
  State<_HomeVentilationPreview> createState() =>
      _HomeVentilationPreviewState();
}

class _HomeVentilationPreviewState extends State<_HomeVentilationPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    if (_active) controller.repeat();
  }

  bool get _active =>
      widget.snapshot.ventilationEnabled &&
      widget.snapshot.ventilationOnCount > 0;

  @override
  void didUpdateWidget(covariant _HomeVentilationPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_active && !controller.isAnimating) {
      controller.repeat();
    } else if (!_active && controller.isAnimating) {
      controller.stop();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _active ? scheme.primary : scheme.onSurfaceVariant;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _HomeVentilationAirPainter(
              color: scheme.primary,
              active: _active,
            ),
          ),
        ),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              for (var i = 0; i < 8; i++)
                SizedBox(
                  width: 31,
                  height: 31,
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => Transform.rotate(
                      angle: controller.value * math.pi * 2,
                      child: CustomPaint(
                        painter: _HomeFanPainter(
                          color: color,
                          active:
                              _active &&
                              i < widget.snapshot.ventilationChannelOn.length &&
                              widget.snapshot.ventilationChannelOn[i],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _HomeMiniBadge(
            icon: Icons.air_outlined,
            label:
                '${widget.snapshot.ventilationEnabledCount}/8 ativos  ${widget.snapshot.ventilationOnCount}/8 ON',
          ),
        ),
      ],
    );
  }
}

class _HomeFanPainter extends CustomPainter {
  const _HomeFanPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final ring = Paint()
      ..color = color.withValues(alpha: active ? .44 : .22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final blade = Paint()
      ..color = color.withValues(alpha: active ? .64 : .24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, ring);
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate((math.pi * 2 / 3) * i);
      final path = Path()
        ..moveTo(0, -3)
        ..quadraticBezierTo(radius * .45, -radius * .20, radius * .60, -1)
        ..quadraticBezierTo(radius * .34, radius * .18, 3, 5)
        ..quadraticBezierTo(-3, 2, 0, -3);
      canvas.drawPath(path, blade);
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      radius * .15,
      Paint()..color = color.withValues(alpha: active ? .85 : .45),
    );
  }

  @override
  bool shouldRepaint(covariant _HomeFanPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.active != active;
}

class _HomeVentilationAirPainter extends CustomPainter {
  const _HomeVentilationAirPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: active ? .16 : .05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (.22 + i * .16);
      final path = Path()
        ..moveTo(size.width * .08, y)
        ..cubicTo(
          size.width * .30,
          y - 12,
          size.width * .48,
          y + 12,
          size.width * .70,
          y,
        )
        ..cubicTo(
          size.width * .80,
          y - 7,
          size.width * .90,
          y - 3,
          size.width * .95,
          y,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeVentilationAirPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.active != active;
}

class _HomeMiniBadge extends StatelessWidget {
  const _HomeMiniBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 122),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLightingPainter extends CustomPainter {
  const _HomeLightingPainter({
    required this.color,
    required this.outline,
    required this.enabled,
    required this.channelOn,
  });

  final Color color;
  final Color outline;
  final bool enabled;
  final List<bool> channelOn;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = outline
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final y = size.height * .42;
    canvas.drawLine(
      Offset(size.width * .12, y),
      Offset(size.width * .88, y),
      line,
    );
    for (var i = 0; i < 4; i++) {
      final x = size.width * (.16 + i * .225);
      final on = enabled && i < channelOn.length && channelOn[i];
      final paint = Paint()
        ..color = (on ? const Color(0xFFFFB020) : color).withValues(
          alpha: on ? .86 : .20,
        )
        ..style = PaintingStyle.fill;
      canvas.drawLine(Offset(x, y), Offset(x, size.height * .62), line);
      canvas.drawCircle(Offset(x, size.height * .66), on ? 9 : 6, paint);
      canvas.drawCircle(Offset(x, size.height * .66), on ? 12 : 8, line);
      if (on) {
        final beam = Paint()
          ..color = color.withValues(alpha: .10)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, size.height * .66), 28, beam);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HomeLightingPainter oldDelegate) =>
      oldDelegate.enabled != enabled ||
      oldDelegate.channelOn != channelOn ||
      oldDelegate.color != color ||
      oldDelegate.outline != outline;
}

class _HomeHousePainter extends CustomPainter {
  const _HomeHousePainter({
    required this.color,
    required this.outline,
    required this.temperatureC,
    required this.humidityPercent,
  });

  final Color color;
  final Color outline;
  final double? temperatureC;
  final double? humidityPercent;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = outline
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = color.withValues(alpha: .09)
      ..style = PaintingStyle.fill;
    final house = Path()
      ..moveTo(size.width * .22, size.height * .60)
      ..lineTo(size.width * .50, size.height * .32)
      ..lineTo(size.width * .78, size.height * .60)
      ..lineTo(size.width * .73, size.height * .60)
      ..lineTo(size.width * .73, size.height * .82)
      ..lineTo(size.width * .27, size.height * .82)
      ..lineTo(size.width * .27, size.height * .60)
      ..close();
    canvas.drawPath(house, fill);
    canvas.drawPath(house, line);
    final temp = ((temperatureC ?? 24) - 15).clamp(0, 25) / 25;
    final humidity = ((humidityPercent ?? 45).clamp(0, 100)) / 100;
    canvas.drawCircle(
      Offset(size.width * .40, size.height * .64),
      12 + 8 * temp.toDouble(),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF2DD4BF),
          const Color(0xFFEF4444),
          temp.toDouble(),
        )!.withValues(alpha: .34),
    );
    canvas.drawCircle(
      Offset(size.width * .60, size.height * .64),
      10 + 8 * humidity.toDouble(),
      Paint()..color = color.withValues(alpha: .22 + .20 * humidity.toDouble()),
    );
  }

  @override
  bool shouldRepaint(covariant _HomeHousePainter oldDelegate) =>
      oldDelegate.temperatureC != temperatureC ||
      oldDelegate.humidityPercent != humidityPercent ||
      oldDelegate.color != color ||
      oldDelegate.outline != outline;
}

class _HomeWaterPainter extends CustomPainter {
  const _HomeWaterPainter({
    required this.color,
    required this.outline,
    required this.level,
    required this.active,
  });

  final Color color;
  final Color outline;
  final double level;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final tankRect = Rect.fromLTWH(
      size.width * .30,
      size.height * .18,
      size.width * .40,
      size.height * .66,
    );
    final tank = RRect.fromRectAndRadius(tankRect, const Radius.circular(16));
    canvas.drawRRect(
      tank,
      Paint()
        ..color = outline
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );
    final waterHeight = (tankRect.height - 8) * level;
    final waterRect = Rect.fromLTWH(
      tankRect.left + 4,
      tankRect.bottom - waterHeight - 4,
      tankRect.width - 8,
      math.max(0, waterHeight),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(waterRect, const Radius.circular(13)),
      Paint()
        ..color = color.withValues(alpha: active ? .58 : .22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      Offset(tankRect.right, tankRect.center.dy),
      Offset(size.width * .86, tankRect.center.dy),
      Paint()
        ..color = outline
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeWaterPainter oldDelegate) =>
      oldDelegate.level != level ||
      oldDelegate.active != active ||
      oldDelegate.color != color ||
      oldDelegate.outline != outline;
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
