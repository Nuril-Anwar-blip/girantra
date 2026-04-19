import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:girantra/ui/app_text_styles.dart';

import '../../ui/app_colors.dart';
// import '../ui/app_widgets.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  int? _selectedCategoryId;
  String? _selectedPriceSort;
  int? _selectedRating;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Supabase.instance.client.from('categories').select();
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response);
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Filter',
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryId = null;
                        _selectedPriceSort = null;
                        _selectedRating = null;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Reset',
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.accentDark, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Kategori', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _isLoadingCategories
                ? const SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : _categories.isEmpty
                    ? const Text('Tidak ada kategori', style: TextStyle(color: AppColors.mutedText, fontSize: 12))
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final int id = cat['id'] ?? cat['category_id'] ?? 0;
                          final String name = cat['name'] ?? cat['category_name'] ?? 'Unknown';
                          final isSelected = _selectedCategoryId == id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = isSelected ? null : id;
                              });
                            },
                            child: _FilterTag(
                              text: name,
                              isSelected: isSelected,
                            ),
                          );
                        }).toList(),
                      ),
            const SizedBox(height: 24),
            Text('Harga', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedPriceSort = _selectedPriceSort == 'Termurah' ? null : 'Termurah';
                  }),
                  child: _FilterTag(text: 'Termurah', isSelected: _selectedPriceSort == 'Termurah'),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedPriceSort = _selectedPriceSort == 'Termahal' ? null : 'Termahal';
                  }),
                  child: _FilterTag(text: 'Termahal', isSelected: _selectedPriceSort == 'Termahal'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Penilaian', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(5, (index) {
                final stars = 5 - index;
                final isSelected = _selectedRating == stars;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = isSelected ? null : stars;
                    });
                  },
                  child: _RatingChip(stars: stars, selected: isSelected),
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF358C36), // Green color matching image
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: pass data back to caller via Navigator pop result
                  Navigator.of(context).pop();
                },
                child: const Text('Tampilkan 30 Hasil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTag extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _FilterTag({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? const Color(0xFF358C36) : Colors.white;
    final fg = isSelected ? Colors.white : AppColors.mutedText;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isSelected ? Colors.transparent : AppColors.divider),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: fg,
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
    final bg = selected ? const Color(0xFF358C36) : Colors.white;
    final fg = selected ? Colors.white : AppColors.mutedText;
    final starColor = selected ? const Color(0xFFFFC107) : const Color(0xFFFFC107);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: selected ? Colors.transparent : AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: starColor),
          const SizedBox(width: 4),
          Text('$stars', style: TextStyle(fontWeight: FontWeight.w600, color: fg, fontSize: 12)),
        ],
      ),
    );
  }
}

