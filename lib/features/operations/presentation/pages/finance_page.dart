import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../lots/application/lots_controller.dart';
import '../../application/operations_controller.dart';

const _businessIncomeCategories = [
  'Venda de ovos',
  'Venda de aves',
  'Serviços',
  'Rendimentos',
  'Reembolso',
  'Bonificação',
  'Outras receitas',
];

const _businessExpenseCategories = [
  'Fatura de cartão',
  'Boleto',
  'Compra parcelada',
  'Mensalidade de serviço',
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
  'Impostos e taxas',
  'Folha/pró-labore',
  'Frete',
  'Outras despesas',
];

const _personalIncomeCategories = [
  'Salário',
  'Pró-labore',
  'Rendimentos',
  'Renda extra',
  'Aluguel recebido',
  'Reembolso',
  'Presente/doação',
  'Outras entradas',
];

const _personalExpenseCategories = [
  'Fatura de cartão',
  'Boleto',
  'Compra parcelada',
  'Mensalidade de serviço',
  'Faculdade/curso',
  'Moradia',
  'Mercado',
  'Transporte',
  'Saúde',
  'Lazer',
  'Educação',
  'Impostos e taxas',
  'Empréstimos',
  'Outras saídas',
];

bool _allows(WidgetRef ref, String permission) =>
    ref.read(authControllerProvider).allows(permission);

bool _canCreateBusinessFinance(WidgetRef ref) =>
    _allows(ref, 'finance.business.create');

bool _canUpdateBusinessFinance(WidgetRef ref) =>
    _allows(ref, 'finance.business.update');

bool _canCreatePersonalFinance(WidgetRef ref) =>
    _allows(ref, 'finance.personal.create');

bool _canUpdatePersonalFinance(WidgetRef ref) =>
    _allows(ref, 'finance.personal.update');

bool _canCreateProLabore(WidgetRef ref) =>
    _canCreateBusinessFinance(ref) && _canCreatePersonalFinance(ref);

Future<void> importPayablesFile(
  BuildContext context, {
  required WidgetRef ref,
  required bool personal,
}) async {
  try {
    final allowed = personal
        ? _canCreatePersonalFinance(ref)
        : _canCreateBusinessFinance(ref);
    if (!allowed) {
      throw StateError(
        'Você não tem permissão para importar contas deste módulo financeiro.',
      );
    }
    final picked = await FilePicker.pickFile(
      dialogTitle: personal
          ? 'Importar contas a pagar pessoais'
          : 'Importar contas a pagar da granja',
      type: FileType.custom,
      allowedExtensions: ['csv', 'xml', 'xlsx', 'xls', 'xlsl'],
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final controller = ref.read(operationsControllerProvider);
    final count = personal
        ? await controller.importPersonalFinancePayables(
            filename: picked.name,
            bytes: bytes,
          )
        : await controller.importFinancePayables(
            filename: picked.name,
            bytes: bytes,
          );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count conta(s) a pagar importada(s).')),
    );
  } catch (e) {
    if (context.mounted) await showOperationError(context, e);
  }
}

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Financeiro da Granja',
    scrollable: false,
    child: DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Resumo'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Lançamentos'),
              Tab(icon: Icon(Icons.event_available_outlined), text: 'Contas'),
              Tab(icon: Icon(Icons.foundation), text: 'Investimentos'),
              Tab(icon: Icon(Icons.calculate_outlined), text: 'Simulador'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                _BusinessOverviewTab(ref: ref),
                _TransactionsTab(ref: ref),
                _BusinessPayablesTab(ref: ref),
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
    child: DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Resumo'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Lançamentos'),
              Tab(icon: Icon(Icons.event_available_outlined), text: 'Contas'),
              Tab(icon: Icon(Icons.savings_outlined), text: 'Patrimônio'),
              Tab(icon: Icon(Icons.tune), text: 'Cadastros'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                _PersonalOverviewTab(ref: ref),
                _PersonalTransactionsTab(ref: ref),
                _PersonalPayablesTab(ref: ref),
                _PersonalAssetsTab(ref: ref),
                _PersonalRecordsTab(ref: ref),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _BusinessOverviewTab extends StatelessWidget {
  const _BusinessOverviewTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(financeMetricsProvider).asData?.value;
    final payoff = metrics == null
        ? null
        : _PayoffForecast.from(
            debtCents: metrics.openPayablesCents,
            currentMonthCapacityCents: metrics.currentMonthResultCents,
            nextMonthCapacityCents: metrics.nextMonthResultCents,
            lastDueDate: metrics.lastOpenPayableDueDate,
          );
    return SeletoTabList(
      children: [
        SeletoKpiGrid(
          forceTwoColumns: true,
          children: [
            SeletoKpiCard(
              label: 'Resultado geral',
              value: metrics == null ? '—' : money(metrics.resultCents),
              icon: Icons.account_balance_wallet_outlined,
            ),
            SeletoKpiCard(
              label: 'Resultado mês atual',
              value: metrics == null
                  ? '—'
                  : money(metrics.currentMonthResultCents),
              icon: Icons.calendar_month_outlined,
              color: Colors.blue,
            ),
            SeletoKpiCard(
              label: 'Resultado próximo mês',
              value: metrics == null
                  ? '—'
                  : money(metrics.nextMonthResultCents),
              icon: Icons.next_plan_outlined,
              color: Colors.indigo,
            ),
            SeletoKpiCard(
              label: 'Contas abertas total',
              value: metrics == null ? '—' : money(metrics.openPayablesCents),
              icon: Icons.credit_card,
              color: Colors.deepOrange,
            ),
            SeletoKpiCard(
              label: 'Previsão de quitação',
              value: payoff?.headline ?? '—',
              icon: Icons.flag_circle_outlined,
              color: Colors.teal,
            ),
            SeletoKpiCard(
              label: 'Contas abertas mês atual',
              value: metrics == null
                  ? '—'
                  : money(metrics.currentMonthOpenPayablesCents),
              icon: Icons.event_available_outlined,
              color: Colors.orange,
            ),
            SeletoKpiCard(
              label: 'Contas abertas próximo mês',
              value: metrics == null
                  ? '—'
                  : money(metrics.nextMonthOpenPayablesCents),
              icon: Icons.event_repeat_outlined,
              color: Colors.deepPurple,
            ),
          ],
        ),
        if (payoff != null) ...[
          const SizedBox(height: 12),
          _PayoffForecastStrip(forecast: payoff),
        ],
      ],
    );
  }
}

class _PayoffForecast {
  const _PayoffForecast({
    required this.debtCents,
    required this.monthlyCapacityCents,
    required this.capacitySource,
    required this.lastDueDate,
    required this.monthsByCapacity,
    required this.capacityPayoffDate,
  });

  factory _PayoffForecast.from({
    required int debtCents,
    required int currentMonthCapacityCents,
    required int nextMonthCapacityCents,
    required DateTime? lastDueDate,
  }) {
    final monthlyCapacityCents = currentMonthCapacityCents > 0
        ? currentMonthCapacityCents
        : nextMonthCapacityCents > 0
        ? nextMonthCapacityCents
        : 0;
    final capacitySource = currentMonthCapacityCents > 0
        ? 'saldo do mês atual'
        : nextMonthCapacityCents > 0
        ? 'saldo do próximo mês'
        : 'sem saldo mensal positivo';
    final monthsByCapacity = debtCents <= 0 || monthlyCapacityCents <= 0
        ? null
        : (debtCents / monthlyCapacityCents).ceil();
    final now = DateTime.now();
    final capacityPayoffDate = monthsByCapacity == null
        ? null
        : DateTime(now.year, now.month + monthsByCapacity, now.day);
    return _PayoffForecast(
      debtCents: debtCents,
      monthlyCapacityCents: monthlyCapacityCents,
      capacitySource: capacitySource,
      lastDueDate: lastDueDate,
      monthsByCapacity: monthsByCapacity,
      capacityPayoffDate: capacityPayoffDate,
    );
  }

  final int debtCents;
  final int monthlyCapacityCents;
  final String capacitySource;
  final DateTime? lastDueDate;
  final int? monthsByCapacity;
  final DateTime? capacityPayoffDate;

  String get headline {
    if (debtCents <= 0) return 'Quitado';
    if (lastDueDate != null) return shortDate.format(lastDueDate!);
    if (monthsByCapacity != null) return _monthsLabel(monthsByCapacity!);
    return 'Sem previsão';
  }

  String get details {
    if (debtCents <= 0) {
      return 'Não há contas ou dívidas abertas para quitar.';
    }
    final parts = <String>[];
    if (lastDueDate != null) {
      parts.add(
        'Pelo calendário das contas abertas, a última quitação prevista é ${shortDate.format(lastDueDate!)}.',
      );
    }
    if (monthsByCapacity != null && capacityPayoffDate != null) {
      parts.add(
        'Pela sobra de ${money(monthlyCapacityCents)} baseada no $capacitySource, a estimativa é ${_monthsLabel(monthsByCapacity!)} (${shortDate.format(capacityPayoffDate!)}).',
      );
    } else {
      parts.add(
        'Cadastre entradas e despesas confirmadas do mês para calcular a estimativa por sobra mensal.',
      );
    }
    return parts.join(' ');
  }
}

class _PayoffForecastStrip extends StatelessWidget {
  const _PayoffForecastStrip({required this.forecast});

  final _PayoffForecast forecast;

  @override
  Widget build(BuildContext context) => SeletoInfoStrip(
    icon: Icons.event_available_outlined,
    text: forecast.details,
  );
}

String _monthsLabel(int months) => months == 1 ? '1 mês' : '$months meses';

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(financeMetricsProvider).asData?.value;
    final canCreate = _canCreateBusinessFinance(ref);
    final canCreateProLabore = _canCreateProLabore(ref);
    return SeletoTabList(
      children: [
        SeletoKpiGrid(
          forceTwoColumns: true,
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
        if (canCreate || canCreateProLabore) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canCreateProLabore)
                  OutlinedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _ProLaboreDialog(ref: ref),
                    ),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Retirar pró-labore'),
                  ),
                if (canCreate)
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _FinanceDialog(ref: ref),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Novo lançamento'),
                  ),
                if (canCreate)
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) =>
                          _FinanceDialog(ref: ref, accountsPayable: true),
                    ),
                    icon: const Icon(Icons.event_available_outlined),
                    label: const Text('Conta a pagar'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
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
                          return _BusinessFinanceTile(item: items[i], ref: ref);
                        },
                      ),
                    ),
            ),
      ],
    );
  }
}

class _BusinessFinanceTile extends StatelessWidget {
  const _BusinessFinanceTile({required this.item, required this.ref});
  final FinanceTransaction item;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final income = item.type == 'INCOME';
    final cancelled = item.status == 'CANCELLED';
    final pending = item.status == 'PENDING';
    final manual = item.referenceType == null;
    final canUpdate = _canUpdateBusinessFinance(ref);
    final amount = '${income ? '+' : '−'} ${money(item.amountCents)}';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (income ? Colors.green : Colors.red).withValues(
          alpha: .12,
        ),
        child: Icon(
          income ? Icons.south_west : Icons.north_east,
          color: income ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        '${item.description} · $amount',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${item.category} · ${shortDate.format(item.occurredAt)} · ${_financeStatusLabel(item.status)}'
        '${item.dueDate == null ? '' : ' · vence ${shortDate.format(item.dueDate!)}'}'
        '${item.paymentMethod == null ? '' : ' · ${item.paymentMethod}'}',
      ),
      trailing: cancelled
          ? const Chip(label: Text('Cancelado'))
          : !manual || !canUpdate
          ? Text(amount, style: Theme.of(context).textTheme.titleMedium)
          : PopupMenuButton<String>(
              tooltip: 'Ações do lançamento',
              onSelected: (action) async {
                if (action == 'pay') {
                  await showDialog<void>(
                    context: context,
                    builder: (_) => _PaymentDialog(
                      title: 'Efetuar pagamento',
                      onPay: (payment, notes) => ref
                          .read(operationsControllerProvider)
                          .payFinance(
                            id: item.id,
                            payment: payment,
                            notes: notes,
                          ),
                    ),
                  );
                  return;
                }
                if (action == 'edit') {
                  await showDialog<void>(
                    context: context,
                    builder: (_) => _FinanceDialog(ref: ref, editing: item),
                  );
                  return;
                }
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Cancelar lançamento'),
                    content: const Text(
                      'O lançamento continuará no histórico como cancelado e deixará de contar no resultado.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Voltar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                try {
                  await ref
                      .read(operationsControllerProvider)
                      .cancelFinance(item.id);
                } catch (e) {
                  await showOperationError(context, e);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Editar lançamento'),
                ),
                if (pending)
                  const PopupMenuItem(
                    value: 'pay',
                    child: Text('Efetuar pagamento'),
                  ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancelar lançamento'),
                ),
              ],
            ),
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
          final canCreate = _canCreateBusinessFinance(ref);
          return SeletoTabList(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total investido: ${money(total)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (canCreate)
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

class _BusinessPayablesTab extends StatelessWidget {
  const _BusinessPayablesTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final canCreate = _canCreateBusinessFinance(ref);
    return SeletoTabList(
      children: [
        if (canCreate) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _importPayables(context, personal: false),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Importar'),
                ),
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) =>
                        _FinanceDialog(ref: ref, accountsPayable: true),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova conta'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        ref
            .watch(financeProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SeletoAsyncError(),
              data: (items) {
                final pending = items
                    .where((item) => item.status == 'PENDING')
                    .toList();
                return _SectionCard(
                  title: 'Contas a pagar da granja',
                  emptyIcon: Icons.event_available_outlined,
                  emptyTitle: 'Nenhuma conta pendente',
                  itemCount: pending.length,
                  itemBuilder: (_, i) =>
                      _BusinessFinanceTile(item: pending[i], ref: ref),
                );
              },
            ),
      ],
    );
  }

  Future<void> _importPayables(
    BuildContext context, {
    required bool personal,
  }) async {
    await importPayablesFile(context, ref: ref, personal: personal);
  }
}

class _PersonalOverviewTab extends StatelessWidget {
  const _PersonalOverviewTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(personalFinanceMetricsProvider).asData?.value;
    final payoff = metrics == null
        ? null
        : _PayoffForecast.from(
            debtCents: metrics.debtOpenCents,
            currentMonthCapacityCents: metrics.currentMonthBalanceCents,
            nextMonthCapacityCents: metrics.nextMonthBalanceCents,
            lastDueDate: metrics.lastDebtDueDate,
          );
    return SeletoTabList(
      children: [
        SeletoKpiGrid(
          forceTwoColumns: true,
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
              label: 'Dívidas abertas total',
              value: metrics == null ? '—' : money(metrics.debtOpenCents),
              icon: Icons.credit_card,
              color: Colors.deepOrange,
            ),
            SeletoKpiCard(
              label: 'Previsão de quitação',
              value: payoff?.headline ?? '—',
              icon: Icons.flag_circle_outlined,
              color: Colors.teal,
            ),
            SeletoKpiCard(
              label: 'Dívidas mês atual',
              value: metrics == null
                  ? '—'
                  : money(metrics.currentMonthDebtOpenCents),
              icon: Icons.calendar_month_outlined,
              color: Colors.orange,
            ),
            SeletoKpiCard(
              label: 'Dívidas próximo mês',
              value: metrics == null
                  ? '—'
                  : money(metrics.nextMonthDebtOpenCents),
              icon: Icons.event_repeat_outlined,
              color: Colors.deepPurple,
            ),
            SeletoKpiCard(
              label: 'Saldo mês atual',
              value: metrics == null
                  ? '—'
                  : money(metrics.currentMonthBalanceCents),
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.blue,
            ),
            SeletoKpiCard(
              label: 'Saldo próximo mês',
              value: metrics == null
                  ? '—'
                  : money(metrics.nextMonthBalanceCents),
              icon: Icons.next_plan_outlined,
              color: Colors.indigo,
            ),
          ],
        ),
        if (payoff != null) ...[
          const SizedBox(height: 12),
          _PayoffForecastStrip(forecast: payoff),
        ],
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
        _PersonalActionGrid(ref: ref),
      ],
    );
  }
}

class _PersonalActionGrid extends StatelessWidget {
  const _PersonalActionGrid({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (!_canCreatePersonalFinance(ref)) return const SizedBox.shrink();
    return SeletoCompactGrid(
      minTileHeight: 72,
      spacing: 8,
      children: [
        _ActionCard(
          icon: Icons.add,
          title: 'Lançamento',
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => _PersonalFinanceDialog(ref: ref),
          ),
        ),
        _ActionCard(
          icon: Icons.event_available_outlined,
          title: 'Conta a pagar',
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) =>
                _PersonalFinanceDialog(ref: ref, accountsPayable: true),
          ),
        ),
        _ActionCard(
          icon: Icons.savings_outlined,
          title: 'Reserva',
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => _ReserveDialog(ref: ref),
          ),
        ),
        _ActionCard(
          icon: Icons.trending_up,
          title: 'Investimento',
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => _PersonalInvestmentDialog(ref: ref),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PersonalTransactionsTab extends StatelessWidget {
  const _PersonalTransactionsTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final canCreate = _canCreatePersonalFinance(ref);
    final canTransfer = _canCreateProLabore(ref);
    return SeletoTabList(
      children: [
        if (canCreate || canTransfer) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canTransfer)
                  OutlinedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _ProLaboreTransferDialog(ref: ref),
                    ),
                    icon: const Icon(Icons.sync_alt),
                    label: const Text('Transferência'),
                  ),
                if (canCreate)
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _PersonalFinanceDialog(ref: ref),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Novo lançamento'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _PersonalTransactions(ref: ref, hidePending: true),
      ],
    );
  }
}

class _PersonalPayablesTab extends StatelessWidget {
  const _PersonalPayablesTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final canCreate = _canCreatePersonalFinance(ref);
    return SeletoTabList(
      children: [
        if (canCreate) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      importPayablesFile(context, ref: ref, personal: true),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Importar'),
                ),
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) =>
                        _PersonalFinanceDialog(ref: ref, accountsPayable: true),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova conta'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _PersonalTransactions(
          ref: ref,
          pendingOnly: true,
          title: 'Contas a pagar pessoais',
          emptyTitle: 'Nenhuma conta pendente',
        ),
      ],
    );
  }
}

class _PersonalAssetsTab extends StatelessWidget {
  const _PersonalAssetsTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final canCreate = _canCreatePersonalFinance(ref);
    return SeletoTabList(
      children: [
        if (canCreate) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _ReserveDialog(ref: ref),
                  ),
                  icon: const Icon(Icons.savings_outlined),
                  label: const Text('Reserva'),
                ),
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _PersonalInvestmentDialog(ref: ref),
                  ),
                  icon: const Icon(Icons.trending_up),
                  label: const Text('Investimento'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _ReserveList(ref: ref),
        const SizedBox(height: 12),
        _PersonalInvestmentList(ref: ref),
      ],
    );
  }
}

class _PersonalRecordsTab extends StatelessWidget {
  const _PersonalRecordsTab({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final canCreate = _canCreatePersonalFinance(ref);
    return SeletoTabList(
      children: [
        if (canCreate) ...[
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
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _DebtDialog(ref: ref),
                  ),
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Dívida'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _DebtList(ref: ref),
        const SizedBox(height: 12),
        _EstablishmentList(ref: ref),
      ],
    );
  }
}

class _PersonalTransactions extends StatelessWidget {
  const _PersonalTransactions({
    required this.ref,
    this.pendingOnly = false,
    this.hidePending = false,
    this.title = 'Entradas e saídas pessoais',
    this.emptyTitle = 'Sem lançamentos pessoais',
  });
  final WidgetRef ref;
  final bool pendingOnly;
  final bool hidePending;
  final String title;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) => ref
      .watch(personalFinanceProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) {
          final canUpdate = _canUpdatePersonalFinance(ref);
          final visible = items.where((item) {
            if (pendingOnly) return item.status == 'PENDING';
            if (hidePending) return item.status != 'PENDING';
            return true;
          }).toList();
          return _SectionCard(
            title: title,
            emptyIcon: pendingOnly
                ? Icons.event_available_outlined
                : Icons.account_balance_wallet_outlined,
            emptyTitle: emptyTitle,
            itemCount: visible.length,
            itemBuilder: (_, i) {
              final item = visible[i];
              final income = item.type == 'INCOME';
              final pending = item.status == 'PENDING';
              return ListTile(
                leading: Icon(
                  pending
                      ? Icons.event_available_outlined
                      : income
                      ? Icons.south_west
                      : Icons.north_east,
                  color: pending
                      ? Colors.deepOrange
                      : income
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(item.description),
                subtitle: Text(
                  '${item.category} · ${shortDate.format(item.occurredAt)}'
                  ' · ${_financeStatusLabel(item.status)}'
                  '${item.dueDate == null ? '' : ' · vence ${shortDate.format(item.dueDate!)}'}'
                  '${item.paymentMethod == null ? '' : ' · ${item.paymentMethod}'}',
                ),
                trailing: item.referenceType != null || !canUpdate
                    ? Text(
                        '${income ? '+' : '−'} ${money(item.amountCents)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${income ? '+' : '−'} ${money(item.amountCents)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Ações do lançamento pessoal',
                            onSelected: (action) async {
                              if (action == 'edit') {
                                await showDialog<void>(
                                  context: context,
                                  builder: (_) => _PersonalFinanceDialog(
                                    ref: ref,
                                    editing: item,
                                  ),
                                );
                                return;
                              }
                              await showDialog<void>(
                                context: context,
                                builder: (_) => _PaymentDialog(
                                  title: 'Efetuar pagamento pessoal',
                                  onPay: (payment, notes) => ref
                                      .read(operationsControllerProvider)
                                      .payPersonalFinance(
                                        id: item.id,
                                        payment: payment,
                                        notes: notes,
                                      ),
                                ),
                              );
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar lançamento'),
                              ),
                              if (pending)
                                const PopupMenuItem(
                                  value: 'pay',
                                  child: Text('Efetuar pagamento'),
                                ),
                            ],
                          ),
                        ],
                      ),
              );
            },
          );
        },
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

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.title, required this.onPay});

  final String title;
  final Future<void> Function(String payment, String notes) onPay;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final payment = TextEditingController();
  final notes = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    payment.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: _DialogFields(
      children: [
        TextField(
          controller: payment,
          decoration: const InputDecoration(labelText: 'Forma/conta usada'),
        ),
        TextField(
          controller: notes,
          decoration: const InputDecoration(
            labelText: 'Observação do pagamento',
          ),
        ),
      ],
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
                setState(() => saving = true);
                try {
                  await widget.onPay(payment.text, notes.text);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                  if (mounted) setState(() => saving = false);
                }
              },
        child: const Text('Pagar'),
      ),
    ],
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
  const _FinanceDialog({
    required this.ref,
    this.accountsPayable = false,
    this.editing,
  });
  final WidgetRef ref;
  final bool accountsPayable;
  final FinanceTransaction? editing;
  @override
  State<_FinanceDialog> createState() => _FinanceDialogState();
}

class _FinanceDialogState extends State<_FinanceDialog> {
  String type = 'EXPENSE';
  String category = _businessExpenseCategories.first;
  final description = TextEditingController();
  final amount = TextEditingController();
  final payment = TextEditingController();
  final notes = TextEditingController();
  DateTime dueDate = DateTime.now();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.editing;
    if (item == null) return;
    type = item.type;
    category = item.category;
    description.text = item.description;
    amount.text = _moneyInput(item.amountCents);
    payment.text = item.paymentMethod ?? '';
    notes.text = item.notes ?? '';
    dueDate = item.dueDate ?? DateTime.now();
  }

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
    final categories = type == 'INCOME'
        ? _businessIncomeCategories
        : _businessExpenseCategories;
    final isEditing = widget.editing != null;
    final payableMode =
        widget.accountsPayable || widget.editing?.status == 'PENDING';
    if (!categories.contains(category)) category = categories.first;
    return AlertDialog(
      title: Text(
        isEditing
            ? 'Editar lançamento'
            : payableMode
            ? 'Conta a pagar'
            : 'Novo lançamento',
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!payableMode) ...[
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'INCOME', label: Text('Entrada')),
                  ButtonSegment(value: 'EXPENSE', label: Text('Saída')),
                ],
                selected: {type},
                onSelectionChanged: (v) => setState(() => type = v.first),
              ),
              const SizedBox(height: 12),
            ],
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                for (final c in categories)
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
            if (!payableMode) ...[
              TextField(
                controller: payment,
                decoration: const InputDecoration(labelText: 'Forma/conta'),
              ),
              const SizedBox(height: 12),
            ],
            if (payableMode) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: const Text('Data de vencimento'),
                subtitle: Text(shortDate.format(dueDate)),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setState(() => dueDate = picked);
                },
              ),
              const SizedBox(height: 12),
            ],
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
                    final controller = widget.ref.read(
                      operationsControllerProvider,
                    );
                    final status = payableMode ? 'PENDING' : 'CONFIRMED';
                    if (isEditing) {
                      await controller.updateFinance(
                        id: widget.editing!.id,
                        type: type,
                        category: category,
                        description: description.text,
                        amount: parseMoneyToCents(amount.text),
                        payment: payment.text,
                        status: status,
                        dueDate: payableMode ? dueDate : null,
                        notes: notes.text,
                      );
                    } else {
                      await controller.addFinance(
                        type: type,
                        category: category,
                        description: description.text,
                        amount: parseMoneyToCents(amount.text),
                        payment: payment.text,
                        status: status,
                        dueDate: payableMode ? dueDate : null,
                        notes: notes.text,
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    await showOperationError(context, e);
                    if (mounted) setState(() => saving = false);
                  }
                },
          child: Text(isEditing ? 'Salvar' : 'Registrar'),
        ),
      ],
    );
  }
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
  const _PersonalFinanceDialog({
    required this.ref,
    this.accountsPayable = false,
    this.editing,
  });
  final WidgetRef ref;
  final bool accountsPayable;
  final PersonalFinanceTransaction? editing;
  @override
  State<_PersonalFinanceDialog> createState() => _PersonalFinanceDialogState();
}

class _PersonalFinanceDialogState extends State<_PersonalFinanceDialog> {
  String type = 'EXPENSE';
  String category = _personalExpenseCategories.first;
  String? establishmentId;
  final description = TextEditingController();
  final amount = TextEditingController();
  final payment = TextEditingController();
  final notes = TextEditingController();
  DateTime dueDate = DateTime.now();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.editing;
    if (item == null) return;
    type = item.type;
    category = item.category;
    establishmentId = item.establishmentId;
    description.text = item.description;
    amount.text = _moneyInput(item.amountCents);
    payment.text = item.paymentMethod ?? '';
    notes.text = item.notes ?? '';
    dueDate = item.dueDate ?? DateTime.now();
  }

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
        ? _personalIncomeCategories
        : _personalExpenseCategories;
    final isEditing = widget.editing != null;
    final payableMode =
        widget.accountsPayable || widget.editing?.status == 'PENDING';
    if (!categories.contains(category)) category = categories.first;
    return AlertDialog(
      title: Text(
        isEditing
            ? 'Editar lançamento pessoal'
            : payableMode
            ? 'Conta a pagar pessoal'
            : 'Lançamento pessoal',
      ),
      content: _DialogFields(
        children: [
          if (!payableMode)
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
          if (payableMode)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Data de vencimento'),
              subtitle: Text(shortDate.format(dueDate)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dueDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => dueDate = picked);
              },
            ),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Observações'),
          ),
        ],
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
                  setState(() => saving = true);
                  try {
                    final controller = widget.ref.read(
                      operationsControllerProvider,
                    );
                    final status = payableMode ? 'PENDING' : 'CONFIRMED';
                    final amountCents = parseMoneyToCents(amount.text);
                    if (amountCents <= 0) {
                      throw ArgumentError('Informe um valor maior que zero.');
                    }
                    final cleanDescription = description.text.trim().isEmpty
                        ? category
                        : description.text.trim();
                    if (isEditing) {
                      await controller.updatePersonalFinance(
                        id: widget.editing!.id,
                        type: type,
                        category: category,
                        description: cleanDescription,
                        amount: amountCents,
                        establishmentId: establishmentId,
                        payment: payment.text,
                        status: status,
                        dueDate: payableMode ? dueDate : null,
                        notes: notes.text,
                      );
                    } else {
                      await controller.addPersonalFinance(
                        type: type,
                        category: category,
                        description: cleanDescription,
                        amount: amountCents,
                        establishmentId: establishmentId,
                        payment: payment.text,
                        status: status,
                        dueDate: payableMode ? dueDate : null,
                        notes: notes.text,
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    await showOperationError(context, e);
                    if (mounted) setState(() => saving = false);
                  }
                },
          child: Text(isEditing ? 'Salvar' : 'Registrar'),
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
            final amountCents = parseMoneyToCents(amount.text);
            if (amountCents <= 0) {
              throw ArgumentError('Informe um valor maior que zero.');
            }
            await widget.ref
                .read(operationsControllerProvider)
                .addPersonalFinance(
                  type: 'EXPENSE',
                  category: 'Transferência de pró-labore',
                  description: name.isEmpty
                      ? 'Transferência de pró-labore'
                      : 'Transferência de pró-labore para $name',
                  amount: amountCents,
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

String _financeStatusLabel(String status) => switch (status) {
  'PENDING' => 'Pendente',
  'CANCELLED' => 'Cancelado',
  _ => 'Confirmado',
};

String _moneyInput(int cents) => (cents / 100).toStringAsFixed(2);

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
