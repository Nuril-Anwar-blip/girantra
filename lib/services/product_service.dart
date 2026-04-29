import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // Get all products
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await supabase.from('products').select('''
        *,
        categories ( category_name ),
        users ( address )
      ''');
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(int productId) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('product_id', productId)
          .single();
      return ProductModel.fromJson(response);
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  // Get product by category
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    try {
      final response = await supabase
          .from('products')
          .select('''
            *,
            categories ( category_name ),
            users ( address )
          ''')
          .eq('category_id', categoryId);
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  // Add product
  Future<bool> addProduct({
    required int category_id,
    required String product_name,
    required String description,
    required double cost_price,
    required double selling_price,
    required double ai_recommendation_price,
    required int stock,
    required String unit, // kg, pcs, liter, dll
    required File image_file,
    required DateTime harvest_date,
    required String status_product, // Enum (available, out_of_stock)
  }) async {
    try {
      await supabase.auth.refreshSession();
      // Take seller ID from logged in user
      final String seller_id = supabase.auth.currentUser!.id;

      // Upload image to storage
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '$seller_id/$fileName';

      await supabase.storage.from('product-image').upload(path, image_file);

      // Get public URL
      final String imageUrl = supabase.storage
          .from('product-image')
          .getPublicUrl(path);

      print('--- DEBUG RLS ---');
      print('User ID: ${supabase.auth.currentUser?.id}');
      print('User Metadata: ${supabase.auth.currentUser?.userMetadata}');
      print('App Metadata: ${supabase.auth.currentUser?.appMetadata}');
      print('-----------------'); 

      // Insert product data
      await supabase.from('products').insert({
        'seller_id': seller_id,
        'category_id': category_id,
        'product_name': product_name,
        'description': description,
        'cost_price': cost_price,
        'selling_price': selling_price,
        'stock': stock,
        'unit': unit,
        'image_url': imageUrl,
        'harvest_date': harvest_date.toIso8601String().split('T')[0],
        'status_product': status_product,
      });
      print('✅ Produk berhasil ditambahkan!');
      return true;
    } catch (e) {
      print('Error adding product: $e');
      throw Exception(e.toString());
    }
  }

  // Update product — image_file opsional, jika null pakai existingImageUrl
  Future<bool> updateProduct({
    required int product_id,
    required int category_id,
    required String product_name,
    required String description,
    required double cost_price,
    required double selling_price,
    required int stock,
    required String unit,
    File? image_file,              // opsional
    String existingImageUrl = '', // URL gambar lama jika tidak ganti gambar
    required DateTime harvest_date,
    required String status_product,
  }) async {
    try {
      await supabase.auth.refreshSession();
      final String sellerId = supabase.auth.currentUser!.id;

      String imageUrl = existingImageUrl;

      // Upload gambar baru hanya jika disediakan
      if (image_file != null) {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String path = '$sellerId/$fileName';
        await supabase.storage.from('product-image').upload(path, image_file);
        imageUrl = supabase.storage.from('product-image').getPublicUrl(path);
      }

      final result = await supabase
          .from('products')
          .update({
            'category_id': category_id,
            'product_name': product_name,
            'description': description,
            'cost_price': cost_price,
            'selling_price': selling_price,
            'stock': stock,
            'unit': unit,
            if (imageUrl.isNotEmpty) 'image_url': imageUrl,
            'harvest_date': harvest_date.toIso8601String().split('T')[0],
            'status_product': status_product,
          })
          .eq('product_id', product_id)
          .eq('seller_id', sellerId)
          .select();

      if (result.isEmpty) {
        throw Exception('Update gagal (0 baris diubah). Periksa RLS policy.');
      }
      print('✅ Produk berhasil diupdate! Result: $result');
      return true;
    } catch (e) {
      print('❌ Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  Future<bool> deleteProduct(int productId) async {
    try {
      await supabase.from('products').delete().eq('product_id', productId);
      print('✅ Produk berhasil dihapus!');
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Get all products milik seller yang sedang login
  Future<List<ProductModel>> getSellerProducts() async {
    try {
      final sellerId = supabase.auth.currentUser?.id;
      if (sellerId == null) return [];
      final response = await supabase
          .from('products')
          .select('''
            *,
            categories ( category_name )
          ''')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting seller products: $e');
      return [];
    }
  }

  // Get produk seller berdasarkan status (available, out_of_stock, archived)
  Future<List<ProductModel>> getSellerProductsByStatus(String status) async {
    try {
      final sellerId = supabase.auth.currentUser?.id;
      if (sellerId == null) {
        print('⚠️ getSellerProductsByStatus("$status"): user tidak login');
        return [];
      }
      final response = await supabase
          .from('products')
          .select('''
            *,
            categories ( category_name ),
            transactions ( * )
          ''')
          .eq('seller_id', sellerId)
          .eq('status_product', status)
          .order('created_at', ascending: false);

      print('📦 Status "$status": ${response.length} produk ditemukan');

      // Parse satu per satu agar error terlihat jelas
      final List<ProductModel> result = [];
      for (final json in response) {
        try {
          int soldCount = 0;
          if (json['transactions'] != null && json['transactions'] is List) {
            for (var trx in json['transactions']) {
              if (trx['payment_status'] == 'paid') {
                final qty = trx['quantity'] ?? trx['qty'] ?? 0;
                soldCount += (qty is int ? qty : int.tryParse(qty.toString()) ?? 0);
              }
            }
          }
          json['sold_count'] = soldCount;

          result.add(ProductModel.fromJson(json));
        } catch (parseErr) {
          print('❌ Parse error untuk produk ${json["product_id"]}: $parseErr');
          print('   Raw data: $json');
        }
      }
      return result;
    } catch (e) {
      print('❌ Error getSellerProductsByStatus("$status"): $e');
      return [];
    }
  }

  // Update status produk (available, out_of_stock, archived)
  Future<bool> updateProductStatus(int productId, String status) async {
    try {
      await supabase.auth.refreshSession();
      print('🔄 Updating product $productId status to: "$status"');
      print('👤 Current user: ${supabase.auth.currentUser?.id}');

      final result = await supabase
          .from('products')
          .update({'status_product': status})
          .eq('product_id', productId)
          .select();

      print('✅ Update result (${result.length} rows): $result');

      if (result.isEmpty) {
        // Silent failure: RLS memblokir UPDATE atau product_id tidak ditemukan
        throw Exception(
          'Update tidak berhasil (0 baris diubah).\n'
          'Kemungkinan penyebab: RLS Policy di Supabase tidak mengizinkan UPDATE.\n'
          'Solusi: Buka Supabase Dashboard → Table Editor → products → Policies → '
          'tambah policy UPDATE untuk authenticated user.',
        );
      }
      return true;
    } catch (e) {
      print('❌ Error updating status to "$status": $e');
      rethrow;
    }
  }

  // Update stok produk saja, otomatis set status available jika stok > 0
  Future<bool> updateProductStock(int productId, int newStock) async {
    try {
      final newStatus = newStock > 0 ? 'available' : 'out_of_stock';
      await supabase
          .from('products')
          .update({'stock': newStock, 'status_product': newStatus})
          .eq('product_id', productId);
      print('✅ Stok produk berhasil diupdate ke $newStock!');
      return true;
    } catch (e) {
      print('Error updating product stock: $e');
      return false;
    }
  }
}

class StorageService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadProductImage(File imageFile) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      // Membuat path unik: user_id/timestamp.jpg
      final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Mengunggah ke bucket 'product-image'
      await supabase.storage.from('product-image').upload(path, imageFile);

      // Mengambil URL publik untuk disimpan ke tabel 'products'
      return supabase.storage.from('product-image').getPublicUrl(path);
    } catch (e) {
      print('Error upload: $e');
      return null;
    }
  }
}
