import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
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
                        itemBuilder: (_, i) => _MovementTile(item: items[i]),
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
  const _MovementTile({required this.item});
  final BirdMovement item;
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
    final input = {
      'PURCHASE',
      'TRANSFER_IN',
      'ADJUSTMENT_IN',
    }.contains(item.type);
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
      title: Text(labels[item.type] ?? item.type),
      subtitle: Text(
        '${shortDate.format(item.occurredAt)} · Lote ${item.lotId.substring(0, item.lotId.length.clamp(0, 8))}${item.notes == null ? '' : ' · ${item.notes}'}',
      ),
      trailing: Text(
        '${input ? '+' : '−'}${item.quantity}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
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
  bool saving = false;
  @override
  void dispose() {
    quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots =
        widget.ref.watch(lotSummariesProvider).asData?.value ?? <LotSummary>[];
    return AlertDialog(
      title: const Text('Transferir aves'),
      content: SizedBox(
        width: 440,
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
              onChanged: (v) => setState(() => from = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: to,
              decoration: const InputDecoration(labelText: 'Lote de destino'),
              items: [
                for (final l in lots)
                  DropdownMenuItem(value: l.lot.id, child: Text(l.lot.name)),
              ],
              onChanged: (v) => setState(() => to = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
          ],
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
                          DateTime.now(),
                          null,
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
