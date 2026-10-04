import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seleto/core/database/payables_import.dart';

void main() {
  test('imports CSV payables with Brazilian money and due date', () {
    final entries = parsePayablesImport(
      filename: 'contas.csv',
      bytes: utf8.encode(
        'descricao,categoria,valor,vencimento,observacao\n'
        'Internet,Mensalidade de serviço,"803,78",10/04/2026,abril\n',
      ),
    );

    expect(entries, hasLength(1));
    expect(entries.single.description, 'Internet');
    expect(entries.single.category, 'Mensalidade de serviço');
    expect(entries.single.amountCents, 80378);
    expect(entries.single.dueDate, DateTime(2026, 4, 10));
    expect(entries.single.notes, 'abril');
  });

  test('imports XML payables', () {
    final entries = parsePayablesImport(
      filename: 'contas.xml',
      bytes: utf8.encode('''
<contas>
  <conta>
    <descricao>Cartão</descricao>
    <categoria>Fatura de cartão</categoria>
    <valor>1200,50</valor>
    <vencimento>2026-05-12</vencimento>
  </conta>
</contas>
'''),
    );

    expect(entries, hasLength(1));
    expect(entries.single.description, 'Cartão');
    expect(entries.single.amountCents, 120050);
    expect(entries.single.dueDate, DateTime(2026, 5, 12));
  });

  test('imports XLSX payables and expands installments', () {
    final excel = Excel.createExcel();
    final sheet = excel['Contas'];
    sheet.appendRow([
      TextCellValue('descricao'),
      TextCellValue('categoria'),
      TextCellValue('valor_total'),
      TextCellValue('vencimento'),
      TextCellValue('parcelas'),
    ]);
    sheet.appendRow([
      TextCellValue('Notebook'),
      TextCellValue('Compra parcelada'),
      TextCellValue('3000,00'),
      TextCellValue('15/06/2026'),
      IntCellValue(3),
    ]);
    final bytes = Uint8List.fromList(excel.encode()!);

    final entries = parsePayablesImport(filename: 'contas.xlsx', bytes: bytes);

    expect(entries, hasLength(3));
    expect(entries.map((entry) => entry.amountCents), [100000, 100000, 100000]);
    expect(entries.map((entry) => entry.description), [
      'Notebook (1/3)',
      'Notebook (2/3)',
      'Notebook (3/3)',
    ]);
    expect(entries.map((entry) => entry.dueDate), [
      DateTime(2026, 6, 15),
      DateTime(2026, 7, 15),
      DateTime(2026, 8, 15),
    ]);
  });
}
