import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/platform/file_export_service.dart';
import '../../../../core/platform/notification_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
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
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => const SeletoAsyncError(),
        data: (settings) {
          final values = {for (final s in settings) s.key: s.value};
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
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

class _BackupCard extends StatelessWidget {
  const _BackupCard({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () async {
              try {
                final json = await ref.read(databaseProvider).exportJson();
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
                final json = await ref.read(databaseProvider).exportJson();
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
      padding: const EdgeInsets.all(20),
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
