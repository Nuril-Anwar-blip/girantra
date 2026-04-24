import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final _supabase = Supabase.instance.client;

  Future<void> addToCart({required int productId, int quantity = 1}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Cek apakah produk sudah ada di keranjang
    final existingCart = await _supabase
        .from('carts')
        .select()
        .eq('buyer_id', user.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existingCart != null) {
      // Update quantity
      await _supabase.from('carts').update({
        'quantity': (existingCart['quantity'] as int) + quantity,
      }).eq('card_id', existingCart['card_id']); // Assuming PK is card_id
    } else {
      // Insert new
      await _supabase.from('carts').insert({
        'buyer_id': user.id,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCarts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    // Assuming relationship exists: carts -> products
    final response = await _supabase
        .from('carts')
        .select('*, products(*)')
        .eq('buyer_id', user.id);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateQuantity(dynamic cartId, int quantity) async {
    await _supabase
        .from('carts')
        .update({'quantity': quantity})
        .eq('card_id', cartId); // Assuming PK is card_id
  }

  Future<void> removeFromCart(dynamic cartId) async {
    await _supabase.from('carts').delete().eq('card_id', cartId);
  }
}
