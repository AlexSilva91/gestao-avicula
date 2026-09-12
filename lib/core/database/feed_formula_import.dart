import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class FeedFormulaImportDefinition {
  const FeedFormulaImportDefinition({
    required this.name,
    this.phase,
    this.notes,
    required this.items,
  });

  final String name;
  final String? phase;
  final String? notes;
  final List<FeedFormulaImportItem> items;
}

class FeedFormulaImportItem {
  const FeedFormulaImportItem({
    required this.ingredientName,
    required this.quantityKg,
  });

  final String ingredientName;
  final double quantityKg;
}

List<FeedFormulaImportDefinition> parseFeedFormulaImport({
  required String filename,
  required Uint8List bytes,
}) {
  final extension = p.extension(filename).toLowerCase().replaceFirst('.', '');
  final formulas = switch (extension) {
    'json' => _parseJson(utf8.decode(bytes)),
    'xml' => _parseXml(utf8.decode(bytes)),
    'xlsx' || 'xls' => _parseWorkbook(bytes),
    _ => throw FormatException('Formato .$extension não suportado.'),
  };
  if (formulas.isEmpty) {
    throw const FormatException('Nenhuma formulação encontrada no arquivo.');
  }
  return formulas;
}

List<FeedFormulaImportDefinition> _parseJson(String content) {
  final raw = jsonDecode(content);
  final source =
      raw is Map &&
          _firstValue(raw, const ['formulas', 'formulacoes', 'formulações'])
              is List
      ? _firstValue(raw, const ['formulas', 'formulacoes', 'formulações'])
      : raw;
  if (source is List) {
    return source.map(_formulaFromJson).toList();
  }
  if (source is Map) {
    return source.entries.map((entry) {
      final value = entry.value;
      if (value is Map && _itemsFromAny(value).isNotEmpty) {
        return _formulaFromJson({'name': entry.key, ...value});
      }
      if (value is Map) {
        return FeedFormulaImportDefinition(
          name: entry.key.toString(),
          items: value.entries
              .map(
                (item) => FeedFormulaImportItem(
                  ingredientName: item.key.toString(),
                  quantityKg: _quantity(item.value),
                ),
              )
              .toList(),
        );
      }
      throw const FormatException('JSON de formulação inválido.');
    }).toList();
  }
  throw const FormatException('JSON de formulação inválido.');
}

FeedFormulaImportDefinition _formulaFromJson(Object? raw) {
  if (raw is! Map) throw const FormatException('Formulação inválida no JSON.');
  final map = raw.cast<Object?, Object?>();
  final name = _text(
    _firstValue(map, const [
      'name',
      'nome',
      'formula',
      'formulacao',
      'formulação',
    ]),
  );
  if (name.isEmpty) throw const FormatException('Formulação sem nome.');
  final items = _itemsFromAny(map);
  if (items.isEmpty) {
    throw FormatException('Formulação "$name" não possui itens.');
  }
  return FeedFormulaImportDefinition(
    name: name,
    phase: _nullableText(_firstValue(map, const ['phase', 'fase'])),
    notes: _nullableText(
      _firstValue(map, const ['notes', 'observacao', 'observação']),
    ),
    items: items,
  );
}

List<FeedFormulaImportItem> _itemsFromAny(Map<Object?, Object?> map) {
  final rawItems = _firstValue(map, const [
    'items',
    'itens',
    'ingredientes',
    'insumos',
  ]);
  if (rawItems is List) {
    return rawItems.map(_itemFromJson).toList();
  }
  if (rawItems is Map) {
    return rawItems.entries
        .map(
          (entry) => FeedFormulaImportItem(
            ingredientName: entry.key.toString(),
            quantityKg: _quantity(entry.value),
          ),
        )
        .toList();
  }
  return const [];
}

FeedFormulaImportItem _itemFromJson(Object? raw) {
  if (raw is! Map) throw const FormatException('Item de formulação inválido.');
  final map = raw.cast<Object?, Object?>();
  final ingredient = _text(
    _firstValue(map, const [
      'ingredient',
      'ingrediente',
      'insumo',
      'name',
      'nome',
    ]),
  );
  if (ingredient.isEmpty) throw const FormatException('Item sem insumo.');
  return FeedFormulaImportItem(
    ingredientName: ingredient,
    quantityKg: _quantity(
      _firstValue(map, const [
        'quantityKg',
        'quantidadeKg',
        'quantity',
        'quantidade',
        'kg',
      ]),
    ),
  );
}

List<FeedFormulaImportDefinition> _parseXml(String content) {
  final document = XmlDocument.parse(content);
  final formulas = <FeedFormulaImportDefinition>[];
  final formulaElements = document.descendants.whereType<XmlElement>().where(
    (element) => {
      'formula',
      'formulacao',
      'formulação',
    }.contains(_key(element.name.local)),
  );
  for (final element in formulaElements) {
    final name = _xmlValue(element, const ['name', 'nome']);
    if (name.isEmpty) continue;
    final items = element.childElements
        .where(
          (child) => {
            'item',
            'insumo',
            'ingrediente',
          }.contains(_key(child.name.local)),
        )
        .map((child) {
          final ingredient = _xmlValue(child, const [
            'ingredient',
            'ingrediente',
            'insumo',
            'name',
            'nome',
          ]);
          if (ingredient.isEmpty) {
            throw const FormatException('Item XML sem insumo.');
          }
          return FeedFormulaImportItem(
            ingredientName: ingredient,
            quantityKg: _quantity(
              _xmlValue(child, const [
                'quantityKg',
                'quantidadeKg',
                'quantity',
                'quantidade',
                'kg',
              ]),
            ),
          );
        })
        .toList();
    formulas.add(
      FeedFormulaImportDefinition(
        name: name,
        phase: _nullableText(_xmlValue(element, const ['phase', 'fase'])),
        notes: _nullableText(
          _xmlValue(element, const ['notes', 'observacao', 'observação']),
        ),
        items: items,
      ),
    );
  }
  return formulas;
}

List<FeedFormulaImportDefinition> _parseWorkbook(Uint8List bytes) {
  final workbook = Excel.decodeBytes(bytes);
  final formulas = <FeedFormulaImportDefinition>[];
  for (final table in workbook.tables.entries) {
    final rows = table.value.rows;
    if (rows.length < 2) continue;
    final headers = rows.first.map(_excelText).toList();
    final formulaIndex = _headerIndex(headers, const [
      'formula',
      'formulacao',
      'formulação',
      'nome',
    ]);
    final ingredientIndex = _headerIndex(headers, const [
      'insumo',
      'ingrediente',
      'ingredient',
    ]);
    final quantityIndex = _headerIndex(headers, const [
      'quantidade',
      'quantidadekg',
      'quantity',
      'quantitykg',
      'kg',
    ]);
    final phaseIndex = _headerIndex(headers, const ['fase', 'phase']);
    if (ingredientIndex < 0 || quantityIndex < 0) continue;
    final grouped =
        <String, ({String? phase, List<FeedFormulaImportItem> items})>{};
    for (final row in rows.skip(1)) {
      if (row.every((cell) => _excelText(cell).isEmpty)) continue;
      final formulaName = formulaIndex >= 0
          ? _excelText(row.length > formulaIndex ? row[formulaIndex] : null)
          : table.key;
      if (formulaName.isEmpty) continue;
      final ingredient = _excelText(
        row.length > ingredientIndex ? row[ingredientIndex] : null,
      );
      if (ingredient.isEmpty) continue;
      final phase = phaseIndex >= 0
          ? _nullableText(
              _excelText(row.length > phaseIndex ? row[phaseIndex] : null),
            )
          : null;
      final current =
          grouped[formulaName] ??
          (phase: phase, items: <FeedFormulaImportItem>[]);
      current.items.add(
        FeedFormulaImportItem(
          ingredientName: ingredient,
          quantityKg: _quantity(
            row.length > quantityIndex ? _excelValue(row[quantityIndex]) : null,
          ),
        ),
      );
      grouped[formulaName] = (
        phase: current.phase ?? phase,
        items: current.items,
      );
    }
    formulas.addAll(
      grouped.entries.map(
        (entry) => FeedFormulaImportDefinition(
          name: entry.key,
          phase: entry.value.phase,
          items: entry.value.items,
        ),
      ),
    );
  }
  return formulas;
}

int _headerIndex(List<String> headers, Iterable<String> names) {
  final keys = names.map(_key).toSet();
  return headers.indexWhere((header) => keys.contains(_key(header)));
}

String _xmlValue(XmlElement element, List<String> names) {
  final keys = names.map(_key).toSet();
  for (final attr in element.attributes) {
    if (keys.contains(_key(attr.name.local))) return attr.value.trim();
  }
  for (final child in element.childElements) {
    if (keys.contains(_key(child.name.local))) return child.innerText.trim();
  }
  return '';
}

Object? _firstValue(Map<Object?, Object?> map, List<String> keys) {
  final normalized = keys.map(_key).toSet();
  for (final entry in map.entries) {
    if (normalized.contains(_key(entry.key.toString()))) return entry.value;
  }
  return null;
}

String _text(Object? value) => value?.toString().trim() ?? '';
String? _nullableText(Object? value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}

double _quantity(Object? value) {
  if (value is num) return value.toDouble();
  final original = _text(value).toLowerCase().replaceAll(',', '.').trim();
  final gramMatch = RegExp(
    r'^(-?[0-9]+(?:[.][0-9]+)?)\s*(g|gr|grama|gramas)$',
  ).firstMatch(original);
  if (gramMatch != null) {
    return (double.tryParse(gramMatch.group(1)!) ?? 0) / 1000;
  }
  final text = original
      .replaceAll('kg', '')
      .replaceAll('quilogramas', '')
      .replaceAll('quilograma', '')
      .trim();
  return double.tryParse(text.replaceAll(RegExp(r'[^0-9.\-]'), '')) ?? 0;
}

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
