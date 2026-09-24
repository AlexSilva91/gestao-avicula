import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/hardware_esp_client.dart';
import '../../application/operations_controller.dart';

class HardwareIntegrationSettings {
  const HardwareIntegrationSettings({
    required this.scaleEnabled,
    required this.scaleConnection,
    required this.scaleMode,
    required this.scaleDevice,
    required this.scaleEndpoint,
    required this.scaleLastWeightKg,
    required this.lightingEnabled,
    required this.lightingConnection,
    required this.lightingEndpoint,
    required this.lightingRelayPin,
    required this.lightingChannels,
  });

  final bool scaleEnabled;
  final String scaleConnection;
  final String scaleMode;
  final String scaleDevice;
  final String scaleEndpoint;
  final double scaleLastWeightKg;
  final bool lightingEnabled;
  final String lightingConnection;
  final String lightingEndpoint;
  final String lightingRelayPin;
  final List<LightingChannelConfig> lightingChannels;

  factory HardwareIntegrationSettings.fromSettings(List<AppSetting> settings) {
    final values = {for (final setting in settings) setting.key: setting.value};
    final scaleConnection = values['hardware_scale_connection'] == 'BLUETOOTH'
        ? 'BLUETOOTH'
        : 'WIFI';
    final scaleMode = switch (values['hardware_scale_mode']) {
      'INGREDIENT_PURCHASE' ||
      'FEEDING' ||
      'BOTH' => values['hardware_scale_mode']!,
      _ => 'BOTH',
    };
    final lightingConnection =
        values['hardware_lighting_connection'] == 'BLUETOOTH'
        ? 'BLUETOOTH'
        : 'WIFI';
    return HardwareIntegrationSettings(
      scaleEnabled: values['hardware_scale_enabled'] == 'true',
      scaleConnection: scaleConnection,
      scaleMode: scaleMode,
      scaleDevice: values['hardware_scale_device']?.trim() ?? '',
      scaleEndpoint: values['hardware_scale_endpoint']?.trim() ?? '',
      scaleLastWeightKg: parseDecimal(
        values['hardware_scale_last_weight_kg'] ?? '',
      ),
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

  bool get scaleReady => scaleEnabled && scaleEndpoint.isNotEmpty;
  bool get lightingReady => lightingEnabled && lightingEndpoint.isNotEmpty;
  bool get scaleForIngredientPurchase =>
      scaleMode == 'BOTH' || scaleMode == 'INGREDIENT_PURCHASE';
  bool get scaleForFeeding => scaleMode == 'BOTH' || scaleMode == 'FEEDING';
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
  final scaleDevice = TextEditingController();
  final scaleEndpoint = TextEditingController();
  final scaleWeight = TextEditingController();
  final scaleTolerance = TextEditingController(text: '0,05');
  final lightingEndpoint = TextEditingController();
  final lightingRelayPin = TextEditingController(text: '23');
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
  final lightingChannelStatus = List.generate(
    4,
    (index) => 'Canal ${index + 1} aguardando teste',
  );
  final lightingChannelOn = List.generate(4, (index) => false);
  final lightingChannelEnabled = List.generate(4, (index) => true);
  final lightingChannelMorningEnabled = List.generate(4, (index) => true);
  final lightingChannelEveningEnabled = List.generate(4, (index) => true);
  String scaleConnection = 'WIFI';
  String scaleMode = 'BOTH';
  String lightingConnection = 'WIFI';
  bool scaleEnabled = false;
  bool lightingEnabled = false;
  bool saving = false;
  bool initialized = false;
  String scaleStatus = 'Aguardando teste';
  String lightingStatus = 'Aguardando teste';
  bool scaleLiveReading = false;
  Timer? scaleReadTimer;
  int scaleSampleCount = 0;
  double? scaleLastSample;
  double? scaleMinSample;
  double? scaleMaxSample;
  DateTime? scaleLastReadAt;
  String? scaleConnectionResult;
  String? scalePrecisionResult;
  String? lightingConnectionResult;
  bool espDiscoveryStarted = false;
  bool espScanning = false;
  String espTerminalTitle = 'SELETO ESP LINK';
  List<String> espTerminalLines = const [
    'SYS> aguardando handshake com ESP32',
    'SYS> modo Wi-Fi procura /api/status automaticamente',
    'SYS> fallback AP: GRANJA-SELETO-SETUP / seleto1234',
  ];

  @override
  void dispose() {
    scaleReadTimer?.cancel();
    scaleDevice.dispose();
    scaleEndpoint.dispose();
    scaleWeight.dispose();
    scaleTolerance.dispose();
    lightingEndpoint.dispose();
    lightingRelayPin.dispose();
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
    super.dispose();
  }

  void _hydrate(List<AppSetting> settings) {
    if (initialized) return;
    initialized = true;
    final values = {for (final setting in settings) setting.key: setting.value};
    final config = HardwareIntegrationSettings.fromSettings(settings);
    scaleEnabled = config.scaleEnabled;
    scaleConnection = config.scaleConnection;
    scaleMode = config.scaleMode;
    scaleDevice.text = config.scaleDevice;
    scaleEndpoint.text = config.scaleEndpoint;
    scaleWeight.text = config.scaleLastWeightKg > 0
        ? decimal.format(config.scaleLastWeightKg)
        : '';
    lightingEnabled = config.lightingEnabled;
    lightingConnection = config.lightingConnection;
    lightingEndpoint.text = config.lightingEndpoint;
    lightingRelayPin.text = config.lightingRelayPin;
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
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    title: 'Integrações',
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
                const SizedBox(height: 16),
                _lightingPanel(context),
              ],
            );
          },
        ),
  );

  // ignore: unused_element
  Widget _scalePanel(BuildContext context) => _IntegrationPanel(
    icon: Icons.scale_outlined,
    title: 'Balança',
    status: scaleStatus,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.monitor_weight_outlined),
        title: const Text('Ativar balança'),
        subtitle: const Text('ESP32 ou Arduino para leitura de ração/insumos'),
        value: scaleEnabled,
        onChanged: saving
            ? null
            : (value) => setState(() => scaleEnabled = value),
      ),
      const SizedBox(height: 8),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'WIFI',
            icon: Icon(Icons.wifi),
            label: Text('Wi-Fi'),
          ),
          ButtonSegment(
            value: 'BLUETOOTH',
            icon: Icon(Icons.bluetooth),
            label: Text('Bluetooth'),
          ),
        ],
        selected: {scaleConnection},
        onSelectionChanged: saving
            ? null
            : (value) => setState(() => scaleConnection = value.first),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: scaleDevice,
        enabled: !saving,
        decoration: const InputDecoration(
          labelText: 'Nome/ID do dispositivo',
          prefixIcon: Icon(Icons.developer_board),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: scaleEndpoint,
        enabled: !saving,
        decoration: InputDecoration(
          labelText: scaleConnection == 'WIFI'
              ? 'Endpoint ou IP do ESP32'
              : 'Identificador Bluetooth',
          prefixIcon: const Icon(Icons.hub_outlined),
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: scaleMode,
        decoration: const InputDecoration(labelText: 'Uso da balança'),
        items: const [
          DropdownMenuItem(value: 'BOTH', child: Text('Entrada e alimentação')),
          DropdownMenuItem(
            value: 'INGREDIENT_PURCHASE',
            child: Text('Entrada de insumos'),
          ),
          DropdownMenuItem(
            value: 'FEEDING',
            child: Text('Alimentação por lote'),
          ),
        ],
        onChanged: saving
            ? null
            : (value) {
                if (value != null) setState(() => scaleMode = value);
              },
      ),
      const SizedBox(height: 12),
      TextField(
        controller: scaleWeight,
        enabled: !saving,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Leitura de teste',
          suffixText: 'kg',
          prefixIcon: Icon(Icons.speed_outlined),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: scaleTolerance,
        enabled: !saving,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Tolerância para precisão',
          suffixText: 'kg',
          prefixIcon: Icon(Icons.rule_outlined),
        ),
      ),
      const SizedBox(height: 12),
      _ScaleReadingPanel(
        reading: parseDecimal(scaleWeight.text),
        sampleCount: scaleSampleCount,
        minSample: scaleMinSample,
        maxSample: scaleMaxSample,
        lastReadAt: scaleLastReadAt,
        live: scaleLiveReading,
      ),
      const SizedBox(height: 12),
      _ResultPanel(
        title: 'Resultado dos testes da balança',
        items: [
          _ResultLine(
            icon: Icons.cable_outlined,
            label: 'Conexão',
            value: scaleConnectionResult ?? 'Ainda não testada',
            ok: scaleConnectionResult?.contains('OK') == true,
          ),
          _ResultLine(
            icon: Icons.monitor_weight_outlined,
            label: 'Leitura',
            value: scaleSampleCount == 0
                ? 'Sem amostras'
                : '$scaleSampleCount amostra(s) recebidas',
            ok: scaleSampleCount > 0,
          ),
          _ResultLine(
            icon: Icons.verified_outlined,
            label: 'Precisão',
            value: scalePrecisionResult ?? 'Aguardando leitura',
            ok: scalePrecisionResult?.contains('OK') == true,
          ),
        ],
      ),
      const SizedBox(height: 12),
      _InfoStrip(
        icon: Icons.memory_outlined,
        text: scaleConnection == 'WIFI'
            ? 'No Wi-Fi, o app consulta o ESP32 real em /api/status e /api/scale. Se nao achar na rede local, conecte o celular em GRANJA-SELETO-SETUP.'
            : 'Bluetooth salva o identificador do ESP. Para teste serial direto, use GRANJA_SELETO_RELE.',
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: saving ? null : _saveScale,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar'),
          ),
          FilledButton.tonalIcon(
            onPressed: saving || espScanning
                ? null
                : () => _testScaleConnection('WIFI'),
            icon: const Icon(Icons.wifi),
            label: const Text('Testar Wi-Fi'),
          ),
          FilledButton.tonalIcon(
            onPressed: saving ? null : () => _testScaleConnection('BLUETOOTH'),
            icon: const Icon(Icons.bluetooth),
            label: const Text('Testar Bluetooth'),
          ),
          FilledButton.tonalIcon(
            onPressed: saving || espScanning ? null : _toggleScaleLiveReading,
            icon: Icon(
              scaleLiveReading
                  ? Icons.stop_circle_outlined
                  : Icons.play_circle_outline,
            ),
            label: Text(
              scaleLiveReading ? 'Parar leitura' : 'Ler em tempo real',
            ),
          ),
          OutlinedButton.icon(
            onPressed: saving ? null : _simulateStableScaleRead,
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Simular precisão'),
          ),
        ],
      ),
    ],
  );

  Widget _lightingPanel(BuildContext context) => _IntegrationPanel(
    icon: Icons.lightbulb_outline,
    title: 'Iluminação',
    status: lightingStatus,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.tungsten_outlined),
        title: const Text('Ativar automação de luz'),
        subtitle: const Text('ESP32 acionando o programa de iluminação'),
        value: lightingEnabled,
        onChanged: saving
            ? null
            : (value) => setState(() => lightingEnabled = value),
      ),
      const SizedBox(height: 8),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'WIFI',
            icon: Icon(Icons.wifi),
            label: Text('Wi-Fi'),
          ),
          ButtonSegment(
            value: 'BLUETOOTH',
            icon: Icon(Icons.bluetooth),
            label: Text('Bluetooth'),
          ),
        ],
        selected: {lightingConnection},
        onSelectionChanged: saving
            ? null
            : (value) => setState(() => lightingConnection = value.first),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: lightingEndpoint,
        enabled: !saving,
        decoration: InputDecoration(
          labelText: lightingConnection == 'WIFI'
              ? 'Endpoint/IP do controlador'
              : 'Identificador Bluetooth',
          prefixIcon: const Icon(Icons.router_outlined),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: lightingRelayPin,
        enabled: !saving,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'GPIO padrão do relé',
          prefixIcon: Icon(Icons.electrical_services),
        ),
      ),
      const SizedBox(height: 12),
      _ResultPanel(
        title: 'Resultado dos testes de iluminação',
        items: [
          _ResultLine(
            icon: Icons.cable_outlined,
            label: 'Conexão',
            value: lightingConnectionResult ?? 'Ainda não testada',
            ok: lightingConnectionResult?.contains('OK') == true,
          ),
          for (var i = 0; i < 4; i++)
            _ResultLine(
              icon: lightingChannelOn[i]
                  ? Icons.lightbulb
                  : Icons.lightbulb_outline,
              label: lightingChannelNames[i].text.trim().isEmpty
                  ? 'Canal ${i + 1}'
                  : lightingChannelNames[i].text.trim(),
              value: lightingChannelStatus[i],
              ok: lightingChannelStatus[i].contains('OK'),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            _LightingChannelTile(
              index: i,
              nameController: lightingChannelNames[i],
              pinController: lightingChannelPins[i],
              onTimeController: lightingChannelOnTimes[i],
              offTimeController: lightingChannelOffTimes[i],
              eveningOnTimeController: lightingChannelEveningOnTimes[i],
              eveningOffTimeController: lightingChannelEveningOffTimes[i],
              enabled: lightingChannelEnabled[i],
              morningEnabled: lightingChannelMorningEnabled[i],
              eveningEnabled: lightingChannelEveningEnabled[i],
              on: lightingChannelOn[i],
              status: lightingChannelStatus[i],
              saving: saving,
              onEnabledChanged: (value) =>
                  setState(() => lightingChannelEnabled[i] = value),
              onMorningEnabledChanged: (value) =>
                  setState(() => lightingChannelMorningEnabled[i] = value),
              onEveningEnabledChanged: (value) =>
                  setState(() => lightingChannelEveningEnabled[i] = value),
              onTurnOn: () => _testLightingChannel(i, true),
              onTurnOff: () => _testLightingChannel(i, false),
              onPulse: () => _pulseLightingChannel(i),
            ),
            if (i < 3) const SizedBox(height: 10),
          ],
        ],
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
            onPressed: saving ? null : () => _testLightingConnection('WIFI'),
            icon: const Icon(Icons.wifi),
            label: const Text('Testar Wi-Fi'),
          ),
          FilledButton.tonalIcon(
            onPressed: saving
                ? null
                : () => _testLightingConnection('BLUETOOTH'),
            icon: const Icon(Icons.bluetooth),
            label: const Text('Testar Bluetooth'),
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

  Future<void> _saveScale() async {
    setState(() => saving = true);
    try {
      final controller = ref.read(operationsControllerProvider);
      final updates = {
        'hardware_scale_enabled': scaleEnabled.toString(),
        'hardware_scale_connection': scaleConnection,
        'hardware_scale_mode': scaleMode,
        'hardware_scale_device': scaleDevice.text.trim(),
        'hardware_scale_endpoint': scaleEndpoint.text.trim(),
        'hardware_scale_last_weight_kg': scaleWeight.text.trim(),
      };
      for (final entry in updates.entries) {
        await controller.saveSetting(entry.key, entry.value);
      }
      if (mounted) {
        setState(() => scaleStatus = 'Configuração da balança salva');
        _snack('Balança salva.');
      }
    } catch (error) {
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
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
      };
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

  Future<void> _testScaleConnection(String connection) async {
    setState(() => scaleConnection = connection);
    if (!scaleEnabled || scaleEndpoint.text.trim().isEmpty) {
      setState(() {
        scaleStatus = 'Falha: ative a balança e informe o endpoint/ID.';
        scaleConnectionResult =
            'FALHA ${_connectionLabel(connection)}: configuração incompleta.';
      });
      return;
    }
    if (connection == 'WIFI') {
      await _probeEspConnection(source: 'balanca');
      return;
    }
    await _saveScale();
    if (!mounted) return;
    setState(() {
      scaleConnectionResult =
          'OK ${_connectionLabel(connection)}: endpoint aceito para leitura.';
      scaleStatus =
          'Conexão ${_connectionLabel(connection)} pronta para leitura.';
    });
    _appendEspLog('BT> identificador aceito: ${scaleEndpoint.text.trim()}');
    _appendEspLog('BT> pareie com GRANJA_SELETO_RELE para terminal serial');
  }

  Future<void> _toggleScaleLiveReading() async {
    if (!scaleEnabled) {
      setState(() {
        scaleStatus = 'Falha: ative a balança antes de ler.';
        scaleConnectionResult = 'FALHA: balança desativada.';
      });
      return;
    }
    if (scaleEndpoint.text.trim().isEmpty) {
      setState(() {
        scaleStatus = 'Falha: informe o endpoint/ID da balança.';
        scaleConnectionResult = 'FALHA: endpoint/ID ausente.';
      });
      return;
    }
    if (scaleLiveReading) {
      _stopScaleLiveReading();
      return;
    }
    await _saveScale();
    if (!mounted) return;
    setState(() {
      scaleLiveReading = true;
      scaleSampleCount = 0;
      scaleLastSample = null;
      scaleMinSample = null;
      scaleMaxSample = null;
      scaleLastReadAt = null;
      scalePrecisionResult = 'Coletando amostras...';
      scaleStatus = 'Lendo balança em tempo real no celular.';
    });
    scaleReadTimer?.cancel();
    scaleReadTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      unawaited(_appendScaleSample());
    });
    await _appendScaleSample();
  }

  void _stopScaleLiveReading() {
    scaleReadTimer?.cancel();
    scaleReadTimer = null;
    setState(() {
      scaleLiveReading = false;
      scaleStatus = scaleSampleCount == 0
          ? 'Leitura em tempo real parada sem amostras.'
          : 'Leitura em tempo real parada com $scaleSampleCount amostra(s).';
    });
  }

  Future<void> _appendScaleSample() async {
    if (scaleConnection == 'WIFI' && scaleEndpoint.text.trim().isNotEmpty) {
      try {
        final reading = await espClient.readScale(scaleEndpoint.text.trim());
        if (!mounted) return;
        _appendScaleSampleValue(reading.weightKg);
        _appendEspLog('ESP> ${reading.message}');
        _appendEspPayload(reading.payload);
        return;
      } catch (error) {
        _appendEspLog('ERR> leitura real falhou: $error');
      }
    }

    final base = parseDecimal(scaleWeight.text) > 0
        ? parseDecimal(scaleWeight.text)
        : 25.0;
    final variation = switch (scaleSampleCount % 5) {
      0 => 0.00,
      1 => 0.01,
      2 => -0.01,
      3 => 0.02,
      _ => -0.02,
    };
    final sample = base + variation;
    _appendScaleSampleValue(sample);
  }

  void _appendScaleSampleValue(double sample) {
    final min = scaleMinSample == null
        ? sample
        : sample < scaleMinSample!
        ? sample
        : scaleMinSample!;
    final max = scaleMaxSample == null
        ? sample
        : sample > scaleMaxSample!
        ? sample
        : scaleMaxSample!;
    final tolerance = parseDecimal(scaleTolerance.text) > 0
        ? parseDecimal(scaleTolerance.text)
        : 0.05;
    final amplitude = max - min;
    setState(() {
      scaleSampleCount += 1;
      scaleLastSample = sample;
      scaleMinSample = min;
      scaleMaxSample = max;
      scaleLastReadAt = DateTime.now();
      scaleWeight.text = decimal.format(sample);
      scalePrecisionResult = amplitude <= tolerance
          ? 'OK: variação ${kg(amplitude)} dentro de ${kg(tolerance)}.'
          : 'FALHA: variação ${kg(amplitude)} acima de ${kg(tolerance)}.';
      scaleStatus = 'Peso exibido em tempo real: ${kg(sample)}.';
    });
  }

  Future<void> _simulateStableScaleRead() async {
    if (!scaleEnabled) {
      setState(() {
        scaleStatus = 'Falha: ative a balança antes de simular.';
        scalePrecisionResult = 'FALHA: balança desativada.';
      });
      return;
    }
    for (var i = 0; i < 4; i++) {
      await _appendScaleSample();
    }
    await _saveScale();
    if (!mounted) return;
    setState(
      () => scaleStatus =
          'Teste de precisão concluído com $scaleSampleCount amostra(s).',
    );
  }

  Future<void> _testLightingConnection(String connection) async {
    setState(() => lightingConnection = connection);
    if (!lightingEnabled || lightingEndpoint.text.trim().isEmpty) {
      setState(() {
        lightingStatus = 'Falha: ative a iluminação e informe o endpoint/ID.';
        lightingConnectionResult =
            'FALHA ${_connectionLabel(connection)}: configuração incompleta.';
      });
      return;
    }
    if (connection == 'WIFI') {
      await _probeEspConnection(source: 'iluminacao');
      return;
    }
    await _saveLighting();
    if (!mounted) return;
    setState(() {
      lightingConnectionResult =
          'OK ${_connectionLabel(connection)}: controlador pronto.';
      lightingStatus =
          'Conexão ${_connectionLabel(connection)} pronta para canais.';
    });
    _appendEspLog('BT> identificador aceito: ${lightingEndpoint.text.trim()}');
    _appendEspLog('BT> pareie com GRANJA_SELETO_RELE para terminal serial');
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
    if (!lightingChannelEnabled[index]) {
      setState(() {
        lightingChannelStatus[index] = 'FALHA: canal desativado.';
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
      if (lightingConnection == 'WIFI') {
        final result = await espClient.setRelay(
          endpoint: lightingEndpoint.text.trim(),
          channel: channel,
          turnOn: turnOn,
        );
        _appendEspLog('ESP> ${result.message}');
        _appendEspPayload(result.payload);
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
          lightingChannelStatus[index] = turnOn
              ? 'OK: canal $channel ligado no GPIO ${lightingChannelPins[index].text.trim()}.'
              : 'OK: canal $channel desligado no GPIO ${lightingChannelPins[index].text.trim()}.';
          lightingStatus = 'Canal $channel testado com sucesso.';
        });
      }
    } catch (error) {
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
        final result = await espClient.pulseRelay(
          endpoint: lightingEndpoint.text.trim(),
          channel: channel,
        );
        await ref
            .read(operationsControllerProvider)
            .saveSetting(
              'hardware_lighting_channel_${channel}_last_test_state',
              'PULSE',
            );
        if (!mounted) return;
        setState(() {
          lightingChannelOn[index] = result.on;
          lightingChannelStatus[index] =
              'OK: pulso do canal $channel confirmado pelo ESP.';
          lightingStatus = 'Pulso do canal $channel concluído no ESP.';
        });
        _appendEspLog('ESP> ${result.message}');
        _appendEspPayload(result.payload);
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
          scaleStatus =
              'ESP não encontrado. Conecte o celular em GRANJA-SELETO-SETUP.';
          lightingStatus =
              'ESP não encontrado. Use a rede padrão do controlador.';
        });
        _appendEspLog('AP> SSID GRANJA-SELETO-SETUP');
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
        scaleConnectionResult = 'FALHA Wi-Fi: ESP não respondeu.';
        lightingConnectionResult = 'FALHA Wi-Fi: ESP não respondeu.';
      });
      _appendEspLog('ERR> endpoint sem resposta: $error');
      _appendEspLog('AP> tente conectar em GRANJA-SELETO-SETUP / seleto1234');
    } finally {
      if (mounted) setState(() => espScanning = false);
    }
  }

  Future<void> _probeEspConnection({required String source}) async {
    setState(() {
      espScanning = true;
      espTerminalTitle = 'ESP HANDSHAKE';
    });
    try {
      final endpoint = source == 'iluminacao'
          ? lightingEndpoint.text.trim()
          : scaleEndpoint.text.trim();
      final probe = await espClient.ping(endpoint);
      if (!mounted) return;
      await _applyEspProbe(probe);
      await (source == 'iluminacao' ? _saveLighting() : _saveScale());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        if (source == 'iluminacao') {
          lightingConnectionResult = 'FALHA Wi-Fi: ESP não respondeu.';
          lightingStatus = 'Falha no handshake com o ESP.';
        } else {
          scaleConnectionResult = 'FALHA Wi-Fi: ESP não respondeu.';
          scaleStatus = 'Falha no handshake com o ESP.';
        }
      });
      _appendEspLog('ERR> handshake falhou: $error');
      _appendEspLog('AP> conecte no Wi-Fi GRANJA-SELETO-SETUP e tente de novo');
    } finally {
      if (mounted) setState(() => espScanning = false);
    }
  }

  Future<void> _applyEspProbe(EspDeviceProbe probe) async {
    final endpoint = probe.endpoint;
    setState(() {
      scaleEnabled = true;
      lightingEnabled = true;
      scaleConnection = 'WIFI';
      lightingConnection = 'WIFI';
      scaleDevice.text = probe.deviceId;
      scaleEndpoint.text = endpoint;
      lightingEndpoint.text = endpoint;
      scaleConnectionResult = 'OK Wi-Fi: ${probe.message}.';
      lightingConnectionResult = 'OK Wi-Fi: ${probe.message}.';
      scaleStatus = 'ESP conectado em $endpoint.';
      lightingStatus = 'Controlador conectado em $endpoint.';
      espTerminalTitle = 'ESP CONECTADO';
    });
    _appendEspLog('ESP> ${probe.message}');
    _appendEspPayload(probe.payload);
  }

  String _currentWifiEndpoint() {
    if (scaleConnection == 'WIFI' && scaleEndpoint.text.trim().isNotEmpty) {
      return scaleEndpoint.text.trim();
    }
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

class _ScaleReadingPanel extends StatelessWidget {
  const _ScaleReadingPanel({
    required this.reading,
    required this.sampleCount,
    required this.minSample,
    required this.maxSample,
    required this.lastReadAt,
    required this.live,
  });

  final double reading;
  final int sampleCount;
  final double? minSample;
  final double? maxSample;
  final DateTime? lastReadAt;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final amplitude = minSample == null || maxSample == null
        ? 0.0
        : maxSample! - minSample!;
    return _ResultPanel(
      title: live ? 'Leitura em tempo real' : 'Leitura da balança',
      items: [
        _ResultLine(
          icon: Icons.monitor_weight_outlined,
          label: 'Peso atual',
          value: reading > 0 ? kg(reading) : 'Sem leitura',
          ok: reading > 0,
        ),
        _ResultLine(
          icon: Icons.timeline_outlined,
          label: 'Amostras',
          value: '$sampleCount recebida(s)',
          ok: sampleCount > 0,
        ),
        _ResultLine(
          icon: Icons.straighten_outlined,
          label: 'Variação',
          value: sampleCount > 1 ? kg(amplitude) : 'Aguardando',
          ok: sampleCount > 1,
        ),
        _ResultLine(
          icon: Icons.schedule_outlined,
          label: 'Última leitura',
          value: lastReadAt == null
              ? 'Aguardando'
              : '${lastReadAt!.hour.toString().padLeft(2, '0')}:${lastReadAt!.minute.toString().padLeft(2, '0')}:${lastReadAt!.second.toString().padLeft(2, '0')}',
          ok: lastReadAt != null,
        ),
      ],
    );
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

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.title, required this.items});

  final String title;
  final List<_ResultLine> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            for (var i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.ok,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = ok ? colors.primary : colors.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _LightingChannelTile extends StatelessWidget {
  const _LightingChannelTile({
    required this.index,
    required this.nameController,
    required this.pinController,
    required this.onTimeController,
    required this.offTimeController,
    required this.eveningOnTimeController,
    required this.eveningOffTimeController,
    required this.enabled,
    required this.morningEnabled,
    required this.eveningEnabled,
    required this.on,
    required this.status,
    required this.saving,
    required this.onEnabledChanged,
    required this.onMorningEnabledChanged,
    required this.onEveningEnabledChanged,
    required this.onTurnOn,
    required this.onTurnOff,
    required this.onPulse,
  });

  final int index;
  final TextEditingController nameController;
  final TextEditingController pinController;
  final TextEditingController onTimeController;
  final TextEditingController offTimeController;
  final TextEditingController eveningOnTimeController;
  final TextEditingController eveningOffTimeController;
  final bool enabled;
  final bool morningEnabled;
  final bool eveningEnabled;
  final bool on;
  final String status;
  final bool saving;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<bool> onMorningEnabledChanged;
  final ValueChanged<bool> onEveningEnabledChanged;
  final VoidCallback onTurnOn;
  final VoidCallback onTurnOff;
  final VoidCallback onPulse;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface.withValues(alpha: .88),
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
                  on ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: on ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Canal ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: saving ? null : onEnabledChanged,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, box) => box.maxWidth > 520
                  ? Row(
                      children: [
                        Expanded(child: _nameField()),
                        const SizedBox(width: 10),
                        SizedBox(width: 150, child: _pinField()),
                      ],
                    )
                  : Column(
                      children: [
                        _nameField(),
                        const SizedBox(height: 10),
                        _pinField(),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            _ScheduleWindowFields(
              title: 'Manhã',
              enabled: enabled && morningEnabled,
              switchValue: morningEnabled,
              saving: saving,
              onEnabledChanged: enabled ? onMorningEnabledChanged : null,
              onController: onTimeController,
              offController: offTimeController,
              icon: Icons.wb_twilight_outlined,
            ),
            const SizedBox(height: 10),
            _ScheduleWindowFields(
              title: 'Tarde/noite',
              enabled: enabled && eveningEnabled,
              switchValue: eveningEnabled,
              saving: saving,
              onEnabledChanged: enabled ? onEveningEnabledChanged : null,
              onController: eveningOnTimeController,
              offController: eveningOffTimeController,
              icon: Icons.nights_stay_outlined,
            ),
            const SizedBox(height: 10),
            Text(
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: status.contains('FALHA')
                    ? colors.error
                    : colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: saving || !enabled ? null : onTurnOn,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: const Text('Ligar'),
                ),
                OutlinedButton.icon(
                  onPressed: saving || !enabled ? null : onTurnOff,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: const Text('Desligar'),
                ),
                OutlinedButton.icon(
                  onPressed: saving || !enabled ? null : onPulse,
                  icon: const Icon(Icons.bolt_outlined),
                  label: const Text('Pulso'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _nameField() => TextField(
    controller: nameController,
    enabled: !saving,
    decoration: const InputDecoration(
      labelText: 'Nome do canal',
      prefixIcon: Icon(Icons.label_outline),
    ),
  );

  Widget _pinField() => TextField(
    controller: pinController,
    enabled: !saving,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      labelText: 'GPIO',
      prefixIcon: Icon(Icons.settings_input_component_outlined),
    ),
  );
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
              'Bancada de integração',
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

String _connectionLabel(String value) =>
    value == 'BLUETOOTH' ? 'Bluetooth' : 'Wi-Fi';
