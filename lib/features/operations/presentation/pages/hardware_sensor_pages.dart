import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/hardware_esp_client.dart';
import '../../application/operations_controller.dart';

const _ventilationChannelCount = 8;
const _ventilationRelayOffset = 4;
const _ventilationDefaultPins = ['18', '5', '17', '16', '4', '25', '2', '15'];

const _environmentSensorPorts = [
  _SensorPort('DHT22 dados', 'GPIO27', Icons.device_thermostat_outlined),
];

const _waterReservoirSensorPorts = [
  _SensorPort('Nível da água', 'GPIO34', Icons.water_outlined),
  _SensorPort('Temperatura', 'GPIO35', Icons.device_thermostat_outlined),
];

const _waterQualitySensorPorts = [
  _SensorPort('pH', 'GPIO36', Icons.science_outlined),
  _SensorPort('TDS', 'GPIO39', Icons.blur_on_outlined),
];

const _waterSystemSensorPorts = [
  ..._waterReservoirSensorPorts,
  ..._waterQualitySensorPorts,
];

const _ventilationSensorPorts = [
  _SensorPort('Ventilação 1', 'GPIO18', Icons.air_outlined),
  _SensorPort('Ventilação 2', 'GPIO5', Icons.air_outlined),
  _SensorPort('Ventilação 3', 'GPIO17', Icons.air_outlined),
  _SensorPort('Ventilação 4', 'GPIO16', Icons.air_outlined),
  _SensorPort('Ventilação 5', 'GPIO4', Icons.air_outlined),
  _SensorPort('Ventilação 6', 'GPIO25', Icons.air_outlined),
  _SensorPort('Ventilação 7', 'GPIO2', Icons.air_outlined),
  _SensorPort('Ventilação 8', 'GPIO15', Icons.air_outlined),
];

class EnvironmentSensorPage extends ConsumerStatefulWidget {
  const EnvironmentSensorPage({super.key});

  @override
  ConsumerState<EnvironmentSensorPage> createState() =>
      _EnvironmentSensorPageState();
}

class _EnvironmentSensorPageState extends ConsumerState<EnvironmentSensorPage> {
  final espClient = const HardwareEspClient();
  final endpoint = TextEditingController();
  bool initialized = false;
  bool working = false;
  double? temperatureC;
  double? humidityPercent;
  String status = 'Aguardando leitura';
  Map<String, Object?>? lastPayload;

  @override
  void dispose() {
    endpoint.dispose();
    super.dispose();
  }

  void _hydrate(List<AppSetting> settings) {
    if (initialized) return;
    initialized = true;
    endpoint.text = _sensorEndpoint(settings, 'hardware_environment_endpoint');
    temperatureC = _settingDouble(
      settings,
      'hardware_environment_last_temperature_c',
    );
    humidityPercent = _settingDouble(
      settings,
      'hardware_environment_last_humidity_percent',
    );
    if (temperatureC != null || humidityPercent != null) {
      status = 'Última leitura carregada';
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    title: 'Ambiente',
    child: ref
        .watch(appSettingsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (settings) {
            _hydrate(settings);
            return _SensorExperience(
              icon: Icons.thermostat_outlined,
              title: 'Ambiente do galpão',
              subtitle: 'Temperatura e umidade do ar',
              status: status,
              visual: _EnvironmentHouseInstrument(
                temperatureC: temperatureC,
                humidityPercent: humidityPercent,
                working: working,
              ),
              metrics: [
                _SensorMetric(
                  icon: Icons.device_thermostat_outlined,
                  label: 'Temperatura',
                  value: temperatureC == null
                      ? 'Sem leitura'
                      : '${decimal.format(temperatureC!)} °C',
                  active: temperatureC != null,
                ),
                _SensorMetric(
                  icon: Icons.water_drop_outlined,
                  label: 'Umidade',
                  value: humidityPercent == null
                      ? 'Sem leitura'
                      : '${decimal.format(humidityPercent!)}%',
                  active: humidityPercent != null,
                ),
              ],
              actions: [
                FilledButton.icon(
                  onPressed: working ? null : _read,
                  icon: const Icon(Icons.sensors_outlined),
                  label: const Text('Ler'),
                ),
                OutlinedButton.icon(
                  onPressed: working
                      ? null
                      : () => _save('hardware_environment_endpoint'),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                ),
              ],
              ports: _environmentSensorPorts,
              payload: lastPayload,
              config: [
                _SensorConfigCard(
                  title: 'Conexão',
                  icon: Icons.router_outlined,
                  children: [
                    _EndpointField(controller: endpoint, working: working),
                  ],
                ),
              ],
            );
          },
        ),
  );

  Future<void> _read() async {
    if (endpoint.text.trim().isEmpty) {
      setState(() => status = 'Informe o endpoint/IP do ESP.');
      return;
    }
    setState(() => working = true);
    try {
      final reading = await espClient.readEnvironment(endpoint.text.trim());
      final controller = ref.read(operationsControllerProvider);
      await controller.saveSetting(
        'hardware_environment_endpoint',
        endpoint.text.trim(),
      );
      await controller.saveSetting(
        'hardware_environment_last_temperature_c',
        decimal.format(reading.airTemperatureC),
      );
      await controller.saveSetting(
        'hardware_environment_last_humidity_percent',
        decimal.format(reading.airHumidityPercent),
      );
      if (!mounted) return;
      setState(() {
        temperatureC = reading.airTemperatureC;
        humidityPercent = reading.airHumidityPercent;
        lastPayload = reading.payload;
        status = reading.message;
      });
    } catch (error) {
      if (mounted) {
        setState(() => status = 'Falha na leitura do ambiente: $error');
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> _save(String key) async {
    await ref
        .read(operationsControllerProvider)
        .saveSetting(key, endpoint.text.trim());
  }
}

class WaterReservoirSensorPage extends ConsumerStatefulWidget {
  const WaterReservoirSensorPage({super.key});

  @override
  ConsumerState<WaterReservoirSensorPage> createState() =>
      _WaterReservoirSensorPageState();
}

class _WaterReservoirSensorPageState
    extends ConsumerState<WaterReservoirSensorPage> {
  final espClient = const HardwareEspClient();
  final endpoint = TextEditingController();
  bool initialized = false;
  bool working = false;
  double? levelPercent;
  double? temperatureC;
  double? ph;
  double? tdsPpm;
  String status = 'Aguardando leitura';
  Map<String, Object?>? lastPayload;

  @override
  void dispose() {
    endpoint.dispose();
    super.dispose();
  }

  void _hydrate(List<AppSetting> settings) {
    if (initialized) return;
    initialized = true;
    endpoint.text = _sensorEndpoint(settings, 'hardware_water_endpoint');
    levelPercent = _settingDouble(
      settings,
      'hardware_water_last_level_percent',
    );
    temperatureC = _settingDouble(
      settings,
      'hardware_water_last_temperature_c',
    );
    ph = _settingDouble(settings, 'hardware_water_last_ph');
    tdsPpm = _settingDouble(settings, 'hardware_water_last_tds_ppm');
    if (levelPercent != null ||
        temperatureC != null ||
        ph != null ||
        tdsPpm != null) {
      status = 'Última leitura carregada';
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    title: 'Água',
    child: ref
        .watch(appSettingsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (settings) {
            _hydrate(settings);
            return _SensorExperience(
              icon: Icons.water_outlined,
              title: 'Reservatório inteligente',
              subtitle: 'Nível, temperatura e qualidade da água',
              status: status,
              visual: _WaterReservoirInstrument(
                levelPercent: levelPercent,
                temperatureC: temperatureC,
                ph: ph,
                tdsPpm: tdsPpm,
                working: working,
              ),
              metrics: [
                _SensorMetric(
                  icon: Icons.water_outlined,
                  label: 'Nível',
                  value: levelPercent == null
                      ? 'Sem leitura'
                      : '${decimal.format(levelPercent!)}%',
                  active: levelPercent != null,
                ),
                _SensorMetric(
                  icon: Icons.device_thermostat_outlined,
                  label: 'Temperatura',
                  value: temperatureC == null
                      ? 'Sem leitura'
                      : '${decimal.format(temperatureC!)} °C',
                  active: temperatureC != null,
                ),
                _SensorMetric(
                  icon: Icons.science_outlined,
                  label: 'pH',
                  value: ph == null ? 'Sem leitura' : decimal.format(ph!),
                  active: ph != null,
                ),
                _SensorMetric(
                  icon: Icons.blur_on_outlined,
                  label: 'TDS',
                  value: tdsPpm == null
                      ? 'Sem leitura'
                      : '${decimal.format(tdsPpm!)} ppm',
                  active: tdsPpm != null,
                ),
              ],
              actions: [
                FilledButton.icon(
                  onPressed: working ? null : _read,
                  icon: const Icon(Icons.sensors_outlined),
                  label: const Text('Ler'),
                ),
                OutlinedButton.icon(
                  onPressed: working
                      ? null
                      : () => _save('hardware_water_endpoint'),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                ),
              ],
              ports: _waterSystemSensorPorts,
              payload: lastPayload,
              config: [
                _SensorConfigCard(
                  title: 'Conexão',
                  icon: Icons.router_outlined,
                  children: [
                    _EndpointField(controller: endpoint, working: working),
                  ],
                ),
              ],
            );
          },
        ),
  );

  Future<void> _read() async {
    if (endpoint.text.trim().isEmpty) {
      setState(() => status = 'Informe o endpoint/IP do ESP.');
      return;
    }
    setState(() => working = true);
    try {
      final reading = await espClient.readWater(endpoint.text.trim());
      final controller = ref.read(operationsControllerProvider);
      await controller.saveSetting(
        'hardware_water_endpoint',
        endpoint.text.trim(),
      );
      await controller.saveSetting(
        'hardware_water_last_level_percent',
        decimal.format(reading.levelPercent),
      );
      await controller.saveSetting(
        'hardware_water_last_temperature_c',
        decimal.format(reading.temperatureC),
      );
      await controller.saveSetting(
        'hardware_water_last_ph',
        decimal.format(reading.ph),
      );
      await controller.saveSetting(
        'hardware_water_last_tds_ppm',
        decimal.format(reading.tdsPpm),
      );
      if (!mounted) return;
      setState(() {
        levelPercent = reading.levelPercent;
        temperatureC = reading.temperatureC;
        ph = reading.ph;
        tdsPpm = reading.tdsPpm;
        lastPayload = reading.payload;
        status = reading.message;
      });
    } catch (error) {
      if (mounted) {
        setState(() => status = 'Falha na leitura do reservatório: $error');
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> _save(String key) async {
    await ref
        .read(operationsControllerProvider)
        .saveSetting(key, endpoint.text.trim());
  }
}

class WaterQualitySensorPage extends ConsumerStatefulWidget {
  const WaterQualitySensorPage({super.key});

  @override
  ConsumerState<WaterQualitySensorPage> createState() =>
      _WaterQualitySensorPageState();
}

class _WaterQualitySensorPageState
    extends ConsumerState<WaterQualitySensorPage> {
  final espClient = const HardwareEspClient();
  final endpoint = TextEditingController();
  bool initialized = false;
  bool working = false;
  double? ph;
  double? tdsPpm;
  String status = 'Aguardando leitura';
  Map<String, Object?>? lastPayload;

  @override
  void dispose() {
    endpoint.dispose();
    super.dispose();
  }

  void _hydrate(List<AppSetting> settings) {
    if (initialized) return;
    initialized = true;
    endpoint.text = _sensorEndpoint(
      settings,
      'hardware_water_quality_endpoint',
    );
    ph = _settingDouble(settings, 'hardware_water_last_ph');
    tdsPpm = _settingDouble(settings, 'hardware_water_last_tds_ppm');
    if (ph != null || tdsPpm != null) {
      status = 'Última leitura carregada';
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    title: 'Qualidade da água',
    child: ref
        .watch(appSettingsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (settings) {
            _hydrate(settings);
            return _SensorPanel(
              icon: Icons.science_outlined,
              title: 'Parâmetros da água',
              status: status,
              children: [
                _ReadingGrid(
                  tiles: [
                    _ReadingTile(
                      icon: Icons.science_outlined,
                      label: 'pH',
                      value: ph == null ? 'Sem leitura' : decimal.format(ph!),
                      active: ph != null,
                    ),
                    _ReadingTile(
                      icon: Icons.blur_on_outlined,
                      label: 'TDS',
                      value: tdsPpm == null
                          ? 'Sem leitura'
                          : '${decimal.format(tdsPpm!)} ppm',
                      active: tdsPpm != null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _SensorActions(
                  working: working,
                  onRead: _read,
                  onSave: () => _save('hardware_water_quality_endpoint'),
                ),
                const SizedBox(height: 10),
                const _SensorPortMap(ports: _waterQualitySensorPorts),
                const SizedBox(height: 10),
                _SensorConfigCard(
                  title: 'Conexão',
                  icon: Icons.router_outlined,
                  children: [
                    _EndpointField(controller: endpoint, working: working),
                  ],
                ),
                const SizedBox(height: 10),
                _PayloadPanel(payload: lastPayload),
              ],
            );
          },
        ),
  );

  Future<void> _read() async {
    if (endpoint.text.trim().isEmpty) {
      setState(() => status = 'Informe o endpoint/IP do ESP.');
      return;
    }
    setState(() => working = true);
    try {
      final reading = await espClient.readWater(endpoint.text.trim());
      final controller = ref.read(operationsControllerProvider);
      await controller.saveSetting(
        'hardware_water_quality_endpoint',
        endpoint.text.trim(),
      );
      await controller.saveSetting(
        'hardware_water_last_ph',
        decimal.format(reading.ph),
      );
      await controller.saveSetting(
        'hardware_water_last_tds_ppm',
        decimal.format(reading.tdsPpm),
      );
      if (!mounted) return;
      setState(() {
        ph = reading.ph;
        tdsPpm = reading.tdsPpm;
        lastPayload = reading.payload;
        status = reading.message;
      });
    } catch (error) {
      if (mounted) setState(() => status = 'Falha na leitura da água: $error');
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> _save(String key) async {
    await ref
        .read(operationsControllerProvider)
        .saveSetting(key, endpoint.text.trim());
  }
}

class VentilationSensorPage extends ConsumerStatefulWidget {
  const VentilationSensorPage({super.key});

  @override
  ConsumerState<VentilationSensorPage> createState() =>
      _VentilationSensorPageState();
}

class _VentilationSensorPageState extends ConsumerState<VentilationSensorPage> {
  final espClient = const HardwareEspClient();
  final endpoint = TextEditingController();
  final channelNames = List.generate(
    _ventilationChannelCount,
    (index) => TextEditingController(text: 'Ventilador ${index + 1}'),
  );
  final channelPins = [
    for (final pin in _ventilationDefaultPins) TextEditingController(text: pin),
  ];
  final channelEnabled = List.generate(
    _ventilationChannelCount,
    (index) => true,
  );
  final channelOn = List.generate(_ventilationChannelCount, (index) => false);
  final channelStatus = List.generate(
    _ventilationChannelCount,
    (index) => 'Ventilador ${index + 1} aguardando teste',
  );
  bool initialized = false;
  bool working = false;
  bool ventilationEnabled = false;
  String status = 'Aguardando configuração';
  Map<String, Object?>? lastPayload;

  @override
  void dispose() {
    endpoint.dispose();
    for (final controller in channelNames) {
      controller.dispose();
    }
    for (final controller in channelPins) {
      controller.dispose();
    }
    super.dispose();
  }

  void _hydrate(List<AppSetting> settings) {
    if (initialized) return;
    initialized = true;
    endpoint.text = _sensorEndpoint(settings, 'hardware_ventilation_endpoint');
    ventilationEnabled =
        _setting(settings, 'hardware_ventilation_enabled') == 'true';
    for (var i = 0; i < _ventilationChannelCount; i++) {
      final number = i + 1;
      final name = _setting(
        settings,
        'hardware_ventilation_channel_${number}_name',
      );
      final pin = _setting(
        settings,
        'hardware_ventilation_channel_${number}_pin',
      );
      final enabled = _setting(
        settings,
        'hardware_ventilation_channel_${number}_enabled',
      );
      final lastState = _setting(
        settings,
        'hardware_ventilation_channel_${number}_last_test_state',
      );
      if (name.isNotEmpty) channelNames[i].text = name;
      if (pin.isNotEmpty) channelPins[i].text = pin;
      channelEnabled[i] = enabled != 'false';
      channelOn[i] = lastState == 'ON';
      if (lastState == 'ON' || lastState == 'OFF') {
        channelStatus[i] = 'Último teste: $lastState';
      }
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    title: 'Ventilação',
    child: ref
        .watch(appSettingsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (settings) {
            _hydrate(settings);
            final enabledCount = channelEnabled.where((value) => value).length;
            final onCount = [
              for (var i = 0; i < channelOn.length; i++)
                channelEnabled[i] && channelOn[i],
            ].where((value) => value).length;
            return _SensorExperience(
              icon: Icons.air_outlined,
              title: 'Ventilação inteligente',
              subtitle: 'Relés ESP32 dedicados aos canais 5 a 12',
              status: status,
              visual: _VentilationInstrument(
                enabled: ventilationEnabled,
                onCount: onCount,
                channelOn: channelOn,
                channelEnabled: channelEnabled,
                channels: _ventilationChannelCount,
              ),
              metrics: [
                _SensorMetric(
                  icon: Icons.power_settings_new,
                  label: 'Modo',
                  value: ventilationEnabled ? 'Ativo' : 'Off',
                  active: ventilationEnabled,
                ),
                _SensorMetric(
                  icon: Icons.air_outlined,
                  label: 'Ligados',
                  value: '$onCount/$_ventilationChannelCount',
                  active: onCount > 0,
                ),
                _SensorMetric(
                  icon: Icons.settings_input_component_outlined,
                  label: 'Canais',
                  value: '$enabledCount/$_ventilationChannelCount',
                  active: enabledCount > 0,
                ),
              ],
              actions: [
                FilledButton.icon(
                  onPressed: working ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                ),
                FilledButton.tonalIcon(
                  onPressed: working || !ventilationEnabled
                      ? null
                      : () => _testFirstEnabled(turnOn: true),
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('Ligar primeiro'),
                ),
                OutlinedButton.icon(
                  onPressed: working || !ventilationEnabled
                      ? null
                      : () => _testFirstEnabled(turnOn: false),
                  icon: const Icon(Icons.power_off_outlined),
                  label: const Text('Desligar primeiro'),
                ),
              ],
              ports: _ventilationSensorPorts,
              payload: lastPayload,
              config: [
                _SensorConfigCard(
                  title: 'Conexão do ESP',
                  icon: Icons.router_outlined,
                  children: [
                    _EndpointField(controller: endpoint, working: working),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.air_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ativar controle de ventilação',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Usa canais ESP 5 a 12 e não altera a iluminação.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: ventilationEnabled,
                          onChanged: working
                              ? null
                              : (value) =>
                                    setState(() => ventilationEnabled = value),
                        ),
                      ],
                    ),
                  ],
                ),
                _SensorConfigCard(
                  title: 'Canais e GPIOs',
                  icon: Icons.dashboard_customize_outlined,
                  children: [
                    _VentilationChannelGrid(
                      labels: [
                        for (var i = 0; i < channelNames.length; i++)
                          channelNames[i].text.trim().isEmpty
                              ? 'Ventilador ${i + 1}'
                              : channelNames[i].text.trim(),
                      ],
                      pins: [
                        for (final controller in channelPins)
                          controller.text.trim().isEmpty
                              ? '-'
                              : controller.text.trim(),
                      ],
                      enabled: channelEnabled,
                      on: channelOn,
                      onOpen: _openChannelSheet,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
  );

  Future<void> _openChannelSheet(int index) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          void updateSheet(VoidCallback update) {
            setState(update);
            setSheetState(() {});
          }

          final colors = Theme.of(sheetContext).colorScheme;
          final espChannel = _ventilationRelayOffset + index + 1;
          final label = channelNames[index].text.trim().isEmpty
              ? 'Ventilador ${index + 1}'
              : channelNames[index].text.trim();
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        channelOn[index] ? Icons.air : Icons.air_outlined,
                        color: channelOn[index]
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: Theme.of(sheetContext).textTheme.titleLarge,
                        ),
                      ),
                      Switch(
                        value: channelEnabled[index],
                        onChanged: working
                            ? null
                            : (value) => updateSheet(
                                () => channelEnabled[index] = value,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SensorStatusStrip(
                    status: '${channelStatus[index]} • Canal ESP $espChannel',
                    failed: channelStatus[index].contains('FALHA'),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, box) => box.maxWidth > 520
                        ? Row(
                            children: [
                              Expanded(child: _nameField(index)),
                              const SizedBox(width: 10),
                              SizedBox(width: 150, child: _pinField(index)),
                            ],
                          )
                        : Column(
                            children: [
                              _nameField(index),
                              const SizedBox(height: 10),
                              _pinField(index),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: working
                            ? null
                            : () => unawaited(_testChannel(index, true)),
                        icon: const Icon(Icons.power_settings_new),
                        label: const Text('Ligar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: working
                            ? null
                            : () => unawaited(_testChannel(index, false)),
                        icon: const Icon(Icons.power_off_outlined),
                        label: const Text('Desligar'),
                      ),
                      FilledButton.icon(
                        onPressed: working ? null : () => unawaited(_save()),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Salvar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _nameField(int index) => TextField(
    controller: channelNames[index],
    enabled: !working,
    decoration: const InputDecoration(
      labelText: 'Nome do ventilador/exaustor',
      prefixIcon: Icon(Icons.label_outline),
    ),
  );

  Widget _pinField(int index) => TextField(
    controller: channelPins[index],
    enabled: !working,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      labelText: 'GPIO',
      prefixIcon: Icon(Icons.settings_input_component_outlined),
    ),
  );

  Future<void> _save() async {
    final pinError = _validatePins();
    if (pinError != null) {
      setState(() => status = pinError);
      return;
    }
    setState(() => working = true);
    try {
      final controller = ref.read(operationsControllerProvider);
      await controller.saveSetting(
        'hardware_ventilation_enabled',
        ventilationEnabled.toString(),
      );
      await controller.saveSetting(
        'hardware_ventilation_endpoint',
        endpoint.text.trim(),
      );
      for (var i = 0; i < _ventilationChannelCount; i++) {
        final number = i + 1;
        await controller.saveSetting(
          'hardware_ventilation_channel_${number}_name',
          channelNames[i].text.trim().isEmpty
              ? 'Ventilador $number'
              : channelNames[i].text.trim(),
        );
        await controller.saveSetting(
          'hardware_ventilation_channel_${number}_pin',
          channelPins[i].text.trim(),
        );
        await controller.saveSetting(
          'hardware_ventilation_channel_${number}_enabled',
          channelEnabled[i].toString(),
        );
      }
      if (!mounted) return;
      setState(() => status = 'Ventilação salva nos canais ESP 5 a 12.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ventilação salva.')));
    } catch (error) {
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  String? _validatePins() {
    const reservedPins = {'23', '22', '21', '19', '27', '34', '35', '36', '39'};
    final used = <String>{};
    for (var i = 0; i < _ventilationChannelCount; i++) {
      if (!channelEnabled[i]) continue;
      final pin = channelPins[i].text.trim();
      if (pin.isEmpty) return 'FALHA: informe o GPIO do ventilador ${i + 1}.';
      if (reservedPins.contains(pin)) {
        return 'FALHA: GPIO $pin já está reservado para iluminação ou sensores.';
      }
      if (!used.add(pin)) return 'FALHA: GPIO $pin repetido na ventilação.';
    }
    return null;
  }

  Future<void> _testFirstEnabled({required bool turnOn}) async {
    final firstEnabled = channelEnabled.indexWhere((value) => value);
    if (firstEnabled < 0) {
      setState(() => status = 'FALHA: ative pelo menos um canal.');
      return;
    }
    await _testChannel(firstEnabled, turnOn);
  }

  Future<void> _testChannel(int index, bool turnOn) async {
    if (!ventilationEnabled) {
      setState(() {
        status = 'FALHA: ative o controle de ventilação.';
        channelStatus[index] = 'FALHA: ventilação desativada.';
      });
      return;
    }
    if (endpoint.text.trim().isEmpty) {
      setState(() {
        status = 'FALHA: informe o endpoint/IP do ESP32.';
        channelStatus[index] = 'FALHA: endpoint ausente.';
      });
      return;
    }
    if (!channelEnabled[index]) {
      setState(() => channelStatus[index] = 'FALHA: canal inativo.');
      return;
    }
    final pinError = _validatePins();
    if (pinError != null) {
      setState(() {
        status = pinError;
        channelStatus[index] = pinError;
      });
      return;
    }
    setState(() => working = true);
    try {
      final espChannel = _ventilationRelayOffset + index + 1;
      final result = await espClient.setRelay(
        endpoint: endpoint.text.trim(),
        channel: espChannel,
        turnOn: turnOn,
      );
      await ref
          .read(operationsControllerProvider)
          .saveSetting(
            'hardware_ventilation_channel_${index + 1}_last_test_state',
            result.on ? 'ON' : 'OFF',
          );
      if (!mounted) return;
      setState(() {
        channelOn[index] = result.on;
        channelStatus[index] = result.on
            ? 'OK: canal ESP $espChannel ligado no GPIO ${channelPins[index].text.trim()}.'
            : 'OK: canal ESP $espChannel desligado no GPIO ${channelPins[index].text.trim()}.';
        status = 'Ventilação testada no canal ESP $espChannel.';
        lastPayload = result.payload;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        final espChannel = _ventilationRelayOffset + index + 1;
        channelStatus[index] = 'FALHA: ESP não confirmou o canal $espChannel.';
        status = 'Falha ao acionar ventilação: $error';
      });
    } finally {
      if (mounted) setState(() => working = false);
    }
  }
}

class _VentilationInstrument extends StatelessWidget {
  const _VentilationInstrument({
    required this.enabled,
    required this.onCount,
    required this.channelOn,
    required this.channelEnabled,
    required this.channels,
  });

  final bool enabled;
  final int onCount;
  final List<bool> channelOn;
  final List<bool> channelEnabled;
  final int channels;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = enabled && onCount > 0;
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _VentilationAirflowPainter(
                color: colors.primary,
                active: active,
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, box) {
                final fanSize = box.maxWidth < 520 ? 46.0 : 58.0;
                return Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: box.maxWidth < 520 ? 10 : 14,
                  runSpacing: 10,
                  children: [
                    for (var i = 0; i < channels; i++)
                      _AnimatedFan(
                        size: fanSize,
                        active:
                            active &&
                            i < channelEnabled.length &&
                            channelEnabled[i] &&
                            i < channelOn.length &&
                            channelOn[i],
                        label: '${i + 1}',
                      ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: _SensorStatusPill(
              label: active ? '$onCount girando' : 'parado',
              icon: active ? Icons.air : Icons.pause_circle_outline,
              positive: active,
              warning: false,
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: _SensorStatusPill(
              label: '$channels canais',
              icon: Icons.settings_input_component_outlined,
              positive: enabled,
              warning: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedFan extends StatefulWidget {
  const _AnimatedFan({
    required this.size,
    required this.active,
    required this.label,
  });

  final double size;
  final bool active;
  final String label;

  @override
  State<_AnimatedFan> createState() => _AnimatedFanState();
}

class _AnimatedFanState extends State<_AnimatedFan>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    if (widget.active) controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _AnimatedFan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !controller.isAnimating) {
      controller.repeat();
    } else if (!widget.active && controller.isAnimating) {
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
    final colors = Theme.of(context).colorScheme;
    final color = widget.active ? colors.primary : colors.onSurfaceVariant;
    return SizedBox(
      width: widget.size,
      height: widget.size + 20,
      child: Column(
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => Transform.rotate(
                angle: controller.value * math.pi * 2,
                child: CustomPaint(
                  painter: _FanPainter(color: color, active: widget.active),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FanPainter extends CustomPainter {
  const _FanPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final ring = Paint()
      ..color = color.withValues(alpha: active ? .42 : .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final blade = Paint()
      ..color = color.withValues(alpha: active ? .62 : .24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, ring);
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate((math.pi * 2 / 3) * i);
      final path = Path()
        ..moveTo(0, -4)
        ..quadraticBezierTo(radius * .48, -radius * .20, radius * .62, -2)
        ..quadraticBezierTo(radius * .36, radius * .18, 3, 6)
        ..quadraticBezierTo(-4, 2, 0, -4);
      canvas.drawPath(path, blade);
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      radius * .16,
      Paint()..color = color.withValues(alpha: active ? .88 : .48),
    );
  }

  @override
  bool shouldRepaint(covariant _FanPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.active != active;
}

class _VentilationAirflowPainter extends CustomPainter {
  const _VentilationAirflowPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: active ? .18 : .07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (.22 + i * .13);
      final path = Path()
        ..moveTo(size.width * .08, y)
        ..cubicTo(
          size.width * .28,
          y - 18,
          size.width * .46,
          y + 18,
          size.width * .66,
          y,
        )
        ..cubicTo(
          size.width * .78,
          y - 10,
          size.width * .88,
          y - 4,
          size.width * .94,
          y,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VentilationAirflowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.active != active;
}

class _VentilationChannelGrid extends StatelessWidget {
  const _VentilationChannelGrid({
    required this.labels,
    required this.pins,
    required this.enabled,
    required this.on,
    required this.onOpen,
  });

  final List<String> labels;
  final List<String> pins;
  final List<bool> enabled;
  final List<bool> on;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final columns = box.maxWidth >= 960
          ? 4
          : box.maxWidth >= 620
          ? 3
          : 2;
      return GridView.builder(
        itemCount: _ventilationChannelCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: box.maxWidth < 430 ? 1.22 : 1.55,
        ),
        itemBuilder: (context, index) => _VentilationChannelTile(
          index: index,
          label: labels[index],
          pin: pins[index],
          enabled: enabled[index],
          on: on[index],
          onOpen: () => onOpen(index),
        ),
      );
    },
  );
}

class _VentilationChannelTile extends StatelessWidget {
  const _VentilationChannelTile({
    required this.index,
    required this.label,
    required this.pin,
    required this.enabled,
    required this.on,
    required this.onOpen,
  });

  final int index;
  final String label;
  final String pin;
  final bool enabled;
  final bool on;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveOn = enabled && on;
    final color = effectiveOn
        ? colors.primary
        : enabled
        ? colors.onSurface
        : colors.onSurfaceVariant;
    final espChannel = _ventilationRelayOffset + index + 1;
    return Material(
      color: colors.surface.withValues(alpha: .94),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: effectiveOn
              ? colors.primary.withValues(alpha: .60)
              : colors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    effectiveOn ? Icons.air : Icons.air_outlined,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    enabled
                        ? Icons.check_circle_outline
                        : Icons.pause_circle_outline,
                    size: 14,
                    color: enabled ? colors.primary : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      enabled ? 'ativo' : 'inativo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: enabled
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ESP $espChannel',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.settings_input_component_outlined,
                    size: 14,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'GPIO $pin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    effectiveOn ? 'ON' : 'OFF',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorMetric {
  const _SensorMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool active;
}

class _SensorExperience extends StatelessWidget {
  const _SensorExperience({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.visual,
    required this.metrics,
    required this.actions,
    required this.ports,
    required this.config,
    required this.payload,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Widget visual;
  final List<_SensorMetric> metrics;
  final List<Widget> actions;
  final List<_SensorPort> ports;
  final List<Widget> config;
  final Map<String, Object?>? payload;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final failed = status.toLowerCase().contains('falha');
    final active = !failed && status != 'Aguardando leitura';
    return Material(
      color: colors.surface.withValues(alpha: .96),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _TechIcon(icon: icon),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _SensorStatusPill(
                  label: failed
                      ? 'Falha'
                      : active
                      ? 'Online'
                      : 'Pronto',
                  icon: failed
                      ? Icons.error_outline
                      : active
                      ? Icons.check_circle_outline
                      : Icons.sensors_outlined,
                  positive: active && !failed,
                  warning: failed,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SensorStatusStrip(status: status, failed: failed),
            const SizedBox(height: 10),
            visual,
            const SizedBox(height: 10),
            _MetricRail(metrics: metrics),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                for (final action in actions)
                  IconTheme.merge(
                    data: const IconThemeData(size: 18),
                    child: action,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _SensorPortMap(ports: ports),
            const SizedBox(height: 10),
            ...config,
            const SizedBox(height: 10),
            _PayloadPanel(payload: payload),
          ],
        ),
      ),
    );
  }
}

class _TechIcon extends StatelessWidget {
  const _TechIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withValues(alpha: .22)),
      ),
      child: Icon(icon, color: colors.primary, size: 21),
    );
  }
}

class _MetricRail extends StatelessWidget {
  const _MetricRail({required this.metrics});

  final List<_SensorMetric> metrics;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final columns = box.maxWidth > 680 ? math.min(metrics.length, 4) : 2;
      return GridView.builder(
        itemCount: metrics.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: box.maxWidth > 420 ? 2.55 : 2.1,
        ),
        itemBuilder: (context, index) => _MetricTile(metric: metrics[index]),
      );
    },
  );
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final _SensorMetric metric;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = metric.active ? colors.primary : colors.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .32),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: metric.active
              ? colors.primary.withValues(alpha: .36)
              : colors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(metric.icon, size: 20, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
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

class _EnvironmentHouseInstrument extends StatelessWidget {
  const _EnvironmentHouseInstrument({
    required this.temperatureC,
    required this.humidityPercent,
    required this.working,
  });

  final double? temperatureC;
  final double? humidityPercent;
  final bool working;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 190,
      decoration: _instrumentDecoration(colors),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _HouseClimatePainter(
                color: colors.primary,
                outline: colors.outlineVariant,
                temperatureC: temperatureC,
                humidityPercent: humidityPercent,
                active:
                    temperatureC != null || humidityPercent != null || working,
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _SceneBadge(
              icon: Icons.device_thermostat_outlined,
              label: temperatureC == null
                  ? '-- °C'
                  : '${decimal.format(temperatureC!)} °C',
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: _SceneBadge(
              icon: Icons.water_drop_outlined,
              label: humidityPercent == null
                  ? '--%'
                  : '${decimal.format(humidityPercent!)}%',
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterReservoirInstrument extends StatelessWidget {
  const _WaterReservoirInstrument({
    required this.levelPercent,
    required this.temperatureC,
    required this.ph,
    required this.tdsPpm,
    required this.working,
  });

  final double? levelPercent;
  final double? temperatureC;
  final double? ph;
  final double? tdsPpm;
  final bool working;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final level = ((levelPercent ?? 0) / 100).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: level),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedLevel, _) => Container(
        height: 218,
        decoration: _instrumentDecoration(colors),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ReservoirPainter(
                  level: animatedLevel,
                  color: colors.primary,
                  outline: colors.outlineVariant,
                  active: levelPercent != null || working,
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: _SceneBadge(
                icon: Icons.water_outlined,
                label: levelPercent == null
                    ? '--%'
                    : '${decimal.format(levelPercent!)}%',
              ),
            ),
            Positioned(
              right: 14,
              top: 14,
              child: _SceneBadge(
                icon: Icons.science_outlined,
                label: ph == null ? 'pH --' : 'pH ${decimal.format(ph!)}',
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: _SceneBadge(
                      icon: Icons.device_thermostat_outlined,
                      label: temperatureC == null
                          ? '-- °C'
                          : '${decimal.format(temperatureC!)} °C',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SceneBadge(
                      icon: Icons.blur_on_outlined,
                      label: tdsPpm == null
                          ? 'TDS --'
                          : '${decimal.format(tdsPpm!)} ppm',
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

class _SceneBadge extends StatelessWidget {
  const _SceneBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _instrumentDecoration(ColorScheme colors) => BoxDecoration(
  color: colors.surfaceContainerHighest.withValues(alpha: .28),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: colors.outlineVariant),
);

class _HouseClimatePainter extends CustomPainter {
  const _HouseClimatePainter({
    required this.color,
    required this.outline,
    required this.temperatureC,
    required this.humidityPercent,
    required this.active,
  });

  final Color color;
  final Color outline;
  final double? temperatureC;
  final double? humidityPercent;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final fill = Paint()
      ..color = color.withValues(alpha: active ? .10 : .05)
      ..style = PaintingStyle.fill;
    final house = Path()
      ..moveTo(size.width * .18, size.height * .58)
      ..lineTo(size.width * .50, size.height * .26)
      ..lineTo(size.width * .82, size.height * .58)
      ..lineTo(size.width * .76, size.height * .58)
      ..lineTo(size.width * .76, size.height * .82)
      ..lineTo(size.width * .24, size.height * .82)
      ..lineTo(size.width * .24, size.height * .58)
      ..close();
    canvas.drawPath(house, fill);
    canvas.drawPath(house, stroke);
    final temp = ((temperatureC ?? 25) - 15).clamp(0, 25) / 25;
    final humidity = ((humidityPercent ?? 50).clamp(0, 100)) / 100;
    final climate = Paint()
      ..color = Color.lerp(
        const Color(0xFF2DD4BF),
        const Color(0xFFEF4444),
        temp.toDouble(),
      )!.withValues(alpha: .38)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * .38, size.height * .62),
      18 + 8 * temp.toDouble(),
      climate,
    );
    final drop = Paint()
      ..color = color.withValues(alpha: .24 + .30 * humidity.toDouble())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * .62, size.height * .62),
      12 + 14 * humidity.toDouble(),
      drop,
    );
    for (var i = 0; i < 4; i++) {
      final y = size.height * (.40 + i * .10);
      canvas.drawLine(
        Offset(size.width * .18, y),
        Offset(size.width * .10, y + 8),
        stroke,
      );
      canvas.drawLine(
        Offset(size.width * .82, y),
        Offset(size.width * .90, y + 8),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HouseClimatePainter oldDelegate) =>
      oldDelegate.temperatureC != temperatureC ||
      oldDelegate.humidityPercent != humidityPercent ||
      oldDelegate.active != active ||
      oldDelegate.color != color ||
      oldDelegate.outline != outline;
}

class _ReservoirPainter extends CustomPainter {
  const _ReservoirPainter({
    required this.level,
    required this.color,
    required this.outline,
    required this.active,
  });

  final double level;
  final Color color;
  final Color outline;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final tankRect = Rect.fromLTWH(
      size.width * .28,
      size.height * .18,
      size.width * .44,
      size.height * .64,
    );
    final tank = RRect.fromRectAndRadius(tankRect, const Radius.circular(18));
    final outlinePaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(tank, outlinePaint);
    final waterHeight = tankRect.height * level;
    final waterRect = Rect.fromLTWH(
      tankRect.left + 4,
      tankRect.bottom - waterHeight - 4,
      tankRect.width - 8,
      math.max(0, waterHeight),
    );
    final waterPaint = Paint()
      ..color = color.withValues(alpha: active ? .58 : .28)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(waterRect, const Radius.circular(14)),
      waterPaint,
    );
    final wavePaint = Paint()
      ..color = color.withValues(alpha: .80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    if (waterHeight > 8) {
      final y = waterRect.top + 6;
      final wave = Path()..moveTo(waterRect.left + 8, y);
      for (var x = waterRect.left + 8; x <= waterRect.right - 8; x += 10) {
        wave.quadraticBezierTo(x + 5, y - 5, x + 10, y);
      }
      canvas.drawPath(wave, wavePaint);
    }
    final pipe = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(tankRect.right, tankRect.center.dy),
      Offset(size.width * .88, tankRect.center.dy),
      pipe,
    );
    canvas.drawCircle(
      Offset(size.width * .88, tankRect.center.dy),
      5,
      Paint()..color = color.withValues(alpha: active ? .65 : .30),
    );
  }

  @override
  bool shouldRepaint(covariant _ReservoirPainter oldDelegate) =>
      oldDelegate.level != level ||
      oldDelegate.active != active ||
      oldDelegate.color != color ||
      oldDelegate.outline != outline;
}

class _SensorPanel extends StatelessWidget {
  const _SensorPanel({
    required this.icon,
    required this.title,
    required this.status,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String status;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final failed = status.toLowerCase().contains('falha');
    final active = !failed && status != 'Aguardando leitura';
    return Material(
      color: colors.surface.withValues(alpha: .95),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SensorStatusPill(
                  label: failed
                      ? 'Falha'
                      : active
                      ? 'Lido'
                      : 'Pronto',
                  icon: failed
                      ? Icons.error_outline
                      : active
                      ? Icons.check_circle_outline
                      : Icons.sensors_outlined,
                  positive: active && !failed,
                  warning: failed,
                ),
              ],
            ),
            const SizedBox(height: 7),
            _SensorStatusStrip(status: status, failed: failed),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _EndpointField extends StatelessWidget {
  const _EndpointField({required this.controller, required this.working});

  final TextEditingController controller;
  final bool working;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: !working,
    decoration: const InputDecoration(
      labelText: 'Endpoint/IP do ESP32',
      prefixIcon: Icon(Icons.router_outlined),
      isDense: true,
    ),
  );
}

class _SensorConfigCard extends StatelessWidget {
  const _SensorConfigCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 17, color: colors.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SensorStatusPill extends StatelessWidget {
  const _SensorStatusPill({
    required this.label,
    required this.icon,
    required this.positive,
    required this.warning,
  });

  final String label;
  final IconData icon;
  final bool positive;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = warning
        ? colors.error
        : positive
        ? colors.primary
        : colors.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorStatusStrip extends StatelessWidget {
  const _SensorStatusStrip({required this.status, required this.failed});

  final String status;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = failed ? colors.error : colors.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              failed ? Icons.error_outline : Icons.info_outline,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                status,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: failed ? colors.error : colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorPort {
  const _SensorPort(this.label, this.gpio, this.icon);

  final String label;
  final String gpio;
  final IconData icon;
}

class _SensorPortMap extends StatelessWidget {
  const _SensorPortMap({required this.ports});

  final List<_SensorPort> ports;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings_input_component_outlined,
              size: 17,
              color: colors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Portas do ESP32',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [for (final port in ports) _SensorPortChip(port: port)],
        ),
      ],
    );
  }
}

class _SensorPortChip extends StatelessWidget {
  const _SensorPortChip({required this.port});

  final _SensorPort port;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(port.icon, size: 15, color: colors.primary),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 104),
            child: Text(
              port.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            port.gpio,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SensorActions extends StatelessWidget {
  const _SensorActions({
    required this.working,
    required this.onRead,
    required this.onSave,
  });

  final bool working;
  final VoidCallback onRead;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.end,
    children: [
      FilledButton.icon(
        onPressed: working ? null : onRead,
        icon: const Icon(Icons.sensors_outlined),
        label: const Text('Ler'),
        style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
      ),
      OutlinedButton.icon(
        onPressed: working ? null : onSave,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Salvar'),
        style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
      ),
    ],
  );
}

class _ReadingGrid extends StatelessWidget {
  const _ReadingGrid({required this.tiles});

  final List<_ReadingTile> tiles;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => GridView.count(
      crossAxisCount: box.maxWidth > 680 ? 4 : 2,
      childAspectRatio: box.maxWidth > 420 ? 2.45 : 2.02,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    ),
  );
}

class _ReadingTile extends StatelessWidget {
  const _ReadingTile({
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
    final color = active ? colors.primary : colors.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .46),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? colors.primary.withValues(alpha: .42)
              : colors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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

class _PayloadPanel extends StatelessWidget {
  const _PayloadPanel({required this.payload});

  final Map<String, Object?>? payload;

  @override
  Widget build(BuildContext context) {
    if (payload == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    const encoder = JsonEncoder.withIndent('  ');
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: .24),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        leading: Icon(
          Icons.data_object_outlined,
          size: 18,
          color: colors.onSurfaceVariant,
        ),
        title: Text(
          'Payload da última leitura',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              encoder.convert(payload),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

String _setting(List<AppSetting> settings, String key) {
  for (final setting in settings) {
    if (setting.key == key) return setting.value.trim();
  }
  return '';
}

double? _settingDouble(List<AppSetting> settings, String key) {
  final value = _setting(settings, key);
  if (value.isEmpty) return null;
  return double.tryParse(value.replaceAll(',', '.'));
}

String _sensorEndpoint(List<AppSetting> settings, String preferredKey) {
  final preferred = _setting(settings, preferredKey);
  if (preferred.isNotEmpty) return preferred;
  return _setting(settings, 'hardware_lighting_endpoint');
}
