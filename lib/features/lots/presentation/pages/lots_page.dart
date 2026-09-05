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
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _showPurchase(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Novo lote'),
          ),
        ),
        const SizedBox(height: SeletoTokens.spacingLg),
        LayoutBuilder(
          builder: (context, box) {
            final crossAxisCount = box.maxWidth >= 850
                ? 3
                : box.maxWidth >= 510
                ? 2
                : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: crossAxisCount == 1 ? 3.2 : 1.85,
              children: [
                _SummaryCard(
                  label: 'Aves ativas',
                  value: '$birds',
                  icon: Icons.egg_alt_outlined,
                ),
                _SummaryCard(
                  label: 'Lotes ativos',
                  value: '$activeLots',
                  icon: Icons.view_module_outlined,
                ),
                _SummaryCard(
                  label: 'Próxima mudança',
                  value: _nextChange(lots),
                  icon: Icons.event_available_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: SeletoTokens.spacingLg),
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
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 238,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ],
      ),
    ),
  );
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lot.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _PhaseChip(label: phase.label, inactive: !isActive),
                PopupMenuButton<String>(
                  tooltip: 'Ações do lote',
                  onSelected: (value) => value == 'EDIT'
                      ? showDialog<void>(
                          context: context,
                          builder: (_) => _EditLotDialog(ref: ref, lot: lot),
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
            const SizedBox(height: 8),
            Text(
              lot.strain?.isNotEmpty == true
                  ? lot.strain!
                  : 'Linhagem não informada',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _LotMetric(
                  value: '${summary.activeBirds}',
                  label: 'aves ativas',
                ),
                const SizedBox(width: 24),
                _LotMetric(value: '$age dias', label: 'idade atual'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              next == null
                  ? 'Última fase alimentar'
                  : 'Próxima fase: ${LotLifecycle.nextPhase(phase)!.label} · ${DateFormat('dd/MM/yyyy').format(next)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openOutflow(BuildContext context, WidgetRef ref, String type) =>
      showDialog<void>(
        context: context,
        builder: (_) => _OutflowDialog(ref: ref, lot: summary, type: type),
      );
}

class _LotMetric extends StatelessWidget {
  const _LotMetric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: Theme.of(context).textTheme.titleMedium),
      Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.label, required this.inactive});
  final String label;
  final bool inactive;
  @override
  Widget build(BuildContext context) => Chip(
    visualDensity: VisualDensity.compact,
    label: Text(inactive ? 'Encerrado' : label),
    avatar: Icon(
      inactive ? Icons.archive_outlined : Icons.eco_outlined,
      size: 16,
    ),
  );
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
            const SizedBox(height: 20),
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
              const SizedBox(height: 22),
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
    .replaceFirst('Invalid argument(s): ', '');
