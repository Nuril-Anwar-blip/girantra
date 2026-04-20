import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/seller_product_card.dart';
import '../overlay/delete_product_dialog.dart';
import '../overlay/archive_product_dialog.dart';
import '../overlay/activate_product_dialog.dart';
import '../overlay/edit_stock_dialog.dart';
import '../overlay/edit_product_dialog.dart';

class ProductSellerScreen extends StatefulWidget {
  const ProductSellerScreen({super.key});

  @override
  State<ProductSellerScreen> createState() => _ProductSellerScreenState();
}

class _ProductSellerScreenState extends State<ProductSellerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
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
        backgroundColor: AppColors.background, // Match with background based on image (looks like slightly off-white like background)
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Produk Saya',
          style: AppTextStyles.h2.copyWith(color: AppColors.text),
        ),
      ),
      body: Column(
        children: [
          // Custom Tab Bar Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildCustomTab(
                  label: 'Aktif',
                  count: '7',
                  index: 0,
                  isSelected: _tabController.index == 0,
                ),
                const SizedBox(width: 8),
                _buildCustomTab(
                  label: 'Habis',
                  count: '2',
                  index: 1,
                  isSelected: _tabController.index == 1,
                  activeColor: Colors.red,
                ),
                const SizedBox(width: 8),
                _buildCustomTab(
                  label: 'Arsip',
                  count: '4',
                  index: 2,
                  isSelected: _tabController.index == 2,
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAktifTab(),
                _buildHabisTab(),
                _buildArsipTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab({
    required String label,
    required String count,
    required int index,
    required bool isSelected,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppColors.primary;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? color : Colors.grey.shade400,
                width: 2,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Text(
                label,
                style: AppTextStyles.subtitle.copyWith(
                  color: isSelected ? color : Colors.grey.shade500,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Positioned(
                top: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.grey.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAktifTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produk Aktif',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.text,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to add product
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tambah Produk',
                          style: AppTextStyles.subtitle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SellerProductCard(
              imageUrl: '', // leave empty for grey box
              title: 'Bibit Padi Unggul',
              stock: 6,
              priceFormatted: 'Rp 255.000',
              statusText: 'Aktif',
              statusColor: AppColors.primary,
              soldCount: 120,
              rating: 4.8,
              secondaryActionText: 'Arsipkan',
              onSecondaryAction: () {
                showDialog(context: context, builder: (_) => const ArchiveProductDialog(productName: 'Bibit Padi Unggul'));
              },
              onPrimaryAction: () {
                showDialog(context: context, builder: (_) => const EditProductDialog(
                  productName: 'Bibit Padi Unggul',
                  description: 'Lorem ipsum dolor sit amet, consectetur a...',
                  category: 'Pupuk',
                  stock: 50,
                ));
              },
            ),
            SellerProductCard(
              imageUrl: '', // leave empty for grey box
              title: 'Bibit Padi Unggul',
              stock: 6,
              priceFormatted: 'Rp 255.000',
              statusText: 'Aktif',
              statusColor: AppColors.primary,
              soldCount: 120,
              rating: 4.8,
              secondaryActionText: 'Arsipkan',
              onSecondaryAction: () {
                showDialog(context: context, builder: (_) => const ArchiveProductDialog(productName: 'Bibit Padi Unggul'));
              },
              onPrimaryAction: () {
                showDialog(context: context, builder: (_) => const EditProductDialog(
                  productName: 'Bibit Padi Unggul',
                  description: 'Lorem ipsum dolor sit amet, consectetur a...',
                  category: 'Pupuk',
                  stock: 50,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabisTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk Habis',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.text,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            SellerProductCard(
              imageUrl: '', 
              title: 'Bibit Padi Unggul',
              stock: 0,
              priceFormatted: 'Rp 255.000',
              statusText: 'Habis',
              statusColor: Colors.red,
              soldCount: 120,
              rating: 4.8,
              primaryActionText: 'Stok Ulang',
              onPrimaryAction: () {
                showDialog(context: context, builder: (_) => const EditStockDialog(productId: 'Prdct002399', productName: 'Bibit Padi Unggul', initialStock: 50));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArsipTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk Arsip',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.text,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            SellerProductCard(
              imageUrl: '', 
              title: 'Bibit Padi Unggul',
              stock: 0,
              priceFormatted: 'Rp 255.000',
              statusText: 'Arsip',
              statusColor: Colors.orange,
              soldCount: 120,
              rating: 4.8,
              secondaryActionText: 'Hapus',
              secondaryActionColor: Colors.red,
              primaryActionText: 'Aktifkan',
              showPrimaryActionIcon: false,
              onSecondaryAction: () {
                showDialog(context: context, builder: (_) => const DeleteProductDialog(productName: 'Bibit Padi Unggul'));
              },
              onPrimaryAction: () {
                showDialog(context: context, builder: (_) => const ActivateProductDialog(productName: 'Bibit Padi Unggul'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
