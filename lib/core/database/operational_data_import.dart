import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class OperationalImportResult {
  const OperationalImportResult({
    required this.backupJson,
    required this.sectionCount,
    required this.rowCount,
  });

  final String backupJson;
  final int sectionCount;
  final int rowCount;
}

OperationalImportResult parseOperationalImport({
  required String filename,
  required Uint8List bytes,
}) {
  final extension = p.extension(filename).toLowerCase().replaceFirst('.', '');
  final payload = switch (extension) {
    'json' => _parseJson(utf8.decode(bytes)),
    'csv' => _parseCsv(filename, utf8.decode(bytes)),
    'xml' => _parseXml(utf8.decode(bytes)),
    'xlsx' || 'xlsl' => _parseWorkbook(bytes),
    _ => throw FormatException('Formato .$extension não suportado.'),
  };
  _removeProtectedSections(payload);
  payload['format'] = 'SELETO_BACKUP_V1';
  payload['exportedAt'] ??= DateTime.now().toIso8601String();

  final sections = payload.entries
      .where((entry) => entry.value is List && _sectionKeys.contains(entry.key))
      .toList();
  return OperationalImportResult(
    backupJson: const JsonEncoder.withIndent('  ').convert(payload),
    sectionCount: sections
        .where((entry) => (entry.value as List).isNotEmpty)
        .length,
    rowCount: sections.fold<int>(
      0,
      (total, entry) => total + (entry.value as List).length,
    ),
  );
}

Map<String, dynamic> _parseJson(String content) {
  final raw = jsonDecode(content);
  if (raw is List) {
    return {'calendarEvents': raw.cast<Map>().map(_row).toList()};
  }
  if (raw is! Map) {
    throw const FormatException('JSON deve ser um objeto ou lista de eventos.');
  }
  return raw.cast<String, dynamic>();
}

Map<String, dynamic> _parseCsv(String filename, String content) {
  final rows = const CsvDecoder(dynamicTyping: false).convert(content);
  if (rows.length < 2) {
    throw const FormatException(
      'CSV precisa ter cabeçalho e ao menos uma linha.',
    );
  }
  final headers = rows.first.map((cell) => cell.toString().trim()).toList();
  final sectionColumn = headers.indexWhere(
    (header) => {'section', 'table', 'tabela'}.contains(_normal(header)),
  );
  final fallbackSection = _sectionFromName(
    p.basenameWithoutExtension(filename),
  );
  final result = <String, dynamic>{};
  for (final row in rows.skip(1)) {
    if (row.every((cell) => cell.toString().trim().isEmpty)) continue;
    final section = sectionColumn >= 0
        ? _sectionFromName(_cell(row, sectionColumn))
        : fallbackSection;
    _ensureSection(section, filename);
    final sectionKey = section!;
    final item = <String, dynamic>{};
    for (var i = 0; i < headers.length; i++) {
      if (i == sectionColumn) continue;
      final field = _fieldName(headers[i]);
      if (field.isEmpty) continue;
      item[field] = _coerce(sectionKey, field, _cell(row, i));
    }
    (result.putIfAbsent(sectionKey, () => <Map<String, dynamic>>[])
            as List<Map<String, dynamic>>)
        .add(item);
  }
  return result;
}

Map<String, dynamic> _parseWorkbook(Uint8List bytes) {
  final workbook = Excel.decodeBytes(bytes);
  final result = <String, dynamic>{};
  for (final entry in workbook.tables.entries) {
    final section = _sectionFromName(entry.key);
    if (section == null || !_sectionKeys.contains(section)) continue;
    final rows = entry.value.rows;
    if (rows.length < 2) continue;
    final headers = rows.first.map(_excelText).toList();
    final data = <Map<String, dynamic>>[];
    for (final row in rows.skip(1)) {
      if (row.every((cell) => _excelText(cell).isEmpty)) continue;
      final item = <String, dynamic>{};
      for (var i = 0; i < headers.length; i++) {
        final field = _fieldName(headers[i]);
        if (field.isEmpty) continue;
        item[field] = _coerce(
          section,
          field,
          i < row.length ? _excelValue(row[i]) : null,
        );
      }
      data.add(item);
    }
    result[section] = data;
  }
  return result;
}

Map<String, dynamic> _parseXml(String content) {
  final document = XmlDocument.parse(content);
  final result = <String, dynamic>{};
  for (final element in document.rootElement.childElements) {
    final section = _sectionFromName(element.name.local);
    if (section == null || !_sectionKeys.contains(section)) continue;
    final rows = <Map<String, dynamic>>[];
    for (final row in element.childElements) {
      rows.add(_xmlRow(section, row));
    }
    result[section] = rows;
  }
  return result;
}

Map<String, dynamic> _xmlRow(String section, XmlElement row) {
  final result = <String, dynamic>{};
  for (final attr in row.attributes) {
    final field = _fieldName(attr.name.local);
    if (field.isNotEmpty) result[field] = _coerce(section, field, attr.value);
  }
  for (final child in row.childElements) {
    final field = _fieldName(child.name.local);
    if (field.isNotEmpty) {
      result[field] = _coerce(section, field, child.innerText);
    }
  }
  return result;
}

Map<String, dynamic> _row(Map row) => row.cast<String, dynamic>();

String _cell(List<dynamic> row, int index) =>
    index >= row.length ? '' : row[index].toString();

dynamic _excelValue(Data? cell) {
  final value = cell?.value;
  return switch (value) {
    null => null,
    TextCellValue() => value.value.toString(),
    IntCellValue() => value.value,
    DoubleCellValue() => value.value,
    BoolCellValue() => value.value,
    DateCellValue() => value.asDateTimeLocal().toIso8601String(),
    DateTimeCellValue() => value.asDateTimeLocal().toIso8601String(),
    TimeCellValue() => value.toString(),
    FormulaCellValue() => value.toString(),
  };
}

String _excelText(Data? cell) => (_excelValue(cell) ?? '').toString().trim();

dynamic _coerce(String section, String field, dynamic value) {
  if (value == null) return null;
  if (value is num || value is bool) return value;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  if (_boolFields.contains(field)) {
    return {
      '1',
      'true',
      'sim',
      'yes',
      'ativo',
      'enabled',
    }.contains(text.toLowerCase());
  }
  if (_intFields.contains(field) && !_isDecimalQuantity(section, field)) {
    return int.tryParse(text.replaceAll(',', '.').split('.').first) ?? 0;
  }
  if (_doubleFields.contains(field) || _isDecimalQuantity(section, field)) {
    return double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
  }
  if (_dateFields.contains(field)) {
    final numeric = int.tryParse(text);
    if (numeric != null && numeric > 100000) {
      return DateTime.fromMillisecondsSinceEpoch(numeric).toIso8601String();
    }
    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed.toIso8601String();
    final match = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})(?:\s+(\d{1,2}):(\d{2}))?$',
    ).firstMatch(text);
    if (match != null) {
      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(2)!),
        int.parse(match.group(1)!),
        int.tryParse(match.group(4) ?? '0') ?? 0,
        int.tryParse(match.group(5) ?? '0') ?? 0,
      ).toIso8601String();
    }
  }
  return text;
}

bool _isDecimalQuantity(String section, String field) =>
    field == 'quantity' && section == 'orderItems';

String? _sectionFromName(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return _sectionAliases[_normal(value)] ?? value.trim();
}

void _ensureSection(String? section, String source) {
  if (section == null || !_sectionKeys.contains(section)) {
    throw FormatException(
      'Não foi possível identificar a seção operacional em $source.',
    );
  }
}

String _fieldName(String header) {
  final trimmed = header.trim();
  if (trimmed.isEmpty) return '';
  if (!trimmed.contains('_')) {
    return trimmed[0].toLowerCase() + trimmed.substring(1);
  }
  final parts = trimmed.toLowerCase().split('_');
  return [
    parts.first,
    for (final part in parts.skip(1))
      if (part.isNotEmpty) part[0].toUpperCase() + part.substring(1),
  ].join();
}

String _normal(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-.]'), '');

void _removeProtectedSections(Map<String, dynamic> payload) {
  for (final key in const [
    'users',
    'usuarios',
    'userPermissions',
    'user_permissions',
    'permissoes',
    'permissoesUsuarios',
    'permissoes_usuarios',
    'auditLogs',
    'audit_logs',
    'auditoria',
  ]) {
    payload.remove(key);
  }
}

const _sectionKeys = {
  'lots',
  'birdMovements',
  'eggCollections',
  'eggStockMovements',
  'ingredients',
  'prices',
  'ingredientLots',
  'ingredientStockMovements',
  'formulas',
  'formulaItems',
  'feedBatches',
  'feedBatchItems',
  'feedStock',
  'feedings',
  'customers',
  'orders',
  'orderItems',
  'orderStatusHistory',
  'sales',
  'finance',
  'investments',
  'lightingPrograms',
  'lightingSteps',
  'lotLighting',
  'calendarEvents',
  'notificationSettings',
  'appSettings',
};

const _sectionAliases = {
  'lots': 'lots',
  'lotes': 'lots',
  'birdmovements': 'birdMovements',
  'movimentosaves': 'birdMovements',
  'eggcollections': 'eggCollections',
  'coletasovos': 'eggCollections',
  'eggstockmovements': 'eggStockMovements',
  'estoqueovos': 'eggStockMovements',
  'ingredients': 'ingredients',
  'ingredientes': 'ingredients',
  'prices': 'prices',
  'precos': 'prices',
  'ingredientlots': 'ingredientLots',
  'lotesinsumos': 'ingredientLots',
  'lotesdeinsumos': 'ingredientLots',
  'ingredientstockmovements': 'ingredientStockMovements',
  'movimentosinsumos': 'ingredientStockMovements',
  'estoqueinsumos': 'ingredientStockMovements',
  'formulas': 'formulas',
  'formulaitems': 'formulaItems',
  'feedbatches': 'feedBatches',
  'lotesracao': 'feedBatches',
  'feedbatchitems': 'feedBatchItems',
  'feedstock': 'feedStock',
  'estoqueracao': 'feedStock',
  'feedings': 'feedings',
  'alimentacao': 'feedings',
  'customers': 'customers',
  'clientes': 'customers',
  'orders': 'orders',
  'pedidos': 'orders',
  'orderitems': 'orderItems',
  'orderstatushistory': 'orderStatusHistory',
  'sales': 'sales',
  'vendas': 'sales',
  'finance': 'finance',
  'financeiro': 'finance',
  'investments': 'investments',
  'investimentos': 'investments',
  'lightingprograms': 'lightingPrograms',
  'programasluz': 'lightingPrograms',
  'lightingsteps': 'lightingSteps',
  'etapasluz': 'lightingSteps',
  'lotlighting': 'lotLighting',
  'calendarevents': 'calendarEvents',
  'eventos': 'calendarEvents',
  'alertas': 'calendarEvents',
  'notificationsettings': 'notificationSettings',
  'configuracoesalertas': 'notificationSettings',
  'appsettings': 'appSettings',
  'configuracoes': 'appSettings',
};

const _boolFields = {
  'isActive',
  'isDefault',
  'isEnabled',
  'isSuperuser',
  'alertEnabled',
};

const _intFields = {
  'initialQuantity',
  'arrivalAgeDays',
  'unitValueCents',
  'quantity',
  'brokenEggs',
  'discardedEggs',
  'pricePerKgCents',
  'pricePerKgCentsSnapshot',
  'version',
  'totalCostCents',
  'itemCostCents',
  'orderNumber',
  'subtotalCents',
  'discountCents',
  'totalCents',
  'dozens',
  'looseEggs',
  'dozenPriceCents',
  'amountCents',
  'startAgeDays',
  'endAgeDays',
  'totalLightMinutes',
  'weeklyIncrementMinutes',
  'daysBefore',
};

const _doubleFields = {
  'baseQuantityKg',
  'producedQuantityKg',
  'costPerKgCents',
  'initialQuantityKg',
  'packageQuantity',
  'packageWeightKg',
  'quantityKg',
  'quantity',
};

const _dateFields = {
  'createdAt',
  'updatedAt',
  'lastLoginAt',
  'receivedAt',
  'occurredAt',
  'collectedOn',
  'effectiveDate',
  'validFrom',
  'producedAt',
  'feedingDate',
  'requestedDate',
  'expectedDeliveryDate',
  'soldAt',
  'investmentDate',
  'assignedAt',
  'startsAt',
  'endsAt',
  'repeatUntil',
};
