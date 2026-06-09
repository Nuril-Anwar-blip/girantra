import 'package:flutter/material.dart';
import 'package:girantra/models/product_model.dart';
import 'package:girantra/services/product_service.dart';
import 'package:girantra/ui/app_colors.dart';
import 'package:girantra/ui/app_text_styles.dart';
import 'package:girantra/widgets/product_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_screen.dart';
import '../overlay/filter_screen.dart';
import 'like_screen.dart';
import '../notification/notification_screen.dart';
import 'product_detail_screen.dart';
import '../ai/ai_research_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productService = ProductService();
  final _searchController = TextEditingController();

  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  RealtimeChannel? _productsChannel;
  String _searchQuery = '';
  FilterResult? _activeFilter;
  String _userAddress = 'Memuat lokasi...';

  // Categories from database
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;

  // Mapping category_name → icon
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
    _loadProducts();
    _subscribeToRealtime();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    _fetchCategories();
    _fetchUserAddress();
  }

  Future<void> _fetchUserAddress() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select('address')
            .eq('user_id', user.id)
            .maybeSingle();
        if (userData != null && mounted) {
          setState(() {
            _userAddress = userData['address'] ?? 'Alamat belum diatur';
          });
        }
      } else {
        setState(() {
          _userAddress = 'Tamu (Alamat belum diatur)';
        });
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
      setState(() {
        _userAddress = 'Alamat belum diatur';
      });
    }
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

  void _subscribeToRealtime() {
    try {
      _productsChannel = Supabase.instance.client
          .channel('public:products')
          .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'products',
              callback: (payload) {
                debugPrint('🔄 Realtime update: ${payload.eventType}');
                _loadProducts(isSilent: true);
              })
          .subscribe();
    } catch (e) {
      debugPrint('⚠️ Realtime subscription failed (non-fatal): $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _productsChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadProducts({bool isSilent = false}) async {
    if (!isSilent && mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
    try {
      final data = await _productService.getProducts();
      if (mounted) {
        setState(() {
          _products = data;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        if (!isSilent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat produk. Menampilkan data terakhir.')),
          );
        }
      }
    }
  }

  Future<void> _openFilter() async {
    final result = await showDialog<FilterResult>(
      context: context,
      builder: (context) => FilterDialog(initialFilter: _activeFilter),
    );
    if (result != null) {
      setState(() => _activeFilter = result.hasFilter ? result : null);
    }
  }

  List<ProductModel> _applyFilter(List<ProductModel> all) {
    var list = List<ProductModel>.from(all);
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => p.product_name.toLowerCase().contains(_searchQuery)).toList();
    }
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.category_id == _selectedCategoryId).toList();
    } else if (_activeFilter?.categoryId != null) {
      list = list.where((p) => p.category_id == _activeFilter!.categoryId).toList();
    }
    if (_activeFilter?.minRating != null) {
      list = list.where((p) => p.rating >= _activeFilter!.minRating!).toList();
    }
    if (_activeFilter?.priceSort == 'Termurah') {
      list.sort((a, b) => a.selling_price.compareTo(b.selling_price));
    } else if (_activeFilter?.priceSort == 'Termahal') {
      list.sort((a, b) => b.selling_price.compareTo(a.selling_price));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/logo_girantra.png',
            width: 36,
            height: 36,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.agriculture,
              color: Color(0xFF1D9E75),
              size: 28,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.orange,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _userAddress,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.text),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
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
            // Search bar + Filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: AppColors.mutedText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: AppColors.text),
                            decoration: const InputDecoration(
                              hintText: 'Cari pupuk atau hasil tani...',
                              hintStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: AppColors.mutedText),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(onTap: () => _searchController.clear(), child: const Icon(Icons.close, size: 16, color: AppColors.mutedText)),
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
                        decoration: BoxDecoration(color: _activeFilter != null ? AppColors.primary : AppColors.primaryDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                      if (_activeFilter != null)
                        const Positioned(top: -4, right: -4, child: CircleAvatar(radius: 6, backgroundColor: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Category shortcuts
            _categories.isEmpty
                ? const SizedBox.shrink()
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryShortcut(label: 'Semua', icon: Icons.apps_outlined, isSelected: _selectedCategoryId == null, onTap: () => setState(() => _selectedCategoryId = null)),
                        ),
                        ..._categories.map((cat) {
                          final int id = cat['category_id'] as int? ?? 0;
                          final String name = cat['category_name']?.toString() ?? 'Lainnya';
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _CategoryShortcut(label: name, icon: _iconForCategory(name), isSelected: _selectedCategoryId == id, onTap: () => setState(() => _selectedCategoryId = _selectedCategoryId == id ? null : id)),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lihat Produk Favorit', style: AppTextStyles.h2),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LikeScreen())),
                  child: Text('Lihat Selengkapnya >', style: AppTextStyles.link.copyWith(color: AppColors.accent, fontWeight: FontWeight.w400, decoration: TextDecoration.underline, decorationColor: AppColors.accent)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoading && _products.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 32), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
            else if (_products.isEmpty && _hasError)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data. Periksa koneksi internet.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _loadProducts(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            else ...[
              Builder(
                builder: (context) {
                  final products = _applyFilter(_products);
                  if (products.isEmpty) {
                    final selectedCatName = _selectedCategoryId != null
                        ? (_categories.firstWhere((c) => c['category_id'] == _selectedCategoryId, orElse: () => {'category_name': 'Kategori ini'})['category_name']?.toString() ?? 'Kategori ini')
                        : null;
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(_selectedCategoryId != null ? Icons.inventory_2_outlined : Icons.search_off, size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            _selectedCategoryId != null ? 'Produk "$selectedCatName" belum tersedia' : 'Produk "${_searchController.text}" tidak ditemukan',
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.55),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        imageUrl: product.image_url,
                        tag: product.category_name ?? (product.category_id == 1 ? 'Pupuk' : (product.category_id == 2 ? 'Benih' : 'Produk')),
                        title: product.product_name,
                        location: product.seller_address?.isNotEmpty == true ? product.seller_address! : 'Surakarta',
                        rating: product.rating > 0 ? '${product.rating}' : 'Baru',
                        price: 'Rp ${product.selling_price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        unit: ' / ${product.unit.length > 1 ? product.unit.substring(0, 1).toUpperCase() + product.unit.substring(1).toLowerCase() : product.unit}',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                      );
                    },
                  );
                },
              ),
            ],
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

  const _CategoryShortcut({required this.label, required this.icon, required this.onTap, this.isSelected = false, Key? key}) : super(key: key);

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
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 1.5 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 3))] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.primaryDark, size: 22),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.subtitle.copyWith(color: isSelected ? Colors.white : AppColors.primaryDark, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
