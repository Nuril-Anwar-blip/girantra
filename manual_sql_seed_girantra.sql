-- MANUAL SEED DATA + STORAGE IMAGE (Girantra)
-- Jalankan di Supabase SQL Editor setelah manual_sql_setup_girantra.sql

-- 1) Bucket gambar produk
insert into storage.buckets (id, name, public)
values ('product-image', 'product-image', true)
on conflict (id) do update set public = true;

-- 2) Policy storage
drop policy if exists "public_read_product_image" on storage.objects;
create policy "public_read_product_image"
on storage.objects
for select
to public
using (bucket_id = 'product-image');

drop policy if exists "auth_insert_product_image" on storage.objects;
create policy "auth_insert_product_image"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'product-image');

drop policy if exists "auth_update_own_product_image" on storage.objects;
create policy "auth_update_own_product_image"
on storage.objects
for update
to authenticated
using (bucket_id = 'product-image' and owner = auth.uid())
with check (bucket_id = 'product-image' and owner = auth.uid());

drop policy if exists "auth_delete_own_product_image" on storage.objects;
create policy "auth_delete_own_product_image"
on storage.objects
for delete
to authenticated
using (bucket_id = 'product-image' and owner = auth.uid());

-- 3) Seed kategori
insert into public.categories (category_name, description, icon_url)
values
  ('Benih', 'Bibit dan benih tanaman', null),
  ('Pupuk', 'Pupuk organik dan anorganik', null),
  ('Sayuran', 'Hasil panen sayuran segar', null),
  ('Buah', 'Hasil panen buah segar', null)
on conflict (category_name) do nothing;

-- 4) Seed produk contoh untuk seller pertama
do $$
declare
  seller_uuid uuid;
  benih_id bigint;
  pupuk_id bigint;
  sayur_id bigint;
  p1 bigint;
  p2 bigint;
begin
  select user_id into seller_uuid
  from public.users
  where role = 'seller'
  order by created_at asc
  limit 1;

  if seller_uuid is null then
    raise notice 'Seed produk dilewati: belum ada user seller.';
    return;
  end if;

  select category_id into benih_id from public.categories where category_name = 'Benih' limit 1;
  select category_id into pupuk_id from public.categories where category_name = 'Pupuk' limit 1;
  select category_id into sayur_id from public.categories where category_name = 'Sayuran' limit 1;

  insert into public.products (
    seller_id, category_id, product_name, description,
    cost_price, selling_price, stock, unit, image_url, status_product
  ) values
    (
      seller_uuid, benih_id, 'Bibit Padi Unggul Cireang',
      'Bibit padi berkualitas untuk hasil panen optimal.',
      55000, 75000, 50, 'kg',
      'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=1000&q=60',
      'available'
    ),
    (
      seller_uuid, pupuk_id, 'Pupuk Kompos Organik',
      'Pupuk organik dari bahan alami, cocok untuk berbagai tanaman.',
      30000, 45000, 100, 'kg',
      'https://images.unsplash.com/photo-1591857177580-dc82b9ac4e1e?auto=format&fit=crop&w=1000&q=60',
      'available'
    ),
    (
      seller_uuid, sayur_id, 'Tomat Cherry Segar Hydro',
      'Tomat cherry segar dari kebun hidroponik.',
      10000, 15000, 120, 'kg',
      'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=1000&q=60',
      'available'
    )
  on conflict do nothing;

  -- 5) Seed prediksi AI khusus girantra (project akhir)
  select product_id into p1 from public.products order by created_at asc limit 1;
  select product_id into p2 from public.products order by created_at asc offset 1 limit 1;

  if p1 is not null then
    insert into public.ai_price_predictions (product_id, predicted_price, confidence_score, model_version)
    values (p1, 76000, 0.92, 'v1.0')
    on conflict do nothing;
  end if;

  if p2 is not null then
    insert into public.ai_price_predictions (product_id, predicted_price, confidence_score, model_version)
    values (p2, 45500, 0.88, 'v1.0')
    on conflict do nothing;
  end if;
end $$;
