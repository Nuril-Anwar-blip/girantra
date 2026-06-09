import 'package:flutter/material.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Kartu rekomendasi penjual
// ─────────────────────────────────────────────────────────────────────────────

class SellerRecommendation {
  final String sellerName;
  final double price;
  final String unit;
  final String productName;
  final String labelType;
  final String label;
  final String location;
  final double rating;
  final int stock;
  final int score;

  const SellerRecommendation({
    required this.sellerName,
    required this.price,
    required this.unit,
    required this.productName,
    required this.labelType,
    required this.label,
    required this.location,
    required this.rating,
    required this.stock,
    required this.score,
  });
}

class SellerRecommendationCard extends StatelessWidget {
  final SellerRecommendation recommendation;
  final VoidCallback? onTap;

  const SellerRecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  // Warna label berdasarkan tipe
  Color _labelBg(String type) {
    switch (type) {
      case 'blue':
        return const Color(0xFFE6F1FB);
      case 'amber':
        return const Color(0xFFFAEEDA);
      default:
        return const Color(0xFFEAF3DE); // green
    }
  }

  Color _labelText(String type) {
    switch (type) {
      case 'blue':
        return const Color(0xFF185FA5);
      case 'amber':
        return const Color(0xFF854F0B);
      default:
        return const Color(0xFF3B6D11); // green
    }
  }

  // Warna progress bar berdasarkan skor
  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFF1D9E75);
    if (score >= 70) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }

  String _formatPrice(double price, String unit) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted/$unit';
  }

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Baris atas: nama toko + harga ──────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 14,
                  color: Color(0xFF1D9E75),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    rec.sellerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatPrice(rec.price, rec.unit),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D9E75),
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ── Nama produk ─────────────────────────────────────────────────
            Text(
              rec.productName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
              ),
            ),

            const SizedBox(height: 8),

            // ── Tags ────────────────────────────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Label AI
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _labelBg(rec.labelType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rec.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: _labelText(rec.labelType),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Lokasi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rec.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 11,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rec.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                // Stok
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stok: ${rec.stock}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Skor rekomendasi AI ─────────────────────────────────────────
            Row(
              children: [
                Text(
                  'Skor AI:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rec.score / 100,
                      minHeight: 5,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _scoreColor(rec.score),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${rec.score}/100',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _scoreColor(rec.score),
                    fontFamily: 'Montserrat',
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
