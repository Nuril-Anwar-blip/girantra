import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/product_card.dart';
import '../buyer/product_detail_screen.dart';

class SellerScreen extends StatefulWidget {
  final String sellerId;

  const SellerScreen({super.key, required this.sellerId});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _sellerData;
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSellerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSellerData() async {
    try {
      // Fetch seller profile
      final sellerResp = await _supabase
          .from('users')
          .select()
          .eq('user_id', widget.sellerId)
          .maybeSingle();

      // Fetch seller products
      final productsResp = await _supabase
          .from('products')
          .select()
          .eq('seller_id', widget.sellerId)
          .eq('status_product', 'available')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _sellerData = sellerResp;
          _products = productsResp.map((json) => ProductModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading seller data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Group products by category
  Map<String, List<ProductModel>> get _productsByCategory {
    final map = <String, List<ProductModel>>{};
    for (final p in _products) {
      final cat = _getCategoryName(p.category_id);
      map.putIfAbsent(cat, () => []).add(p);
    }
    return map;
  }

  String _getCategoryName(int id) {
    switch (id) {
      case 1: return 'Pupuk';
      case 2: return 'Benih';
      case 3: return 'Buah';
      case 4: return 'Sayuran';
      default: return 'Lainnya';
    }
  }

  double get _avgRating {
    if (_products.isEmpty) return 0;
    final total = _products.fold<double>(0, (sum, p) => sum + p.rating);
    return total / _products.length;
  }

  @override
  Widget build(BuildContext context) {
    final sellerName = _sellerData?['full_name']?.toString() ?? 'Penjual';
    final sellerAddress = _sellerData?['address']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leadingWidth: 110,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          label: const Text('Kembali', style: TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text('Detail Penjual', style: TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Seller Header Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Text(
                          sellerName.isNotEmpty ? sellerName[0].toUpperCase() : 'S',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sellerName, style: AppTextStyles.h2.copyWith(color: Colors.white)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.accent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${_avgRating.toStringAsFixed(1)}  |  ${_products.length} Produk',
                                  style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sellerAddress,
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom White Container
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                border: Border(bottom: BorderSide(color: Color(0xFF2E7D32), width: 3)),
                              ),
                              labelColor: const Color(0xFF2E7D32),
                              unselectedLabelColor: Colors.grey,
                              labelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14),
                              tabs: const [Tab(text: 'Produk'), Tab(text: 'Kategori')],
                            ),
                          ),
                        ),

                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Produk Tab
                              _products.isEmpty
                                  ? const Center(child: Text('Belum ada produk'))
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.55,
                                      ),
                                      itemCount: _products.length,
                                      itemBuilder: (context, index) {
                                        final p = _products[index];
                                        return ProductCard(
                                          imageUrl: p.image_url,
                                          tag: _getCategoryName(p.category_id),
                                          title: p.product_name,
                                          location: sellerAddress.split(',').first,
                                          rating: p.rating > 0 ? '${p.rating}' : 'Baru',
                                          price: 'Rp ${p.selling_price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                          unit: '/ ${p.unit}',
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                                            );
                                          },
                                        );
                                      },
                                    ),

                              // Kategori Tab
                              _productsByCategory.isEmpty
                                  ? const Center(child: Text('Belum ada kategori'))
                                  : ListView(
                                      padding: const EdgeInsets.all(16),
                                      children: _productsByCategory.entries.map((entry) {
                                        return _CategoryAccordion(
                                          title: entry.key,
                                          count: entry.value.length,
                                          products: entry.value,
                                        );
                                      }).toList(),
                                    ),
                            ],
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

class _CategoryAccordion extends StatefulWidget {
  final String title;
  final int count;
  final List<ProductModel> products;

  const _CategoryAccordion({required this.title, required this.count, required this.products});

  @override
  State<_CategoryAccordion> createState() => _CategoryAccordionState();
}

class _CategoryAccordionState extends State<_CategoryAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.title} (${widget.count})',
                    style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF2E7D32), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF2E7D32), size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: widget.products.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.white,
                    padding: const EdgeInsets.all(4),
                    child: ProductListTile(
                      title: p.product_name,
                      storeName: 'Stok: ${p.stock} ${p.unit}',
                      price: 'Rp ${p.selling_price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      imageUrl: p.image_url,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
