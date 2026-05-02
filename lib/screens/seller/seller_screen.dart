import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
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

  // Seller info
  String _sellerName = '';
  String _sellerAddress = '';
  String _avatarUrl = '';
  int _totalSold = 0;
  double _avgRating = 0.0;

  // Products & categories
  List<ProductModel> _products = [];
  Map<String, List<ProductModel>> _categoryMap = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchSellerInfo(),
        _fetchSellerProducts(),
      ]);
    } catch (e) {
      debugPrint('Error loading seller data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSellerInfo() async {
    // Fetch profil seller
    final userData = await _supabase
        .from('users')
        .select('full_name, address')
        .eq('user_id', widget.sellerId)
        .maybeSingle();

    // Fetch total terjual
    final txData = await _supabase
        .from('transactions')
        .select('quantity')
        .eq('seller_id', widget.sellerId)
        .eq('payment_status', 'paid');

    int totalSold = 0;
    for (final row in txData) {
      totalSold += (row['quantity'] as int? ?? 0);
    }

    final avatar = _supabase.storage
        .from('avatars')
        .getPublicUrl('${widget.sellerId}/profile.jpg');

    if (mounted) {
      setState(() {
        _sellerName = userData?['full_name']?.toString() ?? 'Seller';
        _sellerAddress = userData?['address']?.toString() ?? '';
        _avatarUrl = avatar;
        _totalSold = totalSold;
      });
    }
  }

  Future<void> _fetchSellerProducts() async {
    final response = await _supabase
        .from('products')
        .select('*, categories(category_name), users(address)')
        .eq('seller_id', widget.sellerId)
        .eq('status_product', 'available')
        .order('created_at', ascending: false);

    final products = (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();

    // Hitung rata-rata rating
    double totalRating = 0;
    int ratedCount = 0;
    for (final p in products) {
      if (p.rating > 0) {
        totalRating += p.rating;
        ratedCount++;
      }
    }

    // Kelompokkan per kategori
    final Map<String, List<ProductModel>> categoryMap = {};
    for (final p in products) {
      final catName = p.category_name ?? 'Lainnya';
      categoryMap.putIfAbsent(catName, () => []).add(p);
    }

    if (mounted) {
      setState(() {
        _products = products;
        _avgRating = ratedCount > 0 ? totalRating / ratedCount : 0.0;
        _categoryMap = categoryMap;
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
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
          label: const Text(
            'Kembali',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Detail Penjual',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // ── Seller Header ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    children: [
                      // Avatar
                      ClipOval(
                        child: Image.network(
                          _avatarUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.white24,
                            child: const Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sellerName,
                              style: AppTextStyles.h2.copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_sellerAddress.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white70, size: 13),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      _sellerAddress,
                                      style: AppTextStyles.subtitle.copyWith(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.accent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _avgRating > 0
                                      ? '${_avgRating.toStringAsFixed(1)}  |  $_totalSold Terjual'
                                      : '$_totalSold Terjual',
                                  style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── White Bottom Sheet ─────────────────────────────────────
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
                        // Tab Bar
                        Padding(
                          padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                ),
                              ),
                              labelColor: const Color(0xFF2E7D32),
                              unselectedLabelColor: Colors.grey,
                              labelStyle: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              tabs: [
                                Tab(text: 'Produk (${_products.length})'),
                                Tab(text: 'Kategori (${_categoryMap.length})'),
                              ],
                            ),
                          ),
                        ),

                        // Tab Content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // ── Tab Produk ───────────────────────────────
                              _products.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Belum ada produk',
                                        style: TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
                                      ),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.55,
                                      ),
                                      itemCount: _products.length,
                                      itemBuilder: (context, index) {
                                        final p = _products[index];
                                        return ProductCard(
                                          imageUrl: p.image_url,
                                          tag: p.category_name ?? 'Produk',
                                          title: p.product_name,
                                          location: p.seller_address ?? _sellerAddress,
                                          rating: p.rating > 0
                                              ? '${p.rating} (${p.sold_count})'
                                              : 'Baru',
                                          price: _formatCurrency(p.selling_price),
                                          unit: '/ ${p.unit}',
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ProductDetailScreen(product: p),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),

                              // ── Tab Kategori ─────────────────────────────
                              _categoryMap.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Belum ada kategori',
                                        style: TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
                                      ),
                                    )
                                  : ListView(
                                      padding: const EdgeInsets.all(16),
                                      children: _categoryMap.entries.map((entry) {
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

// ── Category Accordion Widget ────────────────────────────────────────────────
class _CategoryAccordion extends StatefulWidget {
  final String title;
  final int count;
  final List<ProductModel> products;

  const _CategoryAccordion({
    required this.title,
    required this.count,
    required this.products,
  });

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
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF2E7D32),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF2E7D32),
                    size: 20,
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
                    decoration: const BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.all(4),
                    child: ProductListTile(
                      title: p.product_name,
                      storeName: 'Stok: ${p.stock} ${p.unit}',
                      price: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(p.selling_price),
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
