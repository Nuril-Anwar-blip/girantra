import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class KirimPesananDialog extends StatefulWidget {
  final String orderId;
  final String trackingNumber;

  const KirimPesananDialog({
    super.key,
    required this.orderId,
    required this.trackingNumber,
  });

  @override
  State<KirimPesananDialog> createState() => _KirimPesananDialogState();
}

class _KirimPesananDialogState extends State<KirimPesananDialog> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // Tidak bisa memilih tanggal sebelum hari ini
      lastDate: now.add(const Duration(days: 90)), // Maksimal 90 hari ke depan
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
                  'Kirim Pesanan',
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
                Expanded(
                  child: Text(
                    widget.trackingNumber.isEmpty ? '-' : widget.trackingNumber,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
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
                Expanded(
                  child: Text(
                    widget.orderId,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimasi Barang Sampai:',
                  style: AppTextStyles.h2.copyWith(fontSize: 12),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Pilih Tanggal'
                              : DateFormat('dd MMM yyyy').format(_selectedDate!),
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: 12,
                            color: _selectedDate == null ? Colors.grey : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harap pilih estimasi tanggal barang sampai')),
                    );
                    return;
                  }
                  // Return the selected date
                  Navigator.pop(context, _selectedDate);
                },
                child: const Text('Kirim Pesanan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
