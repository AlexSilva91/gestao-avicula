#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${SUPABASE_DB_URL:-}" ]]; then
  echo "ERRO: informe a connection string Postgres no SUPABASE_DB_URL."
  echo "Exemplo:"
  echo "SUPABASE_DB_URL='postgresql://postgres.<PROJECT_REF>:<PASSWORD>@aws-0-sa-east-1.pooler.supabase.com:6543/postgres' ./scripts/setup_supabase_schema.sh"
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

psql "$SUPABASE_DB_URL" \
  --set=ON_ERROR_STOP=1 \
  --file="$repo_root/docs/supabase_sync_setup.sql"

echo "OK: schema Supabase configurado com as tabelas do banco local."
