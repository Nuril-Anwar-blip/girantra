import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../ui/app_colors.dart';
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
          label: const Text(
            'Kembali',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
          ),
        ),
        leadingWidth: 110,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: Image.network(
                    product.image_url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Rp ${product.selling_price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Pupuk Kompos Organik',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  ChipTag(text: 'Pupuk'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: const TextStyle(fontSize: 12, color: AppColors.mutedText, height: 1.35),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.mutedText),
                  SizedBox(width: 6),
                  Text('Stok', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text('${product.stock}', style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                  SizedBox(width: 4),
                  Text('4.9', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(width: 6),
                  Text('Penilaian Produk (200)', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F5EA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.person_outline, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Plant Store', style: TextStyle(fontWeight: FontWeight.w900)),
                          SizedBox(height: 2),
                          Text('SURAKARTA', style: TextStyle(fontSize: 10, color: AppColors.mutedText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.green),
                            SizedBox(width: 6),
                            Text('Online', style: TextStyle(fontSize: 10, color: AppColors.mutedText)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 72),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Aksi beli (UI mockup).')),
                          );
                        },
                        child: const Text('Beli', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
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

