import 'package:flutter/material.dart';
import 'package:girantra/ui/app_text_styles.dart';

import '../ui/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isBannerVisible = true;

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
                'Notifikasi',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Yellow Banner
          if (_isBannerVisible)
            Container(
              color: const Color(0xFFFFEAAC), // Yellowish banner matching mockup
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.accent, // Orange circle
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Aktifkan notifikasi untuk dapatkan info status pesanan dan promo eksekutif',
                      style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBannerVisible = false;
                      });
                    },
                    child: const Icon(Icons.close, color: Colors.black54, size: 20),
                  ),
                ],
              ),
            ),
          
          // Cards Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Order Card Structure
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pesanan Saya',
                            style: AppTextStyles.h2.copyWith(color: AppColors.text, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Tandai Sudah Dibaca (1)',
                            style: AppTextStyles.link.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Order Item 1
                      const _OrderItem(
                        title: 'Pupuk Kompos Organik',
                        price: 'Rp 45.000',
                        status: 'Pesanan Selesai',
                        imageUrl: 'https://images.unsplash.com/photo-1620577438162-817887e14577?auto=format&fit=crop&w=100&q=60', // Mock plant image
                      ),
                      const SizedBox(height: 10),
                      // Order Item 2
                      const _OrderItem(
                        title: 'Bibit Padi Unggul',
                        price: 'Rp 75.000',
                        status: 'Pesanan Selesai',
                        imageUrl: 'https://images.unsplash.com/photo-1596724896798-17de24c9eb72?w=100&auto=format&fit=crop&q=60', // Mock plant image
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // General Notifications Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notifikasi Umum',
                            style: AppTextStyles.h2.copyWith(color: AppColors.text, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Tandai Sudah Dibaca (2)',
                            style: AppTextStyles.link.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _GeneralNotifItem(text: 'Akun Girantra Berhasil diaktifkan'),
                      const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                      const _GeneralNotifItem(text: 'Lorem Ipsum'),
                    ],
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

class _OrderItem extends StatelessWidget {
  final String title;
  final String price;
  final String status;
  final String imageUrl;

  const _OrderItem({
    required this.title,
    required this.price,
    required this.status,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // Fixed height per item
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 0.4), // Green outline border
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
            child: Image.network(
              imageUrl,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 70, color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 12),
          // Info Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.subtitle.copyWith(color: AppColors.text, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text(
                      status,
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 12),
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

class _GeneralNotifItem extends StatelessWidget {
  final String text;

  const _GeneralNotifItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.accent, // Orange circle
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.text, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}

