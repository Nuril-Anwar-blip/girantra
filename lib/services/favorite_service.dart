import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Ambil semua product_id yang di-favorit oleh user saat ini
  Future<Set<int>> getFavoriteProductIds() async {
    if (_userId == null) return {};
    try {
      final response = await _supabase
          .from('favorites')
          .select('product_id')
          .eq('user_id', _userId!);
      return (response as List)
          .map((row) => row['product_id'] as int)
          .toSet();
    } catch (e) {
      return {};
    }
  }

  /// Ambil semua produk favorit user (join ke tabel products & categories)
  Future<List<Map<String, dynamic>>> getFavoriteProducts() async {
    if (_userId == null) return [];
    try {
      final response = await _supabase
          .from('favorites')
          .select('product_id, products(*, categories(category_name), users(address))')
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Tambah favorit — insert row ke tabel favorites
  Future<void> addFavorite(int productId) async {
    if (_userId == null) return;
    await _supabase.from('favorites').insert({
      'user_id': _userId,
      'product_id': productId,
    });
  }

  /// Hapus favorit — delete row dari tabel favorites
  Future<void> removeFavorite(int productId) async {
    if (_userId == null) return;
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', _userId!)
        .eq('product_id', productId);
  }

  /// Toggle: jika sudah favorit → hapus, belum → tambah
  /// Mengembalikan status baru (true = favorited)
  Future<bool> toggleFavorite(int productId, bool currentlyFavorited) async {
    if (currentlyFavorited) {
      await removeFavorite(productId);
      return false;
    } else {
      await addFavorite(productId);
      return true;
    }
  }
}
