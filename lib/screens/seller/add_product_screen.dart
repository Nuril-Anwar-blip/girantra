import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();
  
  DateTime? _harvestDate;
  File? _imageFile;
  int? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _isFetchingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Supabase.instance.client.from('categories').select();
      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);
        _isFetchingCategories = false;
      });
    } catch (e) {
      if (mounted) {
        // Fallback or error
        setState(() {
          _isFetchingCategories = false;
        });
        print('Error fetching categories: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Far past
      lastDate: DateTime.now(), // Disable future dates
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _harvestDate = picked;
      });
    }
  }

  void _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar produk harus ditambahkan', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }
    if (_harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal panen harus diisi', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori produk', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ProductService().addProduct(
        category_id: _selectedCategory!,
        product_name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        cost_price: double.tryParse(_costPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
        selling_price: double.tryParse(_sellingPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
        ai_recommendation_price: 0.0,
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
        unit: _unitController.text.trim(),
        image_file: _imageFile!,
        harvest_date: _harvestDate!,
        status_product: 'available',
      );

      if (mounted) {
        setState(() { _isLoading = false; });
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
              content: Text('Produk berhasil ditambahkan!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Gagal: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Tambah Produk',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: const [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios, color: Colors.black87, size: 16),
              Text('Kembali', style: TextStyle(color: Colors.black87, fontSize: 14)),
            ],
          ),
        ),
        leadingWidth: 100,
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker 
                    GestureDetector(
                      onTap: _pickImage,
                      child: CustomPaint(
                        painter: DashedRectPainter(color: Colors.grey.shade400, strokeWidth: 1.5, gap: 5.0),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16)
                          ),
                          child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline, size: 40, color: Colors.grey.shade500),
                                  const SizedBox(height: 8),
                                  Text('Tambah Gambar', style: AppTextStyles.subtitle.copyWith(color: Colors.grey.shade600, fontSize: 14)),
                                ],
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('*Gunakan gambar yang jelas', style: AppTextStyles.subtitle.copyWith(fontSize: 12, color: Colors.grey.shade600)),
                    
                    const SizedBox(height: 24),
                    
                    // Form Fields Wrapping inside a Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(label: 'NAMA PRODUK', hint: 'Nama Produk', controller: _nameController),
                          const SizedBox(height: 16),
                          _buildTextField(label: 'HARGA MODAL (Rp)', hint: 'Misal: 40.000', controller: _costPriceController, isNumber: true),
                          const SizedBox(height: 16),
                          _buildTextField(label: 'HARGA JUAL (Rp)', hint: 'Misal: 45.000', controller: _sellingPriceController, isNumber: true),
                          const SizedBox(height: 16),
                          // AI Recommendation (Disabled)
                          _buildTextField(label: 'REKOMENDASI HARGA AI', hint: 'Fitur yang akan datang', controller: TextEditingController(), isEnabled: false),
                          const SizedBox(height: 16),
                          
                          // Category Dropdown
                          Text('KATEGORI', style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          _isFetchingCategories 
                          ? const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: CircularProgressIndicator())
                          : DropdownButtonFormField<int>(
                              value: _selectedCategory,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              isExpanded: true,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                              ),
                              hint: const Text('Pilih Kategori', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              items: _categories.isNotEmpty ? _categories.map((cat) {
                                return DropdownMenuItem<int>(
                                  value: cat['id'] ?? cat['category_id'] ?? 0, // Fallback fields
                                  child: Text(cat['name'] ?? cat['category_name'] ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                                );
                              }).toList() : [
                                const DropdownMenuItem(value: 1, child: Text('Pupuk', style: TextStyle(fontSize: 14))),
                                const DropdownMenuItem(value: 2, child: Text('Bibit', style: TextStyle(fontSize: 14))),
                              ],
                              onChanged: (val) => setState(() => _selectedCategory = val),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildTextField(label: 'DESKRIPSI', hint: 'Lorem ipsum dolor sit amet...', controller: _descriptionController, maxLines: 3),
                          const SizedBox(height: 16),
                          _buildTextField(label: 'STOK', hint: '120', controller: _stockController, isNumber: true),
                          const SizedBox(height: 16),
                          _buildTextField(label: 'SATUAN (Kg/Pack/Pcs/Liter)', hint: 'Kg', controller: _unitController),
                          const SizedBox(height: 24),
                          
                          // Harvest Date
                          Text('TANGGAL PANEN', style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _pickHarvestDate,
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _harvestDate != null 
                                    ? DateFormat('dd MMMM yyyy').format(_harvestDate!) 
                                    : 'Pilih Tanggal',
                                style: TextStyle(fontSize: 14, color: _harvestDate != null ? Colors.black87 : Colors.grey.shade600),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              onPressed: _submitProduct,
                              child: const Text('Tambah Produk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3), // Safe equivalent of older flutter's .withOpacity in most current environments, but let's be careful. Oh it throws deprecation usually in 3.27+. We will leave it for now.
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required String hint, 
    required TextEditingController controller, 
    bool isNumber = false,
    bool isEnabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: isEnabled ? Colors.black87 : Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: isEnabled,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (val) {
            if (isEnabled && (val == null || val.isEmpty)) return 'Wajib diisi';
            return null;
          },
          style: TextStyle(fontSize: 14, color: isEnabled ? Colors.black87 : Colors.grey),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            disabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, style: BorderStyle.none)), // Invisible or dimmed
          ),
        ),
      ],
    );
  }
}

// Custom Painter for internal dashes
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  
  DashedRectPainter({this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
      
    var rRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16));
    
    // Instead of complex dashing for RRect which is hard natively without package, I'll just draw a solid line since path_drawing package isn't imported.
    // Wait, the user's mockup uses a dashed border. If path_drawing isn't available, we can quickly implement basic dashing for the rect or just use solid. For a simpler working path, I'll use a dash over a Path algorithm.
    // Since drawing a dashed RRect is highly complex in plain Flutter without flutter_dash or similar, I will use a dotted effect with solid for now, or just paint the Outline.
    // Let's implement a very generic dashing:
    Path metricsPath = Path()..addRRect(rRect);
    Path dashPath = Path();
    
    // simple dash
    for (PathMetric measurePath in metricsPath.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        dashPath.addPath(measurePath.extractPath(distance, distance + gap), Offset.zero);
        distance += gap * 2;
      }
    }
    
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
