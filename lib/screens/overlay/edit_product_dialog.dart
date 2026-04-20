import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class EditProductDialog extends StatefulWidget {
  final String productName;
  final String description;
  final String category;
  final int stock;

  const EditProductDialog({
    super.key,
    required this.productName,
    required this.description,
    required this.category,
    required this.stock,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _stockController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productName);
    _descController = TextEditingController(text: widget.description);
    _stockController = TextEditingController(text: widget.stock.toString());
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Produk',
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Nama Produk
              Text(
                'Nama Produk',
                style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.h2.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Deskripsi
              Text(
                'Deskripsi',
                style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              TextFormField(
                controller: _descController,
                style: AppTextStyles.h2.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Kategori
              Text(
                'Kategori',
                style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                    items: ['Pupuk', 'Benih', 'Alat', 'Lainnya'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: AppTextStyles.h2.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        if (newValue != null) _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Stok
              Text(
                'Stok',
                style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                style: AppTextStyles.h2.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 48),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // Perform save
                    Navigator.pop(context, true);
                  },
                  child: Text('Simpan', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
