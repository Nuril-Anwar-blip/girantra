-- GIRANTRA SEED DATA — Jalankan di Supabase SQL Editor
-- Sesuai skema aktual database

-- 1. CATEGORIES
INSERT INTO public.categories (category_name, description, icon_url) VALUES
  ('Pupuk',   'Berbagai jenis pupuk organik dan anorganik', NULL),
  ('Benih',   'Bibit dan benih unggul tanaman', NULL),
  ('Buah',    'Buah segar hasil pertanian lokal', NULL),
  ('Sayuran', 'Sayuran segar langsung dari petani', NULL)
ON CONFLICT (category_name) DO NOTHING;

-- 2. USERS (3 seller + 4 buyer)
-- CATATAN: Ganti UUID ini dengan user_id dari auth.users jika sudah register
INSERT INTO public.users (user_id, full_name, email, phone_number, address, role, account_status) VALUES
  ('a1111111-1111-1111-1111-111111111111','Toko Tani Makmur','tokotani@girantra.test','081234567001','Jl. Raya Pertanian No. 12, Surakarta','seller','active'),
  ('a2222222-2222-2222-2222-222222222222','Kebun Organik Sejati','kebunorganik@girantra.test','081234567002','Dusun Sumber Rejeki RT 03, Karanganyar','seller','active'),
  ('a3333333-3333-3333-3333-333333333333','Agro Nusantara','agronusa@girantra.test','081234567003','Jl. Pasar Legi No. 45, Boyolali','seller','active'),
  ('b1111111-1111-1111-1111-111111111111','Budi Santoso','budi@girantra.test','081234567010','Jl. Merdeka No. 10, Surakarta','buyer','active'),
  ('b2222222-2222-2222-2222-222222222222','Siti Aminah','siti@girantra.test','081234567011','Jl. Melati No. 5, Klaten','buyer','active'),
  ('b3333333-3333-3333-3333-333333333333','Andi Prasetyo','andi@girantra.test','081234567012','Jl. Kenanga No. 22, Sragen','buyer','active'),
  ('b4444444-4444-4444-4444-444444444444','Dewi Lestari','dewi@girantra.test','081234567013','Jl. Anggrek No. 8, Wonogiri','buyer','active')
ON CONFLICT (user_id) DO NOTHING;

-- 3. PRODUCTS (20 produk, 5 per kategori)
INSERT INTO public.products (seller_id, category_id, product_name, description, cost_price, selling_price, ai_recommendation_price, stock, unit, image_url, harvest_date, status_product, rating, total_reviews) VALUES
  -- Pupuk (cat 1)
  ('a1111111-1111-1111-1111-111111111111',1,'Pupuk Kompos Organik Premium','Pupuk kompos dari bahan organik pilihan.',30000,45000,42000,150,'Kg','https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400','2026-04-20','available',4.5,12),
  ('a1111111-1111-1111-1111-111111111111',1,'NPK Mutiara 16-16-16','Pupuk NPK serbaguna untuk pertumbuhan.',12000,18000,17500,300,'Kg','https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400','2026-04-15','available',4.2,8),
  ('a2222222-2222-2222-2222-222222222222',1,'Pupuk Organik Cair Bio','Pupuk cair fermentasi mikroba.',20000,35000,33000,80,'Liter','https://images.unsplash.com/photo-1592419044706-39796d40f98c?w=400','2026-04-18','available',4.7,15),
  ('a3333333-3333-3333-3333-333333333333',1,'Dolomit Super','Kapur dolomit untuk menetralkan pH tanah.',8000,12000,11500,500,'Kg','https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=400','2026-04-10','available',4.0,5),
  ('a1111111-1111-1111-1111-111111111111',1,'Pupuk ZA Amonium Sulfat','Pupuk nitrogen tinggi untuk padi dan jagung.',10000,15000,14500,200,'Kg','https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=400','2026-04-12','available',3.8,3),
  -- Benih (cat 2)
  ('a2222222-2222-2222-2222-222222222222',2,'Bibit Padi Ciherang Unggul','Varietas unggul nasional tahan wereng.',50000,75000,72000,100,'Kg','https://images.unsplash.com/photo-1596724896798-17de24c9eb72?w=400','2026-03-25','available',4.8,20),
  ('a2222222-2222-2222-2222-222222222222',2,'Benih Jagung Hibrida NK7328','Jagung hibrida produktivitas tinggi.',85000,120000,115000,50,'Kg','https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400','2026-03-20','available',4.6,10),
  ('a3333333-3333-3333-3333-333333333333',2,'Bibit Cabai Rawit Domba','Cabai rawit pedas maksimal.',15000,25000,23000,200,'Pcs','https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400','2026-04-01','available',4.3,7),
  ('a1111111-1111-1111-1111-111111111111',2,'Benih Tomat Servo F1','Tomat buah besar merah tahan layu bakteri.',30000,45000,43000,120,'Pcs','https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=400','2026-04-05','available',4.4,9),
  ('a2222222-2222-2222-2222-222222222222',2,'Bibit Kangkung Cabut Super','Kangkung darat cepat panen 25 hari.',5000,8000,7500,500,'Pcs','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400','2026-04-08','available',4.1,4),
  -- Buah (cat 3)
  ('a3333333-3333-3333-3333-333333333333',3,'Jeruk Manis Pacitan','Jeruk manis segar dari kebun Pacitan.',15000,22000,21000,80,'Kg','https://images.unsplash.com/photo-1547514701-42782101795e?w=400','2026-04-22','available',4.6,11),
  ('a1111111-1111-1111-1111-111111111111',3,'Mangga Harum Manis','Mangga grade A matang pohon.',25000,38000,36000,60,'Kg','https://images.unsplash.com/photo-1553279768-865429fa0078?w=400','2026-04-25','available',4.9,18),
  ('a2222222-2222-2222-2222-222222222222',3,'Pepaya California','Pepaya daging tebal manis segar.',10000,15000,14000,100,'Kg','https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=400','2026-04-20','available',4.3,6),
  ('a3333333-3333-3333-3333-333333333333',3,'Pisang Raja Nangka','Pisang raja nangka asli Boyolali.',18000,28000,26000,70,'Sisir','https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400','2026-04-18','available',4.4,8),
  ('a1111111-1111-1111-1111-111111111111',3,'Semangka Merah Tanpa Biji','Semangka merah renyah tanpa biji.',12000,20000,19000,40,'Kg','https://images.unsplash.com/photo-1563114773-84221bd62daa?w=400','2026-04-24','available',4.5,7),
  -- Sayuran (cat 4)
  ('a2222222-2222-2222-2222-222222222222',4,'Bayam Hijau Segar','Bayam hijau organik dipetik pagi hari.',3000,5000,4800,200,'Ikat','https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400','2026-04-28','available',4.2,5),
  ('a3333333-3333-3333-3333-333333333333',4,'Wortel Organik Dieng','Wortel segar dari dataran tinggi Dieng.',8000,12000,11500,150,'Kg','https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400','2026-04-26','available',4.7,13),
  ('a1111111-1111-1111-1111-111111111111',4,'Brokoli Segar Premium','Brokoli hijau segar kaya nutrisi.',15000,22000,21000,80,'Kg','https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400','2026-04-27','available',4.5,9),
  ('a2222222-2222-2222-2222-222222222222',4,'Kentang Granola Dieng','Kentang granola super kulit mulus.',12000,18000,17000,250,'Kg','https://images.unsplash.com/photo-1518977676601-b53f82ber40?w=400','2026-04-25','available',4.6,11),
  ('a3333333-3333-3333-3333-333333333333',4,'Cabai Merah Keriting','Cabai merah keriting segar pedas sedang.',30000,45000,43000,100,'Kg','https://images.unsplash.com/photo-1583119022894-919a68a3d0e3?w=400','2026-04-28','available',4.3,6);

-- 4. TRANSACTIONS (sesuai skema aktual — tanpa order_status, payment_method, service_fee, dll)
INSERT INTO public.transactions (transaction_code, buyer_id, seller_id, product_id, quantity, price_at_purchase, sub_total, shipping_cost, total_amount, shipping_address, payment_status, transaction_date) VALUES
  ('TRX-20260425001','b1111111-1111-1111-1111-111111111111','a1111111-1111-1111-1111-111111111111',1,3,45000,135000,5000,140000,'Jl. Merdeka No. 10, Surakarta','paid','2026-04-25 10:30:00+07'),
  ('TRX-20260425002','b2222222-2222-2222-2222-222222222222','a2222222-2222-2222-2222-222222222222',6,2,75000,150000,5000,155000,'Jl. Melati No. 5, Klaten','paid','2026-04-25 14:15:00+07'),
  ('TRX-20260426001','b3333333-3333-3333-3333-333333333333','a3333333-3333-3333-3333-333333333333',11,5,22000,110000,8000,118000,'Jl. Kenanga No. 22, Sragen','paid','2026-04-26 09:00:00+07'),
  ('TRX-20260426002','b4444444-4444-4444-4444-444444444444','a1111111-1111-1111-1111-111111111111',12,3,38000,114000,5000,119000,'Jl. Anggrek No. 8, Wonogiri','paid','2026-04-26 11:30:00+07'),
  ('TRX-20260427001','b1111111-1111-1111-1111-111111111111','a2222222-2222-2222-2222-222222222222',3,2,35000,70000,5000,75000,'Jl. Merdeka No. 10, Surakarta','pending','2026-04-27 08:45:00+07'),
  ('TRX-20260427002','b2222222-2222-2222-2222-222222222222','a3333333-3333-3333-3333-333333333333',17,4,12000,48000,5000,53000,'Jl. Melati No. 5, Klaten','pending','2026-04-27 13:20:00+07'),
  ('TRX-20260428001','b3333333-3333-3333-3333-333333333333','a1111111-1111-1111-1111-111111111111',18,2,22000,44000,5000,49000,'Jl. Kenanga No. 22, Sragen','paid','2026-04-28 10:00:00+07'),
  ('TRX-20260428002','b4444444-4444-4444-4444-444444444444','a2222222-2222-2222-2222-222222222222',16,10,5000,50000,5000,55000,'Jl. Anggrek No. 8, Wonogiri','paid','2026-04-28 15:30:00+07'),
  ('TRX-20260429001','b1111111-1111-1111-1111-111111111111','a3333333-3333-3333-3333-333333333333',8,5,25000,125000,8000,133000,'Jl. Merdeka No. 10, Surakarta','paid','2026-04-29 09:15:00+07'),
  ('TRX-20260430001','b2222222-2222-2222-2222-222222222222','a1111111-1111-1111-1111-111111111111',15,2,20000,40000,5000,45000,'Jl. Melati No. 5, Klaten','pending','2026-04-30 07:30:00+07');

-- 5. CARTS (contoh keranjang)
INSERT INTO public.carts (buyer_id, product_id, quantity) VALUES
  ('b1111111-1111-1111-1111-111111111111', 5, 2),
  ('b1111111-1111-1111-1111-111111111111', 17, 3),
  ('b2222222-2222-2222-2222-222222222222', 12, 1),
  ('b2222222-2222-2222-2222-222222222222', 9, 2),
  ('b3333333-3333-3333-3333-333333333333', 3, 1),
  ('b4444444-4444-4444-4444-444444444444', 20, 5);

-- 6. FAVORITES
INSERT INTO public.favorites (user_id, product_id) VALUES
  ('b1111111-1111-1111-1111-111111111111',1),
  ('b1111111-1111-1111-1111-111111111111',6),
  ('b1111111-1111-1111-1111-111111111111',12),
  ('b2222222-2222-2222-2222-222222222222',3),
  ('b2222222-2222-2222-2222-222222222222',11),
  ('b2222222-2222-2222-2222-222222222222',17),
  ('b3333333-3333-3333-3333-333333333333',8),
  ('b3333333-3333-3333-3333-333333333333',18),
  ('b4444444-4444-4444-4444-444444444444',9),
  ('b4444444-4444-4444-4444-444444444444',14);

-- 7. NOTIFICATIONS
INSERT INTO public.notifications (user_id, title, message, is_read, notification_type) VALUES
  ('b1111111-1111-1111-1111-111111111111','Pesanan Selesai','Pesanan TRX-20260425001 telah selesai!',true,'transaction_update'),
  ('b1111111-1111-1111-1111-111111111111','Promo Spesial','Diskon 20% untuk semua pupuk organik minggu ini!',false,'promo'),
  ('b2222222-2222-2222-2222-222222222222','Pesanan Selesai','Pesanan TRX-20260425002 telah selesai!',true,'transaction_update'),
  ('b2222222-2222-2222-2222-222222222222','Pembayaran Menunggu','Segera bayar pesanan TRX-20260427002.',false,'payment_reminder'),
  ('b3333333-3333-3333-3333-333333333333','Pesanan Dikirim','Pesanan TRX-20260426001 sedang dikirim.',false,'transaction_update'),
  ('b4444444-4444-4444-4444-444444444444','Pesanan Diproses','Pesanan TRX-20260426002 sedang dikemas.',false,'transaction_update'),
  ('a1111111-1111-1111-1111-111111111111','Pesanan Baru!','Pesanan baru TRX-20260427001 dari Budi Santoso.',false,'new_order'),
  ('a2222222-2222-2222-2222-222222222222','Produk Favorit','Pupuk Organik Cair Bio di-favorit 15 pembeli!',false,'product_milestone'),
  ('a3333333-3333-3333-3333-333333333333','Review Baru','Review bintang 5 untuk Bibit Cabai Rawit Domba!',false,'review');

-- 8. WALLETS (saldo penjual)
INSERT INTO public.wallets (seller_id, balance) VALUES
  ('a1111111-1111-1111-1111-111111111111', 399000),
  ('a2222222-2222-2222-2222-222222222222', 260000),
  ('a3333333-3333-3333-3333-333333333333', 251000);

-- 9. WITHDRAWALS (riwayat penarikan)
INSERT INTO public.withdrawals (seller_id, amount, bank_name) VALUES
  ('a1111111-1111-1111-1111-111111111111', 200000, 'Bank BRI'),
  ('a2222222-2222-2222-2222-222222222222', 150000, 'Bank BCA'),
  ('a3333333-3333-3333-3333-333333333333', 100000, 'Bank Mandiri');

-- SELESAI! Data: 4 kategori, 7 users, 20 produk, 10 transaksi, 6 cart, 10 favorit, 9 notifikasi, 3 wallet, 3 withdrawal
