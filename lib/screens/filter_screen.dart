import 'package:flutter/material.dart';

import '../ui/app_colors.dart';
import '../ui/app_widgets.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Filter',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Filter',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    ChipTag(text: 'Benih'),
                    ChipTag(text: 'Sayuran', background: Colors.white, foreground: AppColors.mutedText),
                    ChipTag(text: 'Pupuk', background: Colors.white, foreground: AppColors.mutedText),
                    ChipTag(text: 'Buah', background: Colors.white, foreground: AppColors.mutedText),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Harga', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    ChipTag(text: 'Termurah'),
                    ChipTag(text: 'Termahal', background: Colors.white, foreground: AppColors.mutedText),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Penilaian', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _RatingChip(stars: 5, selected: false),
                    _RatingChip(stars: 4, selected: true),
                    _RatingChip(stars: 3, selected: false),
                    _RatingChip(stars: 2, selected: false),
                    _RatingChip(stars: 1, selected: false),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryPillButton(
                  text: 'Tampilkan 30 Hasil',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final int stars;
  final bool selected;

  const _RatingChip({required this.stars, required this.selected});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFE9F5EA) : Colors.white;
    final fg = selected ? AppColors.primaryDark : AppColors.mutedText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: selected ? const Color(0xFFFFC107) : fg),
          const SizedBox(width: 4),
          Text('$stars', style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

