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
    title: 'Financeiro',
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
          const SizedBox(height: 18),
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
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _FinanceDialog(ref: ref),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Novo lançamento'),
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
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulador de preço da dúzia',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
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
                      : 'Payback estimado: ${payback.toStringAsFixed(1)} meses',
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
