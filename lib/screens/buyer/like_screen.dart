import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/favorite_service.dart';
import '../../ui/app_colors.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  final _favoriteService = FavoriteService();

  List<ProductModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final rows = await _favoriteService.getFavoriteProducts();
      final products = rows
          .map((row) {
            final productJson = row['products'];
            if (productJson == null) return null;
            return ProductModel.fromJson(productJson as Map<String, dynamic>);
          })
          .whereType<ProductModel>()
          .toList();

      if (mounted) {
        setState(() {
          _favorites = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(ProductModel product) async {
    final productId = product.product_id;
    if (productId == null) return;

    // Optimistic UI: hapus dari list langsung
    setState(() {
      _favorites.removeWhere((p) => p.product_id == productId);
    });

    try {
      await _favoriteService.removeFavorite(productId);
    } catch (e) {
      // Rollback jika gagal
      if (mounted) {
        setState(() => _favorites.insert(0, product));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus favorit: $e')),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
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
                'Favorit Saya',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadFavorites,
              child: _favorites.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.55,
                      ),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final product = _favorites[index];
                        return ProductCard(
                          imageUrl: product.image_url,
                          tag: product.category_name ??
                              (product.category_id == 1
                                  ? 'Pupuk'
                                  : (product.category_id == 2 ? 'Benih' : 'Produk')),
                          title: product.product_name,
                          location: product.seller_address ?? 'Surakarta',
                          rating: product.rating > 0 ? '${product.rating}' : 'Baru',
                          price: _formatCurrency(product.selling_price),
                          unit: ' / ${product.unit}',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      // Pakai ListView agar RefreshIndicator bisa dipakai saat kosong
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Belum ada produk favorit',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tekan ikon ❤️ pada produk untuk\nmenambahkannya ke favorit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
