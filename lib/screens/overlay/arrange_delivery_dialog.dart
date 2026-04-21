import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class ArrangeDeliveryDialog extends StatefulWidget {
  final String orderId;

  const ArrangeDeliveryDialog({super.key, required this.orderId});

  @override
  State<ArrangeDeliveryDialog> createState() => _ArrangeDeliveryDialogState();
}

class _ArrangeDeliveryDialogState extends State<ArrangeDeliveryDialog> {
  int _selectedCourier = 1; // 1 for Mandiri, 2 for Others

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atur Pengiriman',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No Resi:',
                  style: AppTextStyles.h2.copyWith(fontSize: 12),
                ),
                Text(
                  'JNE1234567890',
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID Pemesanan:',
                  style: AppTextStyles.h2.copyWith(fontSize: 12),
                ),
                Text(
                  widget.orderId,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Kurir:',
                    style: AppTextStyles.h2.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setState(() => _selectedCourier = 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pengiriman Mandiri (Anda)',
                          style: AppTextStyles.subtitle.copyWith(fontSize: 12, color: Colors.black87),
                        ),
                        Icon(
                          _selectedCourier == 1 ? Icons.check_circle : Icons.circle_outlined,
                          color: _selectedCourier == 1 ? AppColors.primary : Colors.grey.shade300,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setState(() => _selectedCourier = 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'JNE / JNT / Pos',
                          style: AppTextStyles.subtitle.copyWith(fontSize: 12, color: Colors.black87),
                        ),
                        Icon(
                          _selectedCourier == 2 ? Icons.check_circle : Icons.circle_outlined,
                          color: _selectedCourier == 2 ? AppColors.primary : Colors.grey.shade300,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark, // Matching darker green from screenshot
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Perform arrange delivery
                  Navigator.pop(context, true);
                },
                child: Text('Proses Sekarang', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
