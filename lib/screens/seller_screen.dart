import 'package:flutter/material.dart';
import '../ui/app_colors.dart';

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Penjual', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=200&q=60'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Plant Store", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text("4.5", style: TextStyle(color: Colors.white, fontSize: 13)),
                          SizedBox(width: 8),
                          Text("|", style: TextStyle(color: Colors.white, fontSize: 13)),
                          SizedBox(width: 8),
                          Text("300 Terjual", style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryDark,
                    unselectedLabelColor: AppColors.mutedText,
                    indicatorColor: AppColors.primaryDark,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: "Produk"),
                      Tab(text: "Kategori"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                       controller: _tabController,
                       children: [
                         _buildProductGrid(),
                         _buildCategories(),
                       ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildProductCard(index);
      },
    );
  }

  Widget _buildProductCard(int index) {
    List<String> titles = ["Pupuk Kompos Organik", "Bibit Padi Unggul Ciherang", "NPK Mutiara Biru", "Tomat Cherry Segar"];
    List<String> images = [
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=200&q=60',
      'https://images.unsplash.com/photo-1592997572594-34afe4c5ce1b?auto=format&fit=crop&w=200&q=60',
      'https://plus.unsplash.com/premium_photo-1678344158485-be7aabebae5f?auto=format&fit=crop&w=200&q=60',
      'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=60',
    ];
    List<String> prices = ["45.000", "75.000", "18.000", "15.000"];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: index == 1 ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(images[index], height: 110, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titles[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, size: 12, color: AppColors.mutedText),
                    Text("Surakarta", style: TextStyle(fontSize: 10, color: AppColors.mutedText)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rp ${prices[index]}", style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12)),
                    const Text("/ Kg", style: TextStyle(fontSize: 10, color: AppColors.mutedText)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: const Text("Benih (3)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            backgroundColor: AppColors.primary.withOpacity(0.05),
            collapsedBackgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.divider)
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.divider)
            ),
            childrenPadding: const EdgeInsets.all(12),
            children: [
              _buildCategoryListTile("Bibit Padi Unggul", "15.000"),
              const SizedBox(height: 8),
              _buildCategoryListTile("Bibit Padi Hitam", "20.000"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryListTile(String title, String price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8)
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network('https://images.unsplash.com/photo-1592997572594-34afe4c5ce1b?auto=format&fit=crop&w=100&q=60', width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text("Rp $price", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
