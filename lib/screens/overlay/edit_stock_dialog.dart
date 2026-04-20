import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class EditStockDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final int initialStock;

  const EditStockDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.initialStock,
  });

  @override
  State<EditStockDialog> createState() => _EditStockDialogState();
}

class _EditStockDialogState extends State<EditStockDialog> {
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.initialStock.toString());
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Stok',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Product Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID Produk',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Text(
                  widget.productId,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nama Produk:',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Text(
                  widget.productName,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Input Field
            Text(
              'Stok Ulang',
              style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              style: AppTextStyles.h2.copyWith(fontSize: 16),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Perform save
                  final newStock = int.tryParse(_stockController.text) ?? widget.initialStock;
                  Navigator.pop(context, newStock);
                },
                child: Text('Simpan', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
