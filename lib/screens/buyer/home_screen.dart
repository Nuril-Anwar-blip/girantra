import 'package:flutter/material.dart';
import 'package:girantra/models/product_model.dart';
import 'package:girantra/services/product_service.dart';
import 'package:girantra/ui/app_colors.dart';
import 'package:girantra/ui/app_text_styles.dart';
import 'package:girantra/widgets/header_section.dart';
import 'package:girantra/widgets/product_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  late Future<List<ProductModel>> _futureProducts;
  String _searchQuery = '';
  FilterResult? _activeFilter;

  // Kategori dari database
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId; // null = semua kategori

  // Mapping category_name → icon (fallback jika nama tidak dikenal)
  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('benih') || lower.contains('bibit')) return Icons.spa_outlined;
    if (lower.contains('pupuk')) return Icons.eco_outlined;
    if (lower.contains('buah')) return Icons.apple_outlined;
    if (lower.contains('sayur')) return Icons.grass_outlined;
    if (lower.contains('padi') || lower.contains('beras')) return Icons.agriculture_outlined;
    if (lower.contains('pestisida') || lower.contains('obat')) return Icons.science_outlined;
    return Icons.category_outlined;
  }

  @override
  void initState() {
    super.initState();
    _futureProducts = _productService.getProducts();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select('category_id, category_name')
          .order('category_id');
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Buka dialog filter dan terapkan hasil yang dikembalikan
  Future<void> _openFilter() async {
    final result = await showDialog<FilterResult>(
      context: context,
      builder: (context) => FilterDialog(initialFilter: _activeFilter),
    );
    // result null = dialog ditutup tanpa apply
    if (result != null) {
      setState(() => _activeFilter = result.hasFilter ? result : null);
    }
  }

  /// Terapkan filter + sort ke list produk
  List<ProductModel> _applyFilter(List<ProductModel> all) {
    var list = List<ProductModel>.from(all);

    // Filter pencarian nama
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => p.product_name.toLowerCase().contains(_searchQuery)).toList();
    }

    // Filter kategori shortcut (prioritas lebih tinggi dari filter dialog)
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.category_id == _selectedCategoryId).toList();
    } else if (_activeFilter?.categoryId != null) {
      list = list.where((p) => p.category_id == _activeFilter!.categoryId).toList();
    }

    // Filter rating minimum
    if (_activeFilter?.minRating != null) {
      list = list.where((p) => p.rating >= _activeFilter!.minRating!).toList();
    }

    // Sort harga
    if (_activeFilter?.priceSort == 'Termurah') {
      list.sort((a, b) => a.selling_price.compareTo(b.selling_price));
    } else if (_activeFilter?.priceSort == 'Termahal') {
      list.sort((a, b) => b.selling_price.compareTo(a.selling_price));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    // final session = Supabase.instance.client.auth.currentSession;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LocationHeaderAppBar(
        title: 'Location',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.text,
            ),
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
        onRefresh: () async {
          setState(() {
            _futureProducts = _productService.getProducts();
          });
          try {
            await _futureProducts;
          } catch (_) {}
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: AppColors.text,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Cari pupuk atau hasil tani...',
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: const Icon(Icons.close, size: 16, color: AppColors.mutedText),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _openFilter,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _activeFilter != null ? AppColors.primary : AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                    // Badge merah kecil saat filter aktif
                    if (_activeFilter != null)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Category Shortcuts (dinamis dari database) ──────────────
          _categories.isEmpty
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Tombol "Semua"
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _CategoryShortcut(
                          label: 'Semua',
                          icon: Icons.apps_outlined,
                          isSelected: _selectedCategoryId == null,
                          onTap: () => setState(() => _selectedCategoryId = null),
                        ),
                      ),
                      ..._categories.map((cat) {
                        final int id = cat['category_id'] as int? ?? 0;
                        final String name = cat['category_name']?.toString() ?? 'Lainnya';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryShortcut(
                            label: name,
                            icon: _iconForCategory(name),
                            isSelected: _selectedCategoryId == id,
                            onTap: () => setState(() {
                              // Toggle: klik lagi untuk deselect
                              _selectedCategoryId = _selectedCategoryId == id ? null : id;
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lihat Produk Favorit', style: AppTextStyles.h2),
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
          FutureBuilder<List<ProductModel>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              var products = _applyFilter(snapshot.data ?? []);

              if (products.isEmpty) {
                // Tentukan pesan empty state berdasarkan kondisi
                final selectedCatName = _selectedCategoryId != null
                    ? (_categories.firstWhere(
                        (c) => c['category_id'] == _selectedCategoryId,
                        orElse: () => {'category_name': 'Kategori ini'},
                      )['category_name']?.toString() ?? 'Kategori ini')
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Icon(
                        _selectedCategoryId != null ? Icons.inventory_2_outlined : Icons.search_off,
                        size: 56,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedCategoryId != null
                            ? 'Produk "$selectedCatName" belum tersedia'
                            : 'Produk "${_searchController.text}" tidak ditemukan',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                   return ProductCard(
                    imageUrl: product.image_url,
                    tag: product.category_name ?? (product.category_id == 1
                        ? 'Pupuk'
                        : (product.category_id == 2 ? 'Benih' : 'Produk')),
                    title: product.product_name,
                    location: product.seller_address != null && product.seller_address!.isNotEmpty ? product.seller_address! : 'Surakarta',
                    rating: product.rating > 0 ? '${product.rating}' : 'Baru',
                    price:
                        'Rp ${product.selling_price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    unit:
                        ' / ${product.unit.length > 1 ? product.unit.substring(0, 1).toUpperCase() + product.unit.substring(1).toLowerCase() : product.unit}',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
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
  final bool isSelected;

  const _CategoryShortcut({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primaryDark,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.subtitle.copyWith(
                color: isSelected ? Colors.white : AppColors.primaryDark,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
