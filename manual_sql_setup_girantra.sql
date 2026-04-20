-- MANUAL SQL SETUP (tanpa supabase db push)
-- Jalankan file ini langsung di Supabase SQL Editor project GIRANTRA.

-- 1) CART TABLE
create table if not exists public.cart_items (
  cart_id bigint generated always as identity primary key,
  user_id uuid not null references public.users(user_id) on delete cascade,
  product_id bigint not null references public.products(product_id) on delete cascade,
  quantity int not null default 1 check (quantity > 0),
  created_at timestamptz not null default now(),
  unique (user_id, product_id)
);

create index if not exists idx_cart_items_user_created
on public.cart_items(user_id, created_at desc);

create index if not exists idx_favorites_user_created
on public.favorites(user_id, created_at desc);

-- 2) ENABLE RLS
alter table if exists public.users enable row level security;
alter table if exists public.favorites enable row level security;
alter table if exists public.cart_items enable row level security;

-- 3) USERS RLS
drop policy if exists "users_select_own" on public.users;
create policy "users_select_own"
on public.users
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "users_insert_own" on public.users;
create policy "users_insert_own"
on public.users
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "users_update_own" on public.users;
create policy "users_update_own"
on public.users
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- 4) FAVORITES RLS
drop policy if exists "favorites_select_own" on public.favorites;
create policy "favorites_select_own"
on public.favorites
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "favorites_insert_own" on public.favorites;
create policy "favorites_insert_own"
on public.favorites
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "favorites_delete_own" on public.favorites;
create policy "favorites_delete_own"
on public.favorites
for delete
to authenticated
using (auth.uid() = user_id);

-- 5) CART RLS
drop policy if exists "cart_select_own" on public.cart_items;
create policy "cart_select_own"
on public.cart_items
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "cart_insert_own" on public.cart_items;
create policy "cart_insert_own"
on public.cart_items
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "cart_update_own" on public.cart_items;
create policy "cart_update_own"
on public.cart_items
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "cart_delete_own" on public.cart_items;
create policy "cart_delete_own"
on public.cart_items
for delete
to authenticated
using (auth.uid() = user_id);

-- 6) AUTO SYNC auth.users -> public.users
create or replace function public.handle_auth_user_sync()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (
    user_id, full_name, email, phone_number, address, role, account_status
  ) values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    new.email,
    new.raw_user_meta_data->>'phone_number',
    new.raw_user_meta_data->>'address',
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'buyer'::user_role),
    coalesce((new.raw_user_meta_data->>'account_status')::account_status, 'active'::account_status)
  )
  on conflict (user_id) do update
  set
    full_name = excluded.full_name,
    email = excluded.email,
    phone_number = excluded.phone_number,
    address = excluded.address,
    role = excluded.role,
    account_status = excluded.account_status,
    updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_auth_user_sync on auth.users;
create trigger trg_auth_user_sync
after insert or update on auth.users
for each row
execute function public.handle_auth_user_sync();
