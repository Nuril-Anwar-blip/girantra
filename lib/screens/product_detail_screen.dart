import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';
import '../ui/app_widgets.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.text, size: 18),
          label: const Text(
            'Kembali',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
          ),
        ),
        leadingWidth: 110,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Image.network(
                product.image_url,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('HARGA', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w400)),
                              Text('Rp ${product.selling_price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 21)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('KATEGORI', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w400)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              color: AppColors.primary,
                              child: const Text('Pupuk', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('NAMA PRODUK', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w400)),
                    Text(product.product_name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 16),
                    const Text('DESKRIPSI', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 2),
                    Text(product.description, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                    const SizedBox(height: 16),
                    const Text('STOK', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w400)),
                    Text('${product.stock} Stok', style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text('4.9', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                              SizedBox(width: 4),
                              Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                              SizedBox(width: 8),
                              Text('Penilaian Produk (300)', style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=60',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Plant Store', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black)),
                                    SizedBox(height: 2),
                                    Text('SURAKARTA', style: TextStyle(fontSize: 11, color: Colors.black87)),
                                  ],
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.circle, size: 8, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text('Online', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(4))),
                        ),
                        onPressed: () {},
                        child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(4))),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: const Text('Beli', style: TextStyle(color: Colors.white, fontSize: 16)),
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
}

