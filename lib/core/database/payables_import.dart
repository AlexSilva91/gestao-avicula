import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../utils/formatters.dart';

class PayableImportEntry {
  const PayableImportEntry({
    required this.category,
    required this.description,
    required this.amountCents,
    required this.dueDate,
    this.notes,
    this.paymentMethod,
  });

  final String category;
  final String description;
  final int amountCents;
  final DateTime dueDate;
  final String? notes;
  final String? paymentMethod;
}

List<PayableImportEntry> parsePayablesImport({
  required String filename,
  required Uint8List bytes,
}) {
  final extension = p.extension(filename).toLowerCase().replaceFirst('.', '');
  final rows = switch (extension) {
    'csv' => _parseCsv(utf8.decode(bytes)),
    'xml' => _parseXml(utf8.decode(bytes)),
    'xlsx' || 'xls' || 'xlsl' => _parseWorkbook(bytes),
    _ => throw FormatException('Formato .$extension não suportado.'),
  };
  final entries = rows.expand(_entriesFromRow).toList();
  if (entries.isEmpty) {
    throw const FormatException('Nenhuma conta a pagar encontrada no arquivo.');
  }
  return entries;
}

List<Map<String, Object?>> _parseCsv(String content) {
  final rows = const CsvDecoder(dynamicTyping: false).convert(content);
  if (rows.length < 2) {
    throw const FormatException(
      'CSV precisa ter cabeçalho e ao menos uma linha.',
    );
  }
  final headers = rows.first.map((cell) => cell.toString()).toList();
  return rows
      .skip(1)
      .where((row) {
        return row.any((cell) => cell.toString().trim().isNotEmpty);
      })
      .map((row) {
        final result = <String, Object?>{};
        for (var i = 0; i < headers.length; i++) {
          result[_key(headers[i])] = i < row.length ? row[i] : null;
        }
        return result;
      })
      .toList();
}

List<Map<String, Object?>> _parseWorkbook(Uint8List bytes) {
  final workbook = Excel.decodeBytes(bytes);
  final result = <Map<String, Object?>>[];
  for (final table in workbook.tables.values) {
    final rows = table.rows;
    if (rows.length < 2) continue;
    final headers = rows.first.map(_excelText).toList();
    for (final row in rows.skip(1)) {
      if (row.every((cell) => _excelText(cell).isEmpty)) continue;
      final item = <String, Object?>{};
      for (var i = 0; i < headers.length; i++) {
        item[_key(headers[i])] = i < row.length ? _excelValue(row[i]) : null;
      }
      result.add(item);
    }
  }
  return result;
}

List<Map<String, Object?>> _parseXml(String content) {
  final document = XmlDocument.parse(content);
  final rowElements = document.descendants.whereType<XmlElement>().where((
    element,
  ) {
    final name = _key(element.name.local);
    return {
      'conta',
      'contapagar',
      'payable',
      'accountpayable',
      'lancamento',
      'despesa',
    }.contains(name);
  });
  final result = <Map<String, Object?>>[];
  for (final element in rowElements) {
    final item = <String, Object?>{};
    for (final attr in element.attributes) {
      item[_key(attr.name.local)] = attr.value;
    }
    for (final child in element.childElements) {
      item[_key(child.name.local)] = child.innerText;
    }
    if (item.isNotEmpty) result.add(item);
  }
  return result;
}

List<PayableImportEntry> _entriesFromRow(Map<String, Object?> row) {
  final description = _requiredText(row, const [
    'descricao',
    'descrição',
    'description',
    'historico',
    'historico',
    'nome',
    'titulo',
  ], 'descrição');
  final category =
      _nullableText(row, const ['categoria', 'category', 'tipo']) ?? 'Boleto';
  final dueDate = _requiredDate(row, const [
    'vencimento',
    'datavencimento',
    'data_de_vencimento',
    'due',
    'duedate',
    'due_date',
  ]);
  final installments = _positiveInt(
    _firstValue(row, const ['parcelas', 'qtdparcelas', 'installments']),
  );
  final totalCents = _money(row, const [
    'valortotal',
    'valor_total',
    'total',
    'totalcents',
  ]);
  final amountCents = totalCents == null
      ? _money(row, const ['valor', 'amount', 'amountcents']) ?? 0
      : (totalCents / installments).round();
  if (amountCents <= 0) {
    throw FormatException('Conta "$description" está sem valor válido.');
  }
  final notes = _nullableText(row, const [
    'observacao',
    'observação',
    'obs',
    'notes',
    'nota',
  ]);
  final paymentMethod = _nullableText(row, const [
    'forma',
    'formapagamento',
    'forma_pagamento',
    'payment',
    'paymentmethod',
  ]);
  return [
    for (var i = 0; i < installments; i++)
      PayableImportEntry(
        category: category,
        description: installments == 1
            ? description
            : '$description (${i + 1}/$installments)',
        amountCents: amountCents,
        dueDate: _addMonths(dueDate, i),
        notes: notes,
        paymentMethod: paymentMethod,
      ),
  ];
}

Object? _firstValue(Map<String, Object?> row, Iterable<String> names) {
  final wanted = names.map(_key).toSet();
  for (final entry in row.entries) {
    if (wanted.contains(_key(entry.key))) return entry.value;
  }
  return null;
}

String _requiredText(
  Map<String, Object?> row,
  Iterable<String> names,
  String label,
) {
  final value = _nullableText(row, names);
  if (value == null) throw FormatException('Informe $label no arquivo.');
  return value;
}

String? _nullableText(Map<String, Object?> row, Iterable<String> names) {
  final value = _firstValue(row, names)?.toString().trim();
  return value == null || value.isEmpty ? null : value;
}

DateTime _requiredDate(Map<String, Object?> row, Iterable<String> names) {
  final value = _firstValue(row, names);
  final parsed = _date(value);
  if (parsed == null) {
    throw const FormatException('Informe a data de vencimento no arquivo.');
  }
  return DateTime(parsed.year, parsed.month, parsed.day);
}

DateTime? _date(Object? value) {
  if (value is DateTime) return value;
  if (value is num) {
    final days = value.toInt();
    if (days > 20000 && days < 80000) {
      return DateTime(1899, 12, 30).add(Duration(days: days));
    }
  }
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;
  final parsed = DateTime.tryParse(text);
  if (parsed != null) return parsed;
  final match = RegExp(
    r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$',
  ).firstMatch(text);
  if (match == null) return null;
  final yearText = match.group(3)!;
  final year = int.parse(yearText.length == 2 ? '20$yearText' : yearText);
  return DateTime(year, int.parse(match.group(2)!), int.parse(match.group(1)!));
}

int? _money(Map<String, Object?> row, Iterable<String> names) {
  final value = _firstValue(row, names);
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return (value * 100).round();
  return parseMoneyToCents(value.toString());
}

int _positiveInt(Object? value) {
  if (value is num) return value.toInt().clamp(1, 999);
  final parsed = int.tryParse(value?.toString().trim() ?? '');
  return (parsed ?? 1).clamp(1, 999);
}

DateTime _addMonths(DateTime date, int months) {
  final targetMonth = date.month + months;
  final target = DateTime(date.year, targetMonth, 1);
  final lastDay = DateTime(target.year, target.month + 1, 0).day;
  return DateTime(target.year, target.month, date.day.clamp(1, lastDay));
}

Object? _excelValue(Data? cell) {
  final value = cell?.value;
  return switch (value) {
    null => null,
    TextCellValue() => value.value.toString(),
    IntCellValue() => value.value,
    DoubleCellValue() => value.value,
    BoolCellValue() => value.value,
    DateCellValue() => value.asDateTimeLocal(),
    DateTimeCellValue() => value.asDateTimeLocal(),
    TimeCellValue() => value.toString(),
    FormulaCellValue() => value.toString(),
  };
}

String _excelText(Data? cell) => (_excelValue(cell) ?? '').toString().trim();

String _key(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('à', 'a')
    .replaceAll('â', 'a')
    .replaceAll('ã', 'a')
    .replaceAll('é', 'e')
    .replaceAll('ê', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ô', 'o')
    .replaceAll('õ', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('ç', 'c')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '');
