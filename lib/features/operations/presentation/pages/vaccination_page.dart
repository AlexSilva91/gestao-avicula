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
      final customLogo = await controller.vaccinationReportLogoBase64();
      final logoBytes = customLogo == null
          ? (await rootBundle.load('SELETO_LOGO.png')).buffer.asUint8List()
          : base64Decode(customLogo);
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
          margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 28),
          pageTheme: const pw.PageTheme(pageFormat: PdfPageFormat.a4),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: .6),
              ),
            ),
            child: pw.Text(
              'SELETO • Vacinação • Página ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
            ),
          ),
          build: (_) => [
            _pdfCoverHeader(image, generatedAt),
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                _pdfSummaryCard('Registros', rows.length.toString()),
                pw.SizedBox(width: 8),
                _pdfSummaryCard('Aplicadas', applied.length.toString()),
                pw.SizedBox(width: 8),
                _pdfSummaryCard('Pendentes', pending.length.toString()),
                pw.SizedBox(width: 8),
                _pdfSummaryCard('Atrasadas', overdue.toString()),
              ],
            ),
            pw.SizedBox(height: 18),
            _pdfSection(
              title: 'Vacinas aplicadas',
              subtitle: 'Histórico sanitário já executado.',
              color: PdfColors.green700,
              child: _pdfTable(applied, applied: true),
            ),
            pw.SizedBox(height: 16),
            _pdfSection(
              title: 'Vacinas a aplicar',
              subtitle: 'Agenda futura, pendências e itens cancelados.',
              color: PdfColors.orange700,
              child: _pdfTable(pending, applied: false),
            ),
          ],
        ),
      );
      final name =
          'relatorio_vacinacao_seleto_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      final path = await FileExportService().saveBytes(name, await doc.save());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF gerado: $path')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  pw.Widget _pdfCoverHeader(pw.ImageProvider image, DateTime generatedAt) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.grey300, width: .7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Center(child: pw.Image(image, height: 76)),
          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text(
              'Relatório de Vacinação',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'Controle sanitário das aves • SELETO',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(999),
                border: pw.Border.all(color: PdfColors.grey300, width: .6),
              ),
              child: pw.Text(
                'Gerado em ${shortDate.format(generatedAt)} às ${shortTime.format(generatedAt)}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryCard(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey300, width: .7),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfSection({
    required String title,
    required String subtitle,
    required PdfColor color,
    required pw.Widget child,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: .7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(12, 9, 12, 8),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.vertical(
                top: pw.Radius.circular(8),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.all(10), child: child),
        ],
      ),
    );
  }

  pw.Widget _pdfTable(List<VaccinationOverview> rows, {required bool applied}) {
    if (rows.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(6),
        ),
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
      border: pw.TableBorder.all(color: PdfColors.grey300, width: .5),
      columnWidths: const {
        0: pw.FixedColumnWidth(54),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.1),
        4: pw.FixedColumnWidth(62),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _pdfCell(applied ? 'Aplicação' : 'Agenda', header: true),
            _pdfCell('Lote', header: true),
            _pdfCell('Vacina', header: true),
            _pdfCell('Dose / Via', header: true),
            _pdfCell('Status', header: true),
          ],
        ),
        for (var index = 0; index < sorted.length; index++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isEven ? PdfColors.white : PdfColors.grey50,
            ),
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
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            record.vaccineName,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          if (details.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              details,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
          ],
          if (record.notes?.trim().isNotEmpty == true) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              record.notes!,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
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
