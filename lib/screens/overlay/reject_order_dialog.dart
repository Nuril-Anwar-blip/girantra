import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class RejectOrderDialog extends StatelessWidget {
  final String orderId;

  const RejectOrderDialog({super.key, required this.orderId});

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
                  'Konfirmasi Tolak',
                  style: AppTextStyles.h2.copyWith(color: Colors.red, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.subtitle.copyWith(color: Colors.grey.shade700, fontSize: 14),
                children: [
                  const TextSpan(text: 'Apakah Anda yakin untuk menghapus pesanan\n'),
                  const TextSpan(text: 'dengan ID: '),
                  TextSpan(
                    text: orderId,
                    style: AppTextStyles.h2.copyWith(color: Colors.red, fontSize: 14),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400, // Matching the Batal gray from screenshot
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // Perform delete / reject
                      Navigator.pop(context, true);
                    },
                    child: Text('Tolak', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
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
