import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../lots/application/lots_controller.dart';
import '../../../lots/domain/value_objects/lot_lifecycle.dart';
import '../../application/operations_controller.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Ração e alimentação',
    scrollable: false,
    child: DefaultTabController(
      length: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.grain), text: 'Insumos'),
              Tab(icon: Icon(Icons.inventory_outlined), text: 'Lotes'),
              Tab(icon: Icon(Icons.science_outlined), text: 'Formulações'),
              Tab(icon: Icon(Icons.factory_outlined), text: 'Fabricações'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Estoque'),
              Tab(icon: Icon(Icons.restaurant_outlined), text: 'Alimentação'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                _IngredientsTab(ref: ref),
                _IngredientLotsTab(ref: ref),
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

class _IngredientsTab extends StatefulWidget {
  const _IngredientsTab({required this.ref});
  final WidgetRef ref;

  @override
  State<_IngredientsTab> createState() => _IngredientsTabState();
}

class _IngredientsTabState extends State<_IngredientsTab> {
  bool showInactive = false;

  @override
  Widget build(BuildContext context) => widget.ref
      .watch(ingredientsProvider(showInactive))
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (items) {
          final activeItems = items
              .where((item) => item.ingredient.isActive)
              .toList();
          final stockItems = activeItems
              .where((item) => item.stockKg > .0001)
              .toList();
          return SeletoTabList(
            children: [
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    selected: showInactive,
                    onSelected: (value) => setState(() => showInactive = value),
                    avatar: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Exibir inativos'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _IngredientDialog(ref: widget.ref),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Novo insumo'),
                  ),
                  OutlinedButton.icon(
                    onPressed: stockItems.isEmpty || activeItems.length < 2
                        ? null
                        : () => showDialog<void>(
                            context: context,
                            builder: (_) => _IngredientTransferDialog(
                              ref: widget.ref,
                              ingredients: activeItems,
                            ),
                          ),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Transferir estoque'),
                  ),
                  FilledButton.icon(
                    onPressed: activeItems.isEmpty
                        ? null
                        : () => showDialog<void>(
                            context: context,
                            builder: (_) => _IngredientEntryDialog(
                              ref: widget.ref,
                              ingredients: activeItems,
                            ),
                          ),
                    icon: const Icon(Icons.input),
                    label: const Text('Entrada de estoque'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                SeletoEmptyState(
                  icon: Icons.grain,
                  title: showInactive ? 'Nenhum insumo' : 'Nenhum insumo ativo',
                  message: showInactive
                      ? 'Cadastre os ingredientes usados nas formulações.'
                      : 'Ative o filtro de inativos ou cadastre um novo insumo.',
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
                            child: _IngredientCard(ref: widget.ref, item: item),
                          ),
                      ],
                    );
                  },
                ),
            ],
          );
        },
      );
}

class _IngredientLotsTab extends StatefulWidget {
  const _IngredientLotsTab({required this.ref});
  final WidgetRef ref;

  @override
  State<_IngredientLotsTab> createState() => _IngredientLotsTabState();
}

class _IngredientLotsTabState extends State<_IngredientLotsTab> {
  bool showInactive = false;

  @override
  Widget build(BuildContext context) {
    final ingredients =
        widget.ref.watch(ingredientsProvider(false)).asData?.value ?? [];
    return widget.ref
        .watch(ingredientLotsProvider(showInactive))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (lots) => SeletoTabList(
            children: [
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    selected: showInactive,
                    onSelected: (value) => setState(() => showInactive = value),
                    avatar: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Exibir inativos'),
                  ),
                  FilledButton.icon(
                    onPressed: ingredients.isEmpty
                        ? null
                        : () => showDialog<void>(
                            context: context,
                            builder: (_) => _IngredientEntryDialog(
                              ref: widget.ref,
                              ingredients: ingredients,
                            ),
                          ),
                    icon: const Icon(Icons.input),
                    label: const Text('Entrada de estoque'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (lots.isEmpty)
                SeletoEmptyState(
                  icon: Icons.inventory_outlined,
                  title: showInactive
                      ? 'Nenhum lote de insumo'
                      : 'Nenhum lote de insumo ativo',
                  message: showInactive
                      ? 'Registre uma entrada de estoque para criar o primeiro lote.'
                      : 'Ative o filtro de inativos ou registre uma entrada de estoque.',
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
                        for (final lot in lots)
                          SizedBox(
                            width: width,
                            child: _IngredientLotCard(
                              ref: widget.ref,
                              lot: lot,
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
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.ref, required this.item});
  final WidgetRef ref;
  final IngredientOverview item;

  @override
  Widget build(BuildContext context) {
    final price = item.currentPriceCents == null
        ? 'Sem preço cadastrado'
        : '${money(item.currentPriceCents!)} / kg';
    final variation = item.variationPercent == null
        ? null
        : percent(item.variationPercent!);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.ingredient.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Chip(label: Text(kg(item.stockKg))),
                IconButton(
                  tooltip: 'Editar insumo',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _IngredientDialog(ref: ref, item: item),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: item.ingredient.isActive
                      ? 'Desativar insumo'
                      : 'Ativar insumo',
                  onPressed: () async {
                    try {
                      await ref
                          .read(operationsControllerProvider)
                          .updateIngredient(
                            ingredientId: item.ingredient.id,
                            name: item.ingredient.name,
                            unit: item.ingredient.unit,
                            isActive: !item.ingredient.isActive,
                            notes: item.ingredient.notes,
                          );
                    } catch (e) {
                      if (context.mounted) await showOperationError(context, e);
                    }
                  },
                  icon: Icon(
                    item.ingredient.isActive
                        ? Icons.block
                        : Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            Text(
              item.ingredient.isActive ? 'Insumo ativo' : 'Histórico',
              style: TextStyle(
                color: item.ingredient.isActive
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(),
            _IngredientInfoRow(label: 'Estoque total', value: kg(item.stockKg)),
            _IngredientInfoRow(label: 'Unidade', value: item.ingredient.unit),
            _IngredientInfoRow(
              label: 'Lotes com saldo',
              value: '${item.activeLotCount}',
            ),
            _IngredientInfoRow(label: 'Preço atual', value: price),
            if (variation != null)
              _IngredientInfoRow(label: 'Variação', value: variation),
            if ((item.ingredient.notes ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  item.ingredient.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _PriceHistoryDialog(ref: ref, item: item),
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('Histórico'),
                ),
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _PriceDialog(ref: ref, item: item),
                  ),
                  icon: const Icon(Icons.price_change_outlined),
                  label: const Text('Preço'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _confirmDeleteIngredientPermanently(
                    context: context,
                    ref: ref,
                    item: item,
                  ),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Remover'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDeleteIngredientPermanently({
  required BuildContext context,
  required WidgetRef ref,
  required IngredientOverview item,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Remover ${item.ingredient.name}?'),
      content: const Text(
        'Esta ação remove definitivamente o insumo, preços, lotes e movimentos '
        'de estoque vinculados a ele. Se o insumo estiver em formulações ou '
        'fabricações, a remoção será bloqueada para proteger o histórico.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          child: const Text('Remover'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await ref
        .read(operationsControllerProvider)
        .deleteIngredientPermanently(item.ingredient.id);
  } catch (e) {
    if (context.mounted) await showOperationError(context, e);
  }
}

class _IngredientLotCard extends StatelessWidget {
  const _IngredientLotCard({required this.ref, required this.lot});
  final WidgetRef ref;
  final IngredientLotBalance lot;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lot.ingredientName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Chip(label: Text(kg(lot.balanceKg))),
            ],
          ),
          Text(
            lot.lot.code,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(),
          _IngredientInfoRow(
            label: 'Entrada',
            value: shortDate.format(lot.lot.entryDate),
          ),
          _IngredientInfoRow(
            label: 'Quantidade inicial',
            value: lot.lot.packageUnit == 'SACO'
                ? '${lot.lot.packageQuantity.toStringAsFixed(0)} saco(s) de ${kg(lot.lot.packageWeightKg)}'
                : kg(lot.lot.initialQuantityKg),
          ),
          _IngredientInfoRow(
            label: 'Preço',
            value: '${money(lot.lot.pricePerKgCents)}/kg',
          ),
          _IngredientInfoRow(label: 'Consumido', value: kg(lot.consumedKg)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _IngredientCorrectionDialog(ref: ref, lot: lot),
            ),
            icon: const Icon(Icons.tune),
            label: const Text('Correção de estoque'),
          ),
        ],
      ),
    ),
  );
}

class _IngredientInfoRow extends StatelessWidget {
  const _IngredientInfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    ),
  );
}

class _FormulasTab extends StatefulWidget {
  const _FormulasTab({required this.ref});
  final WidgetRef ref;

  @override
  State<_FormulasTab> createState() => _FormulasTabState();
}

class _FormulasTabState extends State<_FormulasTab> {
  bool showInactive = false;

  @override
  Widget build(BuildContext context) {
    final availableIngredients =
        (widget.ref.watch(ingredientsProvider(showInactive)).asData?.value ??
                [])
            .where((item) => item.ingredient.isActive && item.stockKg > .0001)
            .where((item) => _isAllowedFormulaIngredient(item.ingredient.name))
            .toList();
    return widget.ref
        .watch(formulasProvider(showInactive))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SeletoAsyncError(),
          data: (items) => SeletoTabList(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilterChip(
                  selected: showInactive,
                  onSelected: (value) => setState(() => showInactive = value),
                  avatar: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Exibir inativas'),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                SeletoEmptyState(
                  icon: Icons.science,
                  title: showInactive
                      ? 'Sem formulações'
                      : 'Sem formulações ativas',
                  message: showInactive
                      ? 'As formulações padrão serão criadas ao iniciar o banco.'
                      : 'Ative o filtro de inativas para consultar o histórico.',
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
                            child: _FormulaCard(
                              ref: widget.ref,
                              formula: item,
                              availableIngredients: availableIngredients,
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
}

class _FormulaCard extends StatelessWidget {
  const _FormulaCard({
    required this.ref,
    required this.formula,
    required this.availableIngredients,
  });

  final WidgetRef ref;
  final FormulaOverview formula;
  final List<IngredientOverview> availableIngredients;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  feedFormulaNameLabel(
                    formula.formula.name,
                    formula.formula.phase,
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Chip(label: Text('v${formula.formula.version}')),
              IconButton(
                tooltip: 'Editar formulação',
                onPressed: availableIngredients.isEmpty
                    ? null
                    : () => showDialog<void>(
                        context: context,
                        builder: (_) => _FormulaDialog(
                          ref: ref,
                          formula: formula,
                          availableIngredients: availableIngredients,
                          editCurrent: true,
                        ),
                      ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: formula.formula.isActive
                    ? 'Desativar formulação'
                    : 'Ativar formulação',
                onPressed: () async {
                  try {
                    await ref
                        .read(operationsControllerProvider)
                        .updateFormula(
                          source: formula,
                          name: formula.formula.name,
                          phase: formula.formula.phase,
                          isActive: !formula.formula.isActive,
                          values: {
                            for (final ingredient in formula.items)
                              ingredient.ingredientId: ingredient.quantityKg,
                          },
                          notes: formula.formula.notes,
                        );
                  } catch (e) {
                    if (context.mounted) await showOperationError(context, e);
                  }
                },
                icon: Icon(
                  formula.formula.isActive
                      ? Icons.block
                      : Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          Text(
            formula.formula.isActive ? 'Formulação vigente' : 'Histórico',
            style: TextStyle(
              color: formula.formula.isActive
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(),
          for (final ingredient in formula.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: Text(ingredient.name)),
                  Text(kg(ingredient.quantityKg)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    formula.formula.isActive && availableIngredients.isNotEmpty
                    ? () => showDialog<void>(
                        context: context,
                        builder: (_) => _FormulaDialog(
                          ref: ref,
                          formula: formula,
                          availableIngredients: availableIngredients,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.fork_right_outlined),
                label: const Text('Nova versão'),
              ),
              FilledButton.icon(
                onPressed: formula.formula.isActive
                    ? () => showDialog<void>(
                        context: context,
                        builder: (_) =>
                            _ManufactureDialog(ref: ref, formula: formula),
                      )
                    : null,
                icon: const Icon(Icons.factory_outlined),
                label: const Text('Fabricar'),
              ),
            ],
          ),
        ],
      ),
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
        data: (items) => SeletoTabList(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _ReadyFeedDialog(ref: ref),
                ),
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Ração pronta'),
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const SeletoEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Nenhuma ração em estoque',
                message:
                    'Fabrique uma formulação ou cadastre uma ração pronta.',
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
                      leading: CircleAvatar(
                        child: Icon(
                          b.isReadyFeed
                              ? Icons.shopping_bag_outlined
                              : Icons.factory_outlined,
                        ),
                      ),
                      title: Text(
                        b.isReadyFeed
                            ? '${b.displayName} · ${b.batch.code}'
                            : '${b.batch.code} · ${feedPhaseLabel(b.batch.phase)}',
                      ),
                      subtitle: Text(
                        '${b.isReadyFeed ? 'Pronta' : 'Fabricada'} · ${shortDate.format(b.batch.producedAt)} · ${kg(b.batch.producedQuantityKg)} · ${money(b.batch.totalCostCents)}',
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
          return SeletoTabList(
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
              const SizedBox(height: 12),
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
                        title: Text(
                          b.isReadyFeed
                              ? '${b.displayName} · ${b.batch.code}'
                              : b.batch.code,
                        ),
                        subtitle: Text(
                          '${b.isReadyFeed ? 'Pronta' : 'Fabricada'} · ${feedPhaseLabel(b.batch.phase)} · Entrada ${kg(b.batch.producedQuantityKg)} · Consumido ${kg(b.consumedKg)}',
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
        data: (items) => SeletoTabList(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _importConsumption(context),
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Importar consumo'),
                  ),
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _FeedingDialog(ref: ref),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar alimentação'),
                  ),
                ],
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

  Future<void> _importConsumption(BuildContext context) async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: 'Importar consumo por ave',
        type: FileType.custom,
        allowedExtensions: ['json', 'csv', 'xlsx', 'xlsl'],
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final result = await ref
          .read(operationsControllerProvider)
          .importFeedRecommendations(picked.name, bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Consumo importado: ${result.rowCount} recomendação(ões).',
            ),
          ),
        );
      }
    } catch (e) {
      await showOperationError(context, e);
    }
  }
}

class _IngredientDialog extends StatefulWidget {
  const _IngredientDialog({required this.ref, this.item});
  final WidgetRef ref;
  final IngredientOverview? item;
  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final name = TextEditingController();
  final unit = TextEditingController(text: 'kg');
  final notes = TextEditingController();
  bool isActive = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item?.ingredient;
    if (item == null) return;
    name.text = item.name;
    unit.text = item.unit;
    notes.text = item.notes ?? '';
    isActive = item.isActive;
  }

  @override
  void dispose() {
    name.dispose();
    unit.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item == null ? 'Novo insumo' : 'Editar insumo'),
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
          if (widget.item != null) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isActive,
              onChanged: saving
                  ? null
                  : (value) => setState(() => isActive = value),
              title: const Text('Insumo ativo'),
            ),
          ],
        ],
      ),
    ),
    actions: _actions(context, () async {
      final item = widget.item?.ingredient;
      if (item == null) {
        await widget.ref
            .read(operationsControllerProvider)
            .addIngredient(name.text, unit.text, notes.text);
        return;
      }
      await widget.ref
          .read(operationsControllerProvider)
          .updateIngredient(
            ingredientId: item.id,
            name: name.text,
            unit: unit.text,
            isActive: isActive,
            notes: notes.text,
          );
    }),
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
            .watchIngredientPrices(
              item.ingredient.id,
              tenantId: _tenantScope(ref),
            ),
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

String? _tenantScope(WidgetRef ref) {
  final session = ref.read(authControllerProvider).session;
  return session?.allows('tenant.view_all') == true ? null : session?.tenantId;
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

class _IngredientTransferDialog extends StatefulWidget {
  const _IngredientTransferDialog({
    required this.ref,
    required this.ingredients,
  });
  final WidgetRef ref;
  final List<IngredientOverview> ingredients;

  @override
  State<_IngredientTransferDialog> createState() =>
      _IngredientTransferDialogState();
}

class _IngredientTransferDialogState extends State<_IngredientTransferDialog> {
  String? fromIngredientId;
  String? toIngredientId;
  final quantity = TextEditingController();
  final notes = TextEditingController();
  bool saving = false;

  List<IngredientOverview> get sourceIngredients => widget.ingredients
      .where((item) => item.ingredient.isActive && item.stockKg > .0001)
      .toList();

  List<IngredientOverview> get targetIngredients => widget.ingredients
      .where(
        (item) =>
            item.ingredient.isActive && item.ingredient.id != fromIngredientId,
      )
      .toList();

  IngredientOverview? get sourceIngredient => sourceIngredients
      .where((item) => item.ingredient.id == fromIngredientId)
      .firstOrNull;

  @override
  void initState() {
    super.initState();
    fromIngredientId = sourceIngredients.firstOrNull?.ingredient.id;
    toIngredientId = targetIngredients.firstOrNull?.ingredient.id;
  }

  @override
  void dispose() {
    quantity.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = sourceIngredient;
    final targets = targetIngredients;
    if (toIngredientId != null &&
        !targets.any((item) => item.ingredient.id == toIngredientId)) {
      toIngredientId = targets.firstOrNull?.ingredient.id;
    }
    return AlertDialog(
      title: const Text('Transferir estoque'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: fromIngredientId,
                decoration: const InputDecoration(labelText: 'Origem'),
                items: [
                  for (final item in sourceIngredients)
                    DropdownMenuItem(
                      value: item.ingredient.id,
                      child: Text(
                        '${item.ingredient.name} · ${kg(item.stockKg)}',
                      ),
                    ),
                ],
                onChanged: saving
                    ? null
                    : (value) => setState(() {
                        fromIngredientId = value;
                        toIngredientId =
                            targetIngredients.firstOrNull?.ingredient.id;
                      }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: toIngredientId,
                decoration: const InputDecoration(labelText: 'Destino'),
                items: [
                  for (final item in targets)
                    DropdownMenuItem(
                      value: item.ingredient.id,
                      child: Text(item.ingredient.name),
                    ),
                ],
                onChanged: saving
                    ? null
                    : (value) => setState(() => toIngredientId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantity,
                enabled: !saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  suffixText: 'kg',
                  helperText: source == null
                      ? null
                      : 'Disponível: ${kg(source.stockKg)}',
                ),
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
          onPressed:
              saving || fromIngredientId == null || toIngredientId == null
              ? null
              : () async {
                  setState(() => saving = true);
                  try {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .transferIngredientStock(
                          fromIngredientId: fromIngredientId!,
                          toIngredientId: toIngredientId!,
                          quantityKg: parseDecimal(quantity.text),
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
              : const Text('Transferir'),
        ),
      ],
    );
  }
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

class _ReadyFeedDialog extends StatefulWidget {
  const _ReadyFeedDialog({required this.ref});
  final WidgetRef ref;
  @override
  State<_ReadyFeedDialog> createState() => _ReadyFeedDialogState();
}

class _ReadyFeedDialogState extends State<_ReadyFeedDialog> {
  final name = TextEditingController();
  final quantity = TextEditingController();
  final totalCost = TextEditingController();
  final supplier = TextEditingController();
  final notes = TextEditingController();
  String phase = 'CRESCIMENTO';
  DateTime date = DateTime.now();
  bool saving = false;

  @override
  void dispose() {
    name.dispose();
    quantity.dispose();
    totalCost.dispose();
    supplier.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Ração pronta'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: phase,
              decoration: const InputDecoration(labelText: 'Fase'),
              items: const [
                DropdownMenuItem(value: 'CRIA', child: Text('Cria')),
                DropdownMenuItem(
                  value: 'CRESCIMENTO',
                  child: Text('Crescimento'),
                ),
                DropdownMenuItem(value: 'POSTURA', child: Text('Postura')),
                DropdownMenuItem(
                  value: 'MANUTENCAO',
                  child: Text('Manutenção'),
                ),
              ],
              onChanged: saving
                  ? null
                  : (value) => setState(() => phase = value!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantity,
                    enabled: !saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      suffixText: 'kg',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: totalCost,
                    enabled: !saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Valor total',
                      prefixText: 'R\$ ',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: !saving,
              title: const Text('Data da compra'),
              subtitle: Text(shortDate.format(date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: saving
                  ? null
                  : () async {
                      final selected = await pickSeletoDate(context, date);
                      if (selected != null) setState(() => date = selected);
                    },
            ),
            TextField(
              controller: supplier,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Fornecedor'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Observações'),
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
                      .addReadyFeed(
                        name: name.text,
                        phase: phase,
                        quantityKg: parseDecimal(quantity.text),
                        totalCost: parseMoneyToCents(totalCost.text),
                        date: date,
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
            : const Text('Cadastrar'),
      ),
    ],
  );
}

class _ManufactureDialogState extends State<_ManufactureDialog> {
  late final double? recommendedQuantity = _recommendedManufactureQuantity(
    widget.formula.formula.phase,
  );
  late final quantity = TextEditingController(
    text: decimal.format(recommendedQuantity ?? 100),
  );
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
    title: Text(
      'Fabricar · ${feedFormulaNameLabel(widget.formula.formula.name, widget.formula.formula.phase)}',
    ),
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
            runSpacing: 8,
            children: [
              for (final v in _manufactureQuantityOptions(recommendedQuantity))
                ActionChip(
                  label: Text('${decimal.format(v)} kg'),
                  onPressed: () => quantity.text = decimal.format(v),
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

double? _recommendedManufactureQuantity(String phase) {
  final normalized = phase.trim().toUpperCase();
  return switch (normalized) {
    'RECRIA' || 'CRESCIMENTO' => 55,
    'PRE_POSTURA' => 45,
    _ => null,
  };
}

List<double> _manufactureQuantityOptions(double? recommended) {
  final values = <double>[?recommended, 25, 45, 50, 55, 100, 150, 200];
  return values.toSet().toList();
}

bool _isAllowedFormulaIngredient(String name) {
  final normalized = name.trim().toLowerCase();
  return const {
    'xerem fino',
    'farelo de soja fino',
    'farelo de trigo',
    'calcário calcítico',
    'calcario calcitico',
    'meganúcleo frango c 4%',
    'meganucleo frango c 4%',
    'meganúcleo postura 4%',
    'meganucleo postura 4%',
    'urucum',
    'cúrcuma',
    'curcuma',
  }.contains(normalized);
}

class _FormulaDialog extends StatefulWidget {
  const _FormulaDialog({
    required this.ref,
    required this.formula,
    required this.availableIngredients,
    this.editCurrent = false,
  });
  final WidgetRef ref;
  final FormulaOverview formula;
  final List<IngredientOverview> availableIngredients;
  final bool editCurrent;
  @override
  State<_FormulaDialog> createState() => _FormulaDialogState();
}

class _FormulaItemController {
  _FormulaItemController({required this.ingredientId, required double quantity})
    : quantity = TextEditingController(text: decimal.format(quantity));

  String? ingredientId;
  final TextEditingController quantity;

  void dispose() => quantity.dispose();
}

class _FormulaDialogState extends State<_FormulaDialog> {
  late final name = TextEditingController(text: widget.formula.formula.name);
  late final phase = TextEditingController(text: widget.formula.formula.phase);
  late final notes = TextEditingController(
    text: widget.formula.formula.notes ?? '',
  );
  late final List<_FormulaItemController> items = [
    for (final i in widget.formula.items)
      _FormulaItemController(
        ingredientId: i.ingredientId,
        quantity: i.quantityKg,
      ),
  ];
  late bool isActive = widget.formula.formula.isActive;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    phase.dispose();
    notes.dispose();
    for (final item in items) {
      item.dispose();
    }
    super.dispose();
  }

  List<DropdownMenuItem<String>> _ingredientItems(
    _FormulaItemController current,
  ) {
    final currentId = current.ingredientId;
    final selected = _selectedIngredientKeys(except: current);
    final result = <DropdownMenuItem<String>>[];
    final visibleKeys = <String>{};
    if (currentId != null) {
      result.add(
        DropdownMenuItem(
          value: currentId,
          child: Text(_formulaIngredientName(currentId)),
        ),
      );
      visibleKeys.add(_ingredientKey(currentId));
    }
    for (final ingredient in widget.availableIngredients) {
      final ingredientId = ingredient.ingredient.id;
      if (ingredientId == currentId) continue;
      final key = _ingredientKey(ingredientId);
      if (selected.contains(key) || visibleKeys.contains(key)) {
        continue;
      }
      result.add(
        DropdownMenuItem(
          value: ingredientId,
          child: Text(
            ingredient.ingredient.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
      );
      visibleKeys.add(key);
    }
    return result;
  }

  String _formulaIngredientName(String ingredientId) =>
      widget.formula.items
          .where((item) => item.ingredientId == ingredientId)
          .firstOrNull
          ?.name ??
      widget.availableIngredients
          .where((item) => item.ingredient.id == ingredientId)
          .firstOrNull
          ?.ingredient
          .name ??
      ingredientId;

  String _ingredientKey(String ingredientId) =>
      _formulaIngredientName(ingredientId).trim().toUpperCase();

  bool _isIngredientSelectedInAnotherRow(String ingredientId, int index) {
    final key = _ingredientKey(ingredientId);
    for (var i = 0; i < items.length; i++) {
      final otherId = items[i].ingredientId;
      if (i == index || otherId == null) continue;
      if (_ingredientKey(otherId) == key &&
          parseDecimal(items[i].quantity.text) > 0) {
        return true;
      }
    }
    return false;
  }

  void _changeIngredient(BuildContext context, int index, String? value) {
    if (value != null && _isIngredientSelectedInAnotherRow(value, index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este insumo já está na formulação.')),
      );
      return;
    }
    setState(() => items[index].ingredientId = value);
  }

  Set<String> _selectedIngredientKeys({_FormulaItemController? except}) => items
      .where((item) => item != except && parseDecimal(item.quantity.text) > 0)
      .map((item) => item.ingredientId)
      .nonNulls
      .map(_ingredientKey)
      .toSet();

  String? _nextAvailableIngredientId() {
    final selected = _selectedIngredientKeys();
    return widget.availableIngredients
        .where(
          (ingredient) =>
              !selected.contains(_ingredientKey(ingredient.ingredient.id)),
        )
        .firstOrNull
        ?.ingredient
        .id;
  }

  bool _isExplicitZero(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    return RegExp(r'^0+([.]0+)?$').hasMatch(cleaned);
  }

  void _handleQuantityChanged(int index, String value) {
    if (_isExplicitZero(value) && items.length > 1) {
      setState(() {
        final removed = items.removeAt(index);
        removed.dispose();
      });
      return;
    }
    setState(() {});
  }

  Map<String, double> _quantities() {
    final result = <String, double>{};
    final usedKeys = <String>{};
    for (final item in items) {
      final ingredientId = item.ingredientId;
      final quantity = parseDecimal(item.quantity.text);
      if (quantity < 0) {
        throw ArgumentError('Informe apenas quantidades positivas.');
      }
      if (quantity == 0) {
        continue;
      }
      if (ingredientId == null) {
        throw ArgumentError('Selecione todos os insumos da formulação.');
      }
      final key = _ingredientKey(ingredientId);
      if (result.containsKey(ingredientId) || usedKeys.contains(key)) {
        throw ArgumentError('Não repita o mesmo insumo na formulação.');
      }
      usedKeys.add(key);
      result[ingredientId] = quantity;
    }
    if (result.isEmpty) {
      throw ArgumentError('Mantenha pelo menos um insumo na formulação.');
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.editCurrent
          ? 'Editar formulação'
          : 'Nova versão · ${feedFormulaNameLabel(widget.formula.formula.name, widget.formula.formula.phase)}',
    ),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.editCurrent) ...[
              TextField(
                controller: name,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phase,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'Fase'),
              ),
              const SizedBox(height: 10),
            ],
            for (var index = 0; index < items.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(
                          'formula-item-$index-${items[index].ingredientId}',
                        ),
                        initialValue: items[index].ingredientId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Insumo'),
                        items: _ingredientItems(items[index]),
                        onChanged: saving
                            ? null
                            : (value) =>
                                  _changeIngredient(context, index, value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: items[index].quantity,
                        enabled: !saving,
                        onChanged: (value) =>
                            _handleQuantityChanged(index, value),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Kg',
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: saving || _nextAvailableIngredientId() == null
                    ? null
                    : () => setState(
                        () => items.add(
                          _FormulaItemController(
                            ingredientId: _nextAvailableIngredientId(),
                            quantity: 0,
                          ),
                        ),
                      ),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar insumo'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notes,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Observação'),
            ),
            if (widget.editCurrent) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isActive,
                onChanged: saving
                    ? null
                    : (value) => setState(() => isActive = value),
                title: const Text('Formulação ativa'),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              widget.editCurrent
                  ? 'A soma representa o tamanho base desta formulação.'
                  : 'A soma representa o tamanho base desta formulação. O histórico anterior será preservado.',
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
                  final quantities = _quantities();
                  if (widget.editCurrent) {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .updateFormula(
                          source: widget.formula,
                          name: name.text,
                          phase: phase.text,
                          isActive: isActive,
                          values: quantities,
                          notes: notes.text,
                        );
                  } else {
                    await widget.ref
                        .read(operationsControllerProvider)
                        .saveFormula(widget.formula, quantities, notes.text);
                  }
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  await showOperationError(context, e);
                  if (mounted) setState(() => saving = false);
                }
              },
        child: Text(widget.editCurrent ? 'Salvar' : 'Criar versão'),
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
  DateTime date = DateTime.now();
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
    final recommendations =
        widget.ref.watch(feedRecommendationsProvider).asData?.value ??
        <FeedConsumptionRecommendation>[];
    final selectedLot = lots.where((item) => item.lot.id == lot).firstOrNull;
    final selectedAgeDays = selectedLot == null
        ? null
        : LotLifecycle.ageInDays(
            receivedAt: selectedLot.lot.receivedAt,
            arrivalAgeDays: selectedLot.lot.arrivalAgeDays,
            on: date,
          );
    final selectedAgeWeeks = selectedAgeDays == null
        ? null
        : selectedAgeDays ~/ 7;
    final recommendation = selectedAgeWeeks == null
        ? null
        : _recommendationForAge(recommendations, selectedAgeWeeks);
    final recommendedKg = selectedLot == null || recommendation == null
        ? null
        : selectedLot.activeBirds * recommendation.gramsPerBirdDay / 1000;
    final selectedBatch = batches
        .where((item) => item.batch.id == batch)
        .firstOrNull;
    void selectBatchForLot(String? lotId) {
      final summary = lots.where((item) => item.lot.id == lotId).firstOrNull;
      if (summary == null) return;
      final age = LotLifecycle.ageInDays(
        receivedAt: summary.lot.receivedAt,
        arrivalAgeDays: summary.lot.arrivalAgeDays,
        on: date,
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
              .where((item) => item.balanceKg > 0 && item.batch.phase == phase)
              .toList()
            ..sort((a, b) => a.batch.producedAt.compareTo(b.batch.producedAt));
      batch = compatible.firstOrNull?.batch.id;
    }

    return AlertDialog(
      title: const Text('Registrar alimentação'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: lot,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Lote'),
                items: [
                  for (final l in lots.where((l) => l.activeBirds > 0))
                    DropdownMenuItem(
                      value: l.lot.id,
                      child: Text(
                        '${l.lot.name} · ${l.activeBirds} aves',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                ],
                onChanged: saving
                    ? null
                    : (v) {
                        setState(() {
                          lot = v;
                          selectBatchForLot(v);
                        });
                      },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !saving,
                title: const Text('Data da alimentação'),
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
                        if (picked == null) return;
                        setState(() {
                          date = picked;
                          selectBatchForLot(lot);
                        });
                      },
              ),
              const SizedBox(height: 12),
              _FeedRecommendationPanel(
                activeBirds: selectedLot?.activeBirds,
                ageDays: selectedAgeDays,
                ageWeeks: selectedAgeWeeks,
                recommendation: recommendation,
                recommendedKg: recommendedKg,
                onUseRecommendation: recommendedKg == null || saving
                    ? null
                    : () => setState(
                        () => qty.text = decimal.format(recommendedKg),
                      ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: batch,
                isExpanded: true,
                menuMaxHeight: 360,
                decoration: const InputDecoration(
                  labelText: 'Fabricação de ração',
                ),
                items: [
                  for (final b in batches.where((b) => b.balanceKg > 0))
                    DropdownMenuItem(
                      value: b.batch.id,
                      child: Text(
                        '${b.displayName} · ${feedPhaseLabel(b.batch.phase)} · ${kg(b.balanceKg)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                ],
                onChanged: saving ? null : (v) => setState(() => batch = v),
              ),
              const SizedBox(height: 12),
              _SelectedFeedStockPanel(batch: selectedBatch),
              const SizedBox(height: 12),
              TextField(
                controller: qty,
                enabled: !saving,
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
                          date,
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

  FeedConsumptionRecommendation? _recommendationForAge(
    List<FeedConsumptionRecommendation> recommendations,
    int ageWeeks,
  ) {
    for (final item in recommendations) {
      if (ageWeeks >= item.startWeek &&
          (item.endWeek == null || ageWeeks <= item.endWeek!)) {
        return item;
      }
    }
    return null;
  }
}

class _SelectedFeedStockPanel extends StatelessWidget {
  const _SelectedFeedStockPanel({required this.batch});

  final FeedBatchBalance? batch;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = batch;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .46),
        border: Border.all(color: colors.primary.withValues(alpha: .22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: selected == null
            ? Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selecione uma ração para ver o saldo disponível.',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selected.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FeedStockPill(
                        label: 'Saldo disponível',
                        value: kg(selected.balanceKg),
                      ),
                      _FeedStockPill(
                        label: 'Entrada total',
                        value: kg(selected.batch.producedQuantityKg),
                      ),
                      _FeedStockPill(
                        label: 'Consumido',
                        value: kg(selected.consumedKg),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _FeedStockPill extends StatelessWidget {
  const _FeedStockPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedRecommendationPanel extends StatelessWidget {
  const _FeedRecommendationPanel({
    required this.activeBirds,
    required this.ageDays,
    required this.ageWeeks,
    required this.recommendation,
    required this.recommendedKg,
    required this.onUseRecommendation,
  });

  final int? activeBirds;
  final int? ageDays;
  final int? ageWeeks;
  final FeedConsumptionRecommendation? recommendation;
  final double? recommendedKg;
  final VoidCallback? onUseRecommendation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: colors.onSecondaryContainer);
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colors.onSecondaryContainer);
    final rec = recommendation;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: rec == null || recommendedKg == null
          ? Text(
              ageWeeks == null
                  ? 'Recomendação: selecione um lote.'
                  : 'Sem recomendação cadastrada para $ageWeeks semana(s).',
              style: titleStyle,
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recomendado: ${kg(recommendedKg!)} / dia',
                        style: titleStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rec.gramsPerBirdDay.toStringAsFixed(0)} g/ave/dia · ${activeBirds ?? 0} aves · ${ageDays ?? 0} dias (${ageWeeks ?? 0} sem.)${rec.source == null ? '' : ' · ${rec.source}'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: bodyStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Usar recomendado',
                  onPressed: onUseRecommendation,
                  icon: const Icon(Icons.check),
                ),
              ],
            ),
    );
  }
}
