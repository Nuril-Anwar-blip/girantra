import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class CheckoutScreen extends StatefulWidget {
  final ProductModel product;

  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0 for COD, 1 for Transfer Bank
  
  String _fullName = '';
  String _phoneNumber = '';
  String _address = '';
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Langkah 2: Query ke database Supabase
        final userData = await Supabase.instance.client
            .from('users')
            .select('full_name, phone_number, address')
            .eq('user_id', user.id)
            .maybeSingle();

        // Langkah 3: Update state dengan data yang didapat
        if (userData != null && mounted) {
          setState(() {
            _fullName = userData['full_name'] ?? 'Pengguna';
            _phoneNumber = userData['phone_number'] ?? 'Belum ada nomor telepon';
            _address = userData['address'] ?? 'Belum ada alamat, silakan isi di profil Anda';
            _isLoadingUser = false;
          });
        } else {
          if (mounted) setState(() => _isLoadingUser = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingUser = false);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formatCurrency(num amount) {
    return 'Rp${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final double shippingFee = 5000;
    final double serviceFee = 2500;
    final double totalPrice =
        widget.product.selling_price + shippingFee + serviceFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 110,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.text,
            size: 16,
          ),
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
                'Checkout',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Address Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
                      _isLoadingUser 
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox(
                              height: 16, width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              text: '$_fullName ',
                              style: AppTextStyles.link.copyWith(
                                color: AppColors.text,
                              ),
                              children: [
                                TextSpan(
                                  text: _phoneNumber,
                                  style: AppTextStyles.subtitle,
                                ),
                              ],
                            ),
                          ),
                      const SizedBox(height: 4),
                      _isLoadingUser 
                        ? const SizedBox.shrink()
                        : Text(
                            _address,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: AppColors.mutedText,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Product Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Produk', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                ProductListTile(
                  title: widget.product.product_name,
                  storeName: 'Plant Store',
                  price: formatCurrency(widget.product.selling_price),
                  imageUrl: widget.product.image_url,
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Produk',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      formatCurrency(widget.product.selling_price),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Payment Method Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Metode Pembayaran', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _selectedPaymentMethod = 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'COD - Cek Dahulu',
                          style: AppTextStyles.subtitle,
                        ),
                        Icon(
                          _selectedPaymentMethod == 0
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: _selectedPaymentMethod == 0
                              ? const Color(0xFF358C36)
                              : Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _selectedPaymentMethod = 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transfer Bank',
                              style: AppTextStyles.subtitle,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bank BRI',
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _selectedPaymentMethod == 1
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: _selectedPaymentMethod == 1
                              ? const Color(0xFF358C36)
                              : Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Payment Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rincian Pembayaran', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                _buildPaymentRow(
                  'Subtotal Pemesanan',
                  formatCurrency(widget.product.selling_price),
                ),
                const SizedBox(height: 8),
                _buildPaymentRow(
                  'Subtotal Pengiriman',
                  formatCurrency(shippingFee),
                ),
                const SizedBox(height: 8),
                _buildPaymentRow('Biaya Layanan', formatCurrency(serviceFee)),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      formatCurrency(totalPrice),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL', style: AppTextStyles.subtitle),
                    Text(
                      formatCurrency(totalPrice),
                      style: AppTextStyles.finalPrice,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF358C36,
                  ), // Green from the design
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Handle order creation
                },
                child: Text(
                  'Buat Pemesanan',
                  style: AppTextStyles.link.copyWith(
                    color: AppColors.background,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle,
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.text,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
