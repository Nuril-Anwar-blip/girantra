import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/seller_product_card.dart';
import '../overlay/delete_product_dialog.dart';
import '../overlay/archive_product_dialog.dart';
import '../overlay/activate_product_dialog.dart';
import '../overlay/edit_stock_dialog.dart';
// import '../overlay/edit_product_dialog.dart';
import 'add_product_screen.dart';
import 'product_detail_seller_screen.dart';

class ProductSellerScreen extends StatefulWidget {
  const ProductSellerScreen({super.key});

  @override
  State<ProductSellerScreen> createState() => _ProductSellerScreenState();
}

class _ProductSellerScreenState extends State<ProductSellerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductService _productService = ProductService();

  // Data lists per tab
  List<ProductModel> _aktifProducts = [];
  List<ProductModel> _habisProducts = [];
  List<ProductModel> _arsipProducts = [];

  // Product IDs yang sedang dalam transaksi aktif (tidak bisa diarsipkan)
  Set<int> _activeTransactionProductIds = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ── 1. Load produk (wajib) ──────────────────────────────────────────
    try {
      final productResults = await Future.wait([
        _productService.getSellerProductsByStatus('available'),
        _productService.getSellerProductsByStatus('out_of_stock'),
        _productService.getSellerProductsByStatus('archived'),
      ]);

      if (!mounted) return;
      setState(() {
        _aktifProducts = productResults[0];
        _habisProducts = productResults[1];
        _arsipProducts = productResults[2];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error load produk: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat produk. Coba lagi.';
        _isLoading = false;
      });
      return; // stop jika produk gagal
    }

    // ── 2. Load transaksi aktif (opsional, tidak gagalkan load produk) ──
    try {
      final supabase = Supabase.instance.client;
      final sellerId = supabase.auth.currentUser?.id ?? '';

      // Join logistics untuk mendapatkan current_status yang benar
      // (current_status ada di tabel logistics, bukan transactions)
      final txRows = await supabase
          .from('transactions')
          .select('product_id, payment_status, logistics(current_status)')
          .eq('seller_id', sellerId)
          .inFilter('payment_status', ['pending', 'paid']);

      debugPrint('🔒 Cek transaksi aktif: ${txRows.length} transaksi');

      final activeIds = (txRows as List<dynamic>).where((r) {
        // Ambil current_status dari relasi logistics
        final logData = r['logistics'];
        String? logStatus;
        if (logData is List && logData.isNotEmpty) {
          logStatus = logData.last['current_status']?.toString();
        } else if (logData is Map) {
          logStatus = logData['current_status']?.toString();
        }

        debugPrint(
          '  product_id=${r['product_id']} | payment=${r['payment_status']} | logStatus=$logStatus',
        );

        // Produk terkunci jika:
        // - Tidak ada logistik (transaksi baru/pending) ATAU
        // - Logistik masih dalam proses (bukan delivered/received/completed)
        final isFinished = logStatus == 'delivered' ||
            logStatus == 'received' ||
            logStatus == 'completed';
        return !isFinished;
      }).map((r) => r['product_id'] as int?).whereType<int>().toSet();

      debugPrint('🔒 Product IDs terkunci: $activeIds');

      if (mounted) {
        setState(() => _activeTransactionProductIds = activeIds);
      }
    } catch (e) {
      debugPrint('⚠️ Peringatan: gagal cek transaksi aktif: $e');
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  /// Tampilkan loading overlay yang tidak bisa di-dismiss
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 14,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tutup loading overlay
  void _hideLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Produk Saya',
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
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
                  count: _aktifProducts.length.toString(),
                  index: 0,
                  isSelected: _tabController.index == 0,
                ),
                const SizedBox(width: 8),
                _buildCustomTab(
                  label: 'Habis',
                  count: _habisProducts.length.toString(),
                  index: 1,
                  isSelected: _tabController.index == 1,
                  activeColor: Colors.red,
                ),
                const SizedBox(width: 8),
                _buildCustomTab(
                  label: 'Arsip',
                  count: _arsipProducts.length.toString(),
                  index: 2,
                  isSelected: _tabController.index == 2,
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : TabBarView(
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: AppTextStyles.subtitle.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba Lagi'),
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
                label.toUpperCase(),
                style: AppTextStyles.subtitle.copyWith(
                  color: isSelected ? color : Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
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

  // ─── Tab: Aktif ───────────────────────────────────────────────────────────
  Widget _buildAktifTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProductScreen(),
                        ),
                      );
                      _loadProducts();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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
              if (_aktifProducts.isEmpty)
                _buildEmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: 'Belum ada produk aktif',
                  subMessage: 'Tap "Tambah Produk" untuk menambahkan produk baru',
                )
              else
                ...List.generate(_aktifProducts.length, (i) {
                  final product = _aktifProducts[i];
                  return SellerProductCard(
                    imageUrl: product.image_url,
                    title: product.product_name,
                    stock: product.stock,
                    priceFormatted: _formatPrice(product.selling_price),
                    statusText: 'Aktif',
                    statusColor: AppColors.primary,
                    soldCount: product.sold_count,
                    rating: product.rating,
                    secondaryActionText: 'Arsipkan',
                    onSecondaryAction: () async {
                      // Langkah 1: Tampilkan overlay konfirmasi seperti biasa
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => ArchiveProductDialog(
                          productName: product.product_name,
                        ),
                      );

                      if (confirmed != true || product.product_id == null) return;

                      // Langkah 2: Setelah konfirmasi, cek apakah produk sedang dalam transaksi
                      final isLocked = _activeTransactionProductIds.contains(product.product_id);
                      if (isLocked) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Produk ini masih memiliki transaksi yang sedang diproses atau dalam pengiriman.',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFFF57F17),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                        return;
                      }

                      // Langkah 3: Tidak ada transaksi aktif → arsipkan
                      _showLoadingDialog('Mengarsipkan produk...');
                      try {
                        await _productService.updateProductStatus(
                          product.product_id!,
                          'archived',
                        );
                        _hideLoadingDialog();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk berhasil diarsipkan'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          _loadProducts();
                        }
                      } catch (e) {
                        _hideLoadingDialog();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal arsipkan: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 6),
                            ),
                          );
                        }
                      }
                    },
                    onPrimaryAction: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailSellerScreen(
                            product: product,
                          ),
                        ),
                      );
                      if (result == true) _loadProducts();
                    },
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab: Habis ───────────────────────────────────────────────────────────
  Widget _buildHabisTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              if (_habisProducts.isEmpty)
                _buildEmptyState(
                  icon: Icons.check_circle_outline,
                  message: 'Tidak ada produk yang habis',
                  subMessage: 'Semua produk Anda masih tersedia',
                  iconColor: Colors.green,
                )
              else
                ...List.generate(_habisProducts.length, (i) {
                  final product = _habisProducts[i];
                  return SellerProductCard(
                    imageUrl: product.image_url,
                    title: product.product_name,
                    stock: product.stock,
                    priceFormatted: _formatPrice(product.selling_price),
                    statusText: 'Habis',
                    statusColor: Colors.red,
                    soldCount: product.sold_count,
                    rating: product.rating,
                    primaryActionText: 'Stok Ulang',
                    onPrimaryAction: () async {
                      final newStock = await showDialog<int>(
                        context: context,
                        builder: (_) => EditStockDialog(
                          productId: product.product_id?.toString() ?? '-',
                          productName: product.product_name,
                          initialStock: product.stock,
                        ),
                      );
                      if (newStock != null && product.product_id != null) {
                        _showLoadingDialog('Memperbarui stok...');
                        try {
                          final ok = await _productService.updateProductStock(
                            product.product_id!,
                            newStock,
                          );
                          _hideLoadingDialog();
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Stok diperbarui menjadi $newStock'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            _loadProducts();
                          }
                        } catch (e) {
                          _hideLoadingDialog();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal update stok: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab: Arsip ───────────────────────────────────────────────────────────
  Widget _buildArsipTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              if (_arsipProducts.isEmpty)
                _buildEmptyState(
                  icon: Icons.archive_outlined,
                  message: 'Tidak ada produk yang diarsipkan',
                  subMessage: 'Produk yang diarsipkan akan muncul di sini',
                  iconColor: Colors.orange,
                )
              else
                ...List.generate(_arsipProducts.length, (i) {
                  final product = _arsipProducts[i];
                  return SellerProductCard(
                    imageUrl: product.image_url,
                    title: product.product_name,
                    stock: product.stock,
                    priceFormatted: _formatPrice(product.selling_price),
                    statusText: 'Arsip',
                    statusColor: Colors.orange,
                    soldCount: product.sold_count,
                    rating: product.rating,
                    secondaryActionText: 'Hapus',
                    secondaryActionColor: Colors.red,
                    primaryActionText: 'Aktifkan',
                    showPrimaryActionIcon: false,
                    onSecondaryAction: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => DeleteProductDialog(
                          productName: product.product_name,
                        ),
                      );
                      if (confirmed == true && product.product_id != null) {
                        _showLoadingDialog('Menghapus produk...');
                        try {
                          final ok = await _productService.deleteProduct(
                            product.product_id!,
                          );
                          _hideLoadingDialog();
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Produk berhasil dihapus'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            _loadProducts();
                          }
                        } catch (e) {
                          _hideLoadingDialog();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal hapus produk: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    onPrimaryAction: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => ActivateProductDialog(
                          productName: product.product_name,
                        ),
                      );
                      if (confirmed == true && product.product_id != null) {
                        _showLoadingDialog('Mengaktifkan produk...');
                        try {
                          await _productService.updateProductStatus(
                            product.product_id!,
                            'available',
                          );
                          _hideLoadingDialog();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Produk berhasil diaktifkan'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            _loadProducts();
                          }
                        } catch (e) {
                          _hideLoadingDialog();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal aktifkan produk: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: iconColor ?? Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.h2.copyWith(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
