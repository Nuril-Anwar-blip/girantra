import 'package:flutter/material.dart';

import '../ui/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE69C)),
            ),
            child: const Text(
              'Pastikan notifikasi untuk aplikasi ini selalu dalam keadaan ON',
              style: TextStyle(fontSize: 11, color: Color(0xFF7A5A00)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Pesanan Saya', style: TextStyle(fontWeight: FontWeight.w800)),
              Text('Tandai Sudah Dibaca', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
            ],
          ),
          const SizedBox(height: 10),
          _OrderNotifTile(
            title: 'Pupuk Kompos Organik',
            subtitle: 'Rp 75.000',
            status: 'Pesanan Selesai',
          ),
          const SizedBox(height: 10),
          _OrderNotifTile(
            title: 'Bibit Padi Unggul',
            subtitle: 'Rp 75.000',
            status: 'Pesanan Selesai',
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Notifikasi Umum', style: TextStyle(fontWeight: FontWeight.w800)),
              Text('Tandai Sudah Dibaca', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
            ],
          ),
          const SizedBox(height: 10),
          _GeneralNotifTile(
            icon: Icons.check_circle_outline,
            iconColor: Colors.orange,
            title: 'Akun Girantra Berhasil diaktivasi',
          ),
          const SizedBox(height: 10),
          _GeneralNotifTile(
            icon: Icons.campaign_outlined,
            iconColor: Colors.green,
            title: 'Lorem ipsum',
          ),
        ],
      ),
    );
  }
}

class _OrderNotifTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;

  const _OrderNotifTile({
    required this.title,
    required this.subtitle,
    required this.status,
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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F5EA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.local_florist_outlined, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.mutedText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F5EA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralNotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _GeneralNotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
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
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

