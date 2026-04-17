import 'package:flutter/material.dart';

import '../ui/app_colors.dart';
// import '../ui/app_widgets.dart';
import '../widgets/product_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Kembali',
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Text(
                'Keranjang Saya',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
        ),
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
                  imageUrl: 'https://images.unsplash.com/photo-1592424041794-069afab91136?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
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
                  imageUrl: 'https://images.unsplash.com/photo-1592424041794-069afab91136?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
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
                  imageUrl: 'https://images.unsplash.com/photo-1592424041794-069afab91136?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
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
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: AppColors.mutedText, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Rp 315.000',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.primary),
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
                      child: const Text(
                        'Checkout (3)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
