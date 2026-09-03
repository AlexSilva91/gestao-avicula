import 'package:intl/intl.dart';

final brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final decimal = NumberFormat.decimalPattern('pt_BR');
final shortDate = DateFormat('dd/MM/yyyy', 'pt_BR');
final shortTime = DateFormat('HH:mm', 'pt_BR');

String money(int cents) => brl.format(cents / 100);
String kg(double value) => '${NumberFormat('0.##', 'pt_BR').format(value)} kg';
String percent(double value) =>
    NumberFormat.percentPattern('pt_BR').format(value);

int parseMoneyToCents(String value) {
  final cleaned = value
      .replaceAll(RegExp(r'[^0-9,.-]'), '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
  return ((double.tryParse(cleaned) ?? 0) * 100).round();
}

double parseDecimal(String value) =>
    double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
