import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class DeleteProductDialog extends StatelessWidget {
  final String productName;

  const DeleteProductDialog({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Konfirmasi Hapus',
                  style: AppTextStyles.h2.copyWith(color: Colors.red, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.subtitle.copyWith(color: Colors.grey.shade700, fontSize: 14),
                children: [
                  const TextSpan(text: 'Apakah Anda yakin untuk menghapus produk\n'),
                  TextSpan(
                    text: productName,
                    style: AppTextStyles.h2.copyWith(color: Colors.red, fontSize: 14),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Perform delete
                      Navigator.pop(context, true);
                    },
                    child: Text('Hapus', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
