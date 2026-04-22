import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class EditProductDialog extends StatefulWidget {
  final ProductModel product;

  const EditProductDialog({
    super.key,
    required this.product,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _stockController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _unitController;

  int? _selectedCategoryId;
  DateTime? _harvestDate;
  File? _newImageFile;
  bool _isLoading = false;
  bool _isFetchingCategories = true;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p.product_name);
    _descController = TextEditingController(text: p.description);
    _stockController = TextEditingController(text: p.stock.toString());
    _sellingPriceController = TextEditingController(
      text: p.selling_price > 0 ? p.selling_price.toInt().toString() : '',
    );
    _costPriceController = TextEditingController(
      text: p.cost_price > 0 ? p.cost_price.toInt().toString() : '',
    );
    _unitController = TextEditingController(text: p.unit);
    _selectedCategoryId = p.category_id;
    _harvestDate = p.harvest_date;
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _stockController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await Supabase.instance.client.from('categories').select();
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response);
          _isFetchingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingCategories = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _newImageFile = File(picked.path));
    }
  }

  Future<void> _pickHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryDark,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _harvestDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showError('Pilih kategori produk');
      return;
    }
    if (_harvestDate == null) {
      _showError('Pilih tanggal panen');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ProductService().updateProduct(
        product_id: widget.product.product_id!,
        category_id: _selectedCategoryId!,
        product_name: _nameController.text.trim(),
        description: _descController.text.trim(),
        cost_price: double.tryParse(
                _costPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            widget.product.cost_price,
        selling_price: double.tryParse(_sellingPriceController.text
                .replaceAll(RegExp(r'[^0-9]'), '')) ??
            widget.product.selling_price,
        stock: int.tryParse(_stockController.text.trim()) ?? widget.product.stock,
        unit: _unitController.text.trim(),
        image_file: _newImageFile,                       // null jika tidak ganti
        existingImageUrl: widget.product.image_url,       // pakai gambar lama
        harvest_date: _harvestDate!,
        status_product: widget.product.status_product,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil diperbarui!'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Gagal update: $e');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Stack(
        children: [
          // ── Scrollable form ──────────────────────────────────────────────
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
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
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close,
                              color: Colors.grey, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Gambar Produk ─────────────────────────────────────
                    _buildLabel('Gambar Produk'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: _newImageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_newImageFile!,
                                    fit: BoxFit.cover),
                              )
                            : widget.product.image_url.isNotEmpty
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          widget.product.image_url,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => _imagePlaceholder(),
                                        ),
                                      ),
                                      // Overlay edit hint
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit,
                                                color: Colors.white, size: 28),
                                            SizedBox(height: 4),
                                            Text(
                                              'Tap untuk ganti gambar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : _imagePlaceholder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Nama Produk ───────────────────────────────────────
                    _buildLabel('Nama Produk'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Nama produk',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 20),

                    // ── Deskripsi ─────────────────────────────────────────
                    _buildLabel('Deskripsi'),
                    _buildTextField(
                      controller: _descController,
                      hint: 'Deskripsi produk...',
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 20),

                    // ── Kategori ──────────────────────────────────────────
                    _buildLabel('Kategori'),
                    const SizedBox(height: 8),
                    _isFetchingCategories
                        ? const SizedBox(
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedCategoryId,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.black87),
                                hint: const Text('Pilih kategori',
                                    style:
                                        TextStyle(fontSize: 14, color: Colors.grey)),
                                items: _categories.map((cat) {
                                  final id = cat['id'] ?? cat['category_id'];
                                  final name =
                                      cat['name'] ?? cat['category_name'] ?? '';
                                  return DropdownMenuItem<int>(
                                    value: id is int
                                        ? id
                                        : int.tryParse(id.toString()) ?? 0,
                                    child: Text(name,
                                        style: AppTextStyles.h2.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(
                                    () => _selectedCategoryId = val),
                              ),
                            ),
                          ),

                    const SizedBox(height: 20),

                    // ── Harga Jual ────────────────────────────────────────
                    _buildLabel('Harga Jual (Rp)'),
                    _buildTextField(
                      controller: _sellingPriceController,
                      hint: 'Misal: 45000',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 20),

                    // ── Harga Modal ───────────────────────────────────────
                    _buildLabel('Harga Modal (Rp)'),
                    _buildTextField(
                      controller: _costPriceController,
                      hint: 'Misal: 40000',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 20),

                    // ── Stok ──────────────────────────────────────────────
                    _buildLabel('Stok'),
                    _buildTextField(
                      controller: _stockController,
                      hint: 'Jumlah stok',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 20),

                    // ── Satuan ────────────────────────────────────────────
                    _buildLabel('Satuan (Kg / Pack / Pcs / Liter)'),
                    _buildTextField(
                      controller: _unitController,
                      hint: 'Misal: Kg',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 20),

                    // ── Tanggal Panen ─────────────────────────────────────
                    _buildLabel('Tanggal Panen'),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _pickHarvestDate,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _harvestDate != null
                                    ? DateFormat('dd MMMM yyyy')
                                        .format(_harvestDate!)
                                    : 'Pilih tanggal',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: _harvestDate != null
                                      ? Colors.black87
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today_outlined,
                                size: 16, color: Colors.grey.shade500),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Tombol Simpan ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: Text(
                          'Simpan',
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // ── Loading overlay ───────────────────────────────────────────────
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.subtitle.copyWith(
        fontSize: 13,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.h2.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          'Tap untuk tambah gambar',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
