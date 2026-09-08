#!/usr/bin/env bash
set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-https://ldhmpnhyidzpdokjdohv.supabase.co}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-sb_publishable_1Z0UnEnCx7-N0xdACG81Og_UTJsQSOF}"

tables=(
  users
  user_permissions
  audit_logs
  lots
  bird_movements
  egg_collections
  egg_stock_movements
  ingredients
  ingredient_price_history
  ingredient_lots
  ingredient_stock_movements
  feed_formulas
  feed_formula_items
  feed_batches
  feed_batch_items
  feed_stock_movements
  daily_feedings
  feed_consumption_recommendations
  customers
  orders
  order_items
  order_status_history
  sales
  finance_transactions
  investments
  lighting_programs
  lighting_program_steps
  lot_lighting_programs
  calendar_events
  notification_settings
  app_settings
)

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

echo "1/3 Verificando as tabelas remotas..."
for table in "${tables[@]}"; do
  status="$(
    curl -sS -o "$response_file" -w "%{http_code}" \
      "$SUPABASE_URL/rest/v1/$table?select=*&limit=1" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Authorization: Bearer $SUPABASE_ANON_KEY"
  )"

  if [[ "$status" == "404" ]]; then
    echo "ERRO: a tabela public.$table ainda não existe."
    echo "Execute primeiro o SQL em docs/supabase_sync_setup.sql no Supabase SQL Editor."
    cat "$response_file"
    exit 1
  fi

  if [[ "$status" -lt 200 || "$status" -ge 300 ]]; then
    echo "ERRO: não foi possível consultar public.$table. HTTP $status"
    cat "$response_file"
    exit 1
  fi
done

echo "2/3 Injetando dado real em public.app_settings..."
write_status="$(
  curl -sS -o "$response_file" -w "%{http_code}" \
    "$SUPABASE_URL/rest/v1/app_settings" \
    -X POST \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -H "Content-Type: application/json" \
    -H "Prefer: resolution=merge-duplicates,return=representation" \
    --data '{
      "key": "sync_test_marker",
      "value": "ok",
      "updated_at": "2026-09-08T00:00:00.000Z",
      "updated_by": "codex"
    }'
)"

if [[ "$write_status" -lt 200 || "$write_status" -ge 300 ]]; then
  echo "ERRO: falha ao injetar dado em public.app_settings. HTTP $write_status"
  cat "$response_file"
  exit 1
fi

echo "3/3 Lendo dado salvo..."
read_status="$(
  curl -sS -o "$response_file" -w "%{http_code}" \
    "$SUPABASE_URL/rest/v1/app_settings?key=eq.sync_test_marker&select=*" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY"
)"

if [[ "$read_status" -lt 200 || "$read_status" -ge 300 ]]; then
  echo "ERRO: falha ao ler public.app_settings. HTTP $read_status"
  cat "$response_file"
  exit 1
fi

if ! grep -q "sync_test_marker" "$response_file"; then
  echo "ERRO: leitura funcionou, mas o marcador sync_test_marker não apareceu."
  cat "$response_file"
  exit 1
fi

echo "OK: todas as tabelas existem, e app_settings gravou/leu com sucesso."
cat "$response_file"
