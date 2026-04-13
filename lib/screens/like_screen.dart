import 'package:flutter/material.dart';

import '../ui/app_colors.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  final _productService = ProductService();
  late Future<List<ProductModel>> _futureProducts;

  @override
  void initState() {
    super.initState();
    // For now, fetching all products since favorite mechanism might not be fully established.
    // If it's slow, we provide dummy products immediately in UI.
    _futureProducts = _productService.getProducts();
  }

  List<ProductModel> _dummyFavoriteProducts() {
    return List.generate(
      4,
      (index) => ProductModel(
        product_id: -(index + 1),
        category_id: 1, // Let's pretend 1 is 'Benih' in logic if mapping is present
        product_name: 'Bibit Padi Unggul Ciherang',
        description: 'Benih kualitas terbaik untuk hasil panen melimpah.',
        cost_price: 45000,
        selling_price: 75000,
        ai_recommendation_price: 75000,
        stock: 50,
        unit: 'Kg',
        image_url: 'https://images.unsplash.com/photo-1596724896798-17de24c9eb72?w=500&auto=format&fit=crop&q=60',
        harvest_date: DateTime.now(),
        status_product: 'available',
        seller_id: 'dummy',
        created_at: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Kembali',
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Text(
                'Favorit Saya',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          List<ProductModel> products = snapshot.data ?? [];
          
          // Jika kosong atau terjadi error, fallback ke dummy untuk menampilkan UI yang sesuai
          if (products.isEmpty) {
            products = _dummyFavoriteProducts();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55, // Identical to Home screen configuration
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

