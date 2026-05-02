import 'package:flutter/material.dart';
import 'package:girantra/screens/seller/add_product_screen.dart';
import 'package:girantra/screens/seller/product_seller_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/header_section.dart';

class DashboardSellerScreen extends StatefulWidget {
  const DashboardSellerScreen({super.key});

  @override
  State<DashboardSellerScreen> createState() => _DashboardSellerScreenState();
}

class _DashboardSellerScreenState extends State<DashboardSellerScreen> {
  double _totalSaldo = 0;
  int _pesananBaru = 0;
  int _pesananProses = 0;
  int _pesananDikirim = 0;
  bool _isLoadingSaldo = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoadingSaldo = false);
        return;
      }

      final response = await supabase
          .from('transactions')
          .select('''
            *,
            logistics (
              *
            )
          ''')
          .eq('seller_id', user.id)
          .eq('payment_status', 'paid');
      
      double total = 0;
      int baru = 0;
      int proses = 0;
      int dikirim = 0;

      for (var item in response) {
        final subTotal = item['sub_total'];
        if (subTotal != null) {
          total += (subTotal is num ? subTotal.toDouble() : double.tryParse(subTotal.toString()) ?? 0);
        }

        final logisticsData = item['logistics'];
        String? currentStatus;
        String? arrivalDateStr;
        
        if (logisticsData != null) {
          if (logisticsData is List && logisticsData.isNotEmpty) {
            currentStatus = logisticsData.last['current_status']?.toString();
            arrivalDateStr = logisticsData.last['arrival_date']?.toString();
          } else if (logisticsData is Map) {
            currentStatus = logisticsData['current_status']?.toString();
            arrivalDateStr = logisticsData['arrival_date']?.toString();
          }
        }

        if (currentStatus == 'delivery' && arrivalDateStr != null) {
          final arrivalDate = DateTime.tryParse(arrivalDateStr);
          // Cek apakah tanggal saat ini sudah melewati hari kedatangan + 1 hari
          if (arrivalDate != null && DateTime.now().isAfter(arrivalDate.add(const Duration(days: 1)))) {
            currentStatus = 'received';
            final txId = item['transaction_code'] ?? item['transaction_id'] ?? item['id'];
            if (txId != null) {
              // Update ke database di background agar sinkron
              supabase.from('logistics').update({'current_status': 'received'}).eq('transaction_id', txId).catchError((_) => null);
            }
          }
        }

        if (currentStatus == null || currentStatus == 'pending') {
          baru++;
        } else if (currentStatus == 'processing' || currentStatus == 'packed') {
          proses++;
        } else if (currentStatus == 'delivery' || currentStatus == 'on_delivery' || currentStatus == 'delivered' || currentStatus == 'received') {
          dikirim++;
        }
      }

      if (mounted) {
        setState(() {
          _totalSaldo = total;
          _pesananBaru = baru;
          _pesananProses = proses;
          _pesananDikirim = dikirim;
          _isLoadingSaldo = false;
        });
      }

      // Check and update wallets table
      try {
        final walletResponse = await supabase
            .from('wallets')
            .select('wallet_id')
            .eq('seller_id', user.id)
            .maybeSingle();

        if (walletResponse != null) {
          await supabase.from('wallets').update({
            'balance': total,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }).eq('seller_id', user.id);
        } else {
          await supabase.from('wallets').insert({
            'seller_id': user.id,
            'balance': total,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      } catch (e) {
        print('Error updating wallets table: $e');
        // Kita tidak melemparkan error ini ke UI agar saldo tetap tampil di Dashboard
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() => _isLoadingSaldo = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error muat data dashboard: $e')));
      }
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

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
                _isLoadingSaldo ? '-' : _formatCurrency(_totalSaldo),
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
              Expanded(child: _buildStatusCounter(_isLoadingSaldo ? '-' : '$_pesananBaru', 'Pesanan Baru')),
              Container(width: 1, height: 40, color: AppColors.divider),
              Expanded(child: _buildStatusCounter(_isLoadingSaldo ? '-' : '$_pesananProses', 'Diproses')),
              Container(width: 1, height: 40, color: AppColors.divider),
              Expanded(child: _buildStatusCounter(_isLoadingSaldo ? '-' : '$_pesananDikirim', 'Dikirim')),
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
                onTap: () {
                  Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddProductScreen(),
                  ),
                );
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.inventory_2_outlined,
                label: 'Produk Saya',
                onTap: () {
                  Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProductSellerScreen(),
                  ),
                );
                },
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
