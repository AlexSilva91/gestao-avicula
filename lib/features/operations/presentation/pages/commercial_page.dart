import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
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
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Pedidos'),
              Tab(icon: Icon(Icons.point_of_sale_outlined), text: 'Vendas'),
              Tab(icon: Icon(Icons.people_outline), text: 'Clientes'),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: TabBarView(
              children: [
                _OrdersTab(ref: ref),
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
                          '${s.dozens} dúzias + ${s.looseEggs} ovos · ${money(s.totalCents)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${shortDate.format(s.soldAt)} · ${s.paymentMethod} · ${cancelled ? 'Cancelada' : 'Confirmada'}',
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
                                      content: const Text(
                                        'O estoque de ovos será estornado e o lançamento financeiro automático será cancelado.',
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
  String payment = 'DINHEIRO';
  final dozens = TextEditingController();
  final loose = TextEditingController(text: '0');
  final price = TextEditingController();
  final notes = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    dozens.dispose();
    loose.dispose();
    price.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers =
        widget.ref.watch(customersProvider).asData?.value ?? <Customer>[];
    return AlertDialog(
      title: const Text('Venda de ovos'),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dozens,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Dúzias'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: loose,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ovos avulsos',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                        .sellEggs(
                          customerId: customer,
                          dozens: int.tryParse(dozens.text) ?? 0,
                          loose: int.tryParse(loose.text) ?? 0,
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
