import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
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
    );
  }

  bool get scaleReady => scaleEnabled && scaleEndpoint.isNotEmpty;
  bool get lightingReady => lightingEnabled && lightingEndpoint.isNotEmpty;
  bool get scaleForIngredientPurchase =>
      scaleMode == 'BOTH' || scaleMode == 'INGREDIENT_PURCHASE';
  bool get scaleForFeeding => scaleMode == 'BOTH' || scaleMode == 'FEEDING';
}

class HardwareIntegrationsPage extends ConsumerStatefulWidget {
  const HardwareIntegrationsPage({super.key});

  @override
  ConsumerState<HardwareIntegrationsPage> createState() =>
      _HardwareIntegrationsPageState();
}

class _HardwareIntegrationsPageState
    extends ConsumerState<HardwareIntegrationsPage> {
  final scaleDevice = TextEditingController();
  final scaleEndpoint = TextEditingController();
  final scaleWeight = TextEditingController();
  final lightingEndpoint = TextEditingController();
  final lightingRelayPin = TextEditingController(text: '23');
  String scaleConnection = 'WIFI';
  String scaleMode = 'BOTH';
  String lightingConnection = 'WIFI';
  bool scaleEnabled = false;
  bool lightingEnabled = false;
  bool saving = false;
  bool initialized = false;
  String scaleStatus = 'Aguardando teste';
  String lightingStatus = 'Aguardando teste';

  @override
  void dispose() {
    scaleDevice.dispose();
    scaleEndpoint.dispose();
    scaleWeight.dispose();
    lightingEndpoint.dispose();
    lightingRelayPin.dispose();
    super.dispose();
  }

  void _hydrate(List<AppSetting> settings) {
    if (initialized) return;
    initialized = true;
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IntegrationHeader(
                  scaleReady:
                      scaleEnabled && scaleEndpoint.text.trim().isNotEmpty,
                  lightingReady:
                      lightingEnabled &&
                      lightingEndpoint.text.trim().isNotEmpty,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, box) => box.maxWidth > 900
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _scalePanel(context)),
                            const SizedBox(width: 16),
                            Expanded(child: _lightingPanel(context)),
                          ],
                        )
                      : Column(
                          children: [
                            _scalePanel(context),
                            const SizedBox(height: 16),
                            _lightingPanel(context),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
  );

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
      _InfoStrip(
        icon: Icons.call_split_outlined,
        text:
            'A compra de insumos e a alimentação continuam nas telas de ração. A balança só preenche o peso nessas operações.',
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
            onPressed: saving ? null : _testScaleConnection,
            icon: const Icon(Icons.cable_outlined),
            label: const Text('Testar conexão'),
          ),
          OutlinedButton.icon(
            onPressed: saving ? null : _simulateScaleRead,
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Simular leitura'),
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
          labelText: 'GPIO do relé principal',
          prefixIcon: Icon(Icons.electrical_services),
        ),
      ),
      const SizedBox(height: 12),
      _InfoStrip(
        icon: Icons.event_available_outlined,
        text:
            'O cadastro de programas de luz permanece no calendário. Esta tela valida o controlador antes da automação física.',
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
            icon: const Icon(Icons.cable_outlined),
            label: const Text('Testar conexão'),
          ),
          OutlinedButton.icon(
            onPressed: saving ? null : () => _testLightingCommand(true),
            icon: const Icon(Icons.light_mode_outlined),
            label: const Text('Ligar teste'),
          ),
          OutlinedButton.icon(
            onPressed: saving ? null : () => _testLightingCommand(false),
            icon: const Icon(Icons.dark_mode_outlined),
            label: const Text('Desligar teste'),
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

  Future<void> _testScaleConnection() async {
    if (!scaleEnabled || scaleEndpoint.text.trim().isEmpty) {
      setState(() => scaleStatus = 'Ative a balança e informe o endpoint/ID.');
      return;
    }
    await _saveScale();
    if (!mounted) return;
    setState(() {
      scaleStatus =
          'Conexão ${_connectionLabel(scaleConnection)} pronta para teste.';
    });
  }

  Future<void> _simulateScaleRead() async {
    if (!scaleEnabled) {
      setState(() => scaleStatus = 'Ative a balança antes de simular.');
      return;
    }
    final current = parseDecimal(scaleWeight.text);
    final simulated = current > 0 ? current : 25.0;
    scaleWeight.text = decimal.format(simulated);
    await _saveScale();
    if (!mounted) return;
    setState(() => scaleStatus = 'Leitura de ${kg(simulated)} disponível.');
  }

  Future<void> _testLightingConnection() async {
    if (!lightingEnabled || lightingEndpoint.text.trim().isEmpty) {
      setState(
        () => lightingStatus = 'Ative a iluminação e informe o endpoint/ID.',
      );
      return;
    }
    await _saveLighting();
    if (!mounted) return;
    setState(() {
      lightingStatus =
          'Conexão ${_connectionLabel(lightingConnection)} pronta para teste.';
    });
  }

  Future<void> _testLightingCommand(bool turnOn) async {
    if (!lightingEnabled || lightingEndpoint.text.trim().isEmpty) {
      setState(
        () => lightingStatus = 'Configure e teste a conexão antes do comando.',
      );
      return;
    }
    setState(() => saving = true);
    try {
      await ref
          .read(operationsControllerProvider)
          .saveSetting(
            'hardware_lighting_last_test_state',
            turnOn ? 'ON' : 'OFF',
          );
      if (mounted) {
        setState(
          () => lightingStatus = turnOn
              ? 'Comando de teste: luz ligada.'
              : 'Comando de teste: luz desligada.',
        );
      }
    } catch (error) {
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _IntegrationHeader extends StatelessWidget {
  const _IntegrationHeader({
    required this.scaleReady,
    required this.lightingReady,
  });

  final bool scaleReady;
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
              icon: Icons.scale_outlined,
              label: scaleReady ? 'Balança pronta' : 'Balança pendente',
              positive: scaleReady,
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
