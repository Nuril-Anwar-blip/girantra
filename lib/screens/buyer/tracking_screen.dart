import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class TrackingScreen extends StatefulWidget {
  final int transactionId;
  final String transactionCode;

  const TrackingScreen({
    super.key,
    required this.transactionId,
    required this.transactionCode,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Map<String, dynamic>? _transaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      final response = await Supabase.instance.client
          .from('transactions')
          .select('*, products(product_name, image_url)')
          .eq('transaction_id', widget.transactionId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _transaction = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading transaction: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(num amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  // Determine which steps are active based on payment_status
  int _getActiveStep() {
    final status = _transaction?['payment_status']?.toString() ?? 'pending';
    final completed = _transaction?['completed_date'];

    if (completed != null) return 4;
    if (status == 'paid') return 2;
    if (status == 'pending') return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 110,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 16),
          label: const Text(
            'Kembali',
            style: TextStyle(fontFamily: 'Montserrat', color: AppColors.text, fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Lacak Pesanan', style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.text)),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _transaction == null
              ? const Center(child: Text('Transaksi tidak ditemukan'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Status header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.transactionCode,
                                  style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getStatusLabel(),
                                  style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getPaymentBadge(),
                              style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Product info card
                    _buildProductCard(),
                    const SizedBox(height: 24),

                    // Timeline
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status Pesanan', style: AppTextStyles.h2),
                          const SizedBox(height: 20),
                          _buildTimelineStep(
                            index: 0,
                            title: 'Pesanan Dibuat',
                            subtitle: 'Pesanan Anda telah diterima',
                            icon: Icons.receipt_long,
                            isActive: _getActiveStep() >= 0,
                            isLast: false,
                          ),
                          _buildTimelineStep(
                            index: 1,
                            title: 'Menunggu Pembayaran',
                            subtitle: 'Silakan lakukan pembayaran',
                            icon: Icons.payment,
                            isActive: _getActiveStep() >= 1,
                            isLast: false,
                          ),
                          _buildTimelineStep(
                            index: 2,
                            title: 'Pembayaran Dikonfirmasi',
                            subtitle: 'Pembayaran berhasil diverifikasi',
                            icon: Icons.check_circle,
                            isActive: _getActiveStep() >= 2,
                            isLast: false,
                          ),
                          _buildTimelineStep(
                            index: 3,
                            title: 'Pesanan Dikirim',
                            subtitle: 'Pesanan dalam perjalanan ke alamat Anda',
                            icon: Icons.local_shipping,
                            isActive: _getActiveStep() >= 3,
                            isLast: false,
                          ),
                          _buildTimelineStep(
                            index: 4,
                            title: 'Pesanan Selesai',
                            subtitle: 'Pesanan telah sampai di tujuan',
                            icon: Icons.done_all,
                            isActive: _getActiveStep() >= 4,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shipping address
                    _buildAddressCard(),
                  ],
                ),
    );
  }

  String _getStatusLabel() {
    final step = _getActiveStep();
    switch (step) {
      case 0: return 'Pesanan baru dibuat';
      case 1: return 'Menunggu pembayaran';
      case 2: return 'Pembayaran dikonfirmasi';
      case 3: return 'Sedang dikirim';
      case 4: return 'Pesanan selesai';
      default: return '-';
    }
  }

  String _getPaymentBadge() {
    final status = _transaction?['payment_status']?.toString() ?? '';
    switch (status) {
      case 'paid': return '✓ Lunas';
      case 'pending': return '⏳ Pending';
      default: return status.toUpperCase();
    }
  }

  Widget _buildProductCard() {
    final product = _transaction?['products'] as Map<String, dynamic>? ?? {};
    final name = product['product_name']?.toString() ?? 'Produk';
    final imageUrl = product['image_url']?.toString() ?? '';
    final qty = _transaction?['quantity'] as int? ?? 1;
    final total = (_transaction?['total_amount'] as num?)?.toDouble() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60, height: 60, color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Jumlah: $qty', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(
            _formatCurrency(total),
            style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final address = _transaction?['shipping_address']?.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alamat Pengiriman', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(address, style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required bool isLast,
  }) {
    final activeStep = _getActiveStep();
    final isCurrent = index == activeStep;
    final color = isActive ? AppColors.primary : Colors.grey[300]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column (circle + line)
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: isCurrent ? 36 : 28,
                height: isCurrent ? 36 : 28,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.grey[200],
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: isCurrent ? 18 : 14,
                  color: isActive ? Colors.white : Colors.grey[400],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isActive ? AppColors.primary : Colors.grey[300],
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    fontSize: isCurrent ? 14 : 13,
                    color: isActive ? AppColors.text : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: isActive ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
