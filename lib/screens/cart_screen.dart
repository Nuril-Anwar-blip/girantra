import 'package:flutter/material.dart';

import '../ui/app_colors.dart';
import '../ui/app_widgets.dart';

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
              children: const [
                _CartItemTile(
                  tag: 'Pupuk',
                  title: 'Pupuk Kompos Organik',
                  price: 'Rp 45.000',
                ),
                SizedBox(height: 12),
                _CartItemTile(
                  tag: 'Benih',
                  title: 'Bibit Padi Unggul Cireang',
                  price: 'Rp 75.000',
                ),
                SizedBox(height: 12),
                _CartItemTile(
                  tag: 'Sayuran',
                  title: 'Tomat Cherry Segar Hydro',
                  price: 'Rp 15.000',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('total', style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                    Text('Rp 315.000', style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 140,
                    child: PrimaryPillButton(
                      text: 'Checkout (4)',
                      onPressed: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final String tag;
  final String title;
  final String price;

  const _CartItemTile({
    required this.tag,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image_outlined, color: AppColors.mutedText),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChipTag(text: tag),
                const SizedBox(height: 6),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(price, style: const TextStyle(fontSize: 11, color: AppColors.mutedText)),
              ],
            ),
          ),
          Column(
            children: [
              _QtyBox(
                icon: Icons.remove,
                onTap: () {},
              ),
              const SizedBox(height: 6),
              const Text('3', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              _QtyBox(
                icon: Icons.add,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBox({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryDark),
      ),
    );
  }
}

