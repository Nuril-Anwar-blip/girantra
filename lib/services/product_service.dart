import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // Get all products
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await supabase.from('products').select();
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
          .select()
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

  // Update product
  Future<bool> updateProduct({
    required int product_id,
    required int category_id,
    required String product_name,
    required String description,
    required double cost_price,
    required double selling_price,
    required int stock,
    required String unit, // kg, pcs, liter, dll
    required File image_file,
    required DateTime harvest_date,
    required String status_product, // Enum (available, out_of_stock)
  }) async {
    try {
      // Take seller ID from logged in user
      final String sellerId = supabase.auth.currentUser!.id;

      // Upload image to storage
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '$sellerId/$fileName';

      await supabase.storage.from('product-image').upload(path, image_file);

      // Get public URL
      final String imageUrl = supabase.storage
          .from('product-image')
          .getPublicUrl(path);

      // Update product data
      await supabase
          .from('products')
          .update({
            'seller_id': sellerId,
            'category_id': category_id,
            'product_name': product_name,
            'description': description,
            'cost_price': cost_price,
            'selling_price': selling_price,
            'stock': stock,
            'unit': unit,
            'image_url': imageUrl,
            'harvest_date': harvest_date,
            'status_product': status_product,
          })
          .eq('product_id', product_id);
      print('✅ Produk berhasil diupdate!');
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
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
