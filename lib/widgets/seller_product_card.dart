import 'package:flutter/material.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';

class SellerProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int stock;
  final String priceFormatted;
  final String statusText;
  final Color statusColor;
  final int soldCount;
  final double rating;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final Color secondaryActionColor;
  final String primaryActionText;
  final VoidCallback? onPrimaryAction;
  final bool showPrimaryActionIcon;

  const SellerProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.stock,
    required this.priceFormatted,
    required this.statusText,
    required this.statusColor,
    required this.soldCount,
    required this.rating,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.secondaryActionColor = Colors.orange,
    this.primaryActionText = 'Detail Produk',
    this.onPrimaryAction,
    this.showPrimaryActionIcon = true,
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
          // Top Row: Image, Title, Status, Stock, Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 70,
                  height: 70,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 14,
                              color: AppColors.text,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 2),
                    Text(
                      'Sisa Stok: $stock',
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      priceFormatted,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 14,
                        color: AppColors.primary, // Using primary green
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info Row: Sold & Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terjual',
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$soldCount Stok',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 12,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rating',
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 12,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Secondary Action Button (e.g., Arsipkan)
              if (secondaryActionText != null) ...[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: onSecondaryAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: secondaryActionColor),
                      ),
                      child: Text(
                        secondaryActionText!,
                        style: AppTextStyles.subtitle.copyWith(
                          color: secondaryActionColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Primary Action Button
              Expanded(
                flex: secondaryActionText != null ? 2 : 0,
                child: GestureDetector(
                  onTap: onPrimaryAction,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: secondaryActionText == null ? 16 : 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: secondaryActionText == null ? MainAxisSize.min : MainAxisSize.max,
                      children: [
                        Text(
                          primaryActionText,
                          style: AppTextStyles.subtitle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (showPrimaryActionIcon) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
