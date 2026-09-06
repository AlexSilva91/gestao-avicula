import 'package:intl/intl.dart';

final brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final decimal = NumberFormat.decimalPattern('pt_BR');
final shortDate = DateFormat('dd/MM/yyyy', 'pt_BR');
final shortTime = DateFormat('HH:mm', 'pt_BR');

String money(int cents) => brl.format(cents / 100);
String kg(double value) => '${NumberFormat('0.##', 'pt_BR').format(value)} kg';
String percent(double value) =>
    NumberFormat.percentPattern('pt_BR').format(value);

String feedPhaseLabel(String value) {
  final normalized = value.trim().toUpperCase();
  return switch (normalized) {
    'CRIA' => 'Cria',
    'RECRIA' => 'Recria',
    'PRE_POSTURA' => 'Pré-postura',
    'PRODUCAO_I' => 'Produção I',
    'PRODUCAO_II' => 'Produção II',
    'PRODUCAO_III' => 'Produção III',
    'CRESCIMENTO' => 'Crescimento',
    'POSTURA' => 'Postura',
    'MANUTENCAO' => 'Manutenção',
    _ => value,
  };
}

String feedFormulaNameLabel(String name, String phase) {
  final normalizedName = name.trim().toUpperCase().replaceAll(' ', '_');
  final normalizedPhase = phase.trim().toUpperCase();
  return normalizedName == normalizedPhase ? feedPhaseLabel(phase) : name;
}

String paymentMethodLabel(String value) {
  final normalized = value.trim().toUpperCase();
  return switch (normalized) {
    'DINHEIRO' => 'Dinheiro',
    'CARTÃO' || 'CARTAO' => 'Cartão',
    'PRAZO' => 'A prazo',
    'TRANSFER' || 'TRANSFERENCIA' => 'Transferência',
    _ => value,
  };
}

String auditActionLabel(String value) => switch (value) {
  'auth.login' => 'Entrada no sistema',
  'users.create' => 'Usuário criado',
  'users.first_admin' => 'Primeiro administrador criado',
  'users.self_register' => 'Solicitação de usuário',
  'users.update' => 'Usuário atualizado',
  'users.permissions' => 'Permissões atualizadas',
  'birds.purchase' => 'Compra de aves',
  'birds.sell' => 'Venda de aves',
  'birds.mortality' => 'Mortalidade registrada',
  'birds.adjust' => 'Ajuste de aves',
  'birds.transfer' => 'Transferência de aves',
  'birds.transfer.undo' => 'Transferência desfeita',
  'lots.update' => 'Lote atualizado',
  'egg_collection.create' => 'Coleta de ovos',
  'egg_stock.adjust' => 'Ajuste no estoque de ovos',
  'ingredients.manage' => 'Insumo cadastrado',
  'ingredients.update' => 'Insumo atualizado',
  'ingredients.stock_in' => 'Entrada de insumo',
  'ingredients.stock_adjust' => 'Ajuste de insumo',
  'ingredients.price_register' => 'Preço de insumo',
  'feed_formulas.update' => 'Formulação atualizada',
  'feed_batches.create' => 'Fabricação de ração',
  'feed_batches.ready_purchase' => 'Compra de ração pronta',
  'feed_stock.adjust' => 'Ajuste no estoque de ração',
  'feeding.register' => 'Alimentação registrada',
  'feed_recommendations.import' => 'Consumo por ave importado',
  'customers.create' => 'Cliente cadastrado',
  'orders.create' => 'Pedido criado',
  'orders.update' => 'Pedido atualizado',
  'orders.cancel' => 'Pedido cancelado',
  'orders.deliver' => 'Pedido entregue',
  'sales.create' => 'Venda registrada',
  'sales.cancel' => 'Venda cancelada',
  'finance.create' => 'Lançamento financeiro',
  'finance.cancel' => 'Lançamento cancelado',
  'investments.create' => 'Investimento registrado',
  'calendar.create' => 'Evento criado',
  'lighting.manage' => 'Programa de luz definido',
  'settings.update' => 'Configuração atualizada',
  'backup.restore' => 'Cópia de segurança restaurada',
  'data.import' => 'Dados importados',
  _ => value,
};

String auditEntityLabel(String value) => switch (value) {
  'database' => 'banco de dados',
  'user' => 'usuário',
  'lot' => 'lote',
  'bird_movement' => 'movimentação de aves',
  'bird_transfer' => 'transferência de aves',
  'egg_collection' => 'coleta de ovos',
  'egg_stock_movement' => 'movimentação de ovos',
  'ingredient' => 'insumo',
  'ingredient_lot' => 'lote de insumo',
  'ingredient_stock_movement' => 'movimentação de insumo',
  'ingredient_price' => 'preço de insumo',
  'feed_formula' => 'formulação de ração',
  'feed_batch' => 'lote de ração',
  'feed_stock_movement' => 'movimentação de ração',
  'daily_feeding' => 'alimentação diária',
  'feed_consumption_recommendations' => 'recomendações de consumo',
  'customer' => 'cliente',
  'order' => 'pedido',
  'sale' => 'venda',
  'finance_transaction' => 'lançamento financeiro',
  'investment' => 'investimento',
  'calendar_event' => 'evento de calendário',
  'lot_lighting_program' => 'programa de luz do lote',
  'app_setting' => 'configuração',
  'notification_setting' => 'configuração de alerta',
  _ => value,
};

int parseMoneyToCents(String value) {
  final cleaned = value
      .replaceAll(RegExp(r'[^0-9,.-]'), '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
  return ((double.tryParse(cleaned) ?? 0) * 100).round();
}

double parseDecimal(String value) =>
    double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
