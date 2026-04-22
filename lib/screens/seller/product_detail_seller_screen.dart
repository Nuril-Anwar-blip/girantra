import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../overlay/delete_product_dialog.dart';
import '../overlay/edit_product_dialog.dart';

class ProductDetailSellerScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailSellerScreen({super.key, required this.product});

  @override
  State<ProductDetailSellerScreen> createState() =>
      _ProductDetailSellerScreenState();
}

class _ProductDetailSellerScreenState
    extends State<ProductDetailSellerScreen> {
  final ProductService _productService = ProductService();

  String _categoryName = '';
  bool _isFetchingCategory = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryName();
  }

  Future<void> _fetchCategoryName() async {
    try {
      // Ambil semua kategori lalu filter manual — agar tidak tergantung nama kolom PK
      final response = await Supabase.instance.client
          .from('categories')
          .select();

      print('📂 Semua kategori dari DB: $response');

      if (response.isEmpty) {
        if (mounted) setState(() { _categoryName = 'Tidak ada kategori'; _isFetchingCategory = false; });
        return;
      }

      // Cari kategori yang cocok dengan category_id produk
      Map<String, dynamic>? matched;
      for (final cat in response) {
        final catId = cat['id'] ?? cat['category_id'];
        if (catId != null && catId.toString() == widget.product.category_id.toString()) {
          matched = cat;
          break;
        }
      }

      print('🔍 Mencari category_id=${widget.product.category_id} → matched: $matched');

      if (mounted) {
        setState(() {
          _categoryName = matched?['name']?.toString() ??
              matched?['category_name']?.toString() ??
              'Kategori tidak ditemukan';
          _isFetchingCategory = false;
        });
      }
    } catch (e) {
      print('❌ Error fetch kategori: $e');
      if (mounted) {
        setState(() {
          _categoryName = 'Kategori tidak tersedia';
          _isFetchingCategory = false;
        });
      }
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

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteProductDialog(
        productName: widget.product.product_name,
      ),
    );

    if (confirmed == true && widget.product.product_id != null) {
      final ok = await _productService.deleteProduct(widget.product.product_id!);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus'),
            backgroundColor: Colors.red,
          ),
        );
        // Pop dengan hasil true supaya ProductSellerScreen bisa refresh
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _handleEdit() async {
    final result = await showDialog(
      context: context,
      builder: (_) => EditProductDialog(
        productName: widget.product.product_name,
        description: widget.product.description,
        category: _categoryName,
        stock: widget.product.stock,
      ),
    );
    // Refresh jika ada perubahan
    if (result != null && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

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
                'Detail Produk',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // ── Scrollable Content ──────────────────────────────────────────
          ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              // Hero Image
              product.image_url.isNotEmpty
                  ? Image.network(
                      product.image_url,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Harga & Kategori ────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Harga
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HARGA',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                _formatPrice(product.selling_price),
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 21,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Kategori badge
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'KATEGORI',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _isFetchingCategory
                                ? Container(
                                    width: 60,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    color: AppColors.primary,
                                    child: Text(
                                      _categoryName,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Nama Produk ─────────────────────────────────────
                    const Text(
                      'NAMA PRODUK',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.product_name,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Deskripsi ───────────────────────────────────────
                    const Text(
                      'DESKRIPSI',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Stok ────────────────────────────────────────────
                    const Text(
                      'STOK',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.stock} Stok',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Info tambahan: Satuan & Tanggal Panen ───────────
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            label: 'SATUAN',
                            value: product.unit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoChip(
                            label: 'TANGGAL PANEN',
                            value: DateFormat('dd MMM yyyy')
                                .format(product.harvest_date),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Bottom Action Bar ─────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Tombol Hapus
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          foregroundColor: Colors.red,
                        ),
                        onPressed: _handleDelete,
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Edit
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: _handleEdit,
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 280,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: AppColors.mutedText,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
