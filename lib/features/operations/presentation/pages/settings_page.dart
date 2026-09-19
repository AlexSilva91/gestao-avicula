import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/app_version.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/platform/file_export_service.dart';
import '../../../../core/platform/notification_service.dart';
import '../../../../core/sync/firebase_backup_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../application/operations_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Configurações',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, box) => box.maxWidth > 820
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _ProductionSettings(ref: ref)),
                    const SizedBox(width: 16),
                    Expanded(child: _BackupCard(ref: ref)),
                  ],
                )
              : Column(
                  children: [
                    _ProductionSettings(ref: ref),
                    const SizedBox(height: 16),
                    _BackupCard(ref: ref),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _AppUpdateCard(ref: ref),
        const SizedBox(height: 16),
        _HardwareIntegrationCard(ref: ref),
        const SizedBox(height: 16),
        _NotificationsCard(ref: ref),
      ],
    ),
  );
}

class _ProductionSettings extends StatelessWidget {
  const _ProductionSettings({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(appSettingsProvider)
      .when(
        loading: () => const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => const SeletoAsyncError(),
        data: (settings) {
          final values = {for (final s in settings) s.key: s.value};
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parâmetros produtivos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restaurant),
                    title: const Text('Consumo na produção'),
                    subtitle: Text(
                      '${values['production_feed_grams_per_bird'] ?? '115'} g/ave/dia',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _edit(
                        context,
                        'production_feed_grams_per_bird',
                        'Consumo por ave (gramas)',
                        values['production_feed_grams_per_bird'] ?? '115',
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.percent),
                    title: const Text('Taxa de postura projetada'),
                    subtitle: Text(
                      percent(
                        double.tryParse(
                              values['projected_laying_rate'] ?? '0.87',
                            ) ??
                            .87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _edit(
                        context,
                        'projected_laying_rate',
                        'Taxa decimal (ex.: 0,87)',
                        values['projected_laying_rate'] ?? '0.87',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  Future<void> _edit(
    BuildContext context,
    String key,
    String label,
    String initial,
  ) async {
    final controller = TextEditingController(
      text: initial.replaceAll('.', ','),
    );
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.replaceAll(',', '.');
              try {
                await ref
                    .read(operationsControllerProvider)
                    .saveSetting(key, value);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                await showOperationError(context, e);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class _AppUpdateCard extends StatelessWidget {
  const _AppUpdateCard({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => ref
      .watch(appSettingsProvider)
      .when(
        loading: () => const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => const SeletoAsyncError(),
        data: (settings) {
          final values = {for (final s in settings) s.key: s.value};
          final latestCode =
              int.tryParse(values['latest_app_version_code'] ?? '') ?? 0;
          final hasUpdate = latestCode > SeletoAppVersion.code;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atualização do aplicativo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      hasUpdate
                          ? Icons.system_update_alt
                          : Icons.verified_outlined,
                    ),
                    title: Text(
                      hasUpdate
                          ? 'Nova versão disponível'
                          : 'Aplicativo na versão configurada',
                    ),
                    subtitle: Text(
                      'Instalada: ${SeletoAppVersion.name}+${SeletoAppVersion.code} · Disponível: ${values['latest_app_version_name'] ?? '-'}+${values['latest_app_version_code'] ?? '-'}',
                    ),
                  ),
                  const Divider(),
                  _SettingTile(
                    icon: Icons.numbers,
                    title: 'Código da versão disponível',
                    value: values['latest_app_version_code'] ?? '',
                    onEdit: () => _edit(
                      context,
                      key: 'latest_app_version_code',
                      label: 'Código da versão disponível',
                      initial: values['latest_app_version_code'] ?? '',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  _SettingTile(
                    icon: Icons.new_releases_outlined,
                    title: 'Nome da versão disponível',
                    value: values['latest_app_version_name'] ?? '',
                    onEdit: () => _edit(
                      context,
                      key: 'latest_app_version_name',
                      label: 'Nome da versão disponível',
                      initial: values['latest_app_version_name'] ?? '',
                    ),
                  ),
                  _SettingTile(
                    icon: Icons.campaign_outlined,
                    title: 'Mensagem do aviso',
                    value: values['app_update_message'] ?? '',
                    onEdit: () => _edit(
                      context,
                      key: 'app_update_message',
                      label: 'Mensagem do aviso',
                      initial: values['app_update_message'] ?? '',
                      maxLines: 3,
                    ),
                  ),
                  _SettingTile(
                    icon: Icons.link,
                    title: 'Local/link do APK',
                    value: values['app_update_url'] ?? '',
                    onEdit: () => _edit(
                      context,
                      key: 'app_update_url',
                      label: 'Local/link do APK',
                      initial: values['app_update_url'] ?? '',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Future<void> _edit(
    BuildContext context, {
    required String key,
    required String label,
    required String initial,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) async {
    final controller = TextEditingController(text: initial);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(operationsControllerProvider)
                    .saveSetting(key, controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                await showOperationError(context, e);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onEdit,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(
      value.trim().isEmpty ? 'Não configurado' : value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: IconButton(
      tooltip: 'Editar',
      onPressed: onEdit,
      icon: const Icon(Icons.edit),
    ),
  );
}

class _HardwareIntegrationCard extends StatefulWidget {
  const _HardwareIntegrationCard({required this.ref});

  final WidgetRef ref;

  @override
  State<_HardwareIntegrationCard> createState() =>
      _HardwareIntegrationCardState();
}

class _HardwareIntegrationCardState extends State<_HardwareIntegrationCard> {
  final scaleDevice = TextEditingController();
  final scaleEndpoint = TextEditingController();
  final currentWeight = TextEditingController();
  final ingredientTotal = TextEditingController();
  final supplier = TextEditingController();
  final lightingEndpoint = TextEditingController();
  final lightingRelayPin = TextEditingController();
  String scaleConnection = 'WIFI';
  String scaleMode = 'BOTH';
  String lightingConnection = 'WIFI';
  String? ingredientId;
  String? lotId;
  String? feedBatchId;
  bool scaleEnabled = false;
  bool lightingEnabled = false;
  bool saving = false;
  bool initialized = false;

  @override
  void dispose() {
    scaleDevice.dispose();
    scaleEndpoint.dispose();
    currentWeight.dispose();
    ingredientTotal.dispose();
    supplier.dispose();
    lightingEndpoint.dispose();
    lightingRelayPin.dispose();
    super.dispose();
  }

  void _hydrate(Map<String, String> values) {
    if (initialized) return;
    initialized = true;
    scaleEnabled = values['hardware_scale_enabled'] == 'true';
    final savedScaleConnection = values['hardware_scale_connection'] ?? 'WIFI';
    scaleConnection = savedScaleConnection == 'BLUETOOTH'
        ? 'BLUETOOTH'
        : 'WIFI';
    final savedScaleMode = values['hardware_scale_mode'] ?? 'BOTH';
    scaleMode = switch (savedScaleMode) {
      'INGREDIENT_PURCHASE' || 'FEEDING' || 'BOTH' => savedScaleMode,
      _ => 'BOTH',
    };
    scaleDevice.text = values['hardware_scale_device'] ?? '';
    scaleEndpoint.text = values['hardware_scale_endpoint'] ?? '';
    currentWeight.text = values['hardware_scale_last_weight_kg'] ?? '';
    ingredientTotal.text = values['hardware_scale_last_total_cost'] ?? '';
    supplier.text = values['hardware_scale_supplier'] ?? '';
    ingredientId = values['hardware_scale_default_ingredient_id'];
    lotId = values['hardware_scale_default_lot_id'];
    feedBatchId = values['hardware_scale_default_feed_batch_id'];
    lightingEnabled = values['hardware_lighting_enabled'] == 'true';
    final savedLightingConnection =
        values['hardware_lighting_connection'] ?? 'WIFI';
    lightingConnection = savedLightingConnection == 'BLUETOOTH'
        ? 'BLUETOOTH'
        : 'WIFI';
    lightingEndpoint.text = values['hardware_lighting_endpoint'] ?? '';
    lightingRelayPin.text = values['hardware_lighting_relay_pin'] ?? '23';
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.ref.watch(appSettingsProvider).asData?.value;
    final values = {
      for (final setting in settings ?? <AppSetting>[])
        setting.key: setting.value,
    };
    _hydrate(values);
    final ingredients =
        widget.ref.watch(ingredientsProvider(false)).asData?.value ??
        const <IngredientOverview>[];
    final lots =
        widget.ref.watch(lotSummariesProvider).asData?.value ??
        const <LotSummary>[];
    final feedBatches =
        widget.ref.watch(feedBatchesProvider).asData?.value ??
        const <FeedBatchBalance>[];
    final activeIngredients = ingredients
        .where((item) => item.ingredient.isActive)
        .toList(growable: false);
    final activeLots = lots
        .where((lot) => lot.lot.status == 'ACTIVE' && lot.activeBirds > 0)
        .toList(growable: false);
    final availableFeedBatches = feedBatches
        .where((batch) => batch.balanceKg > .0001)
        .toList(growable: false);
    if (ingredientId != null &&
        !activeIngredients.any((item) => item.ingredient.id == ingredientId)) {
      ingredientId = activeIngredients.firstOrNull?.ingredient.id;
    }
    if (lotId != null && !activeLots.any((lot) => lot.lot.id == lotId)) {
      lotId = activeLots.firstOrNull?.lot.id;
    }
    if (feedBatchId != null &&
        !availableFeedBatches.any((batch) => batch.batch.id == feedBatchId)) {
      feedBatchId = availableFeedBatches.firstOrNull?.batch.id;
    }
    ingredientId ??= activeIngredients.firstOrNull?.ingredient.id;
    lotId ??= activeLots.firstOrNull?.lot.id;
    feedBatchId ??= availableFeedBatches.firstOrNull?.batch.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Integrações de hardware',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, box) => box.maxWidth > 820
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ScaleIntegrationPanel(
                            enabled: scaleEnabled,
                            connection: scaleConnection,
                            mode: scaleMode,
                            deviceController: scaleDevice,
                            endpointController: scaleEndpoint,
                            weightController: currentWeight,
                            totalController: ingredientTotal,
                            supplierController: supplier,
                            ingredients: activeIngredients,
                            lots: activeLots,
                            feedBatches: availableFeedBatches,
                            ingredientId: ingredientId,
                            lotId: lotId,
                            feedBatchId: feedBatchId,
                            saving: saving,
                            onEnabledChanged: (value) =>
                                setState(() => scaleEnabled = value),
                            onConnectionChanged: (value) =>
                                setState(() => scaleConnection = value),
                            onModeChanged: (value) =>
                                setState(() => scaleMode = value),
                            onIngredientChanged: (value) =>
                                setState(() => ingredientId = value),
                            onLotChanged: (value) =>
                                setState(() => lotId = value),
                            onFeedBatchChanged: (value) =>
                                setState(() => feedBatchId = value),
                            onSave: _saveHardwareSettings,
                            onRegisterIngredient: () =>
                                _registerIngredientFromScale(context),
                            onRegisterFeeding: () =>
                                _registerFeedingFromScale(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _LightingIntegrationPanel(
                            enabled: lightingEnabled,
                            connection: lightingConnection,
                            endpointController: lightingEndpoint,
                            relayPinController: lightingRelayPin,
                            saving: saving,
                            onEnabledChanged: (value) =>
                                setState(() => lightingEnabled = value),
                            onConnectionChanged: (value) =>
                                setState(() => lightingConnection = value),
                            onSave: _saveHardwareSettings,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _ScaleIntegrationPanel(
                          enabled: scaleEnabled,
                          connection: scaleConnection,
                          mode: scaleMode,
                          deviceController: scaleDevice,
                          endpointController: scaleEndpoint,
                          weightController: currentWeight,
                          totalController: ingredientTotal,
                          supplierController: supplier,
                          ingredients: activeIngredients,
                          lots: activeLots,
                          feedBatches: availableFeedBatches,
                          ingredientId: ingredientId,
                          lotId: lotId,
                          feedBatchId: feedBatchId,
                          saving: saving,
                          onEnabledChanged: (value) =>
                              setState(() => scaleEnabled = value),
                          onConnectionChanged: (value) =>
                              setState(() => scaleConnection = value),
                          onModeChanged: (value) =>
                              setState(() => scaleMode = value),
                          onIngredientChanged: (value) =>
                              setState(() => ingredientId = value),
                          onLotChanged: (value) =>
                              setState(() => lotId = value),
                          onFeedBatchChanged: (value) =>
                              setState(() => feedBatchId = value),
                          onSave: _saveHardwareSettings,
                          onRegisterIngredient: () =>
                              _registerIngredientFromScale(context),
                          onRegisterFeeding: () =>
                              _registerFeedingFromScale(context),
                        ),
                        const SizedBox(height: 16),
                        _LightingIntegrationPanel(
                          enabled: lightingEnabled,
                          connection: lightingConnection,
                          endpointController: lightingEndpoint,
                          relayPinController: lightingRelayPin,
                          saving: saving,
                          onEnabledChanged: (value) =>
                              setState(() => lightingEnabled = value),
                          onConnectionChanged: (value) =>
                              setState(() => lightingConnection = value),
                          onSave: _saveHardwareSettings,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveHardwareSettings() async {
    setState(() => saving = true);
    try {
      final controller = widget.ref.read(operationsControllerProvider);
      final updates = {
        'hardware_scale_enabled': scaleEnabled.toString(),
        'hardware_scale_connection': scaleConnection,
        'hardware_scale_mode': scaleMode,
        'hardware_scale_device': scaleDevice.text.trim(),
        'hardware_scale_endpoint': scaleEndpoint.text.trim(),
        'hardware_scale_last_weight_kg': currentWeight.text.trim(),
        'hardware_scale_last_total_cost': ingredientTotal.text.trim(),
        'hardware_scale_supplier': supplier.text.trim(),
        'hardware_scale_default_ingredient_id': ingredientId ?? '',
        'hardware_scale_default_lot_id': lotId ?? '',
        'hardware_scale_default_feed_batch_id': feedBatchId ?? '',
        'hardware_lighting_enabled': lightingEnabled.toString(),
        'hardware_lighting_connection': lightingConnection,
        'hardware_lighting_endpoint': lightingEndpoint.text.trim(),
        'hardware_lighting_relay_pin': lightingRelayPin.text.trim(),
      };
      for (final entry in updates.entries) {
        await controller.saveSetting(entry.key, entry.value);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Integrações salvas.')));
      }
    } catch (error) {
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _registerIngredientFromScale(BuildContext context) async {
    final selectedIngredientId = ingredientId;
    final weightKg = parseDecimal(currentWeight.text);
    if (selectedIngredientId == null || weightKg <= 0) {
      await showOperationError(
        context,
        StateError('Informe o insumo e uma leitura de peso válida.'),
      );
      return;
    }
    setState(() => saving = true);
    try {
      await widget.ref
          .read(operationsControllerProvider)
          .addIngredientEntry(
            ingredientId: selectedIngredientId,
            entryDate: DateTime.now(),
            packageUnit: 'KG',
            packageQuantity: weightKg,
            packageWeightKg: 1,
            totalCost: parseMoneyToCents(ingredientTotal.text),
            supplier: supplier.text,
            notes:
                'Entrada registrada pela interface da balança ($scaleConnection).',
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entrada de ${kg(weightKg)} registrada.')),
        );
      }
    } catch (error) {
      if (context.mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _registerFeedingFromScale(BuildContext context) async {
    final selectedLotId = lotId;
    final selectedBatchId = feedBatchId;
    final weightKg = parseDecimal(currentWeight.text);
    if (selectedLotId == null || selectedBatchId == null || weightKg <= 0) {
      await showOperationError(
        context,
        StateError('Informe lote, ração e uma leitura de peso válida.'),
      );
      return;
    }
    setState(() => saving = true);
    try {
      await widget.ref
          .read(operationsControllerProvider)
          .feed(
            selectedLotId,
            selectedBatchId,
            weightKg,
            DateTime.now(),
            'Alimentação registrada pela interface da balança ($scaleConnection).',
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alimentação de ${kg(weightKg)} registrada.')),
        );
      }
    } catch (error) {
      if (context.mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

class _ScaleIntegrationPanel extends StatelessWidget {
  const _ScaleIntegrationPanel({
    required this.enabled,
    required this.connection,
    required this.mode,
    required this.deviceController,
    required this.endpointController,
    required this.weightController,
    required this.totalController,
    required this.supplierController,
    required this.ingredients,
    required this.lots,
    required this.feedBatches,
    required this.ingredientId,
    required this.lotId,
    required this.feedBatchId,
    required this.saving,
    required this.onEnabledChanged,
    required this.onConnectionChanged,
    required this.onModeChanged,
    required this.onIngredientChanged,
    required this.onLotChanged,
    required this.onFeedBatchChanged,
    required this.onSave,
    required this.onRegisterIngredient,
    required this.onRegisterFeeding,
  });

  final bool enabled;
  final String connection;
  final String mode;
  final TextEditingController deviceController;
  final TextEditingController endpointController;
  final TextEditingController weightController;
  final TextEditingController totalController;
  final TextEditingController supplierController;
  final List<IngredientOverview> ingredients;
  final List<LotSummary> lots;
  final List<FeedBatchBalance> feedBatches;
  final String? ingredientId;
  final String? lotId;
  final String? feedBatchId;
  final bool saving;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onConnectionChanged;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<String?> onIngredientChanged;
  final ValueChanged<String?> onLotChanged;
  final ValueChanged<String?> onFeedBatchChanged;
  final Future<void> Function() onSave;
  final VoidCallback onRegisterIngredient;
  final VoidCallback onRegisterFeeding;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.scale_outlined),
        title: const Text('Balança de ração e insumos'),
        subtitle: const Text('ESP32/Arduino com Bluetooth ou Wi-Fi'),
        value: enabled,
        onChanged: saving ? null : onEnabledChanged,
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
        selected: {connection},
        onSelectionChanged: saving
            ? null
            : (value) => onConnectionChanged(value.first),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: deviceController,
        enabled: !saving,
        decoration: const InputDecoration(
          labelText: 'Nome/ID do dispositivo',
          prefixIcon: Icon(Icons.developer_board),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: endpointController,
        enabled: !saving,
        decoration: InputDecoration(
          labelText: connection == 'WIFI'
              ? 'Endpoint ou IP do ESP32'
              : 'Identificador Bluetooth',
          prefixIcon: const Icon(Icons.hub_outlined),
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: mode,
        decoration: const InputDecoration(labelText: 'Uso da balança'),
        items: const [
          DropdownMenuItem(value: 'BOTH', child: Text('Ambos')),
          DropdownMenuItem(value: 'INGREDIENT_PURCHASE', child: Text('Compra')),
          DropdownMenuItem(value: 'FEEDING', child: Text('Alimentação')),
        ],
        onChanged: saving || !enabled || mode.isEmpty
            ? null
            : (value) {
                if (value != null) onModeChanged(value);
              },
      ),
      const SizedBox(height: 12),
      TextField(
        controller: weightController,
        enabled: !saving,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Leitura atual da balança',
          suffixText: 'kg',
          prefixIcon: Icon(Icons.monitor_weight_outlined),
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: ingredientId,
        decoration: const InputDecoration(labelText: 'Insumo da compra'),
        items: [
          for (final item in ingredients)
            DropdownMenuItem(
              value: item.ingredient.id,
              child: Text(
                item.ingredient.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: saving || ingredients.isEmpty ? null : onIngredientChanged,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: totalController,
        enabled: !saving,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Valor total da ração/insumo',
          prefixText: 'R\$ ',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: supplierController,
        enabled: !saving,
        decoration: const InputDecoration(labelText: 'Fornecedor padrão'),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: lotId,
        decoration: const InputDecoration(labelText: 'Lote da alimentação'),
        items: [
          for (final lot in lots)
            DropdownMenuItem(
              value: lot.lot.id,
              child: Text(
                '${lot.lot.name} · ${lot.activeBirds} aves',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: saving || lots.isEmpty ? null : onLotChanged,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: feedBatchId,
        decoration: const InputDecoration(labelText: 'Ração/lote de estoque'),
        items: [
          for (final batch in feedBatches)
            DropdownMenuItem(
              value: batch.batch.id,
              child: Text(
                '${batch.displayName} · ${kg(batch.balanceKg)}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: saving || feedBatches.isEmpty ? null : onFeedBatchChanged,
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar balança'),
          ),
          FilledButton.tonalIcon(
            onPressed: saving || !enabled ? null : onRegisterIngredient,
            icon: const Icon(Icons.add_business_outlined),
            label: const Text('Registrar entrada'),
          ),
          FilledButton.tonalIcon(
            onPressed: saving || !enabled ? null : onRegisterFeeding,
            icon: const Icon(Icons.restaurant),
            label: const Text('Registrar alimentação'),
          ),
        ],
      ),
    ],
  );
}

class _LightingIntegrationPanel extends StatelessWidget {
  const _LightingIntegrationPanel({
    required this.enabled,
    required this.connection,
    required this.endpointController,
    required this.relayPinController,
    required this.saving,
    required this.onEnabledChanged,
    required this.onConnectionChanged,
    required this.onSave,
  });

  final bool enabled;
  final String connection;
  final TextEditingController endpointController;
  final TextEditingController relayPinController;
  final bool saving;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onConnectionChanged;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.lightbulb_outline),
        title: const Text('Iluminação automática'),
        subtitle: const Text('ESP32 executando programas de luz do banco'),
        value: enabled,
        onChanged: saving ? null : onEnabledChanged,
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
        selected: {connection},
        onSelectionChanged: saving
            ? null
            : (value) => onConnectionChanged(value.first),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: endpointController,
        enabled: !saving,
        decoration: InputDecoration(
          labelText: connection == 'WIFI'
              ? 'Endpoint/IP do controlador'
              : 'Identificador Bluetooth',
          prefixIcon: const Icon(Icons.router_outlined),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: relayPinController,
        enabled: !saving,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'GPIO do relé principal',
          prefixIcon: Icon(Icons.electrical_services),
        ),
      ),
      const SizedBox(height: 12),
      const _HardwareInfoBox(
        icon: Icons.schedule,
        text:
            'O controlador deve consultar os programas de luz e eventos do calendário. O app mantém o cadastro manual funcionando e apenas publica a configuração de automação.',
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: saving ? null : onSave,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Salvar iluminação'),
      ),
    ],
  );
}

class _HardwareInfoBox extends StatelessWidget {
  const _HardwareInfoBox({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: .36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: .16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cópia de segurança e exportação',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Exporte uma cópia JSON completa do banco operacional ou importe dados iniciais sem alterar usuários e permissões.',
          ),
          const SizedBox(height: 12),
          _FirebaseBackupPanel(ref: ref),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              try {
                final json = await ref
                    .read(operationsControllerProvider)
                    .exportBackupJson();
                final name =
                    'seleto-copia-seguranca-${DateTime.now().toIso8601String().substring(0, 10)}.json';
                final path = await FileExportService().saveText(name, json);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cópia de segurança exportada: $path'),
                    ),
                  );
                  await _showExportPath(
                    context,
                    title: 'Cópia de segurança salva',
                    path: path,
                  );
                }
              } catch (e) {
                await showOperationError(context, e);
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('Salvar cópia'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () async {
              try {
                final json = await ref
                    .read(operationsControllerProvider)
                    .exportBackupJson();
                final name =
                    'seleto-copia-seguranca-${DateTime.now().toIso8601String().substring(0, 10)}.json';
                final path = await FileExportService().shareText(name, json);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cópia de segurança pronta para envio: $path',
                      ),
                    ),
                  );
                  await _showExportPath(
                    context,
                    title: 'Cópia de segurança pronta',
                    path: path,
                  );
                }
              } catch (e) {
                await showOperationError(context, e);
              }
            },
            icon: const Icon(Icons.ios_share),
            label: const Text('Enviar cópia'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                final items = ref.read(financeProvider).asData?.value ?? [];
                final csv = StringBuffer(
                  'data,tipo,categoria,descricao,valor_centavos\n',
                );
                for (final item in items) {
                  csv.writeln(
                    '${shortDate.format(item.occurredAt)},${item.type},${item.category},"${item.description.replaceAll('"', '""')}",${item.amountCents}',
                  );
                }
                final path = await FileExportService().saveText(
                  'seleto-financeiro.csv',
                  csv.toString(),
                );
                if (context.mounted) {
                  await _showExportPath(
                    context,
                    title: 'CSV salvo',
                    path: path,
                  );
                }
              } catch (e) {
                await showOperationError(context, e);
              }
            },
            icon: const Icon(Icons.table_view),
            label: const Text('Exportar financeiro CSV'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _restore(context),
            icon: const Icon(Icons.restore),
            label: const Text('Restaurar cópia JSON'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _importData(context),
            icon: const Icon(Icons.upload_file),
            label: const Text('Importar dados iniciais'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              try {
                await ref.read(operationsControllerProvider).seedDemo();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dados de demonstração inseridos.'),
                    ),
                  );
                }
              } catch (e) {
                await showOperationError(context, e);
              }
            },
            icon: const Icon(Icons.science_outlined),
            label: const Text('Inserir lotes de demonstração'),
          ),
        ],
      ),
    ),
  );
  Future<void> _restore(BuildContext context) async {
    final input = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restaurar cópia de segurança'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cole o conteúdo do arquivo JSON. A operação substitui os dados operacionais atuais e fica registrada na auditoria.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: input,
                minLines: 6,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo SELETO_BACKUP_V1',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(operationsControllerProvider)
                    .restoreBackup(input.text);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                await showOperationError(context, e);
              }
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    input.dispose();
  }

  Future<void> _importData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Importar dados iniciais'),
        content: const Text(
          'A importação substitui dados operacionais do banco, mas mantém usuários, senhas, permissões e auditoria. Use arquivos JSON, CSV, XML ou XLSX no layout SELETO.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Escolher arquivo'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: 'Importar dados SELETO',
        type: FileType.custom,
        allowedExtensions: ['json', 'csv', 'xml', 'xlsx', 'xlsl'],
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final result = await ref
          .read(operationsControllerProvider)
          .importOperationalData(picked.name, bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Importação concluída: ${result.rowCount} linha(s) em ${result.sectionCount} seção(ões).',
            ),
          ),
        );
      }
    } catch (e) {
      await showOperationError(context, e);
    }
  }
}

class _FirebaseBackupPanel extends StatefulWidget {
  const _FirebaseBackupPanel({required this.ref});
  final WidgetRef ref;

  @override
  State<_FirebaseBackupPanel> createState() => _FirebaseBackupPanelState();
}

class _FirebaseBackupPanelState extends State<_FirebaseBackupPanel> {
  static const _encoder = JsonEncoder.withIndent('  ');
  Map<String, dynamic>? _result;
  bool _testing = false;
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final result = _result;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withValues(alpha: .72),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .78)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_sync_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Backup Firebase',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Destino remoto: coleções do Firestore com os nomes das tabelas locais.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _testing || _syncing ? null : _test,
                  icon: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.rule_folder_outlined),
                  label: Text(_testing ? 'Testando...' : 'Testar config'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _testing || _syncing ? null : _syncNow,
                  icon: _syncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync_rounded),
                  label: Text(_syncing ? 'Sincronizando...' : 'Sincronizar'),
                ),
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _encoder.convert(result),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: result['status'] == 'sucesso'
                          ? scheme.primary
                          : scheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    try {
      final result = await widget.ref
          .read(firebaseBackupServiceProvider)
          .testConfiguration();
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) {
        setState(
          () => _result = {
            'servico': 'Firebase Firestore',
            'status': 'erro',
            'erro': {'mensagem': error.toString()},
          },
        );
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    try {
      final result = await widget.ref
          .read(firebaseBackupServiceProvider)
          .syncNow(reason: 'settings', force: true);
      if (mounted) {
        setState(
          () => _result = {
            'servico': 'Firebase Firestore',
            'status': result.changed || result.status == SyncStatus.idle
                ? 'sucesso'
                : 'erro',
            'resultado': _syncStatusLabel(result.status),
            if (result.message != null) 'mensagem': result.message,
            'verificadoEm': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _result = {
            'servico': 'Firebase Firestore',
            'status': 'erro',
            'erro': {'mensagem': error.toString()},
          },
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  String _syncStatusLabel(SyncStatus status) => switch (status) {
    SyncStatus.idle => 'Sem alterações',
    SyncStatus.syncing => 'Sincronizando',
    SyncStatus.skipped => 'Ignorado',
    SyncStatus.uploaded => 'Enviado para o Firebase',
    SyncStatus.downloaded => 'Baixado do Firebase',
    SyncStatus.merged => 'Mesclado com o Firebase',
    SyncStatus.offline => 'Sem conexão',
    SyncStatus.failed => 'Falha',
  };
}

Future<void> _showExportPath(
  BuildContext context, {
  required String title,
  required String path,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Arquivo salvo em:'),
          const SizedBox(height: 8),
          SelectableText(path),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: path));
            Navigator.pop(context);
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copiar caminho'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Alertas locais',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Chip(
                label: Text(
                  NotificationService().nativeSupported
                      ? 'Android nativo'
                      : 'Modo navegador',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ref
              .watch(notificationSettingsProvider)
              .when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Falha ao carregar alertas.'),
                data: (items) => Column(
                  children: [
                    for (final item in items)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: IconButton(
                          tooltip: 'Editar antecedência e horário',
                          icon: const Icon(Icons.edit_notifications_outlined),
                          onPressed: () => _edit(context, item),
                        ),
                        title: Text(_notificationLabel(item.type)),
                        subtitle: Text(
                          '${item.daysBefore} dia(s) antes · ${item.notificationTime}',
                        ),
                        value: item.isEnabled,
                        onChanged: (value) async {
                          try {
                            await ref
                                .read(operationsControllerProvider)
                                .updateNotification(
                                  item,
                                  value,
                                  item.daysBefore,
                                  item.notificationTime,
                                  item.defaultMessage,
                                  item.defaultRecurrence,
                                );
                          } catch (e) {
                            await showOperationError(context, e);
                          }
                        },
                      ),
                  ],
                ),
              ),
        ],
      ),
    ),
  );
  String _notificationLabel(String type) =>
      const {
        'PHASE_CHANGE': 'Mudança de fase',
        'LIGHTING': 'Programa de luz',
        'LOW_STOCK': 'Estoque baixo',
        'ORDER': 'Pedidos',
        'DELIVERY': 'Entregas',
        'FEED': 'Ração',
      }[type] ??
      type;
  Future<void> _edit(BuildContext context, NotificationSetting item) async {
    final days = TextEditingController(text: '${item.daysBefore}');
    final time = TextEditingController(text: item.notificationTime);
    final message = TextEditingController(text: item.defaultMessage ?? '');
    var recurrence = item.defaultRecurrence;
    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(_notificationLabel(item.type)),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: days,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dias de antecedência',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: time,
                  decoration: const InputDecoration(
                    labelText: 'Horário',
                    hintText: '08:00',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: recurrence,
                  decoration: const InputDecoration(
                    labelText: 'Recorrência padrão',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ONCE', child: Text('Uma vez')),
                    DropdownMenuItem(value: 'DAILY', child: Text('Diário')),
                    DropdownMenuItem(value: 'WEEKLY', child: Text('Semanal')),
                    DropdownMenuItem(value: 'MONTHLY', child: Text('Mensal')),
                  ],
                  onChanged: (v) => setState(() => recurrence = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: message,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mensagem padrão',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(operationsControllerProvider)
                      .updateNotification(
                        item,
                        item.isEnabled,
                        int.tryParse(days.text) ?? 0,
                        time.text,
                        message.text,
                        recurrence,
                      );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    days.dispose();
    time.dispose();
    message.dispose();
  }
}
