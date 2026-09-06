import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/operations_controller.dart';

class AuditPage extends ConsumerWidget {
  const AuditPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Auditoria',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ref
            .watch(auditLogsProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SeletoAsyncError(),
              data: (logs) => logs.isEmpty
                  ? const SeletoEmptyState(
                      icon: Icons.history,
                      title: 'Sem eventos',
                      message: 'As ações auditáveis aparecerão aqui.',
                    )
                  : Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logs.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final log = logs[i];
                          return ListTile(
                            leading: const Icon(Icons.verified_user_outlined),
                            title: Text(log.description),
                            subtitle: Text(
                              '${auditActionLabel(log.action)} · ${auditEntityLabel(log.entityType)}${log.entityId == null ? '' : ' · ${log.entityId}'}',
                            ),
                            trailing: Text(
                              '${shortDate.format(log.timestamp)}\n${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                              textAlign: TextAlign.end,
                            ),
                          );
                        },
                      ),
                    ),
            ),
      ],
    ),
  );
}
