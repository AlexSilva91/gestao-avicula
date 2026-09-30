import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/design_tokens.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../application/lots_controller.dart';
import '../../domain/value_objects/lot_lifecycle.dart';

class LotsPage extends ConsumerWidget {
  const LotsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
    title: 'Lotes',
    child: ref
        .watch(lotSummariesProvider)
        .when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, _) => const _LotError(),
          data: (lots) => _LotsContent(lots: lots),
        ),
  );
}

class _LotsContent extends ConsumerWidget {
  const _LotsContent({required this.lots});
  final List<LotSummary> lots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLots = lots.where((lot) => lot.activeBirds > 0).length;
    final birds = lots.fold<int>(0, (total, lot) => total + lot.activeBirds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LotsToolbar(
          lotCount: lots.length,
          activeLots: activeLots,
          birds: birds,
          nextChange: _nextChange(lots),
          onCreate: () => _showPurchase(context, ref),
        ),
        const SizedBox(height: SeletoTokens.spacingSm),
        if (lots.isEmpty)
          _LotEmpty(onCreate: () => _showPurchase(context, ref))
        else
          LayoutBuilder(
            builder: (context, box) {
              final columns = box.maxWidth >= SeletoTokens.expandedBreakpoint
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 136,
                ),
                itemCount: lots.length,
                itemBuilder: (_, index) => _LotCard(summary: lots[index]),
              );
            },
          ),
      ],
    );
  }

  String _nextChange(List<LotSummary> items) {
    DateTime? earliest;
    for (final item in items.where((lot) => lot.activeBirds > 0)) {
      final age = LotLifecycle.ageInDays(
        receivedAt: item.lot.receivedAt,
        arrivalAgeDays: item.lot.arrivalAgeDays,
      );
      final phase = LotLifecycle.phaseForAge(age);
      final date = LotLifecycle.nextPhaseDate(
        birthDate: LotLifecycle.estimatedBirthDate(
          receivedAt: item.lot.receivedAt,
          arrivalAgeDays: item.lot.arrivalAgeDays,
        ),
        currentPhase: phase,
      );
      if (date != null && (earliest == null || date.isBefore(earliest))) {
        earliest = date;
      }
    }
    return earliest == null ? '—' : DateFormat('dd/MM').format(earliest);
  }

  void _showPurchase(BuildContext context, WidgetRef ref) => showDialog<void>(
    context: context,
    builder: (_) => _LotFormDialog(ref: ref),
  );
}

class _LotsToolbar extends StatelessWidget {
  const _LotsToolbar({
    required this.lotCount,
    required this.activeLots,
    required this.birds,
    required this.nextChange,
    required this.onCreate,
  });

  final int lotCount;
  final int activeLots;
  final int birds;
  final String nextChange;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withValues(alpha: .90),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .72)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: LayoutBuilder(
          builder: (context, box) {
            final compact = box.maxWidth < 640;
            final stats = Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _ToolbarStat(
                  icon: Icons.groups_2_outlined,
                  label: 'Aves',
                  value: '$birds',
                ),
                _ToolbarStat(
                  icon: Icons.view_module_outlined,
                  label: 'Ativos',
                  value: '$activeLots/$lotCount',
                ),
                _ToolbarStat(
                  icon: Icons.event_available_outlined,
                  label: 'Mudança',
                  value: nextChange,
                ),
              ],
            );
            final action = FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Novo lote'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  stats,
                  const SizedBox(height: 6),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: stats),
                const SizedBox(width: 8),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ToolbarStat extends StatelessWidget {
  const _ToolbarStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 32,
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .52),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .62)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 5),
          Text(
            '$label ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _LotFactLine extends StatelessWidget {
  const _LotFactLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 13, color: scheme.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _LotStatCell extends StatelessWidget {
  const _LotStatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LotCard extends ConsumerWidget {
  const _LotCard({required this.summary});
  final LotSummary summary;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lot = summary.lot;
    final age = LotLifecycle.ageInDays(
      receivedAt: lot.receivedAt,
      arrivalAgeDays: lot.arrivalAgeDays,
    );
    final phase = LotLifecycle.phaseForAge(age);
    final next = LotLifecycle.nextPhaseDate(
      birthDate: LotLifecycle.estimatedBirthDate(
        receivedAt: lot.receivedAt,
        arrivalAgeDays: lot.arrivalAgeDays,
      ),
      currentPhase: phase,
    );
    final isActive = summary.activeBirds > 0;
    final scheme = Theme.of(context).colorScheme;
    final strain = lot.strain?.isNotEmpty == true
        ? lot.strain!
        : 'Sem linhagem';
    final entryDate = DateFormat('dd/MM/yy').format(lot.receivedAt);
    final nextLabel = next == null
        ? 'Última fase alimentar'
        : '${LotLifecycle.nextPhase(phase)!.label} em ${DateFormat('dd/MM/yyyy').format(next)}';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: ColoredBox(
              color: isActive
                  ? scheme.primary.withValues(alpha: .86)
                  : scheme.outline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 8, 7, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lot.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _PhaseChip(label: phase.label, inactive: !isActive),
                    PopupMenuButton<String>(
                      tooltip: 'Ações do lote',
                      padding: EdgeInsets.zero,
                      splashRadius: 18,
                      constraints: const BoxConstraints.tightFor(
                        width: 30,
                        height: 30,
                      ),
                      icon: const Icon(Icons.more_vert_rounded, size: 18),
                      onSelected: (value) => value == 'EDIT'
                          ? showDialog<void>(
                              context: context,
                              builder: (_) =>
                                  _EditLotDialog(ref: ref, lot: lot),
                            )
                          : _openOutflow(context, ref, value),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'EDIT',
                          child: Text('Editar dados do lote'),
                        ),
                        PopupMenuItem(
                          value: 'SALE',
                          enabled: isActive,
                          child: Text('Registrar venda de aves'),
                        ),
                        PopupMenuItem(
                          value: 'MORTALITY',
                          enabled: isActive,
                          child: Text('Registrar mortalidade'),
                        ),
                        PopupMenuItem(
                          value: 'ADJUSTMENT_OUT',
                          enabled: isActive,
                          child: Text('Registrar ajuste de saída'),
                        ),
                        const PopupMenuItem(
                          value: 'ADJUSTMENT_IN',
                          child: Text('Registrar ajuste de entrada'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _LotFactLine(
                        icon: Icons.category_outlined,
                        label: strain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _LotFactLine(
                        icon: Icons.event_outlined,
                        label: 'Entrada $entryDate',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow.withValues(alpha: .82),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: .62),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _LotStatCell(
                        label: 'Aves',
                        value: '${summary.activeBirds}',
                      ),
                      VerticalDivider(
                        width: 14,
                        thickness: 1,
                        color: scheme.outlineVariant.withValues(alpha: .72),
                      ),
                      _LotStatCell(
                        label: 'Idade',
                        value: LotLifecycle.ageLabel(age),
                      ),
                      VerticalDivider(
                        width: 14,
                        thickness: 1,
                        color: scheme.outlineVariant.withValues(alpha: .72),
                      ),
                      _LotStatCell(
                        label: 'Total',
                        value: LotLifecycle.ageTotalLabel(age),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      next == null
                          ? Icons.check_circle_outline
                          : Icons.event_available_outlined,
                      size: 14,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        nextLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openOutflow(BuildContext context, WidgetRef ref, String type) =>
      showDialog<void>(
        context: context,
        builder: (_) => _OutflowDialog(ref: ref, lot: summary, type: type),
      );
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.label, required this.inactive});
  final String label;
  final bool inactive;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: inactive
            ? scheme.surfaceContainerHighest
            : scheme.primaryContainer.withValues(alpha: .74),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inactive ? Icons.archive_outlined : Icons.eco_outlined,
            size: 13,
            color: inactive ? scheme.onSurfaceVariant : scheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            inactive ? 'Encerrado' : label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: inactive ? scheme.onSurfaceVariant : scheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LotEmpty extends StatelessWidget {
  const _LotEmpty({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(SeletoTokens.spacingXl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.egg_alt_outlined,
              size: 54,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum lote cadastrado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre o primeiro lote para iniciar o acompanhamento.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Novo lote'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LotError extends StatelessWidget {
  const _LotError();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Não foi possível carregar os lotes.'));
}

class _LotFormDialog extends ConsumerStatefulWidget {
  const _LotFormDialog({required this.ref});
  final WidgetRef ref;
  @override
  ConsumerState<_LotFormDialog> createState() => _LotFormDialogState();
}

class _LotFormDialogState extends ConsumerState<_LotFormDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _strain = TextEditingController();
  final _quantity = TextEditingController();
  final _age = TextEditingController();
  final _unitValue = TextEditingController();
  final _supplier = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _strain,
      _quantity,
      _age,
      _unitValue,
      _supplier,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Cadastrar lote'),
    content: SizedBox(
      width: 620,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Identificação',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nome do lote *',
                  hintText: 'Ex.: LOTE 30',
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _strain,
                decoration: const InputDecoration(labelText: 'Linhagem'),
              ),
              const SizedBox(height: 14),
              Text(
                'Recebimento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              _DateField(
                date: _date,
                onChanged: (date) => setState(() => _date = date),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, box) {
                  final fields = [
                    TextFormField(
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade *',
                        suffixText: 'aves',
                      ),
                      validator: _positive,
                    ),
                    TextFormField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Idade na chegada *',
                        suffixText: 'dias',
                      ),
                      validator: _nonNegative,
                    ),
                  ];
                  return box.maxWidth > 480
                      ? Row(
                          children: [
                            Expanded(child: fields[0]),
                            const SizedBox(width: 12),
                            Expanded(child: fields[1]),
                          ],
                        )
                      : Column(
                          children: [
                            fields[0],
                            const SizedBox(height: 12),
                            fields[1],
                          ],
                        );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitValue,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor unitário',
                  prefixText: 'R\$ ',
                ),
                validator: _money,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _supplier,
                decoration: const InputDecoration(labelText: 'Fornecedor'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Observações'),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_saving ? 'Salvando...' : 'Cadastrar'),
      ),
    ],
  );

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await widget.ref
          .read(lotsControllerProvider)
          .purchase(
            name: _name.text,
            strain: _strain.text,
            quantity: int.parse(_quantity.text),
            receivedAt: _date,
            arrivalAgeDays: int.parse(_age.text),
            unitValueCents: _toCents(_unitValue.text),
            supplier: _supplier.text,
            notes: _notes.text,
          );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _OutflowDialog extends ConsumerStatefulWidget {
  const _OutflowDialog({
    required this.ref,
    required this.lot,
    required this.type,
  });
  final WidgetRef ref;
  final LotSummary lot;
  final String type;
  @override
  ConsumerState<_OutflowDialog> createState() => _OutflowDialogState();
}

class _OutflowDialogState extends ConsumerState<_OutflowDialog> {
  final _form = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _value = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _quantity.dispose();
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSale = widget.type == 'SALE';
    final isInput = widget.type == 'ADJUSTMENT_IN';
    final title = isSale
        ? 'Venda de aves'
        : widget.type == 'MORTALITY'
        ? 'Registrar mortalidade'
        : isInput
        ? 'Ajuste de entrada'
        : 'Ajuste de saída';
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.lot.lot.name} · ${widget.lot.activeBirds} aves disponíveis',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade *',
                  suffixText: 'aves',
                ),
                validator: (value) {
                  final number = int.tryParse(value ?? '');
                  if (number == null || number <= 0) {
                    return 'Informe uma quantidade válida.';
                  }
                  return !isInput && number > widget.lot.activeBirds
                      ? 'O saldo disponível é ${widget.lot.activeBirds}.'
                      : null;
                },
              ),
              if (isSale) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _value,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor por ave',
                    prefixText: 'R\$ ',
                  ),
                  validator: _money,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isSale ? 'Observações' : 'Causa ou observações',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Salvando...' : 'Registrar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await widget.ref
          .read(lotsControllerProvider)
          .outflow(
            lot: widget.lot,
            type: widget.type,
            quantity: int.parse(_quantity.text),
            occurredAt: DateTime.now(),
            unitValueCents: _toCents(_value.text),
            notes: _notes.text,
          );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _EditLotDialog extends StatefulWidget {
  const _EditLotDialog({required this.ref, required this.lot});
  final WidgetRef ref;
  final Lot lot;
  @override
  State<_EditLotDialog> createState() => _EditLotDialogState();
}

class _EditLotDialogState extends State<_EditLotDialog> {
  late final name = TextEditingController(text: widget.lot.name);
  late final strain = TextEditingController(text: widget.lot.strain);
  late final supplier = TextEditingController(text: widget.lot.supplier);
  late final notes = TextEditingController(text: widget.lot.notes);
  late String status = widget.lot.status;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    strain.dispose();
    supplier.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Editar lote'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Identificação'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: strain,
              decoration: const InputDecoration(labelText: 'Linhagem'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: supplier,
              decoration: const InputDecoration(labelText: 'Fornecedor'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'ACTIVE', child: Text('Ativo')),
                DropdownMenuItem(value: 'INACTIVE', child: Text('Inativo')),
              ],
              onChanged: (v) => setState(() => status = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Observações'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Quantidade inicial, idade e compra permanecem imutáveis para preservar o histórico.',
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
                      .read(lotsControllerProvider)
                      .update(
                        lot: widget.lot,
                        name: name.text,
                        strain: strain.text,
                        supplier: supplier.text,
                        notes: notes.text,
                        status: status,
                      );
                  if (mounted) Navigator.pop(context);
                } catch (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_friendlyError(error))),
                    );
                  }
                } finally {
                  if (mounted) setState(() => saving = false);
                }
              },
        child: const Text('Salvar'),
      ),
    ],
  );
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
    onTap: () async {
      final picked = await pickSeletoDate(
        context,
        date,
        firstDate: DateTime(2010),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) onChanged(picked);
    },
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Data de recebimento *',
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
      child: Text(DateFormat('dd/MM/yyyy').format(date)),
    ),
  );
}

String? _required(String? value) =>
    value?.trim().isEmpty ?? true ? 'Este campo é obrigatório.' : null;
String? _positive(String? value) => (int.tryParse(value ?? '') ?? 0) <= 0
    ? 'Informe um valor maior que zero.'
    : null;
String? _nonNegative(String? value) =>
    (int.tryParse(value ?? '') ?? -1) < 0 ? 'Informe um número válido.' : null;
String? _money(String? value) => value?.trim().isEmpty ?? true
    ? null
    : _toCents(value!) == null
    ? 'Informe um valor válido.'
    : null;
int? _toCents(String value) {
  final text = value.trim();
  final normalized = text.contains(',')
      ? text.replaceAll('.', '').replaceAll(',', '.')
      : text;
  if (normalized.isEmpty) return null;
  final decimal = double.tryParse(normalized);
  return decimal == null || decimal < 0 ? null : (decimal * 100).round();
}

String _friendlyError(Object error) => error
    .toString()
    .replaceFirst('Bad state: ', '')
    .replaceFirst('Invalid argument(s): ', '')
    .replaceFirst('Invalid argument: ', '')
    .replaceFirst('FormatException: ', '');
