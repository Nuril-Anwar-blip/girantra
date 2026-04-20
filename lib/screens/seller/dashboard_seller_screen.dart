import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/header_section.dart';

class DashboardSellerScreen extends StatefulWidget {
  const DashboardSellerScreen({super.key});

  @override
  State<DashboardSellerScreen> createState() => _DashboardSellerScreenState();
}

class _DashboardSellerScreenState extends State<DashboardSellerScreen> {
  // Use Scaffold so it plays nicely, although the parent has Scaffold as well.
  // We can just use a Container for the body, but Scaffold gives us safe area and app bar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LocationHeaderAppBar(title: 'Lokasi Toko'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildTotalSaldoCard(),
                    const SizedBox(height: 16),
                    _buildStatusPemesananCard(),
                    const SizedBox(height: 16),
                    _buildPerformaTokoCard(),
                    const SizedBox(height: 16),
                    _buildBottomSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSaldoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL SALDO',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp 34.500.000',
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
              const SizedBox(
                height: 24,
              ), // Space for button padding if needed, but we use positioned
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Tarik Saldo',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 10,
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

  Widget _buildStatusPemesananCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUS PEMESANAN',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatusCounter('10', 'Pesanan Baru')),
              Container(width: 1, height: 40, color: AppColors.divider),
              Expanded(child: _buildStatusCounter('6', 'Dikirim')),
              Container(width: 1, height: 40, color: AppColors.divider),
              Expanded(child: _buildStatusCounter('43', 'Diterima')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                size: 20,
                color: AppColors.mutedText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Status Pengiriman Produk',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.mutedText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCounter(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mutedText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPerformaTokoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMA TOKO',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                color: AppColors.text,
                size: 48,
              ), // Large chart icon placeholder
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Turun',
                      style: AppTextStyles.medium.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '-12% dari minggu lalu',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Terlaris
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KATEGORI TERLARIS',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryItem('Pupuk', '50 Terjual'),
                const SizedBox(height: 8),
                _buildCategoryItem('Sayuran & Buah', '45 Terjual'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Action Buttons
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Tambah Produk',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.inventory_2_outlined,
                label: 'Produk Saya',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.link.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
