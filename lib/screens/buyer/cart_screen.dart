import 'package:flutter/material.dart';
import 'package:girantra/ui/app_text_styles.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_constants.dart';
// import '../ui/app_widgets.dart';
import '../../widgets/product_card.dart';
import '../../services/cart_service.dart';
import '../navigation/buyer_navigation.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCarts();
  }

  Future<void> _loadCarts() async {
    setState(() => _isLoading = true);
    try {
      final items = await _cartService.getCarts();
      setState(() {
        _cartItems = items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat keranjang: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateQty(int index, int newQty) async {
    if (newQty < 1) return;
    
    final item = _cartItems[index];
    final cartIdField = item.containsKey('card_id') ? 'card_id' : 'cart_id';
    
    setState(() {
      _cartItems[index]['quantity'] = newQty;
    });

    try {
      await _cartService.updateQuantity(item[cartIdField], newQty);
    } catch (e) {
      // Revert on error
      setState(() {
        _cartItems[index]['quantity'] = item['quantity'];
      });
    }
  }

  Future<void> _deleteItem(int index) async {
    final item = _cartItems[index];
    final cartIdField = item.containsKey('card_id') ? 'card_id' : 'cart_id';
    
    try {
      await _cartService.removeFromCart(item[cartIdField]);
      setState(() {
        _cartItems.removeAt(index);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _cartService.checkoutCart(_cartItems);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil membuat pesanan. Silakan lakukan pembayaran.')),
        );
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation(initialIndex: 1)),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal checkout: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _totalPrice {
    int total = 0;
    for (var item in _cartItems) {
      final product = item['products'];
      if (product != null) {
        final price = (product['selling_price'] as num?)?.toInt() ?? 0;
        final qty = item['quantity'] as int? ?? 1;
        total += (price * qty) + AppConstants.totalFee.toInt(); // Harga produk + biaya kirim & layanan
      }
    }
    return total;
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 110,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 16),
          label: const Text(
            'Kembali',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Keranjang Saya',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(child: Text('Keranjang kosong'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _cartItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            final product = item['products'] ?? {};
                            
                            final categoryId = product['category_id'] as int? ?? 0;
                            final tag = categoryId == 1 ? 'Pupuk' : (categoryId == 2 ? 'Benih' : 'Produk');
                            final price = (product['selling_price'] as num?)?.toInt() ?? 0;
                            final qty = item['quantity'] as int? ?? 1;

                            return ProductCart(
                              tag: tag,
                              title: product['product_name']?.toString() ?? 'Produk',
                              description: product['description']?.toString() ?? '',
                              price: _formatCurrency(price),
                              qty: qty,
                              imageUrl: product['image_url']?.toString() ?? '',
                              onAdd: () => _updateQty(index, qty + 1),
                              onRemove: () => _updateQty(index, qty - 1),
                              onDelete: () => _deleteItem(index),
                            );
                          },
                        ),
                ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TOTAL',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(_totalPrice),
                        style: AppTextStyles.finalPrice,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: _cartItems.isEmpty ? null : _checkout,
                      child: Text(
                        'Checkout (${_cartItems.length})',
                        style: AppTextStyles.link.copyWith(
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
