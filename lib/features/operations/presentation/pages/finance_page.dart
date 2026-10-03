import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../application/operations_controller.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Financeiro da Granja',
    scrollable: false,
    child: DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: 'Lançamentos'),
              Tab(icon: Icon(Icons.foundation), text: 'Investimentos'),
              Tab(icon: Icon(Icons.calculate_outlined), text: 'Simulador'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                _TransactionsTab(ref: ref),
                _InvestmentsTab(ref: ref),
                _SimulatorTab(ref: ref),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PersonalFinancePage extends ConsumerWidget {
  const PersonalFinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Finanças Pessoais',
    scrollable: false,
    child: _PersonalFinanceTab(ref: ref),
  );
}

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(financeMetricsProvider).asData?.value;
    return SeletoTabList(
      children: [
        SeletoKpiGrid(
          children: [
            SeletoKpiCard(
              label: 'Faturamento',
              value: metrics == null ? '—' : money(metrics.incomeCents),
              icon: Icons.trending_up,
              color: Colors.green,
            ),
            SeletoKpiCard(
              label: 'Despesas',
              value: metrics == null ? '—' : money(metrics.expenseCents),
              icon: Icons.trending_down,
              color: Colors.red,
            ),
            SeletoKpiCard(
              label: 'Resultado',
              value: metrics == null ? '—' : money(metrics.resultCents),
              icon: Icons.account_balance_wallet_outlined,
            ),
            SeletoKpiCard(
              label: 'Margem',
              value: metrics == null ? '—' : percent(metrics.margin),
              icon: Icons.percent,
            ),
            SeletoKpiCard(
              label: 'Pró-labore',
              value: metrics == null ? '—' : money(metrics.proLaboreCents),
              icon: Icons.payments_outlined,
              color: Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _ProLaboreDialog(ref: ref),
                ),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Retirar pró-labore'),
              ),
              FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _FinanceDialog(ref: ref),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Novo lançamento'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ref
            .watch(financeProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SeletoAsyncError(),
              data: (items) => items.isEmpty
                  ? const SeletoEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Sem lançamentos',
                      message:
                          'Receitas e despesas automáticas ou manuais aparecerão aqui.',
                    )
                  : Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final f = items[i];
                          final income = f.type == 'INCOME';
                          final cancelled = f.status == 'CANCELLED';
                          final manual = f.referenceType == null;
                          final amount =
                              '${income ? '+' : '−'} ${money(f.amountCents)}';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  (income ? Colors.green : Colors.red)
                                      .withValues(alpha: .12),
                              child: Icon(
                                income ? Icons.south_west : Icons.north_east,
                                color: income ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              '${f.description} · $amount',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${f.category} · ${shortDate.format(f.occurredAt)} · ${cancelled ? 'Cancelado' : 'Confirmado'}',
                            ),
                            trailing: cancelled
                                ? const Chip(label: Text('Cancelado'))
                                : manual
                                ? PopupMenuButton<String>(
                                    tooltip: 'Ações do lançamento',
                                    onSelected: (_) async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text(
                                            'Cancelar lançamento',
                                          ),
                                          content: const Text(
                                            'O lançamento continuará no histórico como cancelado e deixará de contar no resultado.',
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
                                              child: const Text('Cancelar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) return;
                                      try {
                                        await ref
                                            .read(operationsControllerProvider)
                                            .cancelFinance(f.id);
                                      } catch (e) {
                                        await showOperationError(context, e);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'cancel',
                                        child: Text('Cancelar lançamento'),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
            ),
      ],
    );
  }
}

class _InvestmentsTab extends StatelessWidget {
  const _InvestmentsTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(investmentsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) {
          final total = items.fold<int>(0, (s, i) => s + i.amountCents);
          return SeletoTabList(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total investido: ${money(total)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _InvestmentDialog(ref: ref),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Novo investimento'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const SeletoEmptyState(
                  icon: Icons.foundation,
                  title: 'Nenhum investimento',
                  message:
                      'Cadastre estrutura, aves, equipamentos e outros investimentos.',
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return ListTile(
                        leading: const Icon(Icons.foundation),
                        title: Text(item.description),
                        subtitle: Text(
                          '${item.category} · ${shortDate.format(item.investmentDate)}',
                        ),
                        trailing: Text(
                          money(item.amountCents),
                          style: Theme.of(context).textTheme.titleMedium,
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

class _PersonalFinanceTab extends StatelessWidget {
  const _PersonalFinanceTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(personalFinanceMetricsProvider).asData?.value;
    return SeletoTabList(
      children: [
        SeletoKpiGrid(
          children: [
            SeletoKpiCard(
              label: 'Entradas pessoais',
              value: metrics == null ? '—' : money(metrics.incomeCents),
              icon: Icons.south_west,
              color: Colors.green,
            ),
            SeletoKpiCard(
              label: 'Saídas pessoais',
              value: metrics == null ? '—' : money(metrics.expenseCents),
              icon: Icons.north_east,
              color: Colors.red,
            ),
            SeletoKpiCard(
              label: 'Saldo pessoal',
              value: metrics == null ? '—' : money(metrics.balanceCents),
              icon: Icons.account_balance_wallet_outlined,
            ),
            SeletoKpiCard(
              label: 'Reserva',
              value: metrics == null
                  ? '—'
                  : '${money(metrics.reserveCents)} · ${percent(metrics.reservePercent)}',
              icon: Icons.savings_outlined,
              color: Colors.teal,
            ),
            SeletoKpiCard(
              label: 'Investimentos',
              value: metrics == null ? '—' : money(metrics.investmentCents),
              icon: Icons.trending_up,
              color: Colors.indigo,
            ),
            SeletoKpiCard(
              label: 'Dívidas abertas',
              value: metrics == null ? '—' : money(metrics.debtOpenCents),
              icon: Icons.credit_card,
              color: Colors.deepOrange,
            ),
          ],
        ),
        if ((metrics?.debtDueSoonCount ?? 0) > 0) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(
                '${metrics!.debtDueSoonCount} vencimento(s) próximo(s)',
              ),
              subtitle: const Text(
                'Há dívidas com alerta para os próximos 7 dias.',
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _EstablishmentDialog(ref: ref),
                ),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Estabelecimento'),
              ),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _ReserveDialog(ref: ref),
                ),
                icon: const Icon(Icons.savings_outlined),
                label: const Text('Reserva'),
              ),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _PersonalInvestmentDialog(ref: ref),
                ),
                icon: const Icon(Icons.trending_up),
                label: const Text('Investimento'),
              ),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _DebtDialog(ref: ref),
                ),
                icon: const Icon(Icons.credit_card),
                label: const Text('Dívida'),
              ),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _ProLaboreTransferDialog(ref: ref),
                ),
                icon: const Icon(Icons.sync_alt),
                label: const Text('Transferência'),
              ),
              FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _PersonalFinanceDialog(ref: ref),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Lançamento pessoal'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PersonalTransactions(ref: ref),
        const SizedBox(height: 12),
        _DebtList(ref: ref),
        const SizedBox(height: 12),
        _ReserveList(ref: ref),
        const SizedBox(height: 12),
        _PersonalInvestmentList(ref: ref),
        const SizedBox(height: 12),
        _EstablishmentList(ref: ref),
      ],
    );
  }
}

class _PersonalTransactions extends StatelessWidget {
  const _PersonalTransactions({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => ref
      .watch(personalFinanceProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => _SectionCard(
          title: 'Entradas e saídas pessoais',
          emptyIcon: Icons.account_balance_wallet_outlined,
          emptyTitle: 'Sem lançamentos pessoais',
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            final income = item.type == 'INCOME';
            return ListTile(
              leading: Icon(
                income ? Icons.south_west : Icons.north_east,
                color: income ? Colors.green : Colors.red,
              ),
              title: Text(item.description),
              subtitle: Text(
                '${item.category} · ${shortDate.format(item.occurredAt)}'
                '${item.paymentMethod == null ? '' : ' · ${item.paymentMethod}'}',
              ),
              trailing: Text(
                '${income ? '+' : '−'} ${money(item.amountCents)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          },
        ),
      );
}

class _DebtList extends StatelessWidget {
  const _DebtList({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => ref
      .watch(personalDebtsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) {
          final today = DateTime.now();
          return _SectionCard(
            title: 'Dívidas e vencimentos',
            emptyIcon: Icons.credit_card,
            emptyTitle: 'Nenhuma dívida cadastrada',
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              final remaining = item.totalAmountCents - item.paidAmountCents;
              final dueSoon =
                  item.status == 'OPEN' &&
                  item.alertEnabled &&
                  item.dueDate.difference(today).inDays <= 7;
              return ListTile(
                leading: Icon(
                  dueSoon ? Icons.notification_important : Icons.credit_card,
                  color: dueSoon ? Colors.deepOrange : null,
                ),
                title: Text('${item.creditor} · ${money(remaining)}'),
                subtitle: Text(
                  '${item.debtType} · vence ${shortDate.format(item.dueDate)}'
                  '${item.expectedPayoffDate == null ? '' : ' · quitação ${shortDate.format(item.expectedPayoffDate!)}'}',
                ),
                trailing: Chip(
                  label: Text(item.status == 'OPEN' ? 'Aberta' : 'Quitada'),
                ),
              );
            },
          );
        },
      );
}

class _ReserveList extends StatelessWidget {
  const _ReserveList({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => ref
      .watch(financialReservesProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => _SectionCard(
          title: 'Reserva financeira',
          emptyIcon: Icons.savings_outlined,
          emptyTitle: 'Nenhuma reserva cadastrada',
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            final progress = item.targetAmountCents == 0
                ? 0.0
                : (item.currentAmountCents / item.targetAmountCents).clamp(
                    0.0,
                    1.0,
                  );
            return ListTile(
              leading: const Icon(Icons.savings_outlined),
              title: Text(item.name),
              subtitle: LinearProgressIndicator(value: progress),
              trailing: Text(
                '${money(item.currentAmountCents)} / ${money(item.targetAmountCents)}',
              ),
            );
          },
        ),
      );
}

class _PersonalInvestmentList extends StatelessWidget {
  const _PersonalInvestmentList({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => ref
      .watch(personalInvestmentsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => _SectionCard(
          title: 'Investimentos pessoais',
          emptyIcon: Icons.trending_up,
          emptyTitle: 'Nenhum investimento pessoal',
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(item.description),
              subtitle: Text(
                '${item.category} · ${item.allocationPercent.toStringAsFixed(1)}%'
                '${item.institution == null ? '' : ' · ${item.institution}'}',
              ),
              trailing: Text(money(item.amountCents)),
            );
          },
        ),
      );
}

class _EstablishmentList extends StatelessWidget {
  const _EstablishmentList({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => ref
      .watch(financialEstablishmentsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => _SectionCard(
          title: 'Estabelecimentos cadastrados',
          emptyIcon: Icons.storefront_outlined,
          emptyTitle: 'Nenhum estabelecimento cadastrado',
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(item.name),
              subtitle: Text(
                '${item.type}${item.contact == null ? '' : ' · ${item.contact}'}',
              ),
            );
          },
        ),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.itemCount,
    required this.itemBuilder,
  });
  final String title;
  final IconData emptyIcon;
  final String emptyTitle;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (itemCount == 0)
            SeletoEmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              message: 'Os registros cadastrados aparecerão aqui.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: itemBuilder,
            ),
        ],
      ),
    ),
  );
}

class _SimulatorTab extends StatefulWidget {
  const _SimulatorTab({required this.ref});
  final WidgetRef ref;
  @override
  State<_SimulatorTab> createState() => _SimulatorTabState();
}

class _SimulatorTabState extends State<_SimulatorTab> {
  double dozensDay = 10;
  double price = 12;
  @override
  Widget build(BuildContext context) {
    final metrics = widget.ref.watch(financeMetricsProvider).asData?.value;
    final daily = dozensDay * price;
    final monthly = daily * 30;
    final annual = daily * 365;
    final costs = (metrics?.expenseCents ?? 0) / 100;
    final result = monthly - costs;
    final investment = (metrics?.investmentCents ?? 0) / 100;
    final payback = result <= 0 ? null : investment / result;
    return SeletoTabList(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulador de preço da dúzia',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Produção vendida: ${dozensDay.toStringAsFixed(1)} dúzias/dia',
                ),
                Slider(
                  value: dozensDay,
                  min: 1,
                  max: 200,
                  divisions: 199,
                  label: dozensDay.toStringAsFixed(0),
                  onChanged: (v) => setState(() => dozensDay = v),
                ),
                Text('Preço da dúzia: ${brl.format(price)}'),
                Slider(
                  value: price,
                  min: 5,
                  max: 30,
                  divisions: 50,
                  label: brl.format(price),
                  onChanged: (v) => setState(() => price = v),
                ),
                const Divider(),
                SeletoKpiGrid(
                  children: [
                    SeletoKpiCard(
                      label: 'Faturamento diário',
                      value: brl.format(daily),
                      icon: Icons.today,
                    ),
                    SeletoKpiCard(
                      label: 'Faturamento mensal',
                      value: brl.format(monthly),
                      icon: Icons.calendar_month,
                    ),
                    SeletoKpiCard(
                      label: 'Faturamento anual',
                      value: brl.format(annual),
                      icon: Icons.date_range,
                    ),
                    SeletoKpiCard(
                      label: 'Resultado estimado/mês',
                      value: brl.format(result),
                      icon: Icons.insights,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  payback == null
                      ? 'Sem retorno com os parâmetros atuais.'
                      : 'Retorno do investimento estimado: ${payback.toStringAsFixed(1)} meses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: payback == null ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FinanceDialog extends StatefulWidget {
  const _FinanceDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_FinanceDialog> createState() => _FinanceDialogState();
}

class _FinanceDialogState extends State<_FinanceDialog> {
  String type = 'EXPENSE';
  String category = 'Outros';
  final description = TextEditingController();
  final amount = TextEditingController();
  final notes = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    description.dispose();
    amount.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo lançamento'),
    content: SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'INCOME', label: Text('Receita')),
              ButtonSegment(value: 'EXPENSE', label: Text('Despesa')),
            ],
            selected: {type},
            onSelectionChanged: (v) => setState(() => type = v.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [
              for (final c
                  in type == 'INCOME'
                      ? ['Venda de ovos', 'Venda de aves', 'Outras']
                      : [
                          'Ração',
                          'Insumos',
                          'Aves',
                          'Embalagem',
                          'Energia',
                          'Água',
                          'Medicamentos',
                          'Vacinas',
                          'Estrutura',
                          'Equipamentos',
                          'Manutenção',
                          'Outros',
                        ])
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => category = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: description,
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor',
              prefixText: 'R\$ ',
            ),
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
                      .addFinance(
                        type: type,
                        category: category,
                        description: description.text,
                        amount: parseMoneyToCents(amount.text),
                        notes: notes.text,
                      );
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

class _ProLaboreDialog extends StatefulWidget {
  const _ProLaboreDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_ProLaboreDialog> createState() => _ProLaboreDialogState();
}

class _ProLaboreDialogState extends State<_ProLaboreDialog> {
  final description = TextEditingController(text: 'Retirada de pró-labore');
  final amount = TextEditingController();
  final payment = TextEditingController();
  final notes = TextEditingController();

  @override
  void dispose() {
    description.dispose();
    amount.dispose();
    payment.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Retirar pró-labore'),
    content: _DialogFields(
      children: [
        TextField(
          controller: description,
          decoration: const InputDecoration(labelText: 'Descrição'),
        ),
        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor',
            prefixText: 'R\$ ',
          ),
        ),
        TextField(
          controller: payment,
          decoration: const InputDecoration(
            labelText: 'Onde/forma de pagamento',
          ),
        ),
        TextField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () async {
          try {
            await widget.ref
                .read(operationsControllerProvider)
                .addProLabore(
                  description: description.text,
                  amount: parseMoneyToCents(amount.text),
                  payment: payment.text,
                  notes: notes.text,
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            await showOperationError(context, e);
          }
        },
        child: const Text('Registrar'),
      ),
    ],
  );
}

class _PersonalFinanceDialog extends StatefulWidget {
  const _PersonalFinanceDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_PersonalFinanceDialog> createState() => _PersonalFinanceDialogState();
}

class _PersonalFinanceDialogState extends State<_PersonalFinanceDialog> {
  String type = 'EXPENSE';
  String category = 'Cartão';
  String? establishmentId;
  final description = TextEditingController();
  final amount = TextEditingController();
  final payment = TextEditingController();
  final notes = TextEditingController();

  @override
  void dispose() {
    description.dispose();
    amount.dispose();
    payment.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final establishments =
        widget.ref.watch(financialEstablishmentsProvider).asData?.value ?? [];
    final categories = type == 'INCOME'
        ? ['Pró-labore', 'Renda extra', 'Reembolso', 'Outras']
        : [
            'Cartão',
            'Mercado',
            'Casa',
            'Transporte',
            'Saúde',
            'Lazer',
            'Outras',
          ];
    if (!categories.contains(category)) category = categories.first;
    return AlertDialog(
      title: const Text('Lançamento pessoal'),
      content: _DialogFields(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'INCOME', label: Text('Entrada')),
              ButtonSegment(value: 'EXPENSE', label: Text('Saída')),
            ],
            selected: {type},
            onSelectionChanged: (v) => setState(() => type = v.first),
          ),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [
              for (final c in categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => category = v!),
          ),
          DropdownButtonFormField<String?>(
            initialValue: establishmentId,
            decoration: const InputDecoration(labelText: 'Onde'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Não informado')),
              for (final e in establishments)
                DropdownMenuItem(value: e.id, child: Text(e.name)),
            ],
            onChanged: (v) => setState(() => establishmentId = v),
          ),
          TextField(
            controller: description,
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor',
              prefixText: 'R\$ ',
            ),
          ),
          TextField(
            controller: payment,
            decoration: const InputDecoration(labelText: 'Cartão/conta/forma'),
          ),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Observações'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await widget.ref
                  .read(operationsControllerProvider)
                  .addPersonalFinance(
                    type: type,
                    category: category,
                    description: description.text,
                    amount: parseMoneyToCents(amount.text),
                    establishmentId: establishmentId,
                    payment: payment.text,
                    notes: notes.text,
                  );
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              await showOperationError(context, e);
            }
          },
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}

class _ProLaboreTransferDialog extends StatefulWidget {
  const _ProLaboreTransferDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_ProLaboreTransferDialog> createState() =>
      _ProLaboreTransferDialogState();
}

class _ProLaboreTransferDialogState extends State<_ProLaboreTransferDialog> {
  final beneficiary = TextEditingController();
  final amount = TextEditingController();
  final origin = TextEditingController();
  final destination = TextEditingController();
  final notes = TextEditingController();

  @override
  void dispose() {
    beneficiary.dispose();
    amount.dispose();
    origin.dispose();
    destination.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Transferência de pró-labore'),
    content: _DialogFields(
      children: [
        TextField(
          controller: beneficiary,
          decoration: const InputDecoration(labelText: 'Favorecido/sócio'),
        ),
        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor',
            prefixText: 'R\$ ',
          ),
        ),
        TextField(
          controller: origin,
          decoration: const InputDecoration(
            labelText: 'Conta/cartão de origem',
          ),
        ),
        TextField(
          controller: destination,
          decoration: const InputDecoration(labelText: 'Destino'),
        ),
        TextField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () async {
          try {
            final name = beneficiary.text.trim();
            await widget.ref
                .read(operationsControllerProvider)
                .addPersonalFinance(
                  type: 'EXPENSE',
                  category: 'Transferência de pró-labore',
                  description: name.isEmpty
                      ? 'Transferência de pró-labore'
                      : 'Transferência de pró-labore para $name',
                  amount: parseMoneyToCents(amount.text),
                  payment: origin.text,
                  notes: [
                    if (destination.text.trim().isNotEmpty)
                      'Destino: ${destination.text.trim()}',
                    if (notes.text.trim().isNotEmpty) notes.text.trim(),
                  ].join(' · '),
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            await showOperationError(context, e);
          }
        },
        child: const Text('Registrar'),
      ),
    ],
  );
}

class _InvestmentDialog extends StatefulWidget {
  const _InvestmentDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_InvestmentDialog> createState() => _InvestmentDialogState();
}

class _InvestmentDialogState extends State<_InvestmentDialog> {
  String category = 'Estrutura';
  String? lot;
  final description = TextEditingController();
  final amount = TextEditingController();
  @override
  void dispose() {
    description.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots = widget.ref.watch(lotSummariesProvider).asData?.value ?? [];
    return AlertDialog(
      title: const Text('Novo investimento'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                for (final c in ['Estrutura', 'Aves', 'Equipamentos', 'Outros'])
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: lot,
              decoration: const InputDecoration(labelText: 'Lote (opcional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Nenhum')),
                for (final l in lots)
                  DropdownMenuItem(value: l.lot.id, child: Text(l.lot.name)),
              ],
              onChanged: (v) => setState(() => lot = v),
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
              await widget.ref
                  .read(operationsControllerProvider)
                  .addInvestment(
                    description.text,
                    category,
                    parseMoneyToCents(amount.text),
                    lot,
                  );
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              await showOperationError(context, e);
            }
          },
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}

class _EstablishmentDialog extends StatefulWidget {
  const _EstablishmentDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_EstablishmentDialog> createState() => _EstablishmentDialogState();
}

class _EstablishmentDialogState extends State<_EstablishmentDialog> {
  String type = 'Cartão';
  final name = TextEditingController();
  final contact = TextEditingController();
  final notes = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    contact.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo estabelecimento'),
    content: _DialogFields(
      children: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: const InputDecoration(labelText: 'Tipo'),
          items: [
            for (final c in ['Cartão', 'Banco', 'Fornecedor', 'Loja', 'Outro'])
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => setState(() => type = v!),
        ),
        TextField(
          controller: contact,
          decoration: const InputDecoration(labelText: 'Contato/identificação'),
        ),
        TextField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () async {
          try {
            await widget.ref
                .read(operationsControllerProvider)
                .addFinancialEstablishment(
                  name: name.text,
                  type: type,
                  contact: contact.text,
                  notes: notes.text,
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            await showOperationError(context, e);
          }
        },
        child: const Text('Cadastrar'),
      ),
    ],
  );
}

class _ReserveDialog extends StatefulWidget {
  const _ReserveDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_ReserveDialog> createState() => _ReserveDialogState();
}

class _ReserveDialogState extends State<_ReserveDialog> {
  final name = TextEditingController(text: 'Reserva de emergência');
  final target = TextEditingController();
  final current = TextEditingController();
  final account = TextEditingController();
  final notes = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    target.dispose();
    current.dispose();
    account.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Reserva financeira'),
    content: _DialogFields(
      children: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        TextField(
          controller: target,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Meta',
            prefixText: 'R\$ ',
          ),
        ),
        TextField(
          controller: current,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor atual',
            prefixText: 'R\$ ',
          ),
        ),
        TextField(
          controller: account,
          decoration: const InputDecoration(labelText: 'Onde está'),
        ),
        TextField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () async {
          try {
            await widget.ref
                .read(operationsControllerProvider)
                .addFinancialReserve(
                  name: name.text,
                  targetAmount: parseMoneyToCents(target.text),
                  currentAmount: parseMoneyToCents(current.text),
                  account: account.text,
                  notes: notes.text,
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            await showOperationError(context, e);
          }
        },
        child: const Text('Salvar'),
      ),
    ],
  );
}

class _PersonalInvestmentDialog extends StatefulWidget {
  const _PersonalInvestmentDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_PersonalInvestmentDialog> createState() =>
      _PersonalInvestmentDialogState();
}

class _PersonalInvestmentDialogState extends State<_PersonalInvestmentDialog> {
  String category = 'Renda fixa';
  final description = TextEditingController();
  final amount = TextEditingController();
  final allocation = TextEditingController();
  final institution = TextEditingController();
  final notes = TextEditingController();
  @override
  void dispose() {
    description.dispose();
    amount.dispose();
    allocation.dispose();
    institution.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Investimento pessoal'),
    content: _DialogFields(
      children: [
        DropdownButtonFormField<String>(
          initialValue: category,
          decoration: const InputDecoration(labelText: 'Categoria'),
          items: [
            for (final c in [
              'Renda fixa',
              'Tesouro',
              'Fundos',
              'Ações',
              'Cripto',
              'Outros',
            ])
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => setState(() => category = v!),
        ),
        TextField(
          controller: description,
          decoration: const InputDecoration(labelText: 'Descrição'),
        ),
        TextField(
          controller: institution,
          decoration: const InputDecoration(labelText: 'Instituição'),
        ),
        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor',
            prefixText: 'R\$ ',
          ),
        ),
        TextField(
          controller: allocation,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Porcentagem da carteira',
            suffixText: '%',
          ),
        ),
        TextField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () async {
          try {
            await widget.ref
                .read(operationsControllerProvider)
                .addPersonalInvestment(
                  description: description.text,
                  category: category,
                  amount: parseMoneyToCents(amount.text),
                  allocationPercent:
                      double.tryParse(allocation.text.replaceAll(',', '.')) ??
                      0,
                  institution: institution.text,
                  notes: notes.text,
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            await showOperationError(context, e);
          }
        },
        child: const Text('Salvar'),
      ),
    ],
  );
}

class _DebtDialog extends StatefulWidget {
  const _DebtDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_DebtDialog> createState() => _DebtDialogState();
}

class _DebtDialogState extends State<_DebtDialog> {
  String debtType = 'Cartão';
  DateTime dueDate = DateTime.now();
  DateTime? payoffDate;
  bool alertEnabled = true;
  final creditor = TextEditingController();
  final total = TextEditingController();
  final paid = TextEditingController();
  final installment = TextEditingController();
  final notes = TextEditingController();
  @override
  void dispose() {
    creditor.dispose();
    total.dispose();
    paid.dispose();
    installment.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => dueDate = picked);
  }

  Future<void> _pickPayoffDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: payoffDate ?? dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => payoffDate = picked);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nova dívida'),
    content: _DialogFields(
      children: [
        TextField(
          controller: creditor,
          decoration: const InputDecoration(labelText: 'Onde/credor'),
        ),
        DropdownButtonFormField<String>(
          initialValue: debtType,
          decoration: const InputDecoration(labelText: 'Tipo'),
          items: [
            for (final c in [
              'Cartão',
              'Empréstimo',
              'Financiamento',
              'Fornecedor',
              'Outro',
            ])
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => setState(() => debtType = v!),
        ),
        TextField(
          controller: total,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor total',
            prefixText: 'R\$ ',
          ),
        ),
        TextField(
          controller: paid,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor já pago',
            prefixText: 'R\$ ',
          ),
        ),
        TextField(
          controller: installment,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Parcela',
            prefixText: 'R\$ ',
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: const Text('Vencimento'),
          subtitle: Text(shortDate.format(dueDate)),
          onTap: _pickDueDate,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_available_outlined),
          title: const Text('Previsão de quitação'),
          subtitle: Text(
            payoffDate == null ? 'Não definida' : shortDate.format(payoffDate!),
          ),
          onTap: _pickPayoffDate,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: alertEnabled,
          title: const Text('Alerta de vencimento'),
          onChanged: (v) => setState(() => alertEnabled = v),
        ),
        TextField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () async {
          try {
            final installmentCents = installment.text.trim().isEmpty
                ? null
                : parseMoneyToCents(installment.text);
            await widget.ref
                .read(operationsControllerProvider)
                .addPersonalDebt(
                  creditor: creditor.text,
                  debtType: debtType,
                  totalAmount: parseMoneyToCents(total.text),
                  paidAmount: paid.text.trim().isEmpty
                      ? 0
                      : parseMoneyToCents(paid.text),
                  installmentAmount: installmentCents,
                  dueDate: dueDate,
                  expectedPayoffDate: payoffDate,
                  alertEnabled: alertEnabled,
                  notes: notes.text,
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            await showOperationError(context, e);
          }
        },
        child: const Text('Salvar'),
      ),
    ],
  );
}

class _DialogFields extends StatelessWidget {
  const _DialogFields({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 460,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final child in children) ...[child, const SizedBox(height: 12)],
        ],
      ),
    ),
  );
}
