#!/usr/bin/env bash
set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-https://ldhmpnhyidzpdokjdohv.supabase.co}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-sb_publishable_1Z0UnEnCx7-N0xdACG81Og_UTJsQSOF}"

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

upsert() {
  local table="$1"
  local conflict="$2"
  local payload="$3"
  local status

  status="$(
    curl -sS -o "$response_file" -w "%{http_code}" \
      "$SUPABASE_URL/rest/v1/$table?on_conflict=$conflict" \
      -X POST \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -H "Prefer: resolution=merge-duplicates,return=minimal" \
      --data "$payload"
  )"

  if [[ "$status" -lt 200 || "$status" -ge 300 ]]; then
    echo "ERRO em public.$table HTTP $status"
    cat "$response_file"
    exit 1
  fi

  echo "OK public.$table"
}

upsert users id '[{"id":"sync-test-user-master","username":"sync_master","display_name":"Aparelho Master Teste","password_hash":"sync-test-password-hash","is_superuser":true,"is_active":true,"created_at":"2026-09-08T00:00:00.000Z","updated_at":"2026-09-08T00:00:00.000Z","last_login_at":null}]'
upsert user_permissions id '[{"id":"sync-test-perm-master","user_id":"sync-test-user-master","permission":"*","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert audit_logs id '[{"id":"sync-test-audit-001","user_id":"sync-test-user-master","action":"sync.integration.seed","entity_type":"database","entity_id":null,"timestamp":"2026-09-08T00:00:00.000Z","description":"Dados de integração Supabase inseridos.","metadata":"{\"source\":\"codex\"}"}]'
upsert lots id '[{"id":"sync-test-lot-001","name":"LOTE SYNC TESTE","strain":"Embrapa 051","initial_quantity":120,"received_at":"2026-09-08T00:00:00.000Z","arrival_age_days":35,"unit_value_cents":2800,"supplier":"Fornecedor Teste","notes":"Lote criado para validar sincronizacao","status":"ACTIVE","created_at":"2026-09-08T00:00:00.000Z","created_by":"sync-test-user-master"}]'
upsert bird_movements id '[{"id":"sync-test-bird-001","type":"PURCHASE","occurred_at":"2026-09-08T00:00:00.000Z","lot_id":"sync-test-lot-001","related_lot_id":null,"quantity":120,"unit_value_cents":2800,"total_value_cents":336000,"reference":"sync-test","notes":"Entrada teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert egg_collections id '[{"id":"sync-test-egg-collection-001","collected_on":"2026-09-08T00:00:00.000Z","lot_id":"sync-test-lot-001","quantity":84,"broken_eggs":2,"discarded_eggs":1,"notes":"Coleta teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert egg_stock_movements id '[{"id":"sync-test-egg-stock-001","type":"COLLECTION_IN","occurred_at":"2026-09-08T08:00:00.000Z","quantity":81,"collection_id":"sync-test-egg-collection-001","reference":"sync-test","notes":"Estoque teste","created_by":"sync-test-user-master","created_at":"2026-09-08T08:00:00.000Z"}]'
upsert ingredients id '[{"id":"sync-test-ingredient-milho","name":"Milho Sync Teste","unit":"kg","is_active":true,"notes":"Ingrediente teste","created_at":"2026-09-08T00:00:00.000Z","created_by":"sync-test-user-master"}]'
upsert ingredient_price_history id '[{"id":"sync-test-price-001","ingredient_id":"sync-test-ingredient-milho","price_per_kg_cents":185,"effective_date":"2026-09-08T00:00:00.000Z","supplier":"Fornecedor Teste","notes":"Preco teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert ingredient_lots id '[{"id":"sync-test-ingredient-lot-001","ingredient_id":"sync-test-ingredient-milho","code":"SYNC-MILHO-001","entry_date":"2026-09-08T00:00:00.000Z","initial_quantity_kg":500,"package_unit":"SC","package_quantity":10,"package_weight_kg":50,"total_cost_cents":92500,"price_per_kg_cents":185,"supplier":"Fornecedor Teste","notes":"Lote de ingrediente teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert ingredient_stock_movements id '[{"id":"sync-test-ingredient-stock-001","type":"PURCHASE_IN","occurred_at":"2026-09-08T00:00:00.000Z","ingredient_id":"sync-test-ingredient-milho","ingredient_lot_id":"sync-test-ingredient-lot-001","quantity_kg":500,"price_per_kg_cents_snapshot":185,"total_cost_cents":92500,"reference_type":"sync_test","reference_id":"sync-test-ingredient-lot-001","notes":"Entrada teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert feed_formulas id '[{"id":"sync-test-formula-001","name":"Racao Sync Teste","phase":"PRODUCAO_I","version":1,"is_active":true,"valid_from":"2026-09-08T00:00:00.000Z","notes":"Formula teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert feed_formula_items id '[{"id":"sync-test-formula-item-001","formula_id":"sync-test-formula-001","ingredient_id":"sync-test-ingredient-milho","base_quantity_kg":60}]'
upsert feed_batches id '[{"id":"sync-test-feed-batch-001","code":"SYNC-RACAO-001","phase":"PRODUCAO_I","formula_id":"sync-test-formula-001","produced_at":"2026-09-08T00:00:00.000Z","produced_quantity_kg":100,"total_cost_cents":18500,"cost_per_kg_cents":185,"notes":"Batida teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert feed_batch_items id '[{"id":"sync-test-feed-batch-item-001","batch_id":"sync-test-feed-batch-001","ingredient_id":"sync-test-ingredient-milho","quantity_kg":100,"price_per_kg_cents_snapshot":185,"item_cost_cents":18500}]'
upsert feed_stock_movements id '[{"id":"sync-test-feed-stock-001","type":"PRODUCTION_IN","occurred_at":"2026-09-08T00:00:00.000Z","batch_id":"sync-test-feed-batch-001","quantity_kg":100,"feeding_id":null,"notes":"Estoque racao teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert daily_feedings id '[{"id":"sync-test-feeding-001","feeding_date":"2026-09-08T00:00:00.000Z","lot_id":"sync-test-lot-001","batch_id":"sync-test-feed-batch-001","quantity_kg":13.8,"notes":"Arracoamento teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert feed_consumption_recommendations id '[{"id":"sync-test-feed-rec-001","start_week":20,"end_week":24,"grams_per_bird_day":115,"phase":"PRODUCAO_I","source":"Teste integracao","notes":"Recomendacao teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert customers id '[{"id":"sync-test-customer-001","name":"Cliente Sync Teste","phone":"81999990000","address":"Endereco teste","notes":"Cliente teste","is_active":true,"created_at":"2026-09-08T00:00:00.000Z","created_by":"sync-test-user-master"}]'
upsert orders id '[{"id":"sync-test-order-001","order_number":900001,"customer_id":"sync-test-customer-001","requested_date":"2026-09-08T00:00:00.000Z","expected_delivery_date":"2026-09-09T00:00:00.000Z","status":"CONFIRMED","subtotal_cents":4200,"discount_cents":0,"total_cents":4200,"notes":"Pedido teste","created_by":"sync-test-user-master","updated_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z","updated_at":"2026-09-08T00:00:00.000Z"}]'
upsert order_items id '[{"id":"sync-test-order-item-001","order_id":"sync-test-order-001","product_type":"EGGS_DOZEN","quantity":2,"unit_price_cents":2100,"total_cents":4200}]'
upsert order_status_history id '[{"id":"sync-test-order-status-001","order_id":"sync-test-order-001","old_status":null,"new_status":"CONFIRMED","changed_at":"2026-09-08T00:00:00.000Z","changed_by":"sync-test-user-master","notes":"Status teste"}]'
upsert sales id '[{"id":"sync-test-sale-001","sold_at":"2026-09-08T00:00:00.000Z","customer_id":"sync-test-customer-001","order_id":"sync-test-order-001","dozens":2,"loose_eggs":0,"dozen_price_cents":2100,"total_cents":4200,"payment_method":"PIX","status":"CONFIRMED","notes":"Venda teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert finance_transactions id '[{"id":"sync-test-finance-001","occurred_at":"2026-09-08T00:00:00.000Z","type":"INCOME","category":"Venda de ovos","description":"Venda teste integracao","amount_cents":4200,"reference_type":"sale","reference_id":"sync-test-sale-001","payment_method":"PIX","status":"CONFIRMED","notes":"Financeiro teste","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert investments id '[{"id":"sync-test-investment-001","description":"Investimento teste integracao","category":"Infraestrutura","investment_date":"2026-09-08T00:00:00.000Z","amount_cents":150000,"lot_id":"sync-test-lot-001","created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert lighting_programs id '[{"id":"sync-test-lighting-001","name":"Programa Luz Sync Teste","description":"Programa teste","is_default":false,"is_active":true,"created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert lighting_program_steps id '[{"id":"sync-test-lighting-step-001","program_id":"sync-test-lighting-001","start_age_days":126,"end_age_days":null,"total_light_minutes":960,"start_time":"05:00","end_time":"21:00","weekly_increment_minutes":30,"related_phase":"PRODUCAO_I","notes":"Etapa teste"}]'
upsert lot_lighting_programs id '[{"id":"sync-test-lot-lighting-001","lot_id":"sync-test-lot-001","program_id":"sync-test-lighting-001","assigned_at":"2026-09-08T00:00:00.000Z","created_by":"sync-test-user-master"}]'
upsert calendar_events id '[{"id":"sync-test-event-001","title":"Evento Sync Teste","type":"FEED","starts_at":"2026-09-08T09:00:00.000Z","ends_at":"2026-09-08T10:00:00.000Z","lot_id":"sync-test-lot-001","reference_type":"sync_test","reference_id":"sync-test-feeding-001","notes":"Evento teste","alert_enabled":true,"alert_message":"Alerta teste","alert_time":"08:00","recurrence":"ONCE","repeat_until":null,"weekdays":null,"created_by":"sync-test-user-master","created_at":"2026-09-08T00:00:00.000Z"}]'
upsert notification_settings id '[{"id":"sync-test-notification-feed","type":"SYNC_TEST_FEED","is_enabled":true,"days_before":1,"notification_time":"08:00","default_message":"Mensagem teste","default_recurrence":"ONCE"}]'
upsert app_settings key '[{"key":"sync_test_marker","value":"populated_all_tables","updated_at":"2026-09-08T00:00:00.000Z","updated_by":"codex"}]'

echo "Validando leitura dos dados populados..."
for table in users lots egg_collections feed_batches orders sales finance_transactions app_settings; do
  curl -sS \
    "$SUPABASE_URL/rest/v1/$table?select=*&limit=3" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" >"$response_file"
  echo "$table: $(wc -c <"$response_file") bytes"
done

echo "OK: dados de integracao populados no Supabase."
