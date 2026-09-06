import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../application/operations_controller.dart';

class MovementsPage extends ConsumerWidget {
  const MovementsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Movimentações de aves',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _transfer(context, ref),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Transferir aves'),
          ),
        ),
        const SizedBox(height: 24),
        if (ref.watch(birdMetricsProvider).asData case final data?)
          SeletoKpiGrid(
            children: [
              SeletoKpiCard(
                label: 'Aves compradas',
                value: '${data.value.purchased}',
                icon: Icons.add_circle_outline,
              ),
              SeletoKpiCard(
                label: 'Aves ativas',
                value: '${data.value.active}',
                icon: Icons.egg_alt_outlined,
              ),
              SeletoKpiCard(
                label: 'Mortalidade',
                value: '${data.value.mortality}',
                icon: Icons.warning_amber,
              ),
              SeletoKpiCard(
                label: 'Taxa de mortalidade',
                value: percent(data.value.mortalityRate),
                icon: Icons.percent,
              ),
            ],
          ),
        const SizedBox(height: 18),
        ref
            .watch(birdMovementsProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SeletoAsyncError(),
              data: (items) => items.isEmpty
                  ? const SeletoEmptyState(
                      icon: Icons.swap_horiz,
                      title: 'Nenhuma movimentação',
                      message:
                          'As movimentações dos lotes serão exibidas aqui.',
                    )
                  : Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) =>
                            _MovementTile(ref: ref, item: items[i]),
                      ),
                    ),
            ),
      ],
    ),
  );

  void _transfer(BuildContext context, WidgetRef ref) => showDialog<void>(
    context: context,
    builder: (_) => _TransferDialog(ref: ref),
  );
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.ref, required this.item});
  final WidgetRef ref;
  final BirdMovementOverview item;
  static const labels = {
    'PURCHASE': 'Compra',
    'SALE': 'Venda',
    'MORTALITY': 'Mortalidade',
    'TRANSFER_IN': 'Transferência recebida',
    'TRANSFER_OUT': 'Transferência enviada',
    'ADJUSTMENT_IN': 'Ajuste de entrada',
    'ADJUSTMENT_OUT': 'Ajuste de saída',
  };
  @override
  Widget build(BuildContext context) {
    final movement = item.movement;
    final input = {
      'PURCHASE',
      'TRANSFER_IN',
      'ADJUSTMENT_IN',
    }.contains(movement.type);
    final isUndo = movement.reference?.startsWith('undo:') ?? false;
    final route = switch (movement.type) {
      'TRANSFER_OUT' =>
        '${item.lotName} -> ${item.relatedLotName ?? 'destino'}',
      'TRANSFER_IN' => '${item.relatedLotName ?? 'origem'} -> ${item.lotName}',
      _ => item.lotName,
    };
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (input ? Colors.green : Colors.red).withValues(
          alpha: .12,
        ),
        child: Icon(
          input ? Icons.add : Icons.remove,
          color: input ? Colors.green : Colors.red,
        ),
      ),
      title: Text(labels[movement.type] ?? movement.type),
      subtitle: Text(
        '${shortDate.format(movement.occurredAt)} · $route${item.transferUndone ? ' · desfeita' : ''}${isUndo ? ' · reversão' : ''}${movement.notes == null ? '' : ' · ${movement.notes}'}',
      ),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(
            '${input ? '+' : '−'}${movement.quantity}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (item.canUndoTransfer)
            IconButton(
              tooltip: 'Desfazer transferência',
              onPressed: () => _confirmUndo(context),
              icon: const Icon(Icons.undo),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmUndo(BuildContext context) async {
    final reference = item.movement.reference;
    if (reference == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desfazer transferência'),
        content: Text(
          'Voltar ${item.movement.quantity} aves de ${item.relatedLotName ?? 'destino'} para ${item.lotName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Desfazer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref
          .read(operationsControllerProvider)
          .undoTransfer(reference, null);
    } catch (e) {
      if (context.mounted) await showOperationError(context, e);
    }
  }
}

class _TransferDialog extends StatefulWidget {
  const _TransferDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  String? from;
  String? to;
  final quantity = TextEditingController();
  final notes = TextEditingController();
  DateTime date = DateTime.now();
  bool unify = false;
  bool saving = false;
  @override
  void dispose() {
    quantity.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots =
        widget.ref.watch(lotSummariesProvider).asData?.value ?? <LotSummary>[];
    final fromLot = lots.where((l) => l.lot.id == from).firstOrNull;
    return AlertDialog(
      title: const Text('Transferir aves'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: from,
                decoration: const InputDecoration(labelText: 'Lote de origem'),
                items: [
                  for (final l in lots.where((l) => l.activeBirds > 0))
                    DropdownMenuItem(
                      value: l.lot.id,
                      child: Text('${l.lot.name} · ${l.activeBirds} aves'),
                    ),
                ],
                onChanged: saving
                    ? null
                    : (v) => setState(() {
                        from = v;
                        if (to == v) to = null;
                        final selected = lots
                            .where((l) => l.lot.id == v)
                            .firstOrNull;
                        if (unify && selected != null) {
                          quantity.text = '${selected.activeBirds}';
                        }
                      }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: to,
                decoration: const InputDecoration(labelText: 'Lote de destino'),
                items: [
                  for (final l in lots.where((l) => l.lot.id != from))
                    DropdownMenuItem(value: l.lot.id, child: Text(l.lot.name)),
                ],
                onChanged: saving ? null : (v) => setState(() => to = v),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: unify,
                onChanged: saving
                    ? null
                    : (value) => setState(() {
                        unify = value;
                        if (value && fromLot != null) {
                          quantity.text = '${fromLot.activeBirds}';
                        }
                      }),
                title: const Text('Unificar lote de origem'),
                subtitle: const Text('Move todo o saldo e inativa a origem.'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantity,
                enabled: !saving && !unify,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !saving,
                title: const Text('Data da movimentação'),
                subtitle: Text(shortDate.format(date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: saving
                    ? null
                    : () async {
                        final picked = await pickSeletoDate(
                          context,
                          date,
                          firstDate: DateTime(2010),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notes,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'Observação'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: saving
              ? null
              : () async {
                  if (from == null ||
                      to == null ||
                      int.tryParse(quantity.text) == null) {
                    return;
                  }
                  setState(() => saving = true);
                  try {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .transfer(
                          from!,
                          to!,
                          int.parse(quantity.text),
                          date,
                          notes.text,
                          unify,
                        );
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    await showOperationError(context, e);
                    if (mounted) setState(() => saving = false);
                  }
                },
          child: saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Transferir'),
        ),
      ],
    );
  }
}
