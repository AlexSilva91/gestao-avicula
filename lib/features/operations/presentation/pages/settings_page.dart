import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_version.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/platform/file_export_service.dart';
import '../../../../core/platform/notification_service.dart';
import '../../../../core/sync/seleto_sync_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/camera_monitoring.dart';
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
        _CameraSettingsCard(ref: ref),
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

class _CameraSettingsCard extends StatelessWidget {
  const _CameraSettingsCard({required this.ref});
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
          final cameras = onvifCamerasFromSettings(settings);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.videocam_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Câmeras ONVIF',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Chip(label: Text('${cameras.length} canal(is)')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cadastre canais por IP, usuário, senha e porta opcional. A visualização abre em tela dedicada compacta.',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _edit(context, cameras),
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('Adicionar câmera'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/cameras'),
                        icon: const Icon(Icons.grid_view_rounded),
                        label: const Text('Abrir monitoramento'),
                      ),
                    ],
                  ),
                  if (cameras.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    for (final camera in cameras)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          camera.enabled
                              ? Icons.videocam_outlined
                              : Icons.videocam_off_outlined,
                        ),
                        title: Text(camera.name),
                        subtitle: Text(
                          '${camera.host}${camera.port == null ? '' : ':${camera.port}'} · usuário ${camera.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: 'Testar ONVIF',
                              icon: const Icon(Icons.network_check),
                              onPressed: () => _test(context, cameras, camera),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _edit(context, cameras, editing: camera),
                            ),
                            IconButton(
                              tooltip: 'Remover',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  _remove(context, cameras, camera),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      );

  Future<void> _edit(
    BuildContext context,
    List<OnvifCameraConfig> cameras, {
    OnvifCameraConfig? editing,
  }) async {
    final name = TextEditingController(text: editing?.name ?? '');
    final host = TextEditingController(text: editing?.host ?? '');
    final username = TextEditingController(text: editing?.username ?? 'admin');
    final password = TextEditingController(text: editing?.password ?? '');
    final port = TextEditingController(text: editing?.port?.toString() ?? '');
    final snapshot = TextEditingController(text: editing?.snapshotUrl ?? '');
    var enabled = editing?.enabled ?? true;
    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(editing == null ? 'Adicionar câmera' : 'Editar câmera'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: host,
                    decoration: const InputDecoration(
                      labelText: 'IP ou host',
                      hintText: '192.168.1.50',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: username,
                          decoration: const InputDecoration(
                            labelText: 'Usuário',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: password,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Senha'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: port,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Porta ONVIF opcional',
                      hintText: '80',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: snapshot,
                    decoration: const InputDecoration(
                      labelText: 'URL de snapshot opcional',
                      hintText: 'Preencha só se a câmera exigir caminho manual',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: enabled,
                    title: const Text('Canal ativo'),
                    onChanged: (value) => setState(() => enabled = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final cleanHost = host.text.trim();
                if (cleanHost.isEmpty) return;
                final camera = OnvifCameraConfig(
                  id: editing?.id ?? const Uuid().v4(),
                  name: name.text.trim().isEmpty ? cleanHost : name.text.trim(),
                  host: cleanHost,
                  username: username.text.trim().isEmpty
                      ? 'admin'
                      : username.text.trim(),
                  password: password.text,
                  port: int.tryParse(port.text.trim()),
                  snapshotUrl: snapshot.text.trim().isEmpty
                      ? null
                      : snapshot.text.trim(),
                  enabled: enabled,
                );
                final next = [
                  for (final current in cameras)
                    if (current.id != camera.id) current,
                  camera,
                ];
                await _save(context, next);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    host.dispose();
    username.dispose();
    password.dispose();
    port.dispose();
    snapshot.dispose();
  }

  Future<void> _test(
    BuildContext context,
    List<OnvifCameraConfig> cameras,
    OnvifCameraConfig camera,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Testando ${camera.name} via ONVIF...')),
    );
    final result = await OnvifClient().resolveSnapshot(camera);
    if (!context.mounted) return;
    if (result.ok && result.snapshotUrl != null) {
      final updated = camera.copyWith(snapshotUrl: result.snapshotUrl);
      await _save(context, [
        for (final current in cameras)
          if (current.id == camera.id) updated else current,
      ]);
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.ok ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    List<OnvifCameraConfig> cameras,
    OnvifCameraConfig camera,
  ) async {
    await _save(
      context,
      cameras.where((current) => current.id != camera.id).toList(),
    );
  }

  Future<void> _save(
    BuildContext context,
    List<OnvifCameraConfig> cameras,
  ) async {
    try {
      await ref
          .read(operationsControllerProvider)
          .saveSetting(onvifCamerasSettingKey, encodeOnvifCameras(cameras));
    } catch (error) {
      if (context.mounted) await showOperationError(context, error);
    }
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
          _SyncServerPanel(ref: ref),
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

class _SyncServerPanel extends StatefulWidget {
  const _SyncServerPanel({required this.ref});
  final WidgetRef ref;

  @override
  State<_SyncServerPanel> createState() => _SyncServerPanelState();
}

class _SyncServerPanelState extends State<_SyncServerPanel> {
  static const _encoder = JsonEncoder.withIndent('  ');
  Map<String, dynamic>? _result;
  Map<String, dynamic>? _health;
  bool _checkingHealth = false;
  bool _testing = false;
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final result = _result;
    final health = _health;
    final healthOk = health?['status'] == 'sucesso';
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
                    'Servidor SELETO Sync',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Destino remoto: tabelas PostgreSQL equivalentes ao banco local.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: healthOk
                    ? scheme.primaryContainer.withValues(alpha: .52)
                    : scheme.errorContainer.withValues(alpha: .42),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      healthOk
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 18,
                      color: healthOk
                          ? scheme.onPrimaryContainer
                          : scheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        health == null
                            ? 'Saúde remota ainda não verificada.'
                            : healthOk
                            ? 'Servidor remoto online · ${health['latenciaMs']} ms'
                            : 'Servidor remoto indisponível · ${health['latenciaMs']} ms',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: healthOk
                              ? scheme.onPrimaryContainer
                              : scheme.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _checkingHealth || _testing || _syncing
                      ? null
                      : _checkHealth,
                  icon: _checkingHealth
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.health_and_safety_outlined),
                  label: Text(_checkingHealth ? 'Checando...' : 'Saúde remota'),
                ),
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

  Future<void> _checkHealth() async {
    setState(() => _checkingHealth = true);
    try {
      final result = await widget.ref
          .read(seletoSyncServiceProvider)
          .checkRemoteHealth();
      if (mounted) {
        setState(() {
          _health = result;
          _result = result;
        });
      }
    } finally {
      if (mounted) setState(() => _checkingHealth = false);
    }
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    try {
      final result = await widget.ref
          .read(seletoSyncServiceProvider)
          .testConfiguration();
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) {
        setState(
          () => _result = {
            'servico': 'Servidor SELETO Sync',
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
          .read(seletoSyncServiceProvider)
          .syncNow(reason: 'settings', force: true);
      if (mounted) {
        setState(
          () => _result = {
            'servico': 'Servidor SELETO Sync',
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
            'servico': 'Servidor SELETO Sync',
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
    SyncStatus.uploaded => 'Enviado para o servidor',
    SyncStatus.downloaded => 'Baixado do servidor',
    SyncStatus.merged => 'Mesclado com o servidor',
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
