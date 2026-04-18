import 'package:flutter/material.dart';
import '../ui/app_colors.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaksi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Search area
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.search, size: 20, color: AppColors.mutedText),
                  SizedBox(width: 8),
                  Expanded(
                     child: TextField(
                       decoration: InputDecoration(
                         hintText: "Search...",
                         hintStyle: TextStyle(fontSize: 14, color: AppColors.mutedText),
                         border: InputBorder.none,
                         isDense: true,
                         contentPadding: EdgeInsets.zero
                       ),
                     ),
                  )
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTransactionCard(
                  title: "Bibit Padi Unggul",
                  date: "12 April 2026",
                  statusText: "Rp 75.000",
                  statusColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildTransactionCard(
                  title: "Bibit Padi Unggul",
                  date: "12 April 2026",
                  statusText: "Dikemas",
                  statusColor: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildTransactionCard(
                  title: "Bibit Padi Unggul",
                  date: "12 April 2026",
                  statusText: "Failed",
                  statusColor: Colors.red,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String date,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4)
          )
        ]
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
