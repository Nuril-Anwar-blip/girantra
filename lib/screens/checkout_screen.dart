import 'package:flutter/material.dart';
import '../ui/app_colors.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alamat Pengiriman
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider)
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("John Doe  +62 81234567890", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text("Jalan Jendral Sudirman Blok Q, no 45, Babarsari, Kec. Laweyan, Kota Surakarta", style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Produk yang dibeli
          const Text("Produk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider)
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=200&q=60',
                        width: 70, height: 70, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Bibit Padi Unggul", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text("Plant Store", style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                          SizedBox(height: 12),
                          Text("Rp 75.000", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 14)),
                        ],
                      ),
                    )
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Total Produk", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text("Rp 75.000", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 14)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Metode Pembayaran
          const Text("Metode Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider)
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text("COD - Cek Dahulu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.check_circle, color: AppColors.primary),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text("Transfer Bank", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text("Bank BRI", style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Rincian Pembayaran
          const Text("Rincian Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider)
            ),
            child: Column(
              children: [
                _buildRowDetail("Subtotal Pemesanan", "Rp 75.000"),
                const SizedBox(height: 8),
                _buildRowDetail("Subtotal Pengiriman", "Rp 5.000"),
                const SizedBox(height: 8),
                _buildRowDetail("Biaya Layanan", "Rp 2.500"),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Rp 82.500", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("TOTAL", style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                Text("Rp 82.500", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan Berhasil Dibuat!")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text("Buat Pesanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRowDetail(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: AppColors.mutedText)),
        Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
