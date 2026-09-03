import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../../lots/domain/value_objects/lot_lifecycle.dart';
import '../../application/operations_controller.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Ração e alimentação',
    child: DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.grain), text: 'Insumos'),
              Tab(icon: Icon(Icons.science_outlined), text: 'Formulações'),
              Tab(icon: Icon(Icons.factory_outlined), text: 'Fabricações'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Estoque'),
              Tab(icon: Icon(Icons.restaurant_outlined), text: 'Alimentação'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: MediaQuery.sizeOf(context).height.clamp(560, 820),
            child: TabBarView(
              children: [
                _IngredientsTab(ref: ref),
                _FormulasTab(ref: ref),
                _BatchesTab(ref: ref),
                _FeedStockTab(ref: ref),
                _FeedingsTab(ref: ref),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _IngredientsTab extends StatelessWidget {
  const _IngredientsTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(ingredientsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) {
          final lots = ref.watch(ingredientLotsProvider).asData?.value ?? [];
          return ListView(
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
                        builder: (_) => _IngredientDialog(ref: ref),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo insumo'),
                    ),
                    FilledButton.icon(
                      onPressed: items.isEmpty
                          ? null
                          : () => showDialog<void>(
                              context: context,
                              builder: (_) => _IngredientEntryDialog(
                                ref: ref,
                                ingredients: items,
                              ),
                            ),
                      icon: const Icon(Icons.input),
                      label: const Text('Entrada de estoque'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const SeletoEmptyState(
                  icon: Icons.grain,
                  title: 'Nenhum insumo',
                  message: 'Cadastre os ingredientes usados nas formulações.',
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
                        leading: const CircleAvatar(child: Icon(Icons.grain)),
                        title: Text(item.ingredient.name),
                        subtitle: Text(
                          item.currentPriceCents == null
                              ? 'Saldo ${kg(item.stockKg)} · sem preço cadastrado'
                              : 'Saldo ${kg(item.stockKg)} em ${item.activeLotCount} lote(s) · atual ${money(item.currentPriceCents!)} / kg${item.variationPercent == null ? '' : ' · ${percent(item.variationPercent!)}'}',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Histórico de preços',
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (_) =>
                                    _PriceHistoryDialog(ref: ref, item: item),
                              ),
                              icon: const Icon(Icons.history),
                            ),
                            IconButton(
                              tooltip: 'Registrar preço',
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (_) =>
                                    _PriceDialog(ref: ref, item: item),
                              ),
                              icon: const Icon(Icons.price_change_outlined),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 18),
              if (lots.isNotEmpty) ...[
                Text(
                  'Lotes de insumos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lots.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final lot = lots[i];
                      return ListTile(
                        leading: Icon(
                          lot.balanceKg > 0
                              ? Icons.inventory_2_outlined
                              : Icons.inventory_outlined,
                        ),
                        title: Text('${lot.ingredientName} · ${lot.lot.code}'),
                        subtitle: Text(
                          '${shortDate.format(lot.lot.entryDate)} · ${lot.lot.packageUnit == 'SACO' ? '${lot.lot.packageQuantity.toStringAsFixed(0)} saco(s) de ${kg(lot.lot.packageWeightKg)}' : kg(lot.lot.initialQuantityKg)} · ${money(lot.lot.pricePerKgCents)}/kg',
                        ),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              kg(lot.balanceKg),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            IconButton(
                              tooltip: 'Correção de estoque',
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (_) => _IngredientCorrectionDialog(
                                  ref: ref,
                                  lot: lot,
                                ),
                              ),
                              icon: const Icon(Icons.tune),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      );
}

class _FormulasTab extends StatelessWidget {
  const _FormulasTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(formulasProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => ListView(
          children: [
            if (items.isEmpty)
              const SeletoEmptyState(
                icon: Icons.science,
                title: 'Sem formulações',
                message:
                    'As formulações padrão serão criadas ao iniciar o banco.',
              )
            else
              LayoutBuilder(
                builder: (context, box) {
                  final width = box.maxWidth >= 850
                      ? (box.maxWidth - 12) / 2
                      : box.maxWidth;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final item in items)
                        SizedBox(
                          width: width,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.formula.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                      ),
                                      Chip(
                                        label: Text('v${item.formula.version}'),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item.formula.isActive
                                        ? 'Formulação vigente'
                                        : 'Histórico',
                                    style: TextStyle(
                                      color: item.formula.isActive
                                          ? Colors.green
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Divider(),
                                  for (final ingredient in item.items)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(ingredient.name),
                                          ),
                                          Text(
                                            '${ingredient.quantityKg.toStringAsFixed(1)} kg',
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: item.formula.isActive
                                            ? () => showDialog<void>(
                                                context: context,
                                                builder: (_) => _FormulaDialog(
                                                  ref: ref,
                                                  formula: item,
                                                ),
                                              )
                                            : null,
                                        icon: const Icon(Icons.edit_outlined),
                                        label: const Text('Nova versão'),
                                      ),
                                      FilledButton.icon(
                                        onPressed: () => showDialog<void>(
                                          context: context,
                                          builder: (_) => _ManufactureDialog(
                                            ref: ref,
                                            formula: item,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.factory_outlined,
                                        ),
                                        label: const Text('Fabricar'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      );
}

class _BatchesTab extends StatelessWidget {
  const _BatchesTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(feedBatchesProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => ListView(
          children: [
            if (items.isEmpty)
              const SeletoEmptyState(
                icon: Icons.factory_outlined,
                title: 'Nenhuma fabricação',
                message:
                    'Registre uma fabricação a partir da formulação desejada.',
              )
            else
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final b = items[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.factory_outlined),
                      ),
                      title: Text(
                        '${b.batch.code} · ${b.batch.phase.replaceAll('_', ' ')}',
                      ),
                      subtitle: Text(
                        '${shortDate.format(b.batch.producedAt)} · ${kg(b.batch.producedQuantityKg)} · ${money(b.batch.totalCostCents)}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${money(b.batch.costPerKgCents.round())}/kg',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text('Saldo ${kg(b.balanceKg)}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
}

class _FeedStockTab extends StatelessWidget {
  const _FeedStockTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(feedBatchesProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) {
          final stock = items.fold<double>(0, (s, b) => s + b.balanceKg);
          final made = items.fold<double>(
            0,
            (s, b) => s + b.batch.producedQuantityKg,
          );
          return ListView(
            children: [
              SeletoKpiGrid(
                children: [
                  SeletoKpiCard(
                    label: 'Saldo total',
                    value: kg(stock),
                    icon: Icons.inventory_2_outlined,
                  ),
                  SeletoKpiCard(
                    label: 'Total produzido',
                    value: kg(made),
                    icon: Icons.factory_outlined,
                  ),
                  SeletoKpiCard(
                    label: 'Total consumido',
                    value: kg(made - stock),
                    icon: Icons.restaurant_outlined,
                  ),
                  SeletoKpiCard(
                    label: 'Fabricações',
                    value: '${items.length}',
                    icon: Icons.numbers,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (items.isNotEmpty)
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final b = items[i];
                      return ListTile(
                        title: Text(b.batch.code),
                        subtitle: Text(
                          '${b.batch.phase.replaceAll('_', ' ')} · Produzido ${kg(b.batch.producedQuantityKg)} · Consumido ${kg(b.consumedKg)}',
                        ),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              kg(b.balanceKg),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            IconButton(
                              tooltip: 'Ajustar',
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (_) =>
                                    _FeedAdjustmentDialog(ref: ref, batch: b),
                              ),
                              icon: const Icon(Icons.tune),
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

class _FeedingsTab extends StatelessWidget {
  const _FeedingsTab({required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) => ref
      .watch(feedingsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) => ListView(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _FeedingDialog(ref: ref),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Registrar alimentação'),
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const SeletoEmptyState(
                icon: Icons.restaurant,
                title: 'Nenhuma alimentação',
                message: 'Registre o fornecimento diário de ração por lote.',
              )
            else
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final f = items[i];
                    return ListTile(
                      leading: const Icon(Icons.restaurant_outlined),
                      title: Text(kg(f.quantityKg)),
                      subtitle: Text(
                        '${shortDate.format(f.feedingDate)} · Lote ${f.lotId.substring(0, 8)} · Ração ${f.batchId.substring(0, 8)}',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
}

class _IngredientDialog extends StatefulWidget {
  const _IngredientDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final name = TextEditingController();
  final unit = TextEditingController(text: 'kg');
  final notes = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    unit.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo insumo'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: unit,
            decoration: const InputDecoration(labelText: 'Unidade'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Observação'),
          ),
        ],
      ),
    ),
    actions: _actions(
      context,
      () async => widget.ref
          .read(operationsControllerProvider)
          .addIngredient(name.text, unit.text, notes.text),
    ),
  );
  List<Widget> _actions(BuildContext context, Future<void> Function() save) => [
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
                await save();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                await showOperationError(context, e);
                if (mounted) setState(() => saving = false);
              }
            },
      child: const Text('Salvar'),
    ),
  ];
}

class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.ref, required this.item});
  final WidgetRef ref;
  final IngredientOverview item;
  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  final price = TextEditingController();
  final supplier = TextEditingController();
  final notes = TextEditingController();
  DateTime date = DateTime.now();
  bool saving = false;
  @override
  void dispose() {
    price.dispose();
    supplier.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Preço · ${widget.item.ingredient.name}'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Preço por kg',
              prefixText: 'R\$ ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: supplier,
            decoration: const InputDecoration(
              labelText: 'Fornecedor (opcional)',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Data de vigência'),
            subtitle: Text(shortDate.format(date)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await pickSeletoDate(context, date);
              if (d != null) setState(() => date = d);
            },
          ),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Observação'),
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
                setState(() => saving = true);
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .addPrice(
                        widget.item.ingredient.id,
                        parseMoneyToCents(price.text),
                        date,
                        supplier.text,
                        notes.text,
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

class _PriceHistoryDialog extends StatelessWidget {
  const _PriceHistoryDialog({required this.ref, required this.item});
  final WidgetRef ref;
  final IngredientOverview item;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Histórico · ${item.ingredient.name}'),
    content: SizedBox(
      width: 460,
      child: StreamBuilder<List<IngredientPriceHistoryData>>(
        stream: ref
            .read(databaseProvider)
            .watchIngredientPrices(item.ingredient.id),
        builder: (context, snapshot) {
          final prices = snapshot.data ?? [];
          if (prices.isEmpty) {
            return const SeletoEmptyState(
              icon: Icons.price_change_outlined,
              title: 'Sem preços',
              message: 'Registre uma cotação ou entrada de estoque.',
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            itemCount: prices.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final price = prices[i];
              return ListTile(
                leading: const Icon(Icons.price_change_outlined),
                title: Text('${money(price.pricePerKgCents)} / kg'),
                subtitle: Text(
                  '${shortDate.format(price.effectiveDate)}${price.supplier == null ? '' : ' · ${price.supplier}'}',
                ),
              );
            },
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fechar'),
      ),
    ],
  );
}

class _IngredientEntryDialog extends StatefulWidget {
  const _IngredientEntryDialog({required this.ref, required this.ingredients});
  final WidgetRef ref;
  final List<IngredientOverview> ingredients;

  @override
  State<_IngredientEntryDialog> createState() => _IngredientEntryDialogState();
}

class _IngredientEntryDialogState extends State<_IngredientEntryDialog> {
  String? ingredientId;
  String unit = 'SACO';
  final quantity = TextEditingController();
  final kgPerUnit = TextEditingController(text: '50');
  final total = TextEditingController();
  final supplier = TextEditingController();
  final notes = TextEditingController();
  DateTime date = DateTime.now();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    ingredientId = widget.ingredients.firstOrNull?.ingredient.id;
  }

  @override
  void dispose() {
    quantity.dispose();
    kgPerUnit.dispose();
    total.dispose();
    supplier.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Entrada de estoque'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: ingredientId,
              decoration: const InputDecoration(labelText: 'Insumo'),
              items: [
                for (final item in widget.ingredients)
                  DropdownMenuItem(
                    value: item.ingredient.id,
                    child: Text(item.ingredient.name),
                  ),
              ],
              onChanged: saving
                  ? null
                  : (value) => setState(() => ingredientId = value),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'SACO', label: Text('Saco')),
                ButtonSegment(value: 'KG', label: Text('Kg')),
              ],
              selected: {unit},
              onSelectionChanged: saving
                  ? null
                  : (value) => setState(() {
                      unit = value.first;
                      if (unit == 'KG') kgPerUnit.text = '1';
                    }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantity,
              enabled: !saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: unit == 'SACO' ? 'Quantidade de sacos' : 'Kg',
              ),
            ),
            if (unit == 'SACO') ...[
              const SizedBox(height: 12),
              TextField(
                controller: kgPerUnit,
                enabled: !saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Kg por saco',
                  suffixText: 'kg',
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: total,
              enabled: !saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor total',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: supplier,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Fornecedor'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data de entrada'),
              subtitle: Text(shortDate.format(date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: saving
                  ? null
                  : () async {
                      final picked = await pickSeletoDate(context, date);
                      if (picked != null) setState(() => date = picked);
                    },
            ),
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
        onPressed: saving || ingredientId == null
            ? null
            : () async {
                setState(() => saving = true);
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .addIngredientEntry(
                        ingredientId: ingredientId!,
                        entryDate: date,
                        packageUnit: unit,
                        packageQuantity: parseDecimal(quantity.text),
                        packageWeightKg: unit == 'SACO'
                            ? parseDecimal(kgPerUnit.text)
                            : 1,
                        totalCost: parseMoneyToCents(total.text),
                        supplier: supplier.text,
                        notes: notes.text,
                      );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                  if (mounted) setState(() => saving = false);
                }
              },
        child: const Text('Registrar entrada'),
      ),
    ],
  );
}

class _IngredientCorrectionDialog extends StatefulWidget {
  const _IngredientCorrectionDialog({required this.ref, required this.lot});
  final WidgetRef ref;
  final IngredientLotBalance lot;

  @override
  State<_IngredientCorrectionDialog> createState() =>
      _IngredientCorrectionDialogState();
}

class _IngredientCorrectionDialogState
    extends State<_IngredientCorrectionDialog> {
  final quantity = TextEditingController();
  final notes = TextEditingController();
  bool input = true;
  bool saving = false;

  @override
  void dispose() {
    quantity.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Correção · ${widget.lot.lot.code}'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Entrada')),
              ButtonSegment(value: false, label: Text('Saída')),
            ],
            selected: {input},
            onSelectionChanged: saving
                ? null
                : (value) => setState(() => input = value.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: quantity,
            enabled: !saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantidade da correção',
              suffixText: 'kg',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            enabled: !saving,
            decoration: const InputDecoration(labelText: 'Motivo'),
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
                setState(() => saving = true);
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .correctIngredientLot(
                        ingredientLotId: widget.lot.lot.id,
                        quantityKg: parseDecimal(quantity.text),
                        input: input,
                        notes: notes.text,
                      );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                  if (mounted) setState(() => saving = false);
                }
              },
        child: const Text('Registrar correção'),
      ),
    ],
  );
}

class _ManufactureDialog extends StatefulWidget {
  const _ManufactureDialog({required this.ref, required this.formula});
  final WidgetRef ref;
  final FormulaOverview formula;
  @override
  State<_ManufactureDialog> createState() => _ManufactureDialogState();
}

class _ManufactureDialogState extends State<_ManufactureDialog> {
  final quantity = TextEditingController(text: '100');
  final notes = TextEditingController();
  DateTime date = DateTime.now();
  bool saving = false;
  @override
  void dispose() {
    quantity.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Fabricar · ${widget.formula.formula.name}'),
    content: SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantidade produzida',
              suffixText: 'kg',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final v in [25, 50, 100, 150, 200])
                ActionChip(
                  label: Text('$v kg'),
                  onPressed: () => quantity.text = '$v',
                ),
            ],
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
        onPressed: saving ? null : () => Navigator.pop(context),
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
                      .manufacture(
                        widget.formula,
                        parseDecimal(quantity.text),
                        date,
                        notes.text,
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
            : const Text('Confirmar fabricação'),
      ),
    ],
  );
}

class _FormulaDialog extends StatefulWidget {
  const _FormulaDialog({required this.ref, required this.formula});
  final WidgetRef ref;
  final FormulaOverview formula;
  @override
  State<_FormulaDialog> createState() => _FormulaDialogState();
}

class _FormulaDialogState extends State<_FormulaDialog> {
  late final Map<String, TextEditingController> values = {
    for (final i in widget.formula.items)
      i.ingredientId: TextEditingController(text: i.quantityKg.toString()),
  };
  bool saving = false;
  @override
  void dispose() {
    for (final c in values.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Nova versão · ${widget.formula.formula.name}'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final i in widget.formula.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: values[i.ingredientId],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: i.name,
                    suffixText: 'kg',
                  ),
                ),
              ),
            const Text(
              'A soma deve totalizar 100 kg. O histórico anterior será preservado.',
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
                setState(() => saving = true);
                try {
                  await widget.ref
                      .read(operationsControllerProvider)
                      .saveFormula(widget.formula, {
                        for (final e in values.entries)
                          e.key: parseDecimal(e.value.text),
                      }, null);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                  if (mounted) setState(() => saving = false);
                }
              },
        child: const Text('Criar versão'),
      ),
    ],
  );
}

class _FeedAdjustmentDialog extends StatefulWidget {
  const _FeedAdjustmentDialog({required this.ref, required this.batch});
  final WidgetRef ref;
  final FeedBatchBalance batch;
  @override
  State<_FeedAdjustmentDialog> createState() => _FeedAdjustmentDialogState();
}

class _FeedAdjustmentDialogState extends State<_FeedAdjustmentDialog> {
  final qty = TextEditingController();
  final notes = TextEditingController();
  bool input = true;
  @override
  void dispose() {
    qty.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Ajustar ${widget.batch.batch.code}'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Entrada')),
              ButtonSegment(value: false, label: Text('Saída')),
            ],
            selected: {input},
            onSelectionChanged: (v) => setState(() => input = v.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qty,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              suffixText: 'kg',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Motivo'),
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
                .adjustFeed(
                  widget.batch.batch.id,
                  parseDecimal(qty.text),
                  input,
                  notes.text,
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

class _FeedingDialog extends StatefulWidget {
  const _FeedingDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_FeedingDialog> createState() => _FeedingDialogState();
}

class _FeedingDialogState extends State<_FeedingDialog> {
  String? lot;
  String? batch;
  final qty = TextEditingController();
  final notes = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    qty.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots =
        widget.ref.watch(lotSummariesProvider).asData?.value ?? <LotSummary>[];
    final batches =
        widget.ref.watch(feedBatchesProvider).asData?.value ??
        <FeedBatchBalance>[];
    return AlertDialog(
      title: const Text('Registrar alimentação'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: lot,
              decoration: const InputDecoration(labelText: 'Lote'),
              items: [
                for (final l in lots.where((l) => l.activeBirds > 0))
                  DropdownMenuItem(
                    value: l.lot.id,
                    child: Text('${l.lot.name} · ${l.activeBirds} aves'),
                  ),
              ],
              onChanged: (v) {
                setState(() {
                  lot = v;
                  final summary = lots
                      .where((item) => item.lot.id == v)
                      .firstOrNull;
                  if (summary != null) {
                    final age = LotLifecycle.ageInDays(
                      receivedAt: summary.lot.receivedAt,
                      arrivalAgeDays: summary.lot.arrivalAgeDays,
                    );
                    final phase = switch (LotLifecycle.phaseForAge(age)) {
                      FeedingPhase.cria => 'CRIA',
                      FeedingPhase.recria => 'RECRIA',
                      FeedingPhase.prePostura => 'PRE_POSTURA',
                      FeedingPhase.producaoI => 'PRODUCAO_I',
                      FeedingPhase.producaoII => 'PRODUCAO_II',
                      FeedingPhase.producaoIII => 'PRODUCAO_III',
                    };
                    final compatible =
                        batches
                            .where(
                              (item) =>
                                  item.balanceKg > 0 &&
                                  item.batch.phase == phase,
                            )
                            .toList()
                          ..sort(
                            (a, b) => a.batch.producedAt.compareTo(
                              b.batch.producedAt,
                            ),
                          );
                    batch = compatible.firstOrNull?.batch.id;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: batch,
              decoration: const InputDecoration(
                labelText: 'Fabricação de ração',
              ),
              items: [
                for (final b in batches.where((b) => b.balanceKg > 0))
                  DropdownMenuItem(
                    value: b.batch.id,
                    child: Text(
                      '${b.batch.code} · ${b.batch.phase.replaceAll('_', ' ')} · ${kg(b.balanceKg)}',
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => batch = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qty,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Quantidade fornecida',
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: 'Observação'),
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
          onPressed: saving || lot == null || batch == null
              ? null
              : () async {
                  setState(() => saving = true);
                  try {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .feed(
                          lot!,
                          batch!,
                          parseDecimal(qty.text),
                          DateTime.now(),
                          notes.text,
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
}
