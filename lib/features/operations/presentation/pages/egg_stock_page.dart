import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/operations_controller.dart';

class EggStockPage extends ConsumerWidget {
  const EggStockPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Estoque de ovos',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _EggAdjustmentDialog(ref: ref),
            ),
            icon: const Icon(Icons.tune),
            label: const Text('Ajustar estoque'),
          ),
        ),
        const SizedBox(height: 24),
        ref
            .watch(eggStockProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SeletoAsyncError(),
              data: (m) => SeletoKpiGrid(
                children: [
                  SeletoKpiCard(
                    label: 'Ovos em estoque',
                    value: '${m.balance}',
                    icon: Icons.egg_outlined,
                  ),
                  SeletoKpiCard(
                    label: 'Dúzias equivalentes',
                    value: (m.balance / 12).toStringAsFixed(2),
                    icon: Icons.inventory_2_outlined,
                  ),
                  SeletoKpiCard(
                    label: 'Total de entradas',
                    value: '${m.entries}',
                    icon: Icons.south_west,
                  ),
                  SeletoKpiCard(
                    label: 'Perdas registradas',
                    value: '${m.losses}',
                    icon: Icons.warning_amber,
                  ),
                ],
              ),
            ),
        const SizedBox(height: 24),
        const SeletoEmptyState(
          icon: Icons.info_outline,
          title: 'Histórico preservado',
          message:
              'Coletas e vendas geram movimentações automaticamente. Ajustes ficam registrados na auditoria.',
        ),
      ],
    ),
  );
}

class _EggAdjustmentDialog extends StatefulWidget {
  const _EggAdjustmentDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_EggAdjustmentDialog> createState() => _EggAdjustmentDialogState();
}

class _EggAdjustmentDialogState extends State<_EggAdjustmentDialog> {
  final qty = TextEditingController();
  final notes = TextEditingController();
  String type = 'ADJUSTMENT_IN';
  bool saving = false;
  @override
  void dispose() {
    qty.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Ajustar estoque de ovos'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem(
                value: 'ADJUSTMENT_IN',
                child: Text('Entrada de ajuste'),
              ),
              DropdownMenuItem(
                value: 'ADJUSTMENT_OUT',
                child: Text('Saída de ajuste'),
              ),
              DropdownMenuItem(value: 'LOSS_OUT', child: Text('Perda')),
            ],
            onChanged: (v) => setState(() => type = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantidade de ovos'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Motivo/observação'),
            maxLines: 2,
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
                final value = int.tryParse(qty.text) ?? 0;
                setState(() => saving = true);
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .adjustEggs(value, type, notes.text);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                  if (mounted) setState(() => saving = false);
                }
              },
        child: const Text('Registrar'),
      ),
    ],
  );
}
