import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/hardware_esp_client.dart';
import '../../application/hardware_mqtt_client.dart';
import '../../application/operations_controller.dart';

class HardwareIntegrationSettings {
  const HardwareIntegrationSettings({
    required this.lightingEnabled,
    required this.lightingConnection,
    required this.lightingEndpoint,
    required this.lightingRelayPin,
    required this.lightingChannels,
  });

  final bool lightingEnabled;
  final String lightingConnection;
  final String lightingEndpoint;
  final String lightingRelayPin;
  final List<LightingChannelConfig> lightingChannels;

  factory HardwareIntegrationSettings.fromSettings(List<AppSetting> settings) {
    final values = {for (final setting in settings) setting.key: setting.value};
    const lightingConnection = 'WIFI';
    return HardwareIntegrationSettings(
      lightingEnabled: values['hardware_lighting_enabled'] == 'true',
      lightingConnection: lightingConnection,
      lightingEndpoint: values['hardware_lighting_endpoint']?.trim() ?? '',
      lightingRelayPin: values['hardware_lighting_relay_pin']?.trim() ?? '23',
      lightingChannels: [
        for (var i = 1; i <= 4; i++)
          LightingChannelConfig(
            index: i,
            name:
                values['hardware_lighting_channel_${i}_name']?.trim() ??
                'Canal $i',
            pin:
                values['hardware_lighting_channel_${i}_pin']?.trim() ??
                switch (i) {
                  1 => values['hardware_lighting_relay_pin']?.trim() ?? '23',
                  2 => '22',
                  3 => '21',
                  _ => '19',
                },
            enabled:
                values['hardware_lighting_channel_${i}_enabled'] != 'false',
          ),
      ],
    );
  }

  bool get lightingReady => lightingEnabled && lightingEndpoint.isNotEmpty;
}

class LightingChannelConfig {
  const LightingChannelConfig({
    required this.index,
    required this.name,
    required this.pin,
    required this.enabled,
  });

  final int index;
  final String name;
  final String pin;
  final bool enabled;
}

class HardwareIntegrationsPage extends ConsumerStatefulWidget {
  const HardwareIntegrationsPage({super.key});

  @override
  ConsumerState<HardwareIntegrationsPage> createState() =>
      _HardwareIntegrationsPageState();
}

class _HardwareIntegrationsPageState
    extends ConsumerState<HardwareIntegrationsPage> {
  final espClient = const HardwareEspClient();
  final mqttClient = const HardwareMqttClient();
  final mqttRuntime = HardwareMqttRuntime();
  final lightingEndpoint = TextEditingController();
  final lightingRelayPin = TextEditingController(text: '23');
  final wifiProvisionEndpoint = TextEditingController(text: '192.168.4.1');
  final wifiProvisionSsid = TextEditingController();
  final wifiProvisionPassword = TextEditingController();
  final mqttHost = TextEditingController();
  final mqttPort = TextEditingController(text: '1883');
  final mqttBaseTopic = TextEditingController(text: 'seleto/esp32');
  final mqttDeviceId = TextEditingController(text: 'SELETO-RELE-01');
  final mqttUsername = TextEditingController();
  final mqttPassword = TextEditingController();
  final lightingChannelNames = List.generate(
    4,
    (index) => TextEditingController(text: 'Canal ${index + 1}'),
  );
  final lightingChannelPins = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final lightingChannelOnTimes = List.generate(
    4,
    (index) => TextEditingController(text: '04:30'),
  );
  final lightingChannelOffTimes = List.generate(
    4,
    (index) => TextEditingController(text: '06:10'),
  );
  final lightingChannelEveningOnTimes = List.generate(
    4,
    (index) => TextEditingController(text: '17:40'),
  );
  final lightingChannelEveningOffTimes = List.generate(
    4,
    (index) => TextEditingController(text: '20:00'),
  );
  final generalMorningOnTime = TextEditingController(text: '04:30');
  final generalMorningOffTime = TextEditingController(text: '06:10');
  final generalEveningOnTime = TextEditingController(text: '17:40');
  final generalEveningOffTime = TextEditingController(text: '20:00');
  final lightingChannelStatus = List.generate(
    4,
    (index) => 'Canal ${index + 1} aguardando teste',
  );
  final lightingChannelOn = List.generate(4, (index) => false);
  final lightingChannelEnabled = List.generate(4, (index) => true);
  final lightingChannelMorningEnabled = List.generate(4, (index) => true);
  final lightingChannelEveningEnabled = List.generate(4, (index) => true);
  final generalScheduleChannels = List.generate(4, (index) => true);
  bool generalMorningEnabled = true;
  bool generalEveningEnabled = true;
  String lightingConnection = 'WIFI';
  bool lightingEnabled = false;
  bool saving = false;
  bool initialized = false;
  bool wifiProvisionPasswordHidden = true;
  bool mqttPasswordHidden = true;
  bool mqttEnabled = false;
  bool mqttConnected = false;
  bool mqttRuntimeStarted = false;
  StreamSubscription<EspMqttUpdate>? mqttRuntimeSubscription;
  bool espWifiConnected = false;
  String lightingStatus = 'Aguardando teste';
  String? lightingConnectionResult;
  bool espDiscoveryStarted = false;
  bool espScanning = false;
  String espTerminalTitle = 'SELETO ESP LINK';
  List<String> espTerminalLines = const [
    'SYS> aguardando handshake com ESP32',
    'SYS> modo Wi-Fi procura /api/status automaticamente',
    'SYS> fallback AP: SELETO-SETUP / seleto1234',
  ];

  @override
  void dispose() {
    mqttRuntimeSubscription?.cancel();
    unawaited(mqttRuntime.dispose());
    lightingEndpoint.dispose();
    lightingRelayPin.dispose();
    wifiProvisionEndpoint.dispose();
    wifiProvisionSsid.dispose();
    wifiProvisionPassword.dispose();
    mqttHost.dispose();
    mqttPort.dispose();
    mqttBaseTopic.dispose();
    mqttDeviceId.dispose();
    mqttUsername.dispose();
    mqttPassword.dispose();
    for (final controller in lightingChannelNames) {
      controller.dispose();
    }
    for (final controller in lightingChannelPins) {
      controller.dispose();
    }
    for (final controller in lightingChannelOnTimes) {
      controller.dispose();
    }
    for (final controller in lightingChannelOffTimes) {
      controller.dispose();
    }
    for (final controller in lightingChannelEveningOnTimes) {
      controller.dispose();
    }
    for (final controller in lightingChannelEveningOffTimes) {
      controller.dispose();
    }
    generalMorningOnTime.dispose();
    generalMorningOffTime.dispose();
    generalEveningOnTime.dispose();
    generalEveningOffTime.dispose();
    super.dispose();
  }

  void _hydrate(List<AppSetting> settings) {
    if (initialized) return;
    initialized = true;
    final values = {for (final setting in settings) setting.key: setting.value};
    final config = HardwareIntegrationSettings.fromSettings(settings);
    lightingEnabled = config.lightingEnabled;
    lightingConnection = config.lightingConnection;
    lightingEndpoint.text = config.lightingEndpoint;
    lightingRelayPin.text = config.lightingRelayPin;
    wifiProvisionEndpoint.text =
        values['hardware_esp_setup_endpoint']?.trim() ?? '192.168.4.1';
    wifiProvisionSsid.text = values['hardware_esp_wifi_ssid']?.trim() ?? '';
    wifiProvisionPassword.text =
        values['hardware_esp_wifi_password']?.trim() ?? '';
    mqttEnabled = values['hardware_esp_mqtt_enabled'] == 'true';
    mqttHost.text = values['hardware_esp_mqtt_host']?.trim() ?? '';
    mqttPort.text = values['hardware_esp_mqtt_port']?.trim() ?? '1883';
    final savedMqttBaseTopic = values['hardware_esp_mqtt_base_topic']?.trim();
    mqttBaseTopic.text =
        savedMqttBaseTopic == null || savedMqttBaseTopic == 'granja/esp32'
        ? 'seleto/esp32'
        : savedMqttBaseTopic;
    final savedMqttDeviceId = values['hardware_esp_mqtt_device_id']?.trim();
    mqttDeviceId.text =
        savedMqttDeviceId == null ||
            savedMqttDeviceId == 'GRANJA-SELETO-RELE-01'
        ? 'SELETO-RELE-01'
        : savedMqttDeviceId;
    mqttUsername.text = values['hardware_esp_mqtt_username']?.trim() ?? '';
    mqttPassword.text = values['hardware_esp_mqtt_password'] ?? '';
    for (final channel in config.lightingChannels) {
      final index = channel.index - 1;
      if (index < 0 || index >= 4) continue;
      lightingChannelNames[index].text = channel.name;
      lightingChannelPins[index].text = channel.pin;
      lightingChannelEnabled[index] = channel.enabled;
      lightingChannelMorningEnabled[index] =
          values['hardware_lighting_channel_${channel.index}_morning_enabled'] !=
          'false';
      lightingChannelEveningEnabled[index] =
          values['hardware_lighting_channel_${channel.index}_evening_enabled'] !=
          'false';
      lightingChannelOnTimes[index].text =
          values['hardware_lighting_channel_${channel.index}_morning_on_time']
              ?.trim() ??
          values['hardware_lighting_channel_${channel.index}_on_time']
              ?.trim() ??
          '04:30';
      lightingChannelOffTimes[index].text =
          values['hardware_lighting_channel_${channel.index}_morning_off_time']
              ?.trim() ??
          values['hardware_lighting_channel_${channel.index}_off_time']
              ?.trim() ??
          '06:10';
      lightingChannelEveningOnTimes[index].text =
          values['hardware_lighting_channel_${channel.index}_evening_on_time']
              ?.trim() ??
          '17:40';
      lightingChannelEveningOffTimes[index].text =
          values['hardware_lighting_channel_${channel.index}_evening_off_time']
              ?.trim() ??
          '20:00';
      final lastState =
          values['hardware_lighting_channel_${channel.index}_last_test_state'];
      lightingChannelOn[index] = lastState == 'ON';
      if (lastState == 'ON' || lastState == 'OFF') {
        lightingChannelStatus[index] = 'Último estado: $lastState';
      }
    }
    generalMorningEnabled =
        values['hardware_lighting_general_morning_enabled'] != 'false';
    generalEveningEnabled =
        values['hardware_lighting_general_evening_enabled'] != 'false';
    generalMorningOnTime.text =
        values['hardware_lighting_general_morning_on_time']?.trim() ?? '04:30';
    generalMorningOffTime.text =
        values['hardware_lighting_general_morning_off_time']?.trim() ?? '06:10';
    generalEveningOnTime.text =
        values['hardware_lighting_general_evening_on_time']?.trim() ?? '17:40';
    generalEveningOffTime.text =
        values['hardware_lighting_general_evening_off_time']?.trim() ?? '20:00';
    for (var i = 0; i < 4; i++) {
      generalScheduleChannels[i] =
          values['hardware_lighting_general_channel_${i + 1}_selected'] !=
          'false';
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    title: 'Iluminação',
    child: ref
        .watch(appSettingsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (settings) {
            _hydrate(settings);
            if (!espDiscoveryStarted) {
              espDiscoveryStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _discoverEsp(auto: true);
              });
            }
            if (!mqttRuntimeStarted && _mqttConfig().isUsable) {
              mqttRuntimeStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) unawaited(_startMqttRuntime());
              });
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IntegrationHeader(
                  lightingReady:
                      lightingEnabled &&
                      lightingEndpoint.text.trim().isNotEmpty,
                ),
                const SizedBox(height: 16),
                _EspTerminalPanel(
                  title: espTerminalTitle,
                  lines: espTerminalLines,
                  scanning: espScanning,
                  onDiscover: () => _discoverEsp(auto: false),
                  onTestEndpoint: () => _testSavedWifiEndpoint(),
                ),
                const SizedBox(height: 12),
                _EspWifiProvisionPanel(
                  endpointController: wifiProvisionEndpoint,
                  ssidController: wifiProvisionSsid,
                  passwordController: wifiProvisionPassword,
                  passwordHidden: wifiProvisionPasswordHidden,
                  connected: espWifiConnected,
                  busy: saving || espScanning,
                  onConfigure: _configureEspWifi,
                  onDisconnect: _disconnectEspWifi,
                  onTogglePassword: () => setState(
                    () => wifiProvisionPasswordHidden =
                        !wifiProvisionPasswordHidden,
                  ),
                  onHelp: _showEspWifiHelp,
                ),
                const SizedBox(height: 12),
                _EspMqttPanel(
                  enabled: mqttEnabled,
                  connected: mqttConnected,
                  busy: saving || espScanning,
                  hostController: mqttHost,
                  portController: mqttPort,
                  baseTopicController: mqttBaseTopic,
                  deviceIdController: mqttDeviceId,
                  usernameController: mqttUsername,
                  passwordController: mqttPassword,
                  passwordHidden: mqttPasswordHidden,
                  onEnabledChanged: (value) =>
                      setState(() => mqttEnabled = value),
                  onTogglePassword: () =>
                      setState(() => mqttPasswordHidden = !mqttPasswordHidden),
                  onSave: _saveMqttSettings,
                  onTest: _testMqttConnection,
                  onPushToEsp: _configureEspMqtt,
                ),
                const SizedBox(height: 16),
                _lightingPanel(context),
              ],
            );
          },
        ),
  );

  // ignore: unused_element
  Widget _lightingPanel(BuildContext context) {
    final channelLabels = [
      for (var i = 0; i < lightingChannelNames.length; i++)
        lightingChannelNames[i].text.trim().isEmpty
            ? 'Canal ${i + 1}'
            : lightingChannelNames[i].text.trim(),
    ];
    final enabledCount = lightingChannelEnabled.where((value) => value).length;
    final onCount = [
      for (var i = 0; i < lightingChannelOn.length; i++)
        lightingChannelEnabled[i] && lightingChannelOn[i],
    ].where((value) => value).length;

    return _IntegrationPanel(
      icon: Icons.lightbulb_outline,
      title: 'Iluminação',
      status: lightingStatus,
      children: [
        _LightingControlInstrument(
          enabled: lightingEnabled,
          channelLabels: channelLabels,
          pins: [
            for (final controller in lightingChannelPins)
              controller.text.trim().isEmpty ? '-' : controller.text.trim(),
          ],
          channelEnabled: lightingChannelEnabled,
          channelOn: lightingChannelOn,
          morningEnabled: lightingChannelMorningEnabled,
          eveningEnabled: lightingChannelEveningEnabled,
          connection: lightingConnection,
          connectionOk: lightingConnectionResult?.contains('OK') == true,
          enabledCount: enabledCount,
          onCount: onCount,
        ),
        const SizedBox(height: 12),
        _LightingConnectionPanel(
          enabled: lightingEnabled,
          connection: lightingConnection,
          connectionResult: lightingConnectionResult ?? 'Ainda não testada',
          endpointController: lightingEndpoint,
          relayPinController: lightingRelayPin,
          saving: saving,
          onEnabledChanged: (value) => setState(() => lightingEnabled = value),
          onConnectionChanged: (value) =>
              setState(() => lightingConnection = value),
          enabledCount: enabledCount,
          onCount: onCount,
        ),
        const SizedBox(height: 12),
        _LightingChannelBoard(
          labels: channelLabels,
          pins: [
            for (final controller in lightingChannelPins)
              controller.text.trim().isEmpty ? '-' : controller.text.trim(),
          ],
          enabled: lightingChannelEnabled,
          on: lightingChannelOn,
          morningEnabled: lightingChannelMorningEnabled,
          eveningEnabled: lightingChannelEveningEnabled,
          morningOnTimes: [
            for (final controller in lightingChannelOnTimes)
              controller.text.trim(),
          ],
          morningOffTimes: [
            for (final controller in lightingChannelOffTimes)
              controller.text.trim(),
          ],
          eveningOnTimes: [
            for (final controller in lightingChannelEveningOnTimes)
              controller.text.trim(),
          ],
          eveningOffTimes: [
            for (final controller in lightingChannelEveningOffTimes)
              controller.text.trim(),
          ],
          onOpen: _openLightingChannelSheet,
        ),
        const SizedBox(height: 12),
        _GeneralLightingSchedulePanel(
          selectedChannels: generalScheduleChannels,
          channelLabels: channelLabels,
          morningEnabled: generalMorningEnabled,
          eveningEnabled: generalEveningEnabled,
          saving: saving,
          morningTime:
              '${generalMorningOnTime.text.trim()}-${generalMorningOffTime.text.trim()}',
          eveningTime:
              '${generalEveningOnTime.text.trim()}-${generalEveningOffTime.text.trim()}',
          onOpen: () => _openGeneralLightingScheduleSheet(channelLabels),
        ),
        const SizedBox(height: 12),
        _InfoStrip(
          icon: Icons.event_available_outlined,
          text:
              'Cada canal pode ser testado separadamente. A agenda enviada fica salva no ESP e roda pelo relógio NTP ou pela hora sincronizada pelo app.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: saving ? null : _saveLighting,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar'),
            ),
            FilledButton.tonalIcon(
              onPressed: saving ? null : _testLightingConnection,
              icon: const Icon(Icons.wifi),
              label: const Text('Testar Wi-Fi'),
            ),
            FilledButton.tonalIcon(
              onPressed: saving || espScanning ? null : _syncLightingSchedule,
              icon: const Icon(Icons.event_repeat_outlined),
              label: const Text('Sincronizar agenda'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openLightingChannelSheet(int index) async {
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

          final label = lightingChannelNames[index].text.trim().isEmpty
              ? 'Canal ${index + 1}'
              : lightingChannelNames[index].text.trim();
          final colors = Theme.of(sheetContext).colorScheme;
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
                        lightingChannelOn[index]
                            ? Icons.lightbulb
                            : Icons.lightbulb_outline,
                        color: lightingChannelOn[index]
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
                        value: lightingChannelEnabled[index],
                        onChanged: saving
                            ? null
                            : (value) => updateSheet(
                                () => lightingChannelEnabled[index] = value,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoStrip(
                    icon: lightingChannelStatus[index].contains('FALHA')
                        ? Icons.error_outline
                        : Icons.info_outline,
                    text: lightingChannelStatus[index],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, box) => box.maxWidth > 520
                        ? Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: lightingChannelNames[index],
                                  enabled: !saving,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome do canal',
                                    prefixIcon: Icon(Icons.label_outline),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: lightingChannelPins[index],
                                  enabled: !saving,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'GPIO',
                                    prefixIcon: Icon(
                                      Icons.settings_input_component_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              TextField(
                                controller: lightingChannelNames[index],
                                enabled: !saving,
                                decoration: const InputDecoration(
                                  labelText: 'Nome do canal',
                                  prefixIcon: Icon(Icons.label_outline),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: lightingChannelPins[index],
                                enabled: !saving,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'GPIO',
                                  prefixIcon: Icon(
                                    Icons.settings_input_component_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 10),
                  _ScheduleWindowFields(
                    title: 'Manhã',
                    enabled:
                        lightingChannelEnabled[index] &&
                        lightingChannelMorningEnabled[index],
                    switchValue: lightingChannelMorningEnabled[index],
                    saving: saving,
                    onEnabledChanged: lightingChannelEnabled[index]
                        ? (value) => updateSheet(
                            () => lightingChannelMorningEnabled[index] = value,
                          )
                        : null,
                    onController: lightingChannelOnTimes[index],
                    offController: lightingChannelOffTimes[index],
                    icon: Icons.wb_twilight_outlined,
                  ),
                  const SizedBox(height: 10),
                  _ScheduleWindowFields(
                    title: 'Tarde/noite',
                    enabled:
                        lightingChannelEnabled[index] &&
                        lightingChannelEveningEnabled[index],
                    switchValue: lightingChannelEveningEnabled[index],
                    saving: saving,
                    onEnabledChanged: lightingChannelEnabled[index]
                        ? (value) => updateSheet(
                            () => lightingChannelEveningEnabled[index] = value,
                          )
                        : null,
                    onController: lightingChannelEveningOnTimes[index],
                    offController: lightingChannelEveningOffTimes[index],
                    icon: Icons.nights_stay_outlined,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: saving
                            ? null
                            : () =>
                                  unawaited(_testLightingChannel(index, true)),
                        icon: const Icon(Icons.light_mode_outlined),
                        label: const Text('Ligar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () =>
                                  unawaited(_testLightingChannel(index, false)),
                        icon: const Icon(Icons.dark_mode_outlined),
                        label: const Text('Desligar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () => unawaited(_pulseLightingChannel(index)),
                        icon: const Icon(Icons.bolt_outlined),
                        label: const Text('Pulso'),
                      ),
                      FilledButton.icon(
                        onPressed: saving
                            ? null
                            : () => unawaited(_saveLighting()),
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

  Future<void> _openGeneralLightingScheduleSheet(
    List<String> channelLabels,
  ) async {
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
          final selectedCount = generalScheduleChannels
              .where((selected) => selected)
              .length;
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
                      Icon(Icons.tune_outlined, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Agenda geral',
                          style: Theme.of(sheetContext).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '$selectedCount/4',
                        style: Theme.of(sheetContext).textTheme.labelLarge
                            ?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () => updateSheet(() {
                                for (
                                  var i = 0;
                                  i < generalScheduleChannels.length;
                                  i++
                                ) {
                                  generalScheduleChannels[i] = true;
                                }
                              }),
                        icon: const Icon(Icons.done_all_outlined),
                        label: const Text('Todos'),
                      ),
                      OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () => updateSheet(() {
                                for (
                                  var i = 0;
                                  i < generalScheduleChannels.length;
                                  i++
                                ) {
                                  generalScheduleChannels[i] = false;
                                }
                              }),
                        icon: const Icon(Icons.remove_done_outlined),
                        label: const Text('Nenhum'),
                      ),
                      for (var i = 0; i < generalScheduleChannels.length; i++)
                        FilterChip(
                          selected: generalScheduleChannels[i],
                          onSelected: saving
                              ? null
                              : (value) => updateSheet(
                                  () => generalScheduleChannels[i] = value,
                                ),
                          avatar: Icon(
                            generalScheduleChannels[i]
                                ? Icons.check_circle_outline
                                : Icons.circle_outlined,
                            size: 18,
                          ),
                          label: Text(
                            i < channelLabels.length
                                ? channelLabels[i]
                                : 'Canal ${i + 1}',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ScheduleWindowFields(
                    title: 'Manhã geral',
                    enabled: generalMorningEnabled,
                    switchValue: generalMorningEnabled,
                    saving: saving,
                    onEnabledChanged: (value) =>
                        updateSheet(() => generalMorningEnabled = value),
                    onController: generalMorningOnTime,
                    offController: generalMorningOffTime,
                    icon: Icons.wb_twilight_outlined,
                  ),
                  const SizedBox(height: 10),
                  _ScheduleWindowFields(
                    title: 'Tarde/noite geral',
                    enabled: generalEveningEnabled,
                    switchValue: generalEveningEnabled,
                    saving: saving,
                    onEnabledChanged: (value) =>
                        updateSheet(() => generalEveningEnabled = value),
                    onController: generalEveningOnTime,
                    offController: generalEveningOffTime,
                    icon: Icons.nights_stay_outlined,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: saving
                            ? null
                            : () => unawaited(
                                _applyGeneralLightingSchedule(syncAfter: false),
                              ),
                        icon: const Icon(Icons.playlist_add_check_outlined),
                        label: const Text('Aplicar'),
                      ),
                      FilledButton.icon(
                        onPressed: saving
                            ? null
                            : () => unawaited(
                                _applyGeneralLightingSchedule(syncAfter: true),
                              ),
                        icon: const Icon(Icons.sync_outlined),
                        label: const Text('Aplicar e sincronizar'),
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

  Future<void> _saveLighting() async {
    setState(() => saving = true);
    try {
      final controller = ref.read(operationsControllerProvider);
      final updates = {
        'hardware_lighting_enabled': lightingEnabled.toString(),
        'hardware_lighting_connection': lightingConnection,
        'hardware_lighting_endpoint': lightingEndpoint.text.trim(),
        'hardware_lighting_relay_pin': lightingRelayPin.text.trim(),
        'hardware_esp_mqtt_enabled': mqttEnabled.toString(),
        'hardware_esp_mqtt_host': mqttHost.text.trim(),
        'hardware_esp_mqtt_port': mqttPort.text.trim(),
        'hardware_esp_mqtt_base_topic': mqttBaseTopic.text.trim(),
        'hardware_esp_mqtt_device_id': mqttDeviceId.text.trim(),
        'hardware_esp_mqtt_username': mqttUsername.text.trim(),
        'hardware_esp_mqtt_password': mqttPassword.text,
        'hardware_lighting_general_morning_enabled': generalMorningEnabled
            .toString(),
        'hardware_lighting_general_morning_on_time': generalMorningOnTime.text
            .trim(),
        'hardware_lighting_general_morning_off_time': generalMorningOffTime.text
            .trim(),
        'hardware_lighting_general_evening_enabled': generalEveningEnabled
            .toString(),
        'hardware_lighting_general_evening_on_time': generalEveningOnTime.text
            .trim(),
        'hardware_lighting_general_evening_off_time': generalEveningOffTime.text
            .trim(),
      };
      for (var i = 0; i < 4; i++) {
        updates['hardware_lighting_general_channel_${i + 1}_selected'] =
            generalScheduleChannels[i].toString();
      }
      for (var i = 0; i < 4; i++) {
        final number = i + 1;
        updates['hardware_lighting_channel_${number}_name'] =
            lightingChannelNames[i].text.trim().isEmpty
            ? 'Canal $number'
            : lightingChannelNames[i].text.trim();
        updates['hardware_lighting_channel_${number}_pin'] =
            lightingChannelPins[i].text.trim();
        updates['hardware_lighting_channel_${number}_enabled'] =
            lightingChannelEnabled[i].toString();
        updates['hardware_lighting_channel_${number}_on_time'] =
            lightingChannelOnTimes[i].text.trim();
        updates['hardware_lighting_channel_${number}_off_time'] =
            lightingChannelOffTimes[i].text.trim();
        updates['hardware_lighting_channel_${number}_morning_enabled'] =
            lightingChannelMorningEnabled[i].toString();
        updates['hardware_lighting_channel_${number}_morning_on_time'] =
            lightingChannelOnTimes[i].text.trim();
        updates['hardware_lighting_channel_${number}_morning_off_time'] =
            lightingChannelOffTimes[i].text.trim();
        updates['hardware_lighting_channel_${number}_evening_enabled'] =
            lightingChannelEveningEnabled[i].toString();
        updates['hardware_lighting_channel_${number}_evening_on_time'] =
            lightingChannelEveningOnTimes[i].text.trim();
        updates['hardware_lighting_channel_${number}_evening_off_time'] =
            lightingChannelEveningOffTimes[i].text.trim();
      }
      for (final entry in updates.entries) {
        await controller.saveSetting(entry.key, entry.value);
      }
      if (mounted) {
        setState(() => lightingStatus = 'Configuração de iluminação salva');
        _snack('Iluminação salva.');
      }
    } catch (error) {
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  EspMqttConfig _mqttConfig() => EspMqttConfig(
    enabled: mqttEnabled,
    host: mqttHost.text.trim(),
    port: int.tryParse(mqttPort.text.trim()) ?? 1883,
    baseTopic: mqttBaseTopic.text.trim().isEmpty
        ? 'seleto/esp32'
        : mqttBaseTopic.text.trim(),
    deviceId: mqttDeviceId.text.trim().isEmpty
        ? 'SELETO-RELE-01'
        : mqttDeviceId.text.trim(),
    username: mqttUsername.text.trim(),
    password: mqttPassword.text,
  );

  Future<void> _saveMqttSettings() async {
    setState(() => saving = true);
    try {
      final controller = ref.read(operationsControllerProvider);
      final updates = {
        'hardware_esp_mqtt_enabled': mqttEnabled.toString(),
        'hardware_esp_mqtt_host': mqttHost.text.trim(),
        'hardware_esp_mqtt_port': mqttPort.text.trim(),
        'hardware_esp_mqtt_base_topic': mqttBaseTopic.text.trim(),
        'hardware_esp_mqtt_device_id': mqttDeviceId.text.trim(),
        'hardware_esp_mqtt_username': mqttUsername.text.trim(),
        'hardware_esp_mqtt_password': mqttPassword.text,
      };
      for (final entry in updates.entries) {
        await controller.saveSetting(entry.key, entry.value);
      }
      if (!mounted) return;
      setState(() {
        lightingStatus = 'Configuração MQTT salva.';
        espTerminalTitle = 'MQTT SALVO';
      });
      _appendEspLog('APP> MQTT salvo em ${mqttHost.text.trim()}');
      _snack('MQTT salvo.');
      if (mqttEnabled) {
        unawaited(_startMqttRuntime());
      } else {
        await mqttRuntime.disconnect();
        if (mounted) setState(() => mqttConnected = false);
      }
    } catch (error) {
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _testMqttConnection() async {
    final config = _mqttConfig();
    if (!config.isUsable) {
      setState(() {
        lightingStatus = 'Informe broker, porta e tópico MQTT.';
        lightingConnectionResult = 'FALHA MQTT: configuração incompleta.';
      });
      return;
    }
    setState(() {
      saving = true;
      espTerminalTitle = 'MQTT HANDSHAKE';
    });
    try {
      final probe = await mqttClient.test(config);
      if (!mounted) return;
      await _saveMqttSettings();
      if (!mounted) return;
      setState(() {
        mqttConnected = probe.connected;
        lightingConnectionResult = probe.connected
            ? 'OK MQTT: broker conectado.'
            : 'MQTT configurado.';
        lightingStatus = probe.connected
            ? 'MQTT operacional para comandos rápidos.'
            : 'MQTT conectado ao broker; ESP ainda sem status.';
        espTerminalTitle = probe.connected ? 'MQTT CONECTADO' : 'MQTT PENDENTE';
      });
      _appendEspLog('MQTT> ${probe.message}');
      await _startMqttRuntime();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        mqttConnected = false;
        lightingConnectionResult = 'FALHA MQTT: broker não respondeu.';
        lightingStatus = 'Falha ao testar MQTT.';
      });
      _appendEspLog('ERR> MQTT falhou: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _configureEspMqtt() async {
    final endpoint = _currentWifiEndpoint();
    final config = _mqttConfig();
    if (endpoint.isEmpty) {
      setState(() {
        lightingStatus = 'Informe o endpoint Wi-Fi do ESP antes do MQTT.';
        lightingConnectionResult = 'FALHA MQTT: endpoint do ESP ausente.';
      });
      return;
    }
    if (!config.isUsable) {
      setState(() {
        lightingStatus = 'Informe broker, porta e tópico MQTT.';
        lightingConnectionResult = 'FALHA MQTT: configuração incompleta.';
      });
      return;
    }
    setState(() {
      saving = true;
      espTerminalTitle = 'CONFIG MQTT ESP';
    });
    try {
      await _saveMqttSettings();
      final payload = await espClient.configureMqtt(
        endpoint: endpoint,
        enabled: config.enabled,
        host: config.host,
        port: config.port,
        baseTopic: config.baseTopic,
        deviceId: config.deviceId,
        username: config.username,
        password: config.password,
      );
      if (!mounted) return;
      _appendEspLog('ESP> configuração MQTT enviada');
      _appendEspPayload(payload);
      setState(() {
        lightingStatus = 'MQTT enviado para o ESP.';
        lightingConnectionResult = 'OK MQTT: configuração salva no ESP.';
      });
      _snack('MQTT enviado para o ESP.');
      unawaited(_startMqttRuntime());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        lightingStatus = 'Falha ao enviar MQTT para o ESP.';
        lightingConnectionResult = 'FALHA MQTT: ESP não confirmou.';
      });
      _appendEspLog('ERR> configurar MQTT falhou: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<bool> _tryMqttRelayCommand(int channel, String state) async {
    final config = _mqttConfig();
    if (!config.isUsable) return false;
    try {
      if (!mqttRuntime.connected) await _startMqttRuntime();
      if (mqttRuntime.connected) {
        mqttRuntime.publishRelayCommand(channel: channel, state: state);
      } else {
        await mqttClient.publishRelayCommand(
          config: config,
          channel: channel,
          state: state,
        );
      }
      if (!mounted) return true;
      setState(() => mqttConnected = true);
      _appendEspLog('MQTT> comando canal $channel enviado: $state');
      return true;
    } catch (error) {
      if (!mounted) return false;
      setState(() => mqttConnected = false);
      _appendEspLog('WARN> MQTT falhou; usando HTTP: $error');
      return false;
    }
  }

  Future<void> _startMqttRuntime() async {
    final config = _mqttConfig();
    if (!config.isUsable) return;
    mqttRuntimeSubscription ??= mqttRuntime.updates.listen(_handleMqttUpdate);
    try {
      await mqttRuntime.connect(config);
      if (!mounted) return;
      setState(() {
        mqttConnected = true;
        lightingConnectionResult = 'OK MQTT: tempo real ativo.';
        lightingStatus = 'MQTT bidirecional ativo em tempo de execução.';
        espTerminalTitle = 'MQTT TEMPO REAL';
      });
      _appendEspLog(
        'MQTT> tempo real conectado em ${config.host}:${config.port}',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        mqttConnected = false;
        lightingConnectionResult = 'FALHA MQTT: tempo real indisponível.';
      });
      await ref
          .read(databaseProvider)
          .recordAutomationEvent(
            severity: 'WARN',
            type: 'mqtt_runtime_failure',
            title: 'MQTT em tempo real indisponível',
            message: '$error',
            source: 'MQTT',
          );
      _appendEspLog('WARN> tempo real MQTT indisponível: $error');
    }
  }

  void _handleMqttUpdate(EspMqttUpdate update) {
    if (!mounted) return;
    final suffix = update.topic.split('/').isEmpty
        ? update.topic
        : update.topic.split('/').last;
    if (update.topic == 'runtime/disconnected') {
      setState(() {
        mqttConnected = false;
        lightingConnectionResult = 'MQTT desconectado.';
      });
      _appendEspLog('MQTT> desconectado');
      return;
    }
    if (update.topic == 'runtime/connected') {
      setState(() {
        mqttConnected = true;
        lightingConnectionResult = 'OK MQTT: tempo real ativo.';
      });
      _appendEspLog('MQTT> reconectado');
      return;
    }
    setState(() => mqttConnected = true);
    if (suffix == 'status') {
      final ip = (update.payload['ip'] ?? '').toString();
      unawaited(
        ref
            .read(databaseProvider)
            .saveAppSetting(
              'hardware_esp_last_seen_at',
              update.receivedAt.toIso8601String(),
              'system',
            ),
      );
      setState(() {
        espWifiConnected = update.payload['wifiConnected'] == true;
        lightingConnectionResult = 'OK MQTT: status recebido.';
        lightingStatus = ip.isEmpty
            ? 'ESP32 online via MQTT.'
            : 'ESP32 online via MQTT em $ip.';
      });
      _appendEspLog('MQTT> status recebido${ip.isEmpty ? '' : ' ($ip)'}');
      return;
    }
    if (update.topic.endsWith('/relay/state')) {
      final rawRelays = update.payload['relays'];
      if (rawRelays is List) {
        setState(() {
          for (final relay in rawRelays) {
            if (relay is! Map) continue;
            final channel = int.tryParse((relay['channel'] ?? '').toString());
            if (channel == null || channel < 1 || channel > 4) continue;
            final index = channel - 1;
            lightingChannelOn[index] = relay['on'] == true;
            lightingChannelStatus[index] =
                'MQTT tempo real: ${lightingChannelOn[index] ? 'ON' : 'OFF'}';
            unawaited(
              ref
                  .read(databaseProvider)
                  .recordRelayState(
                    channel: channel,
                    on: lightingChannelOn[index],
                    transport: 'MQTT',
                    payload: update.payload,
                  ),
            );
          }
          lightingStatus = 'Estados dos relés atualizados via MQTT.';
        });
      }
      _appendEspLog('MQTT> estado dos relés recebido');
      return;
    }
    if (suffix == 'sensors') {
      unawaited(_recordMqttSensorPayload(update.payload));
      _appendEspLog('MQTT> sensores recebidos em tempo real');
    }
  }

  Future<void> _recordMqttSensorPayload(Map<String, Object?> payload) async {
    final db = ref.read(databaseProvider);
    final environment = payload['environment'];
    if (environment is Map) {
      final env = Map<String, Object?>.from(environment);
      final temperature = _doublePayload(
        env['airTemperatureC'] ?? env['temperatureC'],
      );
      final humidity = _doublePayload(
        env['airHumidityPercent'] ?? env['humidityPercent'],
      );
      if (temperature != null) {
        await db.recordSensorReading(
          source: 'environment',
          metric: 'air_temperature_c',
          value: temperature,
          unit: '°C',
          transport: 'MQTT',
          payload: payload,
        );
      }
      if (humidity != null) {
        await db.recordSensorReading(
          source: 'environment',
          metric: 'air_humidity_percent',
          value: humidity,
          unit: '%',
          transport: 'MQTT',
          payload: payload,
        );
      }
    }
    final water = payload['water'];
    if (water is Map) {
      final data = Map<String, Object?>.from(water);
      final values = {
        'water_level_percent': (data['levelPercent'], '%'),
        'water_temperature_c': (data['temperatureC'], '°C'),
        'water_ph': (data['ph'], 'pH'),
        'water_tds_ppm': (data['tdsPpm'], 'ppm'),
        'water_chlorine_orp_mv': (data['chlorineOrpMv'] ?? data['orpMv'], 'mV'),
      };
      for (final entry in values.entries) {
        final value = _doublePayload(entry.value.$1);
        if (value == null) continue;
        await db.recordSensorReading(
          source: 'water',
          metric: entry.key,
          value: value,
          unit: entry.value.$2,
          transport: 'MQTT',
          payload: payload,
        );
      }
    }
  }

  double? _doublePayload(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }

  Future<void> _applyGeneralLightingSchedule({required bool syncAfter}) async {
    final selectedIndexes = [
      for (var i = 0; i < 4; i++)
        if (generalScheduleChannels[i]) i,
    ];
    if (selectedIndexes.isEmpty) {
      setState(() {
        lightingStatus = 'Selecione pelo menos um canal na agenda geral.';
      });
      return;
    }
    if (!generalMorningEnabled && !generalEveningEnabled) {
      setState(() {
        lightingStatus = 'Ative pelo menos um período na agenda geral.';
      });
      return;
    }

    final invalidMorning =
        generalMorningEnabled &&
        (!_validScheduleTime(generalMorningOnTime.text.trim()) ||
            !_validScheduleTime(generalMorningOffTime.text.trim()));
    final invalidEvening =
        generalEveningEnabled &&
        (!_validScheduleTime(generalEveningOnTime.text.trim()) ||
            !_validScheduleTime(generalEveningOffTime.text.trim()));
    if (invalidMorning || invalidEvening) {
      setState(() {
        lightingStatus = 'Revise a agenda geral. Use horários em HH:MM.';
      });
      return;
    }

    setState(() {
      for (final index in selectedIndexes) {
        lightingChannelEnabled[index] = true;
        lightingChannelMorningEnabled[index] = generalMorningEnabled;
        lightingChannelEveningEnabled[index] = generalEveningEnabled;
        lightingChannelOnTimes[index].text = generalMorningOnTime.text.trim();
        lightingChannelOffTimes[index].text = generalMorningOffTime.text.trim();
        lightingChannelEveningOnTimes[index].text = generalEveningOnTime.text
            .trim();
        lightingChannelEveningOffTimes[index].text = generalEveningOffTime.text
            .trim();
        lightingChannelStatus[index] =
            'OK: agenda geral aplicada ao canal ${index + 1}.';
      }
      lightingStatus =
          'Agenda geral aplicada em ${selectedIndexes.length} canal(is).';
    });

    if (syncAfter) {
      await _syncGeneralLightingSchedule(selectedIndexes);
      return;
    }
    await _saveLighting();
    if (!mounted) return;
    setState(() {
      lightingStatus =
          'Agenda geral aplicada em ${selectedIndexes.length} canal(is).';
    });
  }

  Future<void> _syncGeneralLightingSchedule(List<int> selectedIndexes) async {
    if (!lightingEnabled || lightingEndpoint.text.trim().isEmpty) {
      setState(() {
        lightingStatus = 'Falha: configure a conexão antes da agenda geral.';
        lightingConnectionResult = 'FALHA: endpoint/IP ausente.';
      });
      return;
    }
    if (lightingConnection != 'WIFI') {
      setState(() {
        lightingStatus = 'Agenda geral requer Wi-Fi com o ESP.';
        lightingConnectionResult = 'FALHA: selecione Wi-Fi para sincronizar.';
      });
      return;
    }

    setState(() {
      saving = true;
      espTerminalTitle = 'SYNC AGENDA GERAL';
    });
    try {
      final endpoint = lightingEndpoint.text.trim();
      final channels = [for (final index in selectedIndexes) index + 1];
      final schedule = EspChannelSchedule(
        channel: channels.first,
        enabled: true,
        morningEnabled: generalMorningEnabled,
        morningOnTime: generalMorningOnTime.text.trim(),
        morningOffTime: generalMorningOffTime.text.trim(),
        eveningEnabled: generalEveningEnabled,
        eveningOnTime: generalEveningOnTime.text.trim(),
        eveningOffTime: generalEveningOffTime.text.trim(),
      );

      final timePayload = await espClient.syncTime(endpoint, DateTime.now());
      _appendEspLog('ESP> relógio sincronizado pelo app');
      _appendEspPayload(timePayload);

      try {
        final payload = await espClient.setGroupSchedule(
          endpoint: endpoint,
          channels: channels,
          schedule: schedule,
        );
        _appendEspLog(
          'ESP> agenda geral salva nos canais ${channels.join(',')}',
        );
        _appendEspPayload(payload);
      } catch (error) {
        _appendEspLog('WARN> agenda geral em lote falhou: $error');
        _appendEspLog('SYS> usando envio individual por compatibilidade');
        for (final index in selectedIndexes) {
          final channel = index + 1;
          final payload = await espClient.setChannelSchedule(
            endpoint: endpoint,
            schedule: EspChannelSchedule(
              channel: channel,
              enabled: lightingChannelEnabled[index],
              morningEnabled: lightingChannelMorningEnabled[index],
              morningOnTime: lightingChannelOnTimes[index].text.trim(),
              morningOffTime: lightingChannelOffTimes[index].text.trim(),
              eveningEnabled: lightingChannelEveningEnabled[index],
              eveningOnTime: lightingChannelEveningOnTimes[index].text.trim(),
              eveningOffTime: lightingChannelEveningOffTimes[index].text.trim(),
            ),
          );
          _appendEspLog('ESP> agenda canal $channel salva por fallback');
          _appendEspPayload(payload);
        }
      }

      await _saveLighting();
      await ref
          .read(databaseProvider)
          .saveAppSetting(
            'hardware_lighting_schedule_last_synced_at',
            DateTime.now().toIso8601String(),
            'system',
          );
      if (!mounted) return;
      setState(() {
        for (final index in selectedIndexes) {
          lightingChannelStatus[index] =
              'OK: agenda geral enviada e salva no ESP.';
        }
        lightingStatus =
            'Agenda geral sincronizada em ${channels.length} canal(is).';
        lightingConnectionResult =
            'OK Wi-Fi: agenda geral confirmada pelo ESP.';
      });
      _snack('Agenda geral enviada para o ESP.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        lightingStatus = 'Falha ao sincronizar agenda geral no ESP.';
        lightingConnectionResult = 'FALHA Wi-Fi: agenda geral não confirmada.';
      });
      _appendEspLog('ERR> sync agenda geral falhou: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _testLightingConnection() async {
    setState(() => lightingConnection = 'WIFI');
    if (!lightingEnabled || lightingEndpoint.text.trim().isEmpty) {
      setState(() {
        lightingStatus = 'Falha: ative a iluminação e informe o endpoint/ID.';
        lightingConnectionResult = 'FALHA Wi-Fi: configuração incompleta.';
      });
      return;
    }
    await _probeEspConnection();
  }

  Future<void> _syncLightingSchedule() async {
    if (!lightingEnabled || lightingEndpoint.text.trim().isEmpty) {
      setState(() {
        lightingStatus = 'Falha: configure a conexão antes da agenda.';
        lightingConnectionResult = 'FALHA: endpoint/IP ausente.';
      });
      return;
    }
    if (lightingConnection != 'WIFI') {
      setState(() {
        lightingStatus = 'Agenda automática requer Wi-Fi com o ESP.';
        lightingConnectionResult = 'FALHA: selecione Wi-Fi para sincronizar.';
      });
      return;
    }

    for (var i = 0; i < 4; i++) {
      final invalidMorning =
          lightingChannelMorningEnabled[i] &&
          (!_validScheduleTime(lightingChannelOnTimes[i].text.trim()) ||
              !_validScheduleTime(lightingChannelOffTimes[i].text.trim()));
      final invalidEvening =
          lightingChannelEveningEnabled[i] &&
          (!_validScheduleTime(lightingChannelEveningOnTimes[i].text.trim()) ||
              !_validScheduleTime(
                lightingChannelEveningOffTimes[i].text.trim(),
              ));
      if (invalidMorning || invalidEvening) {
        setState(() {
          lightingChannelStatus[i] =
              'FALHA: use horário no formato HH:MM para a agenda.';
          lightingStatus = 'Revise a agenda do canal ${i + 1}.';
        });
        return;
      }
    }

    setState(() {
      saving = true;
      espTerminalTitle = 'SYNC AGENDA';
    });
    try {
      final endpoint = lightingEndpoint.text.trim();
      final timePayload = await espClient.syncTime(endpoint, DateTime.now());
      _appendEspLog('ESP> relógio sincronizado pelo app');
      _appendEspPayload(timePayload);

      for (var i = 0; i < 4; i++) {
        final channel = i + 1;
        final morningLabel = lightingChannelMorningEnabled[i]
            ? '${lightingChannelOnTimes[i].text.trim()}-${lightingChannelOffTimes[i].text.trim()}'
            : 'OFF';
        final eveningLabel = lightingChannelEveningEnabled[i]
            ? '${lightingChannelEveningOnTimes[i].text.trim()}-${lightingChannelEveningOffTimes[i].text.trim()}'
            : 'OFF';
        final payload = await espClient.setChannelSchedule(
          endpoint: endpoint,
          schedule: EspChannelSchedule(
            channel: channel,
            enabled: lightingChannelEnabled[i],
            morningEnabled: lightingChannelMorningEnabled[i],
            morningOnTime: lightingChannelOnTimes[i].text.trim(),
            morningOffTime: lightingChannelOffTimes[i].text.trim(),
            eveningEnabled: lightingChannelEveningEnabled[i],
            eveningOnTime: lightingChannelEveningOnTimes[i].text.trim(),
            eveningOffTime: lightingChannelEveningOffTimes[i].text.trim(),
          ),
        );
        _appendEspLog(
          'ESP> agenda canal $channel salva: M $morningLabel / T $eveningLabel',
        );
        _appendEspPayload(payload);
        if (!mounted) return;
        setState(() {
          lightingChannelStatus[i] = lightingChannelEnabled[i]
              ? 'OK: agenda enviada e salva no ESP.'
              : 'OK: agenda desativada e salva no ESP.';
        });
      }

      await _saveLighting();
      await ref
          .read(databaseProvider)
          .saveAppSetting(
            'hardware_lighting_schedule_last_synced_at',
            DateTime.now().toIso8601String(),
            'system',
          );
      if (!mounted) return;
      setState(() {
        lightingStatus = 'Agenda sincronizada e cacheada no ESP.';
        lightingConnectionResult = 'OK Wi-Fi: agenda confirmada pelo ESP.';
      });
      _snack('Agenda enviada para o ESP.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        lightingStatus = 'Falha ao sincronizar agenda no ESP.';
        lightingConnectionResult = 'FALHA Wi-Fi: agenda não confirmada.';
      });
      _appendEspLog('ERR> sync agenda falhou: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _testLightingChannel(int index, bool turnOn) async {
    if (!lightingEnabled || lightingEndpoint.text.trim().isEmpty) {
      setState(() {
        lightingStatus = 'Falha: configure a conexão antes do canal.';
        lightingChannelStatus[index] = 'FALHA: conexão não configurada.';
      });
      return;
    }
    if (lightingChannelPins[index].text.trim().isEmpty) {
      setState(() {
        lightingChannelStatus[index] = 'FALHA: informe o GPIO do canal.';
      });
      return;
    }
    setState(() => saving = true);
    try {
      final channel = index + 1;
      var usedMqtt = false;
      if (lightingConnection == 'WIFI') {
        final mqttSent = await _tryMqttRelayCommand(
          channel,
          turnOn ? 'on' : 'off',
        );
        usedMqtt = mqttSent;
        if (!mqttSent) {
          final result = await espClient.setRelay(
            endpoint: lightingEndpoint.text.trim(),
            channel: channel,
            turnOn: turnOn,
          );
          if (result.endpoint != lightingEndpoint.text.trim()) {
            lightingEndpoint.text = result.endpoint;
            await ref
                .read(operationsControllerProvider)
                .saveSetting('hardware_lighting_endpoint', result.endpoint);
            _appendEspLog('ESP> endpoint atualizado para ${result.endpoint}');
          }
          turnOn = result.on;
          unawaited(
            ref
                .read(databaseProvider)
                .recordRelayState(
                  channel: channel,
                  on: result.on,
                  transport: 'HTTP',
                  payload: result.payload,
                ),
          );
          _appendEspLog('ESP> ${result.message}');
          _appendEspPayload(result.payload);
        }
      }
      await ref
          .read(operationsControllerProvider)
          .saveSetting(
            'hardware_lighting_channel_${channel}_last_test_state',
            turnOn ? 'ON' : 'OFF',
          );
      if (mounted) {
        setState(() {
          lightingChannelOn[index] = turnOn;
          lightingChannelStatus[index] = usedMqtt
              ? 'OK: comando MQTT enviado ao canal $channel.'
              : turnOn
              ? 'OK: canal $channel ligado no GPIO ${lightingChannelPins[index].text.trim()}.'
              : 'OK: canal $channel desligado no GPIO ${lightingChannelPins[index].text.trim()}.';
          lightingStatus = usedMqtt
              ? 'Canal $channel enviado via MQTT.'
              : 'Canal $channel testado com sucesso.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        lightingChannelStatus[index] =
            'FALHA: ESP nao confirmou o canal ${index + 1}.';
        lightingStatus = 'Falha ao acionar canal ${index + 1}.';
      });
      _appendEspLog('ERR> canal ${index + 1} falhou: $error');
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _pulseLightingChannel(int index) async {
    if (lightingConnection == 'WIFI' &&
        lightingEnabled &&
        lightingEndpoint.text.trim().isNotEmpty &&
        lightingChannelEnabled[index] &&
        lightingChannelPins[index].text.trim().isNotEmpty) {
      setState(() => saving = true);
      try {
        final channel = index + 1;
        final mqttSent = await _tryMqttRelayCommand(channel, 'pulse');
        EspRelayResult? result;
        if (!mqttSent) {
          result = await espClient.pulseRelay(
            endpoint: lightingEndpoint.text.trim(),
            channel: channel,
          );
        }
        await ref
            .read(operationsControllerProvider)
            .saveSetting(
              'hardware_lighting_channel_${channel}_last_test_state',
              'PULSE',
            );
        if (!mounted) return;
        setState(() {
          lightingChannelOn[index] = result?.on ?? false;
          lightingChannelStatus[index] = mqttSent
              ? 'OK: pulso do canal $channel enviado via MQTT.'
              : 'OK: pulso do canal $channel confirmado pelo ESP.';
          lightingStatus = mqttSent
              ? 'Pulso do canal $channel enviado via MQTT.'
              : 'Pulso do canal $channel concluído no ESP.';
        });
        if (result != null) {
          unawaited(
            ref
                .read(databaseProvider)
                .recordRelayState(
                  channel: channel,
                  on: result.on,
                  transport: 'HTTP',
                  payload: result.payload,
                ),
          );
          _appendEspLog('ESP> ${result.message}');
          _appendEspPayload(result.payload);
        }
      } catch (error) {
        if (!mounted) return;
        setState(() {
          lightingChannelStatus[index] = 'FALHA: ESP nao confirmou o pulso.';
          lightingStatus = 'Falha ao acionar canal ${index + 1}.';
        });
        _appendEspLog('ERR> pulso falhou: $error');
      } finally {
        if (mounted) setState(() => saving = false);
      }
      return;
    }

    await _testLightingChannel(index, true);
    if (!mounted || lightingChannelStatus[index].startsWith('FALHA')) return;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    await _testLightingChannel(index, false);
    if (!mounted) return;
    setState(() {
      lightingChannelStatus[index] =
          'OK: pulso do canal ${index + 1} executado.';
      lightingStatus = 'Pulso do canal ${index + 1} concluído.';
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validScheduleTime(String value) {
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value);
    return match != null;
  }

  Future<void> _configureEspWifi() async {
    final endpoint = wifiProvisionEndpoint.text.trim().isEmpty
        ? '192.168.4.1'
        : wifiProvisionEndpoint.text.trim();
    final ssid = wifiProvisionSsid.text.trim();
    final password = wifiProvisionPassword.text;
    if (ssid.isEmpty) {
      setState(() => espTerminalTitle = 'WIFI DO ESP');
      _appendEspLog('ERR> informe o nome da rede Wi-Fi');
      _snack('Informe o nome da rede Wi-Fi.');
      return;
    }

    setState(() {
      saving = true;
      espTerminalTitle = 'CONFIG WIFI ESP';
    });
    _appendEspLog('APP> enviando rede "$ssid" para $endpoint');

    try {
      var payload = await espClient.configureWifi(
        endpoint: endpoint,
        ssid: ssid,
        password: password,
      );
      if (!mounted) return;

      _appendEspPayload(payload);
      for (
        var attempt = 1;
        attempt <= 12 && payload['wifiConnected'] != true;
        attempt++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 2500));
        if (!mounted) return;
        try {
          final probe = await espClient.ping(endpoint);
          payload = probe.payload;
          _appendEspLog('ESP> aguardando DHCP... tentativa $attempt/12');
          _appendEspPayload(payload);
        } catch (error) {
          _appendEspLog(
            'ESP> aguardando resposta do AP... tentativa $attempt/12',
          );
        }
      }
      final connected = payload['wifiConnected'] == true;
      final ip = (payload['ip'] ?? '').toString().trim();
      final setupApIp = (payload['setupApIp'] ?? '').toString().trim();
      final normalizedIp = ip.isEmpty
          ? ''
          : ip.startsWith('http')
          ? ip
          : 'http://$ip';
      final controller = ref.read(operationsControllerProvider);
      await controller.saveSetting('hardware_esp_setup_endpoint', endpoint);
      await controller.saveSetting('hardware_esp_wifi_ssid', ssid);
      await controller.saveSetting('hardware_esp_wifi_password', password);
      await controller.saveSetting('hardware_esp_remote_sync_enabled', 'false');

      var statusMessage =
          'Credenciais enviadas; aguardando confirmação de rede.';
      var resultMessage =
          'Wi-Fi enviado para o ESP. Conecte na rede e detecte o endpoint.';
      if (connected && normalizedIp.isNotEmpty) {
        lightingEndpoint.text = normalizedIp;
        lightingConnection = 'WIFI';
        lightingEnabled = true;
        await controller.saveSetting(
          'hardware_lighting_endpoint',
          normalizedIp,
        );
        await controller.saveSetting('hardware_lighting_connection', 'WIFI');
        await controller.saveSetting('hardware_lighting_enabled', 'true');
        statusMessage = 'ESP conectado em $normalizedIp.';
        resultMessage = 'OK Wi-Fi: ESP conectado em $normalizedIp.';
      }

      if (!mounted) return;
      setState(() {
        espWifiConnected = connected;
        espTerminalTitle = connected ? 'WIFI CONFIGURADO' : 'WIFI SALVO NO ESP';
        lightingConnectionResult = resultMessage;
        lightingStatus = statusMessage;
      });
      _appendEspLog(
        connected
            ? 'ESP> Wi-Fi conectado em ${normalizedIp.isEmpty ? ip : normalizedIp}'
            : 'ESP> credenciais salvas; conexao ainda nao confirmada',
      );
      if (setupApIp.isNotEmpty) {
        _appendEspLog('ESP> AP backup continua em $setupApIp');
      }
      _snack(connected ? 'Wi-Fi do ESP configurado.' : 'Credenciais enviadas.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        espTerminalTitle = 'FALHA WIFI ESP';
        lightingConnectionResult = 'FALHA Wi-Fi: nao foi possivel configurar.';
        lightingStatus = 'Falha ao enviar credenciais para o ESP.';
      });
      _appendEspLog('ERR> Wi-Fi do ESP falhou: $error');
      await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _disconnectEspWifi() async {
    final endpoint = _currentWifiEndpoint().isNotEmpty
        ? _currentWifiEndpoint()
        : wifiProvisionEndpoint.text.trim().isEmpty
        ? '192.168.4.1'
        : wifiProvisionEndpoint.text.trim();

    setState(() {
      saving = true;
      espTerminalTitle = 'DESCONECTAR WIFI ESP';
    });
    _appendEspLog('APP> solicitando desconexao Wi-Fi em $endpoint');

    try {
      final payload = await espClient.disconnectWifi(endpoint: endpoint);
      final controller = ref.read(operationsControllerProvider);
      await controller.saveSetting('hardware_lighting_endpoint', '');
      await controller.saveSetting('hardware_esp_wifi_ssid', '');
      await controller.saveSetting('hardware_esp_wifi_password', '');
      if (!mounted) return;
      _appendEspPayload(payload);
      setState(() {
        espWifiConnected = false;
        lightingEnabled = false;
        lightingEndpoint.clear();
        lightingConnection = 'WIFI';
        lightingConnectionResult = 'Wi-Fi do ESP desconectado.';
        lightingStatus =
            'ESP saiu da rede Wi-Fi. Use o AP SELETO-SETUP para reconectar.';
        espTerminalTitle = 'WIFI DESCONECTADO';
      });
      _appendEspLog('ESP> Wi-Fi desconectado e credenciais removidas');
      _snack('Wi-Fi do ESP desconectado.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        espTerminalTitle = 'FALHA DESCONECTAR WIFI';
        lightingConnectionResult = 'FALHA Wi-Fi: nao foi possivel desconectar.';
      });
      _appendEspLog('ERR> desconexao Wi-Fi falhou: $error');
      await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _showEspWifiHelp() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conectar o ESP no Wi-Fi'),
        content: const Text(
          'Conecte o celular na rede SELETO-SETUP, senha seleto1234. '
          'Depois informe o Wi-Fi da propriedade aqui no app e toque em Enviar. '
          'A tela web do ESP continua disponivel apenas como backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Future<void> _discoverEsp({required bool auto}) async {
    if (espScanning) return;
    setState(() {
      espScanning = true;
      espTerminalTitle = auto ? 'AUTO SCAN' : 'MANUAL SCAN';
      espTerminalLines = [
        'SYS> ${auto ? 'varredura automatica' : 'varredura manual'} iniciada',
      ];
    });
    try {
      final probe = await espClient.discover(onLog: _appendEspLog);
      if (!mounted) return;
      if (probe == null) {
        setState(() {
          espTerminalTitle = 'ESP NAO ENCONTRADO';
          lightingStatus =
              'ESP não encontrado. Use a rede padrão do controlador.';
        });
        _appendEspLog('AP> SSID SELETO-SETUP');
        _appendEspLog('AP> senha seleto1234');
        _appendEspLog('AP> depois toque em Detectar ESP');
        return;
      }
      await _applyEspProbe(probe);
    } catch (error) {
      if (!mounted) return;
      setState(() => espTerminalTitle = 'ERRO NO LINK');
      _appendEspLog('ERR> $error');
    } finally {
      if (mounted) setState(() => espScanning = false);
    }
  }

  Future<void> _testSavedWifiEndpoint() async {
    final endpoint = _currentWifiEndpoint();
    if (endpoint.isEmpty) {
      _appendEspLog('ERR> nenhum endpoint Wi-Fi salvo para testar');
      return;
    }
    setState(() {
      espScanning = true;
      espTerminalTitle = 'ESP HANDSHAKE';
    });
    try {
      final probe = await espClient.ping(endpoint);
      if (!mounted) return;
      await _applyEspProbe(probe);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        lightingConnectionResult = 'FALHA Wi-Fi: ESP não respondeu.';
      });
      await ref
          .read(databaseProvider)
          .recordAutomationEvent(
            severity: 'WARN',
            type: 'esp_connection_failure',
            title: 'Falha de conexão com ESP32',
            message: 'Endpoint salvo não respondeu: $error',
            source: 'HTTP',
          );
      _appendEspLog('ERR> endpoint sem resposta: $error');
      _appendEspLog('AP> tente conectar em SELETO-SETUP / seleto1234');
    } finally {
      if (mounted) setState(() => espScanning = false);
    }
  }

  Future<void> _probeEspConnection() async {
    setState(() {
      espScanning = true;
      espTerminalTitle = 'ESP HANDSHAKE';
    });
    try {
      final endpoint = lightingEndpoint.text.trim();
      final probe = await espClient.ping(endpoint);
      if (!mounted) return;
      await _applyEspProbe(probe);
      await _saveLighting();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        lightingConnectionResult = 'FALHA Wi-Fi: ESP não respondeu.';
        lightingStatus = 'Falha no handshake com o ESP.';
      });
      await ref
          .read(databaseProvider)
          .recordAutomationEvent(
            severity: 'WARN',
            type: 'esp_handshake_failure',
            title: 'Handshake do ESP32 falhou',
            message: 'ESP32 não confirmou /api/status: $error',
            source: 'HTTP',
          );
      _appendEspLog('ERR> handshake falhou: $error');
      _appendEspLog('AP> conecte no Wi-Fi SELETO-SETUP e tente de novo');
    } finally {
      if (mounted) setState(() => espScanning = false);
    }
  }

  Future<void> _applyEspProbe(EspDeviceProbe probe) async {
    final endpoint = probe.endpoint;
    final relayStates = _relayStatesFromPayload(probe.payload);
    final controller = ref.read(operationsControllerProvider);
    for (final entry in relayStates.entries) {
      final channel = entry.key;
      final state = entry.value ? 'ON' : 'OFF';
      if (channel >= 1 && channel <= 4) {
        await controller.saveSetting(
          'hardware_lighting_channel_${channel}_last_test_state',
          state,
        );
      } else if (channel >= 5 && channel <= 12) {
        await controller.saveSetting(
          'hardware_ventilation_channel_${channel - 4}_last_test_state',
          state,
        );
      }
    }
    setState(() {
      lightingEnabled = true;
      lightingConnection = 'WIFI';
      lightingEndpoint.text = endpoint;
      espWifiConnected = probe.payload['wifiConnected'] == true;
      lightingConnectionResult = 'OK Wi-Fi: ${probe.message}.';
      lightingStatus = 'Controlador conectado em $endpoint.';
      espTerminalTitle = 'ESP CONECTADO';
      for (var i = 0; i < lightingChannelOn.length; i++) {
        final state = relayStates[i + 1];
        if (state == null) continue;
        lightingChannelOn[i] = state;
        lightingChannelStatus[i] = 'Estado real ESP: ${state ? 'ON' : 'OFF'}';
      }
    });
    _appendEspLog('ESP> ${probe.message}');
    _appendEspPayload(probe.payload);
  }

  Map<int, bool> _relayStatesFromPayload(Map<String, Object?> payload) {
    final rawRelays = payload['relays'];
    if (rawRelays is! List) return const {};
    final states = <int, bool>{};
    for (final relay in rawRelays) {
      if (relay is! Map) continue;
      final channel = int.tryParse((relay['channel'] ?? '').toString());
      if (channel == null) continue;
      states[channel] = relay['on'] == true;
    }
    return states;
  }

  String _currentWifiEndpoint() {
    if (lightingConnection == 'WIFI' &&
        lightingEndpoint.text.trim().isNotEmpty) {
      return lightingEndpoint.text.trim();
    }
    return '';
  }

  void _appendEspLog(String message) {
    if (!mounted) return;
    setState(() {
      final nextLines = [...espTerminalLines, message];
      espTerminalLines = nextLines.length > 12
          ? nextLines.sublist(nextLines.length - 12)
          : nextLines;
    });
  }

  void _appendEspPayload(Map<String, Object?> payload) {
    const encoder = JsonEncoder.withIndent('  ');
    final lines = encoder.convert(payload).split('\n');
    for (final line in lines.take(8)) {
      _appendEspLog('JSON> $line');
    }
  }
}

class _EspTerminalPanel extends StatelessWidget {
  const _EspTerminalPanel({
    required this.title,
    required this.lines,
    required this.scanning,
    required this.onDiscover,
    required this.onTestEndpoint,
  });

  final String title;
  final List<String> lines;
  final bool scanning;
  final VoidCallback onDiscover;
  final VoidCallback onTestEndpoint;

  @override
  Widget build(BuildContext context) {
    const terminalGreen = Color(0xFF39FF88);
    const terminalAmber = Color(0xFFFFD166);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF07130D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: terminalGreen.withValues(alpha: .42)),
        boxShadow: [
          BoxShadow(
            color: terminalGreen.withValues(alpha: .10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  scanning ? Icons.radar_outlined : Icons.terminal_outlined,
                  color: scanning ? terminalAmber : terminalGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: terminalGreen,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (scanning)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 132, maxHeight: 220),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: terminalGreen.withValues(alpha: .18),
                  ),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  child: SelectableText(
                    lines.join('\n'),
                    style: const TextStyle(
                      color: terminalGreen,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: scanning ? null : onDiscover,
                  icon: const Icon(Icons.radar_outlined),
                  label: const Text('Detectar ESP'),
                ),
                OutlinedButton.icon(
                  onPressed: scanning ? null : onTestEndpoint,
                  icon: const Icon(Icons.lan_outlined),
                  label: const Text('Testar endpoint'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EspWifiProvisionPanel extends StatelessWidget {
  const _EspWifiProvisionPanel({
    required this.endpointController,
    required this.ssidController,
    required this.passwordController,
    required this.passwordHidden,
    required this.connected,
    required this.busy,
    required this.onConfigure,
    required this.onDisconnect,
    required this.onTogglePassword,
    required this.onHelp,
  });

  final TextEditingController endpointController;
  final TextEditingController ssidController;
  final TextEditingController passwordController;
  final bool passwordHidden;
  final bool connected;
  final bool busy;
  final VoidCallback onConfigure;
  final VoidCallback onDisconnect;
  final VoidCallback onTogglePassword;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withValues(alpha: .20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.wifi_tethering_outlined,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wi-Fi do ESP',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        connected
                            ? 'Controlador conectado na rede local'
                            : 'Conecta o controlador na rede local',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endpointController,
              enabled: !busy,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Endpoint do AP do ESP',
                hintText: '192.168.4.1',
                prefixIcon: Icon(Icons.router_outlined),
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final ssidField = TextField(
                  controller: ssidController,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'Rede Wi-Fi',
                    prefixIcon: Icon(Icons.wifi_outlined),
                  ),
                );
                final passwordField = TextField(
                  controller: passwordController,
                  enabled: !busy,
                  obscureText: passwordHidden,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: busy ? null : onTogglePassword,
                      icon: Icon(
                        passwordHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      tooltip: passwordHidden
                          ? 'Mostrar senha'
                          : 'Ocultar senha',
                    ),
                  ),
                );
                if (compact) {
                  return Column(
                    children: [
                      ssidField,
                      const SizedBox(height: 10),
                      passwordField,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: ssidField),
                    const SizedBox(width: 10),
                    Expanded(child: passwordField),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            _InfoStrip(
              icon: Icons.security_outlined,
              text:
                  'Use o AP SELETO-SETUP apenas para configurar. Depois disso o app fala com o ESP pelo IP recebido na rede local.',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : onConfigure,
                  icon: const Icon(Icons.send_to_mobile_outlined),
                  label: const Text('Conectar Wi-Fi'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onDisconnect,
                  icon: const Icon(Icons.wifi_off_outlined),
                  label: const Text('Desconectar'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onHelp,
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Como conectar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EspMqttPanel extends StatelessWidget {
  const _EspMqttPanel({
    required this.enabled,
    required this.connected,
    required this.busy,
    required this.hostController,
    required this.portController,
    required this.baseTopicController,
    required this.deviceIdController,
    required this.usernameController,
    required this.passwordController,
    required this.passwordHidden,
    required this.onEnabledChanged,
    required this.onTogglePassword,
    required this.onSave,
    required this.onTest,
    required this.onPushToEsp,
  });

  final bool enabled;
  final bool connected;
  final bool busy;
  final TextEditingController hostController;
  final TextEditingController portController;
  final TextEditingController baseTopicController;
  final TextEditingController deviceIdController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool passwordHidden;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSave;
  final VoidCallback onTest;
  final VoidCallback onPushToEsp;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: connected
              ? colors.primary.withValues(alpha: .28)
              : colors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.hub_outlined,
                    color: colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MQTT operacional',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        connected
                            ? 'Broker conectado em tempo real'
                            : 'Canal bidirecional para status, sensores e relés',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: busy ? null : onEnabledChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, box) {
                final compact = box.maxWidth < 680;
                final host = TextField(
                  controller: hostController,
                  enabled: enabled && !busy,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Broker MQTT',
                    hintText: '192.168.0.10',
                    prefixIcon: Icon(Icons.dns_outlined),
                  ),
                );
                final port = TextField(
                  controller: portController,
                  enabled: enabled && !busy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Porta',
                    prefixIcon: Icon(Icons.tag_outlined),
                  ),
                );
                final topic = TextField(
                  controller: baseTopicController,
                  enabled: enabled && !busy,
                  decoration: const InputDecoration(
                    labelText: 'Tópico base',
                    prefixIcon: Icon(Icons.account_tree_outlined),
                  ),
                );
                final device = TextField(
                  controller: deviceIdController,
                  enabled: enabled && !busy,
                  decoration: const InputDecoration(
                    labelText: 'Device ID',
                    prefixIcon: Icon(Icons.memory_outlined),
                  ),
                );
                if (compact) {
                  return Column(
                    children: [
                      host,
                      const SizedBox(height: 10),
                      port,
                      const SizedBox(height: 10),
                      topic,
                      const SizedBox(height: 10),
                      device,
                    ],
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: host),
                        const SizedBox(width: 10),
                        SizedBox(width: 120, child: port),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: topic),
                        const SizedBox(width: 10),
                        Expanded(child: device),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, box) {
                final compact = box.maxWidth < 560;
                final user = TextField(
                  controller: usernameController,
                  enabled: enabled && !busy,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                );
                final pass = TextField(
                  controller: passwordController,
                  enabled: enabled && !busy,
                  obscureText: passwordHidden,
                  decoration: InputDecoration(
                    labelText: 'Senha MQTT',
                    prefixIcon: const Icon(Icons.key_outlined),
                    suffixIcon: IconButton(
                      onPressed: busy ? null : onTogglePassword,
                      icon: Icon(
                        passwordHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                );
                if (compact) {
                  return Column(
                    children: [user, const SizedBox(height: 10), pass],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: user),
                    const SizedBox(width: 10),
                    Expanded(child: pass),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            _InfoStrip(
              icon: Icons.compare_arrows_outlined,
              text:
                  'HTTP continua ativo para configuração e agenda. MQTT fica conectado em tempo de execução para troca bidirecional praticamente em tempo real.',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar MQTT'),
                ),
                FilledButton.tonalIcon(
                  onPressed: enabled && !busy ? onTest : null,
                  icon: const Icon(Icons.hub_outlined),
                  label: const Text('Testar MQTT'),
                ),
                OutlinedButton.icon(
                  onPressed: enabled && !busy ? onPushToEsp : null,
                  icon: const Icon(Icons.upload_outlined),
                  label: const Text('Enviar ao ESP'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LightingControlInstrument extends StatelessWidget {
  const _LightingControlInstrument({
    required this.enabled,
    required this.channelLabels,
    required this.pins,
    required this.channelEnabled,
    required this.channelOn,
    required this.morningEnabled,
    required this.eveningEnabled,
    required this.connection,
    required this.connectionOk,
    required this.enabledCount,
    required this.onCount,
  });

  final bool enabled;
  final List<String> channelLabels;
  final List<String> pins;
  final List<bool> channelEnabled;
  final List<bool> channelOn;
  final List<bool> morningEnabled;
  final List<bool> eveningEnabled;
  final String connection;
  final bool connectionOk;
  final int enabledCount;
  final int onCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: .22),
                    ),
                  ),
                  child: Icon(
                    enabled ? Icons.light_mode : Icons.light_mode_outlined,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Painel de luz do galpão',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Relés ESP32, horários e acionamento manual',
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
                _SmallStatusPill(
                  icon: connection == 'WIFI' ? Icons.wifi : Icons.bluetooth,
                  label: connectionOk ? 'sincronizado' : connection,
                  positive: connectionOk,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 188,
              child: CustomPaint(
                painter: _LightingInstrumentPainter(
                  color: colors.primary,
                  outline: colors.outlineVariant,
                  enabled: enabled,
                  channelOn: channelOn,
                  channelEnabled: channelEnabled,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _LightingHudChip(
                            icon: Icons.power_settings_new,
                            label: enabled ? 'Automação ativa' : 'Desativada',
                            positive: enabled,
                          ),
                          const SizedBox(width: 8),
                          _LightingHudChip(
                            icon: Icons.tungsten_outlined,
                            label: '$onCount ligados',
                            positive: onCount > 0,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          for (var i = 0; i < 4; i++) ...[
                            Expanded(
                              child: _LightingLampNode(
                                label: i < channelLabels.length
                                    ? channelLabels[i]
                                    : 'Canal ${i + 1}',
                                pin: i < pins.length ? pins[i] : '-',
                                enabled: i < channelEnabled.length
                                    ? channelEnabled[i]
                                    : false,
                                on: i < channelOn.length ? channelOn[i] : false,
                                morning: i < morningEnabled.length
                                    ? morningEnabled[i]
                                    : false,
                                evening: i < eveningEnabled.length
                                    ? eveningEnabled[i]
                                    : false,
                              ),
                            ),
                            if (i < 3) const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _LightingMetricRail(
              enabledCount: enabledCount,
              onCount: onCount,
              connection: connection,
              connectionOk: connectionOk,
              enabled: enabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _LightingHudChip extends StatelessWidget {
  const _LightingHudChip({
    required this.icon,
    required this.label,
    required this.positive,
  });

  final IconData icon;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = positive ? colors.primary : colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
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

class _LightingLampNode extends StatelessWidget {
  const _LightingLampNode({
    required this.label,
    required this.pin,
    required this.enabled,
    required this.on,
    required this.morning,
    required this.evening,
  });

  final String label;
  final String pin;
  final bool enabled;
  final bool on;
  final bool morning;
  final bool evening;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = on
        ? colors.primary
        : enabled
        ? colors.onSurface
        : colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: on ? .92 : .74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: on
              ? colors.primary.withValues(alpha: .42)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            on ? Icons.lightbulb : Icons.lightbulb_outline,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            'G$pin',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_twilight_outlined,
                size: 12,
                color: morning ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.nights_stay_outlined,
                size: 12,
                color: evening ? colors.primary : colors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LightingMetricRail extends StatelessWidget {
  const _LightingMetricRail({
    required this.enabledCount,
    required this.onCount,
    required this.connection,
    required this.connectionOk,
    required this.enabled,
  });

  final int enabledCount;
  final int onCount;
  final String connection;
  final bool connectionOk;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth > 620;
        final items = [
          _LightingMetricData(
            Icons.power_settings_new,
            'Modo',
            enabled ? 'Ativo' : 'Off',
            enabled,
          ),
          _LightingMetricData(
            Icons.tungsten_outlined,
            'Canais',
            '$enabledCount/4',
            enabledCount > 0,
          ),
          _LightingMetricData(
            Icons.light_mode_outlined,
            'Ligados',
            '$onCount/4',
            onCount > 0,
          ),
          _LightingMetricData(
            connection == 'WIFI' ? Icons.wifi : Icons.bluetooth,
            'Conexão',
            connectionOk ? 'OK' : connection,
            connectionOk,
          ),
        ];
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 4 : 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: wide ? 2.7 : 2.35,
          ),
          itemBuilder: (context, index) =>
              _LightingMetricTile(data: items[index]),
        );
      },
    );
  }
}

class _LightingMetricData {
  const _LightingMetricData(this.icon, this.label, this.value, this.positive);

  final IconData icon;
  final String label;
  final String value;
  final bool positive;
}

class _LightingMetricTile extends StatelessWidget {
  const _LightingMetricTile({required this.data});

  final _LightingMetricData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = data.positive ? colors.primary : colors.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: data.positive
              ? colors.primary.withValues(alpha: .28)
              : colors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(data.icon, size: 18, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
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

class _LightingInstrumentPainter extends CustomPainter {
  const _LightingInstrumentPainter({
    required this.color,
    required this.outline,
    required this.enabled,
    required this.channelOn,
    required this.channelEnabled,
  });

  final Color color;
  final Color outline;
  final bool enabled;
  final List<bool> channelOn;
  final List<bool> channelEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final glow = Paint()
      ..color = color.withValues(alpha: enabled ? .14 : .06)
      ..style = PaintingStyle.fill;
    final board = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .20, size.height * .25, size.width * .60, 58),
      const Radius.circular(12),
    );
    canvas.drawRRect(board, glow);
    canvas.drawRRect(board, line);
    final busY = size.height * .58;
    canvas.drawLine(
      Offset(size.width * .18, busY),
      Offset(size.width * .82, busY),
      line,
    );
    for (var i = 0; i < 4; i++) {
      final x = size.width * (.18 + i * .213);
      final active = i < channelEnabled.length && channelEnabled[i];
      final on = active && i < channelOn.length && channelOn[i];
      final onColor = const Color(0xFFFFB020);
      final idleColor = color;
      final lampPaint = Paint()
        ..color = (on ? onColor : idleColor).withValues(
          alpha: on
              ? .70
              : active
              ? .28
              : .12,
        )
        ..style = PaintingStyle.fill;
      final beamPaint = Paint()
        ..color = (on ? onColor : idleColor).withValues(alpha: on ? .18 : .03)
        ..style = PaintingStyle.fill;
      final beam = Path()
        ..moveTo(x - 22, busY + 12)
        ..lineTo(x + 22, busY + 12)
        ..lineTo(x + 34, size.height * .93)
        ..lineTo(x - 34, size.height * .93)
        ..close();
      canvas.drawPath(beam, beamPaint);
      canvas.drawLine(Offset(x, size.height * .48), Offset(x, busY), line);
      canvas.drawCircle(Offset(x, busY), on ? 7 : 5, lampPaint);
      canvas.drawCircle(Offset(x, busY), on ? 8.5 : 6, line);
    }
  }

  @override
  bool shouldRepaint(covariant _LightingInstrumentPainter oldDelegate) =>
      oldDelegate.enabled != enabled ||
      oldDelegate.color != color ||
      oldDelegate.outline != outline ||
      oldDelegate.channelOn != channelOn ||
      oldDelegate.channelEnabled != channelEnabled;
}

class _LightingConnectionPanel extends StatelessWidget {
  const _LightingConnectionPanel({
    required this.enabled,
    required this.connection,
    required this.connectionResult,
    required this.endpointController,
    required this.relayPinController,
    required this.saving,
    required this.onEnabledChanged,
    required this.onConnectionChanged,
    required this.enabledCount,
    required this.onCount,
  });

  final bool enabled;
  final String connection;
  final String connectionResult;
  final TextEditingController endpointController;
  final TextEditingController relayPinController;
  final bool saving;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onConnectionChanged;
  final int enabledCount;
  final int onCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: .40),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  enabled ? Icons.power_settings_new : Icons.power_off_outlined,
                  color: enabled ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Controlador ESP32',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: saving ? null : onEnabledChanged,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SmallStatusPill(
                  icon: Icons.cable_outlined,
                  label: connectionResult.contains('OK')
                      ? 'Conectado'
                      : 'Pendente',
                  positive: connectionResult.contains('OK'),
                ),
                _SmallStatusPill(
                  icon: Icons.tungsten_outlined,
                  label: '$enabledCount/4 ativos',
                  positive: enabledCount > 0,
                ),
                _SmallStatusPill(
                  icon: Icons.light_mode_outlined,
                  label: '$onCount/4 ligados',
                  positive: onCount > 0,
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, box) {
                Widget connectionControl() => SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'WIFI',
                      icon: Icon(Icons.wifi),
                      label: Text('Wi-Fi'),
                    ),
                  ],
                  selected: {connection},
                  onSelectionChanged: saving
                      ? null
                      : (value) => onConnectionChanged(value.first),
                );
                Widget endpointField() => TextField(
                  controller: endpointController,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint/IP local',
                    prefixIcon: Icon(Icons.router_outlined),
                  ),
                );
                Widget relayPinField() => TextField(
                  controller: relayPinController,
                  enabled: !saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'GPIO padrão',
                    prefixIcon: Icon(Icons.electrical_services),
                  ),
                );
                if (box.maxWidth > 760) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      connectionControl(),
                      const SizedBox(width: 10),
                      Expanded(child: endpointField()),
                      const SizedBox(width: 10),
                      SizedBox(width: 150, child: relayPinField()),
                    ],
                  );
                }
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: connectionControl(),
                    ),
                    const SizedBox(height: 10),
                    endpointField(),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(width: 150, child: relayPinField()),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallStatusPill extends StatelessWidget {
  const _SmallStatusPill({
    required this.icon,
    required this.label,
    required this.positive,
  });

  final IconData icon;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = positive ? colors.primary : colors.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightingChannelBoard extends StatelessWidget {
  const _LightingChannelBoard({
    required this.labels,
    required this.pins,
    required this.enabled,
    required this.on,
    required this.morningEnabled,
    required this.eveningEnabled,
    required this.morningOnTimes,
    required this.morningOffTimes,
    required this.eveningOnTimes,
    required this.eveningOffTimes,
    required this.onOpen,
  });

  final List<String> labels;
  final List<String> pins;
  final List<bool> enabled;
  final List<bool> on;
  final List<bool> morningEnabled;
  final List<bool> eveningEnabled;
  final List<String> morningOnTimes;
  final List<String> morningOffTimes;
  final List<String> eveningOnTimes;
  final List<String> eveningOffTimes;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard_customize_outlined, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Canais',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, box) => GridView.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: box.maxWidth < 520
                  ? 1.62
                  : box.maxWidth < 760
                  ? 1.95
                  : 2.25,
            ),
            itemBuilder: (context, index) => _LightingChannelCard(
              index: index,
              label: labels[index],
              pin: pins[index],
              enabled: enabled[index],
              on: on[index],
              morningEnabled: morningEnabled[index],
              eveningEnabled: eveningEnabled[index],
              morningTime: '${morningOnTimes[index]}-${morningOffTimes[index]}',
              eveningTime: '${eveningOnTimes[index]}-${eveningOffTimes[index]}',
              onOpen: () => onOpen(index),
            ),
          ),
        ),
      ],
    );
  }
}

class _LightingChannelCard extends StatelessWidget {
  const _LightingChannelCard({
    required this.index,
    required this.label,
    required this.pin,
    required this.enabled,
    required this.on,
    required this.morningEnabled,
    required this.eveningEnabled,
    required this.morningTime,
    required this.eveningTime,
    required this.onOpen,
  });

  final int index;
  final String label;
  final String pin;
  final bool enabled;
  final bool on;
  final bool morningEnabled;
  final bool eveningEnabled;
  final String morningTime;
  final String eveningTime;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveOn = enabled && on;
    final activeColor = effectiveOn
        ? colors.primary
        : enabled
        ? colors.onSurface
        : colors.onSurfaceVariant;
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
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    effectiveOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    size: 19,
                    color: activeColor,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'G$pin',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
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
                  Text(
                    enabled ? 'Ativo' : 'Inativo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: enabled ? colors.primary : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    effectiveOn ? 'ON' : 'OFF',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: activeColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              _CompactScheduleLine(
                icon: Icons.wb_twilight_outlined,
                label: morningEnabled ? 'M $morningTime' : 'M OFF',
              ),
              const SizedBox(height: 1),
              _CompactScheduleLine(
                icon: Icons.nights_stay_outlined,
                label: eveningEnabled ? 'N $eveningTime' : 'N OFF',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactScheduleLine extends StatelessWidget {
  const _CompactScheduleLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _GeneralLightingSchedulePanel extends StatelessWidget {
  const _GeneralLightingSchedulePanel({
    required this.selectedChannels,
    required this.channelLabels,
    required this.morningEnabled,
    required this.eveningEnabled,
    required this.saving,
    required this.morningTime,
    required this.eveningTime,
    required this.onOpen,
  });

  final List<bool> selectedChannels;
  final List<String> channelLabels;
  final bool morningEnabled;
  final bool eveningEnabled;
  final bool saving;
  final String morningTime;
  final String eveningTime;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedCount = selectedChannels.where((selected) => selected).length;
    final selectedLabels = [
      for (var i = 0; i < selectedChannels.length; i++)
        if (selectedChannels[i])
          i < channelLabels.length ? channelLabels[i] : 'Canal ${i + 1}',
    ];
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: .34),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: saving ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_outlined, size: 20, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Agenda geral',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '$selectedCount/4',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                selectedLabels.isEmpty
                    ? 'Nenhum canal selecionado'
                    : selectedLabels.join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: _CompactScheduleLine(
                      icon: Icons.wb_twilight_outlined,
                      label: morningEnabled ? 'M $morningTime' : 'M OFF',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CompactScheduleLine(
                      icon: Icons.nights_stay_outlined,
                      label: eveningEnabled ? 'N $eveningTime' : 'N OFF',
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

class _ScheduleWindowFields extends StatelessWidget {
  const _ScheduleWindowFields({
    required this.title,
    required this.enabled,
    required this.switchValue,
    required this.saving,
    required this.onEnabledChanged,
    required this.onController,
    required this.offController,
    required this.icon,
  });

  final String title;
  final bool enabled;
  final bool switchValue;
  final bool saving;
  final ValueChanged<bool>? onEnabledChanged;
  final TextEditingController onController;
  final TextEditingController offController;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Switch(
                  value: switchValue,
                  onChanged: saving ? null : onEnabledChanged,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, box) => box.maxWidth > 520
                  ? Row(
                      children: [
                        Expanded(child: _timeField(onController, 'Liga às')),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _timeField(offController, 'Desliga às'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _timeField(onController, 'Liga às'),
                        const SizedBox(height: 10),
                        _timeField(offController, 'Desliga às'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        enabled: !saving && enabled,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: label,
          hintText: label == 'Liga às' ? '04:30' : '06:10',
          prefixIcon: const Icon(Icons.schedule_outlined),
        ),
      );
}

class _IntegrationHeader extends StatelessWidget {
  const _IntegrationHeader({required this.lightingReady});

  final bool lightingReady;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .92),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Controle de iluminação',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            _StatusChip(
              icon: Icons.lightbulb_outline,
              label: lightingReady
                  ? 'Iluminação pronta'
                  : 'Iluminação pendente',
              positive: lightingReady,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntegrationPanel extends StatelessWidget {
  const _IntegrationPanel({
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
    return Material(
      color: colors.surface.withValues(alpha: .95),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoStrip(icon: Icons.verified_outlined, text: status),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withValues(alpha: .16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.positive,
  });

  final IconData icon;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = positive ? colors.primary : colors.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
