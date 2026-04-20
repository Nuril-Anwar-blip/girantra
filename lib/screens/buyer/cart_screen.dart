import 'package:flutter/material.dart';
import 'package:girantra/ui/app_text_styles.dart';

import '../../ui/app_colors.dart';
// import '../ui/app_widgets.dart';
import '../../widgets/product_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Keranjang Saya',
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProductCart(
                  tag: 'Pupuk',
                  title: 'Pupuk Kompos Organik',
                  description: 'Lorem ipsum dolor sit amet, conse ksdjf ...',
                  price: 'Rp 45.000',
                  qty: 3,
                  imageUrl:
                      'https://images.unsplash.com/photo-1592424041794-069afab91136?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                  onAdd: () {},
                  onRemove: () {},
                ),
                const SizedBox(height: 12),
                ProductCart(
                  tag: 'Benih',
                  title: 'Bibit Padi Unggul Ciherang',
                  description: 'Lorem ipsum dolor sit amet, conse ksdjf ...',
                  price: 'Rp 75.000',
                  qty: 1,
                  imageUrl:
                      'https://images.unsplash.com/photo-1592424041794-069afab91136?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                  onAdd: () {},
                  onRemove: () {},
                ),
                const SizedBox(height: 12),
                ProductCart(
                  tag: 'Sayuran',
                  title: 'Tomat Cherry Segar Hydro',
                  description: 'Lorem ipsum dolor sit amet, conse ksdjf ...',
                  price: 'Rp 15.000',
                  qty: 7,
                  imageUrl:
                      'https://images.unsplash.com/photo-1592424041794-069afab91136?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                  onAdd: () {},
                  onRemove: () {},
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'TOTAL',
                        style: AppTextStyles.subtitle,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Rp 315.000',
                        style: AppTextStyles.finalPrice,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Checkout (3)',
                        style: AppTextStyles.link.copyWith(
                          color: AppColors.background,
                        ),
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
