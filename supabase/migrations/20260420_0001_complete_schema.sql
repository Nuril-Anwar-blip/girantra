-- Girantra (Project Akhir)
-- Complete baseline schema with Midtrans + realtime support.

create extension if not exists "pgcrypto";

do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type user_role as enum ('buyer', 'seller', 'admin');
  end if;
  if not exists (select 1 from pg_type where typname = 'account_status') then
    create type account_status as enum ('active', 'inactive', 'blocked');
  end if;
  if not exists (select 1 from pg_type where typname = 'product_status') then
    create type product_status as enum ('available', 'out_of_stock', 'archived');
  end if;
  if not exists (select 1 from pg_type where typname = 'order_status') then
    create type order_status as enum ('pending', 'processing', 'shipped', 'completed', 'cancelled');
  end if;
  if not exists (select 1 from pg_type where typname = 'payment_status') then
    create type payment_status as enum ('unpaid', 'pending', 'paid', 'failed', 'refunded');
  end if;
  if not exists (select 1 from pg_type where typname = 'payment_method') then
    create type payment_method as enum ('cod', 'transfer', 'qris', 'ewallet');
  end if;
  if not exists (select 1 from pg_type where typname = 'shipping_status') then
    create type shipping_status as enum ('pending', 'picked_up', 'in_transit', 'delivered', 'returned');
  end if;
end $$;

create table if not exists public.users (
  user_id uuid primary key default gen_random_uuid(),
  full_name varchar not null,
  email varchar not null unique,
  phone_number varchar,
  address text,
  role user_role not null default 'buyer',
  account_status account_status not null default 'active',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.categories (
  category_id bigint generated always as identity primary key,
  category_name varchar not null unique,
  description text,
  icon_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  product_id bigint generated always as identity primary key,
  seller_id uuid references public.users(user_id) on delete set null,
  category_id bigint references public.categories(category_id) on delete set null,
  product_name varchar not null,
  description text default '',
  cost_price numeric not null default 0,
  selling_price numeric not null default 0,
  ai_recommended_price numeric,
  stock bigint not null default 0 check (stock >= 0),
  unit varchar not null default 'Kg',
  image_url text,
  harvest_date date,
  status_product product_status not null default 'available',
  rating numeric not null default 0,
  total_reviews int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.transactions (
  transaction_id bigint generated always as identity primary key,
  transaction_code varchar not null unique,
  buyer_id uuid not null references public.users(user_id),
  seller_id uuid not null references public.users(user_id),
  product_id bigint not null references public.products(product_id),
  quantity int not null default 1 check (quantity > 0),
  price_at_purchase numeric not null default 0,
  sub_total numeric not null default 0,
  shipping_cost numeric not null default 0,
  service_fee numeric not null default 0,
  total_amount numeric not null default 0,
  shipping_address text,
  courier_name varchar,
  tracking_number varchar,
  latitude numeric,
  longitude numeric,
  notes text,
  order_status order_status not null default 'pending',
  payment_status payment_status not null default 'unpaid',
  payment_method payment_method not null default 'cod',
  payment_provider varchar,
  payment_token text,
  payment_url text,
  gateway_response jsonb,
  paid_at timestamptz,
  transaction_date timestamptz not null default now(),
  completed_date timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists public.logistics (
  logistic_id bigint generated always as identity primary key,
  transaction_id bigint not null unique references public.transactions(transaction_id) on delete cascade,
  courier_name varchar not null,
  tracking_number varchar not null unique,
  current_status shipping_status not null default 'pending',
  shipping_date date,
  arrival_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  notification_id bigint generated always as identity primary key,
  user_id uuid not null references public.users(user_id) on delete cascade,
  title varchar not null,
  message text not null,
  is_read boolean not null default false,
  notification_type varchar,
  related_id bigint,
  created_at timestamptz not null default now()
);

create table if not exists public.favorites (
  favorite_id bigint generated always as identity primary key,
  user_id uuid not null references public.users(user_id) on delete cascade,
  product_id bigint not null references public.products(product_id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_id, product_id)
);

create table if not exists public.reviews (
  review_id bigint generated always as identity primary key,
  transaction_id bigint unique references public.transactions(transaction_id) on delete set null,
  product_id bigint references public.products(product_id) on delete set null,
  buyer_id uuid references public.users(user_id) on delete set null,
  rating int check (rating >= 1 and rating <= 5),
  review_text text,
  created_at timestamptz not null default now()
);

-- Final-project-specific table (difference from Hangkeen)
create table if not exists public.ai_price_predictions (
  prediction_id bigint generated always as identity primary key,
  product_id bigint not null references public.products(product_id) on delete cascade,
  predicted_price numeric not null,
  confidence_score numeric,
  model_version varchar,
  generated_at timestamptz not null default now()
);

create index if not exists idx_products_seller on public.products(seller_id);
create index if not exists idx_products_category on public.products(category_id);
create index if not exists idx_transactions_buyer on public.transactions(buyer_id, transaction_date desc);
create index if not exists idx_transactions_seller on public.transactions(seller_id, transaction_date desc);
create index if not exists idx_transactions_code on public.transactions(transaction_code);
create index if not exists idx_transactions_status on public.transactions(order_status, payment_status);
create index if not exists idx_notifications_user on public.notifications(user_id, created_at desc);
create index if not exists idx_favorites_user on public.favorites(user_id);
create index if not exists idx_ai_price_predictions_product on public.ai_price_predictions(product_id, generated_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_users_updated_at on public.users;
create trigger trg_users_updated_at
before update on public.users
for each row execute function public.set_updated_at();

drop trigger if exists trg_products_updated_at on public.products;
create trigger trg_products_updated_at
before update on public.products
for each row execute function public.set_updated_at();

drop trigger if exists trg_transactions_updated_at on public.transactions;
create trigger trg_transactions_updated_at
before update on public.transactions
for each row execute function public.set_updated_at();

drop trigger if exists trg_logistics_updated_at on public.logistics;
create trigger trg_logistics_updated_at
before update on public.logistics
for each row execute function public.set_updated_at();

-- Realtime helper notification on transaction status updates
create or replace function public.notify_transaction_status_change()
returns trigger
language plpgsql
as $$
begin
  if new.order_status is distinct from old.order_status
     or new.payment_status is distinct from old.payment_status then
    insert into public.notifications(user_id, title, message, notification_type, related_id)
    values (
      new.buyer_id,
      'Update Pesanan',
      'Status pesanan ' || new.transaction_code || ' berubah ke ' || new.order_status::text,
      'transaction_update',
      new.transaction_id
    );
  end if;
  return new;
end;
$$;

drop trigger if exists trg_notify_transaction_update on public.transactions;
create trigger trg_notify_transaction_update
after update on public.transactions
for each row execute function public.notify_transaction_status_change();
