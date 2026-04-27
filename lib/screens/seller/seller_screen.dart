import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/product_card.dart';
// import '../buyer/product_detail_screen.dart'; // Just in case routing is needed for the grid items
// import '../../models/product_model.dart'; // To create dummy products here

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dummy data matching the image layout
  final List<Map<String, dynamic>> _dummyProducts = [
    {
      'tag': 'Pupuk',
      'title': 'Pupuk Kompos Organik',
      'location': 'Surakarta',
      'rating': '4.8 (120)',
      'price': 'Rp 45.000',
      'unit': '/ Kg',
      'imageUrl':
          'https://images.unsplash.com/photo-1596724896798-17de24c9eb72?w=500&auto=format&fit=crop&q=60', // Placeholder
    },
    {
      'tag': 'Benih',
      'title': 'Bibit Padi Unggul Ciherang',
      'location': 'Sragen',
      'rating': '4.9 (220)',
      'price': 'Rp 75.000',
      'unit': '/ Kg',
      'imageUrl':
          'https://images.unsplash.com/photo-1416879598555-220b329c29af?w=500&auto=format&fit=crop&q=60', // Placeholder
    },
    {
      'tag': 'Pupuk',
      'title': 'NPK Mutiara Biru 16-16-16',
      'location': 'Sukoharjo',
      'rating': '4.7 (890)',
      'price': 'Rp 18.000',
      'unit': '/ Kg',
      'imageUrl':
          'https://images.unsplash.com/photo-1596724896798-17de24c9eb72?w=500&auto=format&fit=crop&q=60', // Placeholder
    },
    {
      'tag': 'Sayur',
      'title': 'Tomat Cherry Segar Hydro',
      'location': 'Boyolali',
      'rating': '5.0 (56)',
      'price': 'Rp 15.000',
      'unit': '/ Kg',
      'imageUrl':
          'https://images.unsplash.com/photo-1592424041794-069afab91136?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80', // Placeholder
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors
          .primaryDark, // Dark green background for header area (matches AppColors.primary if it's the same)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 110,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 16,
          ),
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
      body: Column(
        children: [
          // Seller Header Info
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=60', // Profil pic dummy
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plant Store',
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppColors.accent, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '4.5  |  300 Terjual',
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom White Container overlapping
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
                    padding: const EdgeInsets.only(
                      top: 24.0,
                      left: 16,
                      right: 16,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: const BoxDecoration(
                          color: Color(0xFFE8F5E9), // Light green tint
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF2E7D32),
                              width: 3,
                            ), // Dark green line at bottom
                          ),
                        ),
                        labelColor: const Color(0xFF2E7D32),
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(text: 'Produk'),
                          Tab(text: 'Kategori'),
                        ],
                      ),
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Produk Tab
                        GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio:
                                    0.55, // Match ProductCard aspects
                              ),
                          itemCount: _dummyProducts.length,
                          itemBuilder: (context, index) {
                            final p = _dummyProducts[index];
                            return ProductCard(
                              imageUrl: p['imageUrl']!,
                              tag: p['tag']!,
                              title: p['title']!,
                              location: p['location']!,
                              rating: p['rating']!,
                              price: p['price']!,
                              unit: p['unit']!,
                              onTap: () {
                                // For dummy, maybe pop back or push a new product details.
                              },
                            );
                          },
                        ),

                        // Kategori Tab
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: const [
                            _CategoryAccordion(
                              title: 'Benih',
                              count: 3,
                              initialExpanded: false,
                              items: [],
                            ),
                            _CategoryAccordion(
                              title: 'Bibit',
                              count: 2,
                              initialExpanded: true,
                              items: [
                                {
                                  'title': 'Bibit Padi Unggul',
                                  'storeName' : 'Plant Store',
                                  'price': 'Rp 75.000',
                                  'image': 'https://images.unsplash.com/photo-1599427303058-f04d70798bc8?w=100&auto=format&fit=crop&q=60', // Placeholder plant pot
                                },
                                {
                                  'title': 'Bibit Padi Unggul',
                                  'storeName' : 'Plant Store',
                                  'price': 'Rp 75.000',
                                  'image': 'https://images.unsplash.com/photo-1599427303058-f04d70798bc8?w=100&auto=format&fit=crop&q=60', 
                                },
                              ],
                            ),
                          ],
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
  final bool initialExpanded;
  final List<Map<String, String>> items;

  const _CategoryAccordion({
    required this.title,
    required this.count,
    this.initialExpanded = false,
    required this.items,
  });

  @override
  State<_CategoryAccordion> createState() => _CategoryAccordionState();
}

class _CategoryAccordionState extends State<_CategoryAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light green background
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
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
          if (_isExpanded && widget.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: widget.items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(4), // Little padding since the tile has none internally and border bounds it
                    child: ProductListTile(
                      title: item['title']!,
                      storeName: item['storeName']!,
                      price: item['price']!,
                      imageUrl: item['image']!,
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

