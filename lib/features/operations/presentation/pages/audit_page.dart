import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/operations_controller.dart';

const _auditPageSize = 15;

class AuditPage extends ConsumerStatefulWidget {
  const AuditPage({super.key});

  @override
  ConsumerState<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends ConsumerState<AuditPage> {
  int _page = 1;

  void _goToPage(int page, int totalPages) {
    setState(() => _page = page.clamp(1, totalPages));
  }

  @override
  Widget build(BuildContext context) {
    final totalAsync = ref.watch(auditLogCountProvider);
    final total = totalAsync.asData?.value ?? 0;
    final totalPages = math.max(1, (total / _auditPageSize).ceil());
    if (_page > totalPages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _page = totalPages);
      });
    }
    final page = math.min(_page, totalPages);
    final logsAsync = ref.watch(
      pagedAuditLogsProvider((page: page, pageSize: _auditPageSize)),
    );

    return AppShell(
      title: 'Auditoria',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SeletoAsyncError(),
            data: (logs) => logs.isEmpty
                ? const SeletoEmptyState(
                    icon: Icons.history,
                    title: 'Sem eventos',
                    message: 'As ações auditáveis aparecerão aqui.',
                  )
                : _AuditLogList(
                    logs: logs,
                    page: page,
                    total: total,
                    totalPages: totalPages,
                    countLoading: totalAsync.isLoading,
                    onFirst: () => _goToPage(1, totalPages),
                    onPrevious: () => _goToPage(page - 1, totalPages),
                    onNext: () => _goToPage(page + 1, totalPages),
                    onLast: () => _goToPage(totalPages, totalPages),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogList extends StatelessWidget {
  const _AuditLogList({
    required this.logs,
    required this.page,
    required this.total,
    required this.totalPages,
    required this.countLoading,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLast,
  });

  final List<AuditLog> logs;
  final int page;
  final int total;
  final int totalPages;
  final bool countLoading;
  final VoidCallback onFirst;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onLast;

  @override
  Widget build(BuildContext context) {
    final firstRecord = ((page - 1) * _auditPageSize) + 1;
    final lastRecord = math.min(firstRecord + logs.length - 1, total);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, index) => _AuditLogTile(log: logs[index]),
          ),
          const Divider(height: 1),
          _AuditPaginationBar(
            firstRecord: firstRecord,
            lastRecord: lastRecord,
            total: total,
            page: page,
            totalPages: totalPages,
            countLoading: countLoading,
            onFirst: page <= 1 ? null : onFirst,
            onPrevious: page <= 1 ? null : onPrevious,
            onNext: page >= totalPages ? null : onNext,
            onLast: page >= totalPages ? null : onLast,
          ),
        ],
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  const _AuditLogTile({required this.log});

  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    final time =
        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';
    return ListTile(
      leading: const Icon(Icons.verified_user_outlined),
      title: Text(
        log.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${auditActionLabel(log.action)} · ${auditEntityLabel(log.entityType)}${log.entityId == null ? '' : ' · ${log.entityId}'}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 64),
        child: Text(
          '${shortDate.format(log.timestamp)}\n$time',
          textAlign: TextAlign.end,
        ),
      ),
    );
  }
}

class _AuditPaginationBar extends StatelessWidget {
  const _AuditPaginationBar({
    required this.firstRecord,
    required this.lastRecord,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.countLoading,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLast,
  });

  final int firstRecord;
  final int lastRecord;
  final int total;
  final int page;
  final int totalPages;
  final bool countLoading;
  final VoidCallback? onFirst;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rangeLabel = countLoading
        ? 'Carregando total'
        : '$firstRecord-$lastRecord de $total';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            '$rangeLabel · página $page de $totalPages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Primeira página',
                onPressed: onFirst,
                icon: const Icon(Icons.first_page),
              ),
              IconButton(
                tooltip: 'Página anterior',
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Próxima página',
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                tooltip: 'Última página',
                onPressed: onLast,
                icon: const Icon(Icons.last_page),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
