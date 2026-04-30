import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/app_constants.dart';

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

  Future<void> checkoutCart(List<Map<String, dynamic>> cartItems) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    if (cartItems.isEmpty) return;

    // Ambil alamat pembeli
    final userResponse = await _supabase
        .from('users')
        .select('address')
        .eq('user_id', user.id)
        .maybeSingle();

    final String address = userResponse?['address']?.toString() ?? '-';

    for (var item in cartItems) {
      final product = item['products'];
      if (product == null) continue;

      final int qty = item['quantity'] ?? 1;
      final double priceAtPurchase = (product['selling_price'] as num?)?.toDouble() ?? 0;
      final double subTotal = priceAtPurchase * qty;
      final double shippingCost = AppConstants.totalFee; // Dari AppConstants (shippingFee + serviceFee)
      final double totalAmount = subTotal + shippingCost;
      
      final String transactionCode = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

      // 1. Insert ke transactions
      await _supabase.from('transactions').insert({
        'transaction_code': transactionCode,
        'buyer_id': user.id,
        'seller_id': product['seller_id'],
        'product_id': product['product_id'],
        'quantity': qty,
        'price_at_purchase': priceAtPurchase,
        'sub_total': subTotal,
        'shipping_cost': shippingCost,
        'total_amount': totalAmount,
        'shipping_address': address,
        'payment_status': 'pending',
      });

      // 2. Hapus dari keranjang
      final cartIdField = item.containsKey('card_id') ? 'card_id' : 'cart_id';
      await removeFromCart(item[cartIdField]);
    }
  }
}
