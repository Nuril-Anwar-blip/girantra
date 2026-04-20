import 'package:flutter/material.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';

class SellerOrderCard extends StatelessWidget {
  final String orderId;
  final String statusText;
  final Color statusColor;
  final String imageUrl;
  final String title;
  final int quantity;
  final String priceFormatted;
  final String deliveryAddress;
  final String courierName;
  final String deliveryStatusText;
  final Color deliveryStatusColor;
  final String? actionButtonText;
  final VoidCallback? onAction;

  const SellerOrderCard({
    super.key,
    required this.orderId,
    required this.statusText,
    required this.statusColor,
    required this.imageUrl,
    required this.title,
    required this.quantity,
    required this.priceFormatted,
    required this.deliveryAddress,
    required this.courierName,
    required this.deliveryStatusText,
    required this.deliveryStatusColor,
    this.actionButtonText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: ID & Main Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: $orderId',
                style: AppTextStyles.subtitle.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                statusText,
                style: AppTextStyles.subtitle.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 2: Product Image & Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade300,
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, color: Colors.grey);
                        })
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 14,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Jumlah: $quantity',
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceFormatted,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 3: Address Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengiriman ke',
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deliveryAddress,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.text,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Column 4: Courier Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kurir',
                style: AppTextStyles.subtitle.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                courierName,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 12,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 5: Detailed Delivery Status & Optional Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deliveryStatusText,
                      style: AppTextStyles.subtitle.copyWith(
                        color: deliveryStatusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionButtonText != null && onAction != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary, // Typical green action button
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      actionButtonText!,
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
