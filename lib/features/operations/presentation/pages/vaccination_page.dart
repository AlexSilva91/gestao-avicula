import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/database/app_database.dart';
import '../../../../core/database/operations_repository.dart';
import '../../../../core/platform/file_export_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/seleto_widgets.dart';
import '../../../lots/application/lots_controller.dart';
import '../../application/operations_controller.dart';

class VaccinationPage extends ConsumerStatefulWidget {
  const VaccinationPage({super.key});

  @override
  ConsumerState<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends ConsumerState<VaccinationPage> {
  String _filter = 'ALL';
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final asyncRows = ref.watch(vaccinationRecordsProvider);
    final lots = ref.watch(lotSummariesProvider).asData?.value ?? const [];
    return AppShell(
      title: 'Vacinação',
      child: asyncRows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SeletoAsyncError(),
        data: (rows) {
          final filtered = _filteredRows(rows);
          final applied = rows.where((row) => row.record.status == 'APPLIED');
          final pending = rows.where((row) => row.record.status != 'APPLIED');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeletoPageHeader(
                title: 'Vacinação das aves',
                subtitle:
                    'Agenda, aplicação, edição e relatório sanitário por lote.',
                action: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _exporting ? null : _pickLogo,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Logo do PDF'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _exporting ? null : _exportPdf,
                      icon: _exporting
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('PDF'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openForm(lots),
                      icon: const Icon(Icons.add),
                      label: const Text('Vacina'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SeletoKpiGrid(
                children: [
                  SeletoKpiCard(
                    label: 'Total',
                    value: rows.length.toString(),
                    icon: Icons.vaccines_outlined,
                  ),
                  SeletoKpiCard(
                    label: 'Aplicadas',
                    value: applied.length.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  SeletoKpiCard(
                    label: 'Pendentes',
                    value: pending.length.toString(),
                    icon: Icons.event_available_outlined,
                    color: Colors.orange,
                  ),
                  SeletoKpiCard(
                    label: 'Atrasadas',
                    value: rows
                        .where(
                          (row) =>
                              row.record.status != 'APPLIED' &&
                              row.record.scheduledAt.isBefore(DateTime.now()),
                        )
                        .length
                        .toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in const [
                    ('ALL', 'Todas'),
                    ('SCHEDULED', 'Agendadas'),
                    ('APPLIED', 'Aplicadas'),
                    ('MISSED', 'Atrasadas'),
                    ('CANCELED', 'Canceladas'),
                  ])
                    FilterChip(
                      label: Text(status.$2),
                      selected: _filter == status.$1,
                      onSelected: (_) => setState(() => _filter = status.$1),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                SeletoEmptyState(
                  icon: Icons.vaccines_outlined,
                  title: 'Nenhuma vacinação encontrada',
                  message: 'Cadastre a primeira vacinação ou ajuste o filtro.',
                  action: FilledButton.icon(
                    onPressed: () => _openForm(lots),
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar vacinação'),
                  ),
                )
              else
                SeletoListCard(
                  children: [
                    for (final row in filtered)
                      _VaccinationTile(
                        row: row,
                        onEdit: () => _openForm(lots, row: row),
                        onDelete: () => _confirmDelete(row.record),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  List<VaccinationOverview> _filteredRows(List<VaccinationOverview> rows) {
    final copy = [...rows];
    copy.sort((a, b) => a.record.scheduledAt.compareTo(b.record.scheduledAt));
    if (_filter == 'ALL') return copy;
    return copy.where((row) => row.record.status == _filter).toList();
  }

  Future<void> _openForm(
    List<LotSummary> lots, {
    VaccinationOverview? row,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _VaccinationDialog(lots: lots, row: row),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Vacinação salva.')));
  }

  Future<void> _confirmDelete(VaccinationRecord record) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover vacinação?'),
        content: Text('A vacinação ${record.vaccineName} será removida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(operationsControllerProvider).deleteVaccination(record);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Vacinação removida.')));
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.pickFile(
      dialogTitle: 'Selecionar logo do relatório',
      type: FileType.image,
    );
    if (result == null) return;
    final bytes = await result.readAsBytes();
    await ref
        .read(operationsControllerProvider)
        .saveVaccinationReportLogo(base64Encode(bytes));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logo personalizada salva para o PDF.')),
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final controller = ref.read(operationsControllerProvider);
      final rows = await controller.vaccinationReportRows();
      final logoBytes = await _loadReportLogoBytes(
        await controller.vaccinationReportLogoBase64(),
      );
      final doc = pw.Document();
      final image = pw.MemoryImage(Uint8List.fromList(logoBytes));
      final applied = rows
          .where((row) => row.record.status == 'APPLIED')
          .toList();
      final pending = rows
          .where((row) => row.record.status != 'APPLIED')
          .toList();
      final overdue = pending
          .where((row) => row.record.scheduledAt.isBefore(DateTime.now()))
          .length;
      final generatedAt = DateTime.now();
      doc.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.fromLTRB(32, 26, 32, 30),
          pageTheme: const pw.PageTheme(pageFormat: PdfPageFormat.a4),
          footer: (context) => pw.Container(
            padding: const pw.EdgeInsets.only(top: 7),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: .5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SELETO • Controle de vacinação',
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 8,
                  ),
                ),
                pw.Text(
                  'Página ${context.pageNumber}/${context.pagesCount}',
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          build: (_) => [
            _pdfHeader(image, generatedAt),
            pw.SizedBox(height: 14),
            _pdfSummaryStrip(
              total: rows.length,
              applied: applied.length,
              pending: pending.length,
              overdue: overdue,
            ),
            pw.SizedBox(height: 20),
            _pdfSection(
              title: 'Vacinas aplicadas',
              subtitle: 'Histórico sanitário já executado',
              color: PdfColors.green700,
              child: _pdfTable(applied, applied: true),
            ),
            pw.SizedBox(height: 18),
            _pdfSection(
              title: 'Vacinas a aplicar',
              subtitle: 'Agenda futura, pendências e itens cancelados',
              color: PdfColors.orange700,
              child: _pdfTable(pending, applied: false),
            ),
          ],
        ),
      );
      final name =
          'relatorio_vacinacao_seleto_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      final path = await FileExportService().openBytes(name, await doc.save());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF aberto: $path')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<Uint8List> _loadReportLogoBytes(String? customLogo) async {
    if (customLogo?.trim().isNotEmpty == true) {
      try {
        return base64Decode(customLogo!.trim());
      } catch (_) {
        // Mantem o relatorio funcional caso uma logo antiga/invalida esteja salva.
      }
    }
    return (await rootBundle.load('SELETO_LOGO.png')).buffer.asUint8List();
  }

  pw.Widget _pdfHeader(pw.ImageProvider image, DateTime generatedAt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(
          child: pw.Image(
            image,
            width: 132,
            height: 76,
            fit: pw.BoxFit.contain,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 2, color: PdfColors.green800),
        pw.SizedBox(height: 12),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Relatório de vacinação',
                  style: pw.TextStyle(
                    fontSize: 23,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Controle sanitário das aves',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Text(
              '${shortDate.format(generatedAt)} • ${shortTime.format(generatedAt)}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfSummaryStrip({
    required int total,
    required int applied,
    required int pending,
    required int overdue,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: .6),
          bottom: pw.BorderSide(color: PdfColors.grey300, width: .6),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _pdfSummaryItem('Total', total.toString(), PdfColors.grey900),
          _pdfSummaryItem('Aplicadas', applied.toString(), PdfColors.green800),
          _pdfSummaryItem('Pendentes', pending.toString(), PdfColors.orange800),
          _pdfSummaryItem('Atrasadas', overdue.toString(), PdfColors.red700),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfSection({
    required String title,
    required String subtitle,
    required PdfColor color,
    required pw.Widget child,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 4, height: 28, color: color),
            pw.SizedBox(width: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 14.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: .55),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: child),
        ),
      ],
    );
  }

  pw.Widget _pdfTable(List<VaccinationOverview> rows, {required bool applied}) {
    if (rows.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        child: pw.Text(
          'Sem registros nesta seção.',
          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
        ),
      );
    }
    final sorted = [...rows]
      ..sort(
        (a, b) => (a.record.appliedAt ?? a.record.scheduledAt).compareTo(
          b.record.appliedAt ?? b.record.scheduledAt,
        ),
      );
    return pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: .45),
      ),
      columnWidths: const {
        0: pw.FixedColumnWidth(58),
        1: pw.FlexColumnWidth(1.15),
        2: pw.FlexColumnWidth(1.85),
        3: pw.FlexColumnWidth(1.0),
        4: pw.FixedColumnWidth(68),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _pdfCell(applied ? 'Aplicação' : 'Agenda', header: true),
            _pdfCell('Lote', header: true),
            _pdfCell('Vacina e detalhes', header: true),
            _pdfCell('Dose / via', header: true),
            _pdfCell('Status', header: true),
          ],
        ),
        for (var index = 0; index < sorted.length; index++)
          pw.TableRow(
            children: [
              _pdfCell(
                shortDate.format(
                  sorted[index].record.appliedAt ??
                      sorted[index].record.scheduledAt,
                ),
              ),
              _pdfCell(sorted[index].lotName ?? 'Todos os lotes'),
              _pdfVaccineCell(sorted[index].record),
              _pdfCell(
                [sorted[index].record.dose, sorted[index].record.route]
                    .where((value) => value?.trim().isNotEmpty == true)
                    .join(' / '),
                fallback: '-',
              ),
              _pdfStatusCell(sorted[index].record.status),
            ],
          ),
      ],
    );
  }

  pw.Widget _pdfVaccineCell(VaccinationRecord record) {
    final details = [
      record.disease,
      record.manufacturer,
      record.batchNumber == null ? null : 'Lote ${record.batchNumber}',
      record.responsible == null ? null : 'Resp. ${record.responsible}',
    ].where((value) => value?.trim().isNotEmpty == true).join(' • ');
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            record.vaccineName,
            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
          ),
          if (details.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              details,
              style: const pw.TextStyle(
                fontSize: 7.5,
                color: PdfColors.grey700,
              ),
            ),
          ],
          if (record.notes?.trim().isNotEmpty == true) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              record.notes!,
              style: const pw.TextStyle(
                fontSize: 7.5,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _pdfCell(
    String value, {
    bool header = false,
    String fallback = '',
  }) {
    final text = value.trim().isEmpty ? fallback : value.trim();
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: header ? 8 : 9,
          fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: header ? PdfColors.grey800 : PdfColors.grey900,
        ),
      ),
    );
  }

  pw.Widget _pdfStatusCell(String status) {
    final color = switch (status) {
      'APPLIED' => PdfColors.green700,
      'MISSED' => PdfColors.red700,
      'CANCELED' => PdfColors.grey600,
      _ => PdfColors.orange700,
    };
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(999),
        ),
        child: pw.Text(
          _statusLabel(status),
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _VaccinationTile extends StatelessWidget {
  const _VaccinationTile({
    required this.row,
    required this.onEdit,
    required this.onDelete,
  });

  final VaccinationOverview row;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final record = row.record;
    final scheme = Theme.of(context).colorScheme;
    final date = record.status == 'APPLIED' && record.appliedAt != null
        ? record.appliedAt!
        : record.scheduledAt;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _statusColor(record.status).withValues(alpha: .14),
        child: Icon(
          record.status == 'APPLIED'
              ? Icons.check_rounded
              : Icons.vaccines_outlined,
          color: _statusColor(record.status),
        ),
      ),
      title: Text(record.vaccineName),
      subtitle: Text(
        '${row.lotName ?? 'Todos os lotes'} · ${shortDate.format(date)}'
        '${record.dose == null ? '' : ' · ${record.dose}'}'
        '${record.route == null ? '' : ' · ${record.route}'}',
      ),
      trailing: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Chip(
            label: Text(_statusLabel(record.status)),
            visualDensity: VisualDensity.compact,
            backgroundColor: _statusColor(record.status).withValues(alpha: .12),
            labelStyle: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Remover',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _VaccinationDialog extends ConsumerStatefulWidget {
  const _VaccinationDialog({required this.lots, this.row});

  final List<LotSummary> lots;
  final VaccinationOverview? row;

  @override
  ConsumerState<_VaccinationDialog> createState() => _VaccinationDialogState();
}

class _VaccinationDialogState extends ConsumerState<_VaccinationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vaccine;
  late final TextEditingController _disease;
  late final TextEditingController _dose;
  late final TextEditingController _route;
  late final TextEditingController _batch;
  late final TextEditingController _manufacturer;
  late final TextEditingController _responsible;
  late final TextEditingController _notes;
  late DateTime _scheduledAt;
  DateTime? _appliedAt;
  String? _lotId;
  String _status = 'SCHEDULED';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final record = widget.row?.record;
    _vaccine = TextEditingController(text: record?.vaccineName ?? '');
    _disease = TextEditingController(text: record?.disease ?? '');
    _dose = TextEditingController(text: record?.dose ?? '');
    _route = TextEditingController(text: record?.route ?? '');
    _batch = TextEditingController(text: record?.batchNumber ?? '');
    _manufacturer = TextEditingController(text: record?.manufacturer ?? '');
    _responsible = TextEditingController(text: record?.responsible ?? '');
    _notes = TextEditingController(text: record?.notes ?? '');
    _scheduledAt = record?.scheduledAt ?? DateTime.now();
    _appliedAt = record?.appliedAt;
    _lotId = record?.lotId;
    _status = record?.status ?? 'SCHEDULED';
  }

  @override
  void dispose() {
    _vaccine.dispose();
    _disease.dispose();
    _dose.dispose();
    _route.dispose();
    _batch.dispose();
    _manufacturer.dispose();
    _responsible.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.row == null ? 'Cadastrar vacinação' : 'Editar vacinação',
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _vaccine,
                  decoration: const InputDecoration(labelText: 'Vacina'),
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Informe a vacina.'
                      : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  initialValue: _lotId,
                  decoration: const InputDecoration(labelText: 'Lote'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todos os lotes'),
                    ),
                    for (final lot in widget.lots)
                      DropdownMenuItem<String?>(
                        value: lot.lot.id,
                        child: Text(lot.lot.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _lotId = value),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: 'Agendada',
                        date: _scheduledAt,
                        onPick: () async {
                          final date = await _pickDate(_scheduledAt);
                          if (date != null) {
                            setState(() => _scheduledAt = date);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DateButton(
                        label: 'Aplicada',
                        date: _appliedAt,
                        empty: 'Não aplicada',
                        onPick: () async {
                          final date = await _pickDate(
                            _appliedAt ?? DateTime.now(),
                          );
                          if (date != null) setState(() => _appliedAt = date);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'SCHEDULED',
                      child: Text('Agendada'),
                    ),
                    DropdownMenuItem(value: 'APPLIED', child: Text('Aplicada')),
                    DropdownMenuItem(value: 'MISSED', child: Text('Atrasada')),
                    DropdownMenuItem(
                      value: 'CANCELED',
                      child: Text('Cancelada'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _status = value;
                      if (value == 'APPLIED') _appliedAt ??= DateTime.now();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 190,
                      child: TextFormField(
                        controller: _disease,
                        decoration: const InputDecoration(labelText: 'Doença'),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _dose,
                        decoration: const InputDecoration(labelText: 'Dose'),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _route,
                        decoration: const InputDecoration(labelText: 'Via'),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        controller: _batch,
                        decoration: const InputDecoration(
                          labelText: 'Lote vacina',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      child: TextFormField(
                        controller: _manufacturer,
                        decoration: const InputDecoration(
                          labelText: 'Fabricante',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      child: TextFormField(
                        controller: _responsible,
                        decoration: const InputDecoration(
                          labelText: 'Responsável',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Observações'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Salvando...' : 'Salvar'),
        ),
      ],
    );
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final controller = ref.read(operationsControllerProvider);
      if (widget.row == null) {
        await controller.addVaccination(
          vaccineName: _vaccine.text,
          disease: _disease.text,
          scheduledAt: _scheduledAt,
          appliedAt: _appliedAt,
          lotId: _lotId,
          dose: _dose.text,
          route: _route.text,
          batchNumber: _batch.text,
          manufacturer: _manufacturer.text,
          responsible: _responsible.text,
          status: _status,
          notes: _notes.text,
        );
      } else {
        await controller.updateVaccination(
          record: widget.row!.record,
          vaccineName: _vaccine.text,
          disease: _disease.text,
          scheduledAt: _scheduledAt,
          appliedAt: _appliedAt,
          lotId: _lotId,
          dose: _dose.text,
          route: _route.text,
          batchNumber: _batch.text,
          manufacturer: _manufacturer.text,
          responsible: _responsible.text,
          status: _status,
          notes: _notes.text,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onPick,
    this.empty,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onPick;
  final String? empty;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.event_outlined),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$label: ${date == null ? empty ?? '-' : shortDate.format(date!)}',
        ),
      ),
    );
  }
}

String _statusLabel(String status) => switch (status) {
  'APPLIED' => 'Aplicada',
  'MISSED' => 'Atrasada',
  'CANCELED' => 'Cancelada',
  _ => 'Agendada',
};

Color _statusColor(String status) => switch (status) {
  'APPLIED' => Colors.green,
  'MISSED' => Colors.red,
  'CANCELED' => Colors.grey,
  _ => Colors.orange,
};
