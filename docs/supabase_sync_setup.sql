drop table if exists public.seleto_sync_snapshots;

create table if not exists public.users (
  id text primary key,
  username text not null unique,
  display_name text not null,
  password_hash text not null,
  is_superuser boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  last_login_at timestamptz
);

create table if not exists public.user_permissions (
  id text primary key,
  user_id text not null,
  permission text not null,
  created_at timestamptz not null,
  unique (user_id, permission)
);

create table if not exists public.audit_logs (
  id text primary key,
  user_id text,
  action text not null,
  entity_type text not null,
  entity_id text,
  timestamp timestamptz not null,
  description text not null,
  metadata text
);

create table if not exists public.lots (
  id text primary key,
  name text not null unique,
  strain text,
  initial_quantity integer not null,
  received_at timestamptz not null,
  arrival_age_days integer not null,
  unit_value_cents integer,
  supplier text,
  notes text,
  status text not null default 'ACTIVE',
  created_at timestamptz not null,
  created_by text not null
);

create table if not exists public.bird_movements (
  id text primary key,
  type text not null,
  occurred_at timestamptz not null,
  lot_id text not null,
  related_lot_id text,
  quantity integer not null,
  unit_value_cents integer,
  total_value_cents integer,
  reference text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.egg_collections (
  id text primary key,
  collected_on timestamptz not null,
  lot_id text not null,
  quantity integer not null,
  broken_eggs integer not null default 0,
  discarded_eggs integer not null default 0,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.egg_stock_movements (
  id text primary key,
  type text not null,
  occurred_at timestamptz not null,
  quantity integer not null,
  collection_id text,
  reference text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.ingredients (
  id text primary key,
  name text not null unique,
  unit text not null default 'kg',
  is_active boolean not null default true,
  notes text,
  created_at timestamptz not null,
  created_by text not null
);

create table if not exists public.ingredient_price_history (
  id text primary key,
  ingredient_id text not null,
  price_per_kg_cents integer not null,
  effective_date timestamptz not null,
  supplier text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.ingredient_lots (
  id text primary key,
  ingredient_id text not null,
  code text not null unique,
  entry_date timestamptz not null,
  initial_quantity_kg double precision not null,
  package_unit text not null default 'KG',
  package_quantity double precision not null default 0,
  package_weight_kg double precision not null default 1,
  total_cost_cents integer not null,
  price_per_kg_cents integer not null,
  supplier text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.ingredient_stock_movements (
  id text primary key,
  type text not null,
  occurred_at timestamptz not null,
  ingredient_id text not null,
  ingredient_lot_id text not null,
  quantity_kg double precision not null,
  price_per_kg_cents_snapshot integer not null,
  total_cost_cents integer not null,
  reference_type text,
  reference_id text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.feed_formulas (
  id text primary key,
  name text not null,
  phase text not null,
  version integer not null default 1,
  is_active boolean not null default true,
  valid_from timestamptz not null,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.feed_formula_items (
  id text primary key,
  formula_id text not null,
  ingredient_id text not null,
  base_quantity_kg double precision not null
);

create table if not exists public.feed_batches (
  id text primary key,
  code text not null unique,
  phase text not null,
  formula_id text not null,
  produced_at timestamptz not null,
  produced_quantity_kg double precision not null,
  total_cost_cents integer not null,
  cost_per_kg_cents double precision not null,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.feed_batch_items (
  id text primary key,
  batch_id text not null,
  ingredient_id text not null,
  quantity_kg double precision not null,
  price_per_kg_cents_snapshot integer not null,
  item_cost_cents integer not null
);

create table if not exists public.feed_stock_movements (
  id text primary key,
  type text not null,
  occurred_at timestamptz not null,
  batch_id text not null,
  quantity_kg double precision not null,
  feeding_id text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.daily_feedings (
  id text primary key,
  feeding_date timestamptz not null,
  lot_id text not null,
  batch_id text not null,
  quantity_kg double precision not null,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.feed_consumption_recommendations (
  id text primary key,
  start_week integer not null,
  end_week integer,
  grams_per_bird_day double precision not null,
  phase text,
  source text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.customers (
  id text primary key,
  name text not null,
  phone text,
  address text,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null,
  created_by text not null
);

create table if not exists public.orders (
  id text primary key,
  order_number integer not null unique,
  customer_id text,
  requested_date timestamptz not null,
  expected_delivery_date timestamptz,
  status text not null default 'DRAFT',
  subtotal_cents integer not null,
  discount_cents integer not null default 0,
  total_cents integer not null,
  notes text,
  created_by text not null,
  updated_by text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null
);

create table if not exists public.order_items (
  id text primary key,
  order_id text not null,
  product_type text not null,
  quantity double precision not null,
  unit_price_cents integer not null,
  total_cents integer not null
);

create table if not exists public.order_status_history (
  id text primary key,
  order_id text not null,
  old_status text,
  new_status text not null,
  changed_at timestamptz not null,
  changed_by text not null,
  notes text
);

create table if not exists public.packaging_items (
  id text primary key,
  type text not null,
  name text not null,
  notes text,
  is_active boolean not null default true,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.packaging_lots (
  id text primary key,
  item_id text not null,
  batch_code text,
  initial_quantity integer not null,
  unit_cost_cents integer not null default 0,
  total_cost_cents integer not null default 0,
  purchased_at timestamptz not null,
  supplier text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.packaging_stock_movements (
  id text primary key,
  item_id text not null,
  lot_id text not null,
  type text not null,
  occurred_at timestamptz not null,
  quantity integer not null,
  reference text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.egg_tray_batches (
  id text primary key,
  tray_lot_id text not null,
  label_lot_id text not null,
  quantity integer not null,
  eggs_per_tray integer not null,
  assembled_at timestamptz not null,
  unit_packaging_cost_cents integer not null default 0,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.egg_tray_stock_movements (
  id text primary key,
  batch_id text not null,
  type text not null,
  occurred_at timestamptz not null,
  quantity integer not null,
  reference text,
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.sales (
  id text primary key,
  sold_at timestamptz not null,
  customer_id text,
  order_id text unique,
  tray_batch_id text,
  tray_quantity integer not null default 0,
  dozens integer not null default 0,
  loose_eggs integer not null default 0,
  dozen_price_cents integer not null,
  total_cents integer not null,
  payment_method text not null,
  status text not null default 'CONFIRMED',
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

alter table public.sales add column if not exists tray_batch_id text;
alter table public.sales add column if not exists tray_quantity integer not null default 0;

create table if not exists public.finance_transactions (
  id text primary key,
  occurred_at timestamptz not null,
  type text not null,
  category text not null,
  description text not null,
  amount_cents integer not null,
  reference_type text,
  reference_id text,
  payment_method text,
  status text not null default 'CONFIRMED',
  notes text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.investments (
  id text primary key,
  description text not null,
  category text not null,
  investment_date timestamptz not null,
  amount_cents integer not null,
  lot_id text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.lighting_programs (
  id text primary key,
  name text not null,
  description text,
  is_default boolean not null default false,
  is_active boolean not null default true,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.lighting_program_steps (
  id text primary key,
  program_id text not null,
  start_age_days integer not null,
  end_age_days integer,
  total_light_minutes integer not null,
  start_time text,
  end_time text,
  weekly_increment_minutes integer not null default 0,
  related_phase text,
  notes text
);

create table if not exists public.lot_lighting_programs (
  id text primary key,
  lot_id text not null unique,
  program_id text not null,
  assigned_at timestamptz not null,
  created_by text not null
);

create table if not exists public.calendar_events (
  id text primary key,
  title text not null,
  type text not null,
  starts_at timestamptz not null,
  ends_at timestamptz,
  lot_id text,
  reference_type text,
  reference_id text,
  notes text,
  alert_enabled boolean not null default true,
  alert_message text,
  alert_time text not null default '08:00',
  recurrence text not null default 'ONCE',
  repeat_until timestamptz,
  weekdays text,
  created_by text not null,
  created_at timestamptz not null
);

create table if not exists public.notification_settings (
  id text primary key,
  type text not null unique,
  is_enabled boolean not null default true,
  days_before integer not null default 1,
  notification_time text not null default '08:00',
  default_message text,
  default_recurrence text not null default 'ONCE'
);

create table if not exists public.app_settings (
  key text primary key,
  value text not null,
  updated_at timestamptz not null,
  updated_by text
);

do $$
declare
  table_name text;
  table_names text[] := array[
    'users',
    'user_permissions',
    'audit_logs',
    'lots',
    'bird_movements',
    'egg_collections',
    'egg_stock_movements',
    'ingredients',
    'ingredient_price_history',
    'ingredient_lots',
    'ingredient_stock_movements',
    'feed_formulas',
    'feed_formula_items',
    'feed_batches',
    'feed_batch_items',
    'feed_stock_movements',
    'daily_feedings',
    'feed_consumption_recommendations',
    'customers',
    'orders',
    'order_items',
    'order_status_history',
    'packaging_items',
    'packaging_lots',
    'packaging_stock_movements',
    'egg_tray_batches',
    'egg_tray_stock_movements',
    'sales',
    'finance_transactions',
    'investments',
    'lighting_programs',
    'lighting_program_steps',
    'lot_lighting_programs',
    'calendar_events',
    'notification_settings',
    'app_settings'
  ];
begin
  foreach table_name in array table_names loop
    execute format('alter table public.%I enable row level security', table_name);

    execute format('drop policy if exists %I on public.%I', table_name || '_read', table_name);
    execute format('drop policy if exists %I on public.%I', table_name || '_insert', table_name);
    execute format('drop policy if exists %I on public.%I', table_name || '_update', table_name);
    execute format('drop policy if exists %I on public.%I', table_name || '_delete', table_name);

    execute format(
      'create policy %I on public.%I for select to anon, authenticated using (true)',
      table_name || '_read',
      table_name
    );
    execute format(
      'create policy %I on public.%I for insert to anon, authenticated with check (true)',
      table_name || '_insert',
      table_name
    );
    execute format(
      'create policy %I on public.%I for update to anon, authenticated using (true) with check (true)',
      table_name || '_update',
      table_name
    );
    execute format(
      'create policy %I on public.%I for delete to anon, authenticated using (true)',
      table_name || '_delete',
      table_name
    );
  end loop;
end $$;
