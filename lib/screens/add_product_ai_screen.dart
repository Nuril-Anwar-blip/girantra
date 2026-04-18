import 'package:flutter/material.dart';
import '../ui/app_colors.dart';

class AddProductAiScreen extends StatefulWidget {
  const AddProductAiScreen({super.key});

  @override
  State<AddProductAiScreen> createState() => _AddProductAiScreenState();
}

class _AddProductAiScreenState extends State<AddProductAiScreen> {
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  
  bool _isLoadingAi = false;
  String? _aiRecommendation;

  void _generateAiPrice() async {
    setState(() {
      _isLoadingAi = true;
    });
    
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoadingAi = false;
      _aiRecommendation = "Rp 85.000"; 
      _sellingPriceController.text = "85000"; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Produk & AI', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-1592997572594-34afe4c5ce1b?q=80&w=800&auto=format&fit=crop',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              "Informasi Harga",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _costPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Harga Modal (Cost Price)",
                prefixText: "Rp ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3), 
                    blurRadius: 12, 
                    offset: const Offset(0, 6)
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                      SizedBox(width: 8),
                      Text(
                        "AI Price Suggester", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "AI kami akan menganalisis tren pasar agrikultur, kategori organik, dan profit untuk menyarankan harga jual terbaik.",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_aiRecommendation != null)
                        Text(
                          _aiRecommendation!,
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                        )
                      else
                        Text(
                          "Belum ada saran",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                        
                      ElevatedButton(
                        onPressed: _isLoadingAi ? null : _generateAiPrice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        child: _isLoadingAi 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)) 
                          : const Text("Minta Saran AI", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            TextField(
              controller: _sellingPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Harga Jual Akhir (Selling Price)",
                prefixText: "Rp ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Produk berhasil ditambahkan!"),
                      backgroundColor: AppColors.primary,
                    )
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Simpan Produk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
