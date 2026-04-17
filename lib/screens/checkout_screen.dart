import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';

class CheckoutScreen extends StatefulWidget {
  final ProductModel product;

  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0 for COD, 1 for Transfer Bank

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
                      RichText(
                        text: TextSpan(
                          text: 'John Doe ',
                          style: AppTextStyles.link.copyWith(
                            color: AppColors.text,
                          ),
                          children: [
                            TextSpan(
                              text: '+23 1234567890',
                              style: AppTextStyles.subtitle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Jalan Jendral Sudirman Blok Q, no 45. Babarsari, Kec. Laweyan, Kita Surakarta',
                        style: TextStyle(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: widget.product.image_url.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                widget.product.image_url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.product_name,
                            style: AppTextStyles.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Plant Store', // Replace with real store name if available
                            style: AppTextStyles.subtitle,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            formatCurrency(widget.product.selling_price),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: AppColors.text,
                            fontSize: 13,
                          ),
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
                          children: const [
                            Text(
                              'Transfer Bank',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: AppColors.text,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bank BRI',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: AppColors.mutedText,
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
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.text,
            fontSize: 13,
          ),
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
