import 'package:flutter/material.dart';
// import '../models/product_model.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String tag;
  final String title;
  final String location;
  final String rating;
  final String price;
  final String unit;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.tag,
    required this.title,
    required this.location,
    required this.rating,
    required this.price,
    required this.unit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          // Subtle shadow to mimic the card feel requested
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Image and Tag)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    child: Container(
                      color: Colors.grey[200],
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                  ),
                  // Tag label (kiri atas)
                  Positioned(
                    top: 12,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Text(
                        tag,
                        style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Section (Information)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.productName,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCart extends StatelessWidget {
  final String imageUrl;
  final String tag;
  final String title;
  final String description;
  final String price;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback? onDelete;

  const ProductCart({
    Key? key,
    required this.imageUrl,
    required this.tag,
    required this.title,
    required this.description,
    required this.price,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag and Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: const Color(0xFF358C36),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (onDelete != null)
                InkWell(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, color: Colors.grey),
                      )
                    : const Icon(Icons.image_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      description,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Price
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF358C36),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Qty Control
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF358C36)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: onRemove,
                              child: Container(
                                width: 28,
                                alignment: Alignment.center,
                                child: const Icon(Icons.remove, size: 16, color: Color(0xFF358C36)),
                              ),
                            ),
                            Container(
                              width: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF358C36).withOpacity(0.15),
                                border: const Border(
                                  left: BorderSide(color: Color(0xFF358C36)),
                                  right: BorderSide(color: Color(0xFF358C36)),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                qty.toString(),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF358C36),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onAdd,
                              child: Container(
                                width: 28,
                                alignment: Alignment.center,
                                child: const Icon(Icons.add, size: 16, color: Color(0xFF358C36)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final String title;
  final String storeName;
  final String price;
  final String imageUrl;

  const ProductListTile({
    Key? key,
    required this.title,
    this.storeName = '',
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                )
              : const Icon(Icons.image_outlined, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 80, // Menyamakan tinggi teks dengan tinggi gambar (80px)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (storeName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        storeName,
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ],
                ),
                Text(
                  price,
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
        ),
      ],
    );
  }
}