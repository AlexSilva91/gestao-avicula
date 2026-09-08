import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/operations_controller.dart';

class CommercialPage extends ConsumerWidget {
  const CommercialPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Comercial',
    scrollable: false,
    child: DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Pedidos'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Materiais'),
              Tab(icon: Icon(Icons.egg_alt_outlined), text: 'Montar bandeja'),
              Tab(icon: Icon(Icons.point_of_sale_outlined), text: 'Vendas'),
              Tab(icon: Icon(Icons.people_outline), text: 'Clientes'),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: TabBarView(
              children: [
                _OrdersTab(ref: ref),
                _PackagingTab(ref: ref),
                _TrayAssemblyTab(ref: ref),
                _SalesTab(ref: ref),
                _CustomersTab(ref: ref),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

const orderLabels = {
  'DRAFT': 'Rascunho',
  'PENDING': 'Pendente',
  'CONFIRMED': 'Confirmado',
  'IN_PROCESS': 'Em processamento',
  'READY': 'Pronto',
  'DELIVERED': 'Entregue',
  'CANCELLED': 'Cancelado',
};
Color _statusColor(String status) => switch (status) {
  'DELIVERED' => Colors.green,
  'CANCELLED' => Colors.red,
  'READY' => Colors.blue,
  'IN_PROCESS' => Colors.orange,
  _ => Colors.blueGrey,
};

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(ordersProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => SeletoTabList(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _OrderDialog(ref: ref),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Novo pedido'),
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const SeletoEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Nenhum pedido',
                message:
                    'Crie o primeiro pedido para acompanhar a preparação e entrega.',
              )
            else
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => _OrderTile(ref: ref, order: items[i]),
                ),
              ),
          ],
        ),
      );
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.ref, required this.order});
  final WidgetRef ref;
  final Order order;
  @override
  Widget build(BuildContext context) {
    final closed = {'DELIVERED', 'CANCELLED'}.contains(order.status);
    return ListTile(
      leading: CircleAvatar(child: Text('#${order.orderNumber}')),
      title: Text('Pedido #${order.orderNumber} · ${money(order.totalCents)}'),
      subtitle: Text(
        '${shortDate.format(order.requestedDate)}${order.expectedDeliveryDate == null ? '' : ' · Entrega ${shortDate.format(order.expectedDeliveryDate!)}'}',
      ),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Chip(
            label: Text(orderLabels[order.status] ?? order.status),
            side: BorderSide(color: _statusColor(order.status)),
          ),
          if (!closed)
            PopupMenuButton<String>(
              tooltip: 'Alterar status',
              onSelected: (value) async {
                try {
                  await ref
                      .read(operationsControllerProvider)
                      .setOrderStatus(order.id, value);
                } catch (e) {
                  await showOperationError(context, e);
                }
              },
              itemBuilder: (_) => [
                for (final s in [
                  'CONFIRMED',
                  'IN_PROCESS',
                  'READY',
                  'DELIVERED',
                  'CANCELLED',
                ])
                  PopupMenuItem(value: s, child: Text(orderLabels[s]!)),
              ],
            ),
        ],
      ),
    );
  }
}

class _PackagingTab extends StatelessWidget {
  const _PackagingTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final lots = ref.watch(packagingLotsProvider(null)).asData?.value ?? [];
    return ref
        .watch(packagingItemsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (items) => SeletoTabList(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => _PackagingItemDialog(ref: ref),
                      ),
                      icon: const Icon(Icons.add_box_outlined),
                      label: const Text('Novo material'),
                    ),
                    FilledButton.icon(
                      onPressed: items.isEmpty
                          ? null
                          : () => showDialog<void>(
                              context: context,
                              builder: (_) =>
                                  _PackagingLotDialog(ref: ref, items: items),
                            ),
                      icon: const Icon(Icons.inventory_outlined),
                      label: const Text('Novo lote'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const SeletoEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Nenhum material cadastrado',
                  message:
                      'Cadastre bandejas/embalagens e etiquetas antes de montar bandejas.',
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Icon(
                          item.item.type == 'TRAY'
                              ? Icons.inventory_2_outlined
                              : Icons.sell_outlined,
                        ),
                        title: Text(item.item.name),
                        subtitle: Text(
                          '${_packagingTypeLabel(item.item.type)} · ${item.activeLotCount} lote(s) com saldo',
                        ),
                        trailing: Chip(label: Text('${item.balance} un.')),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              if (lots.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lotes cadastrados',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        for (final lot in lots)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(lot.item.name),
                            subtitle: Text(
                              [
                                _packagingTypeLabel(lot.item.type),
                                if ((lot.lot.batchCode ?? '').isNotEmpty)
                                  'Lote ${lot.lot.batchCode}',
                                shortDate.format(lot.lot.purchasedAt),
                                money(lot.lot.unitCostCents),
                              ].join(' · '),
                            ),
                            trailing: Text('${lot.balance} un.'),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
  }
}

class _TrayAssemblyTab extends StatelessWidget {
  const _TrayAssemblyTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final trayLots =
        ref.watch(packagingLotsProvider('TRAY')).asData?.value ?? [];
    final labelLots =
        ref.watch(packagingLotsProvider('LABEL')).asData?.value ?? [];
    final eggStock = ref.watch(eggStockProvider).asData?.value.balance ?? 0;
    return ref
        .watch(eggTrayBatchesProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (batches) => SeletoTabList(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ovos disponíveis para montagem: $eggStock',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  FilledButton.icon(
                    onPressed:
                        trayLots.any((lot) => lot.balance > 0) &&
                            labelLots.any((lot) => lot.balance > 0) &&
                            eggStock >= 12
                        ? () => showDialog<void>(
                            context: context,
                            builder: (_) => _TrayAssemblyDialog(
                              ref: ref,
                              trayLots: trayLots,
                              labelLots: labelLots,
                            ),
                          )
                        : null,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Montar bandeja'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (batches.isEmpty)
                const SeletoEmptyState(
                  icon: Icons.egg_alt_outlined,
                  title: 'Nenhuma bandeja montada',
                  message:
                      'Monte bandejas usando ovos, bandejas/embalagens e etiquetas antes da venda.',
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: batches.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final batch = batches[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.egg_alt_outlined),
                        ),
                        title: Text(_trayBatchLabel(batch)),
                        subtitle: Text(
                          '${batch.trayName} · ${batch.labelName} · ${shortDate.format(batch.batch.assembledAt)}',
                        ),
                        trailing: Chip(
                          label: Text('${batch.balance} pronta(s)'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
  }
}

class _SalesTab extends StatelessWidget {
  const _SalesTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(salesProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) {
          final total = items
              .where((s) => s.status == 'CONFIRMED')
              .fold<int>(0, (sum, s) => sum + s.totalCents);
          return SeletoTabList(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Faturamento listado: ${money(total)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _SaleDialog(ref: ref),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Venda balcão'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const SeletoEmptyState(
                  icon: Icons.point_of_sale,
                  title: 'Nenhuma venda',
                  message:
                      'Vendas diretas e pedidos entregues serão exibidos aqui.',
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final s = items[i];
                      final cancelled = s.status == 'CANCELLED';
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.payments_outlined),
                        ),
                        title: Text(
                          s.trayQuantity > 0
                              ? '${s.trayQuantity} bandeja(s) · ${s.dozens} dúzias + ${s.looseEggs} ovos · ${money(s.totalCents)}'
                              : '${s.dozens} dúzias + ${s.looseEggs} ovos · ${money(s.totalCents)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${shortDate.format(s.soldAt)} · ${paymentMethodLabel(s.paymentMethod)} · ${cancelled ? 'Cancelada' : 'Confirmada'}',
                        ),
                        trailing: cancelled
                            ? const Chip(label: Text('Cancelada'))
                            : PopupMenuButton<String>(
                                tooltip: 'Ações da venda',
                                onSelected: (_) async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Cancelar venda'),
                                      content: Text(
                                        s.trayQuantity > 0
                                            ? 'O estoque de bandejas prontas será estornado e o lançamento financeiro automático será cancelado.'
                                            : 'O estoque de ovos será estornado e o lançamento financeiro automático será cancelado.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text('Voltar'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text('Cancelar venda'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm != true) return;
                                  try {
                                    await ref
                                        .read(operationsControllerProvider)
                                        .cancelSale(s.id);
                                  } catch (e) {
                                    await showOperationError(context, e);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'cancel',
                                    child: Text('Cancelar venda'),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      );
}

class _CustomersTab extends StatelessWidget {
  const _CustomersTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(customersProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => SeletoTabList(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _CustomerDialog(ref: ref),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Novo cliente'),
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const SeletoEmptyState(
                icon: Icons.people_outline,
                title: 'Nenhum cliente',
                message:
                    'O cadastro é opcional; vendas de balcão continuam disponíveis.',
              )
            else
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = items[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(c.name.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(c.name),
                      subtitle: Text(
                        [c.phone, c.address].whereType<String>().join(' · '),
                      ),
                      trailing: Icon(
                        c.isActive ? Icons.check_circle : Icons.block,
                        color: c.isActive ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
}

class _CustomerDialog extends StatefulWidget {
  const _CustomerDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo cliente'),
    content: SizedBox(
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phone,
            decoration: const InputDecoration(labelText: 'Telefone'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: address,
            decoration: const InputDecoration(labelText: 'Endereço'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Observações'),
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
        onPressed: saving
            ? null
            : () async {
                setState(() => saving = true);
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .addCustomer(
                        name.text,
                        phone.text,
                        address.text,
                        notes.text,
                      );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                  if (mounted) setState(() => saving = false);
                }
              },
        child: const Text('Cadastrar'),
      ),
    ],
  );
}

class _PackagingItemDialog extends StatefulWidget {
  const _PackagingItemDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_PackagingItemDialog> createState() => _PackagingItemDialogState();
}

class _PackagingItemDialogState extends State<_PackagingItemDialog> {
  String type = 'TRAY';
  final name = TextEditingController();
  final notes = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    name.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo material'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem(value: 'TRAY', child: Text('Bandeja')),
              DropdownMenuItem(value: 'LABEL', child: Text('Etiqueta')),
            ],
            onChanged: (v) => setState(() => type = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Observações'),
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
        onPressed: saving
            ? null
            : () async {
                setState(() => saving = true);
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .addPackagingItem(type, name.text, notes.text);
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
            : const Text('Cadastrar'),
      ),
    ],
  );
}

class _PackagingLotDialog extends StatefulWidget {
  const _PackagingLotDialog({required this.ref, required this.items});
  final WidgetRef ref;
  final List<PackagingItemStock> items;

  @override
  State<_PackagingLotDialog> createState() => _PackagingLotDialogState();
}

class _PackagingLotDialogState extends State<_PackagingLotDialog> {
  String? itemId;
  final batchCode = TextEditingController();
  final quantity = TextEditingController();
  final unitCost = TextEditingController();
  final supplier = TextEditingController();
  final notes = TextEditingController();
  DateTime purchasedAt = DateTime.now();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    itemId = widget.items.isEmpty ? null : widget.items.first.item.id;
  }

  @override
  void dispose() {
    batchCode.dispose();
    quantity.dispose();
    unitCost.dispose();
    supplier.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo lote'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: itemId,
              decoration: const InputDecoration(labelText: 'Material'),
              items: [
                for (final item in widget.items)
                  DropdownMenuItem(
                    value: item.item.id,
                    child: Text(
                      '${item.item.name} · ${_packagingTypeLabel(item.item.type)}',
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => itemId = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitCost,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Valor unitário',
                      prefixText: 'R\$ ',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: batchCode,
              decoration: const InputDecoration(labelText: 'Código do lote'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: supplier,
              decoration: const InputDecoration(labelText: 'Fornecedor'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data de entrada'),
              subtitle: Text(shortDate.format(purchasedAt)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await pickSeletoDate(context, purchasedAt);
                if (picked != null) setState(() => purchasedAt = picked);
              },
            ),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: 'Observações'),
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
        onPressed: saving
            ? null
            : () async {
                setState(() => saving = true);
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .addPackagingLot(
                        itemId: itemId ?? '',
                        batchCode: batchCode.text,
                        quantity: int.tryParse(quantity.text) ?? 0,
                        unitCost: parseMoneyToCents(unitCost.text),
                        purchasedAt: purchasedAt,
                        supplier: supplier.text,
                        notes: notes.text,
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
            : const Text('Cadastrar lote'),
      ),
    ],
  );
}

class _TrayAssemblyDialog extends StatefulWidget {
  const _TrayAssemblyDialog({
    required this.ref,
    required this.trayLots,
    required this.labelLots,
  });
  final WidgetRef ref;
  final List<PackagingLotBalance> trayLots;
  final List<PackagingLotBalance> labelLots;

  @override
  State<_TrayAssemblyDialog> createState() => _TrayAssemblyDialogState();
}

class _TrayAssemblyDialogState extends State<_TrayAssemblyDialog> {
  String? trayLotId;
  String? labelLotId;
  final quantity = TextEditingController();
  final eggsPerTray = TextEditingController(text: '30');
  final notes = TextEditingController();
  DateTime assembledAt = DateTime.now();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final availableTrays = widget.trayLots.where((lot) => lot.balance > 0);
    final availableLabels = widget.labelLots.where((lot) => lot.balance > 0);
    trayLotId = availableTrays.isEmpty ? null : availableTrays.first.lot.id;
    labelLotId = availableLabels.isEmpty ? null : availableLabels.first.lot.id;
  }

  @override
  void dispose() {
    quantity.dispose();
    eggsPerTray.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trayLots = widget.trayLots.where((lot) => lot.balance > 0).toList();
    final labelLots = widget.labelLots.where((lot) => lot.balance > 0).toList();
    return AlertDialog(
      title: const Text('Montar bandeja'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: trayLotId,
                decoration: const InputDecoration(labelText: 'Bandeja'),
                items: [
                  for (final lot in trayLots)
                    DropdownMenuItem(
                      value: lot.lot.id,
                      child: Text(_packagingLotLabel(lot)),
                    ),
                ],
                onChanged: (v) => setState(() => trayLotId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: labelLotId,
                decoration: const InputDecoration(labelText: 'Etiqueta'),
                items: [
                  for (final lot in labelLots)
                    DropdownMenuItem(
                      value: lot.lot.id,
                      child: Text(_packagingLotLabel(lot)),
                    ),
                ],
                onChanged: (v) => setState(() => labelLotId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bandejas a montar',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: eggsPerTray,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ovos por bandeja',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data da montagem'),
                subtitle: Text(shortDate.format(assembledAt)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await pickSeletoDate(context, assembledAt);
                  if (picked != null) setState(() => assembledAt = picked);
                },
              ),
              TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'Observações'),
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
          onPressed: saving
              ? null
              : () async {
                  setState(() => saving = true);
                  try {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .assembleEggTrays(
                          trayLotId: trayLotId ?? '',
                          labelLotId: labelLotId ?? '',
                          quantity: int.tryParse(quantity.text) ?? 0,
                          eggsPerTray: int.tryParse(eggsPerTray.text) ?? 0,
                          assembledAt: assembledAt,
                          notes: notes.text,
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
              : const Text('Montar'),
        ),
      ],
    );
  }
}

class _OrderDialog extends StatefulWidget {
  const _OrderDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<_OrderDialog> {
  String? customer;
  String product = 'DOZEN';
  final quantity = TextEditingController();
  final price = TextEditingController();
  final notes = TextEditingController();
  DateTime date = DateTime.now();
  DateTime? delivery;
  bool saving = false;
  @override
  void dispose() {
    quantity.dispose();
    price.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers =
        widget.ref.watch(customersProvider).asData?.value ?? <Customer>[];
    return AlertDialog(
      title: const Text('Novo pedido'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: customer,
                decoration: const InputDecoration(
                  labelText: 'Cliente (opcional)',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Venda balcão'),
                  ),
                  for (final c in customers)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => customer = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: product,
                decoration: const InputDecoration(labelText: 'Produto'),
                items: const [
                  DropdownMenuItem(
                    value: 'DOZEN',
                    child: Text('Dúzias de ovos'),
                  ),
                  DropdownMenuItem(value: 'EGG', child: Text('Ovos avulsos')),
                  DropdownMenuItem(value: 'BIRD', child: Text('Aves')),
                ],
                onChanged: (v) => setState(() => product = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantity,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Valor unitário',
                        prefixText: 'R\$ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Entrega prevista'),
                subtitle: Text(
                  delivery == null
                      ? 'Não definida'
                      : shortDate.format(delivery!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await pickSeletoDate(context, delivery ?? date);
                  if (d != null) setState(() => delivery = d);
                },
              ),
              TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'Observações'),
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
          onPressed: saving
              ? null
              : () async {
                  setState(() => saving = true);
                  try {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .addOrder(
                          customerId: customer,
                          productType: product,
                          quantity: parseDecimal(quantity.text),
                          unitPrice: parseMoneyToCents(price.text),
                          date: date,
                          delivery: delivery,
                          notes: notes.text,
                        );
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    await showOperationError(context, e);
                    if (mounted) setState(() => saving = false);
                  }
                },
          child: const Text('Criar pedido'),
        ),
      ],
    );
  }
}

class _SaleDialog extends StatefulWidget {
  const _SaleDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<_SaleDialog> {
  String? customer;
  String? trayBatchId;
  String payment = 'DINHEIRO';
  final quantity = TextEditingController();
  final price = TextEditingController();
  final notes = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    quantity.dispose();
    price.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers =
        widget.ref.watch(customersProvider).asData?.value ?? <Customer>[];
    final batches =
        (widget.ref.watch(eggTrayBatchesProvider).asData?.value ??
                <EggTrayBatchBalance>[])
            .where((batch) => batch.balance > 0)
            .toList();
    final selectedBatchId =
        batches.any((batch) => batch.batch.id == trayBatchId)
        ? trayBatchId
        : (batches.isEmpty ? null : batches.first.batch.id);
    EggTrayBatchBalance? selectedBatch;
    for (final batch in batches) {
      if (batch.batch.id == selectedBatchId) {
        selectedBatch = batch;
        break;
      }
    }
    final trayQuantity = int.tryParse(quantity.text) ?? 0;
    final dozenPrice = parseMoneyToCents(price.text);
    final previewTotal = selectedBatch == null || trayQuantity <= 0
        ? 0
        : (trayQuantity * selectedBatch.batch.eggsPerTray * dozenPrice / 12)
              .round();
    return AlertDialog(
      title: const Text('Venda de bandejas'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: customer,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Venda balcão'),
                  ),
                  for (final c in customers)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => customer = v),
              ),
              const SizedBox(height: 12),
              if (batches.isEmpty)
                const SeletoEmptyState(
                  icon: Icons.egg_alt_outlined,
                  title: 'Sem bandejas prontas',
                  message:
                      'Monte bandejas com ovos, bandejas/embalagens e etiquetas antes de vender.',
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: selectedBatchId,
                  decoration: const InputDecoration(
                    labelText: 'Lote de bandejas prontas',
                  ),
                  items: [
                    for (final batch in batches)
                      DropdownMenuItem(
                        value: batch.batch.id,
                        child: Text(_trayBatchLabel(batch)),
                      ),
                  ],
                  onChanged: (v) => setState(() => trayBatchId = v),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: quantity,
                enabled: batches.isNotEmpty,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Quantidade de bandejas',
                  helperText: selectedBatch == null
                      ? null
                      : 'Disponível: ${selectedBatch.balance}',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: price,
                enabled: batches.isNotEmpty,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Valor da dúzia',
                  prefixText: 'R\$ ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: payment,
                decoration: const InputDecoration(labelText: 'Pagamento'),
                items: const [
                  DropdownMenuItem(value: 'DINHEIRO', child: Text('Dinheiro')),
                  DropdownMenuItem(value: 'PIX', child: Text('PIX')),
                  DropdownMenuItem(value: 'CARTÃO', child: Text('Cartão')),
                  DropdownMenuItem(value: 'PRAZO', child: Text('A prazo')),
                ],
                onChanged: (v) => setState(() => payment = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notes,
                enabled: batches.isNotEmpty,
                decoration: const InputDecoration(labelText: 'Observações'),
              ),
              if (previewTotal > 0) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Chip(label: Text('Total: ${money(previewTotal)}')),
                ),
              ],
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
          onPressed: saving || batches.isEmpty
              ? null
              : () async {
                  setState(() => saving = true);
                  try {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .sellEggTrays(
                          customerId: customer,
                          trayBatchId: selectedBatchId ?? '',
                          trayQuantity: int.tryParse(quantity.text) ?? 0,
                          dozenPrice: parseMoneyToCents(price.text),
                          payment: payment,
                          notes: notes.text,
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
              : const Text('Confirmar venda'),
        ),
      ],
    );
  }
}

String _packagingTypeLabel(String type) => switch (type) {
  'TRAY' => 'Bandeja',
  'LABEL' => 'Etiqueta',
  _ => type,
};

String _packagingLotLabel(PackagingLotBalance lot) {
  final batch = (lot.lot.batchCode ?? '').trim();
  return [
    lot.item.name,
    if (batch.isNotEmpty) 'Lote $batch',
    '${lot.balance} un.',
  ].join(' · ');
}

String _trayBatchLabel(EggTrayBatchBalance batch) {
  final eggs = batch.batch.eggsPerTray;
  final dozens = eggs ~/ 12;
  final loose = eggs % 12;
  final composition = loose == 0
      ? '$dozens dúzia(s)'
      : '$dozens dúzia(s) + $loose ovo(s)';
  return '$composition · ${batch.balance} bandeja(s)';
}
