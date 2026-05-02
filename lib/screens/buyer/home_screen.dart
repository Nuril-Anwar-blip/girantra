import 'package:flutter/material.dart';
import 'package:girantra/models/product_model.dart';
import 'package:girantra/services/product_service.dart';
import 'package:girantra/ui/app_colors.dart';
import 'package:girantra/ui/app_text_styles.dart';
import 'package:girantra/widgets/header_section.dart';
import 'package:girantra/widgets/product_card.dart';

import 'cart_screen.dart';
import '../overlay/filter_screen.dart';
import 'like_screen.dart';
import '../notification/notification_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productService = ProductService();
  final _searchController = TextEditingController();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _displayProducts = [];
  bool _isLoading = true;

  // Filter state
  int? _filterCategoryId;
  String? _filterPriceSort;
  int? _filterRating;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.getProducts();
      setState(() {
        _allProducts = products;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<ProductModel> result = List.from(_allProducts);

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) =>
        p.product_name.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q)
      ).toList();
    }

    // Category filter
    if (_filterCategoryId != null) {
      result = result.where((p) => p.category_id == _filterCategoryId).toList();
    }

    // Rating filter
    if (_filterRating != null) {
      result = result.where((p) => p.rating >= _filterRating!).toList();
    }

    // Price sort
    if (_filterPriceSort == 'Termurah') {
      result.sort((a, b) => a.selling_price.compareTo(b.selling_price));
    } else if (_filterPriceSort == 'Termahal') {
      result.sort((a, b) => b.selling_price.compareTo(a.selling_price));
    }

    _displayProducts = result;
  }

  String _getCategoryTag(int categoryId) {
    switch (categoryId) {
      case 1: return 'Pupuk';
      case 2: return 'Benih';
      case 3: return 'Buah';
      case 4: return 'Sayuran';
      default: return 'Produk';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LocationHeaderAppBar(
        title: 'Location',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.text),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadProducts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=60',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search bar + Filter button
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: AppColors.mutedText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cari pupuk atau hasil tani...',
                              hintStyle: TextStyle(fontSize: 12, color: AppColors.mutedText),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 13, color: AppColors.text),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                            child: const Icon(Icons.close, size: 16, color: AppColors.mutedText),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => FilterDialog(
                        initialCategoryId: _filterCategoryId,
                        initialPriceSort: _filterPriceSort,
                        initialRating: _filterRating,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _filterCategoryId = result['categoryId'];
                        _filterPriceSort = result['priceSort'];
                        _filterRating = result['rating'];
                        _applyFilters();
                      });
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (_filterCategoryId != null || _filterPriceSort != null || _filterRating != null)
                          ? AppColors.primary
                          : AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category shortcuts (functional)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CategoryShortcut(
                  label: 'Benih', icon: Icons.spa_outlined,
                  isActive: _filterCategoryId == 2,
                  onTap: () {
                    setState(() {
                      _filterCategoryId = _filterCategoryId == 2 ? null : 2;
                      _applyFilters();
                    });
                  },
                ),
                _CategoryShortcut(
                  label: 'Pupuk', icon: Icons.eco_outlined,
                  isActive: _filterCategoryId == 1,
                  onTap: () {
                    setState(() {
                      _filterCategoryId = _filterCategoryId == 1 ? null : 1;
                      _applyFilters();
                    });
                  },
                ),
                _CategoryShortcut(
                  label: 'Buah', icon: Icons.apple_outlined,
                  isActive: _filterCategoryId == 3,
                  onTap: () {
                    setState(() {
                      _filterCategoryId = _filterCategoryId == 3 ? null : 3;
                      _applyFilters();
                    });
                  },
                ),
                _CategoryShortcut(
                  label: 'Sayuran', icon: Icons.grass_outlined,
                  isActive: _filterCategoryId == 4,
                  onTap: () {
                    setState(() {
                      _filterCategoryId = _filterCategoryId == 4 ? null : 4;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _filterCategoryId != null
                    ? 'Hasil Filter (${_displayProducts.length})'
                    : _searchQuery.isNotEmpty
                      ? 'Hasil Pencarian (${_displayProducts.length})'
                      : 'Lihat Produk Favorit',
                  style: AppTextStyles.h2,
                ),
                if (_filterCategoryId == null && _searchQuery.isEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const LikeScreen()),
                      );
                    },
                    child: Text(
                      'Lihat Selengkapnya >',
                      style: AppTextStyles.link.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Product grid
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_displayProducts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
                itemCount: _displayProducts.length,
                itemBuilder: (context, index) {
                  final product = _displayProducts[index];
                  return ProductCard(
                    imageUrl: product.image_url,
                    tag: _getCategoryTag(product.category_id),
                    title: product.product_name,
                    location: 'Surakarta',
                    rating: product.rating > 0 ? '${product.rating}' : 'Baru',
                    price: 'Rp ${product.selling_price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    unit: ' / ${product.unit.length > 1 ? product.unit.substring(0, 1).toUpperCase() + product.unit.substring(1).toLowerCase() : product.unit}',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _CategoryShortcut({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.divider,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.primaryDark,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
