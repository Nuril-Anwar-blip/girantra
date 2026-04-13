import 'package:flutter/material.dart';
import 'package:girantra/ui/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../ui/app_colors.dart';
import 'cart_screen.dart';
import 'filter_screen.dart';
import 'like_screen.dart';
import 'notification_screen.dart';
import 'product_detail_screen.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productService = ProductService();
  final _authService = AuthService();

  late Future<List<ProductModel>> _futureProducts;
  String _userAddress = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _futureProducts = _productService.getProducts();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('users')
            .select('address')
            .eq('user_id', user.id)
            .maybeSingle();

        if (data != null && data['address'] != null) {
          if (mounted) {
            setState(() {
              _userAddress = data['address'];
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _userAddress = 'Alamat tidak diatur';
            });
          }
        }
      } catch (e) {
        print('Error fetching address: $e');
        if (mounted) {
          setState(() {
            _userAddress = 'Gagal memuat alamat';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _userAddress = 'Belum login';
        });
      }
    }
  }

  List<ProductModel> _dummyProducts() {
    return [
      ProductModel(
        product_id: -1,
        category_id: 1,
        product_name: 'Pupuk Kompos Organik (Dummy)',
        description:
            'Ini produk dummy agar kamu bisa langsung masuk Home. Nanti akan terganti otomatis saat data Supabase sudah ada.',
        cost_price: 25000,
        selling_price: 45000,
        ai_recommendation_price: 45000,
        stock: 50,
        unit: 'kg',
        image_url:
            'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=1200&q=60',
        harvest_date: DateTime.now(),
        status_product: 'available',
        seller_id: 'dummy',
        created_at: DateTime.now(),
      ),
      ProductModel(
        product_id: -2,
        category_id: 2,
        product_name: 'Bibit Cabai Rawit (Dummy)',
        description:
            'Bibit cabai rawit berkualitas tinggi, cocok untuk ditanam di lahan pertanian.',
        cost_price: 25000,
        selling_price: 45000,
        ai_recommendation_price: 45000,
        stock: 50,
        unit: 'kg',
        image_url:
            'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=1200&q=60',
        harvest_date: DateTime.now(),
        status_product: 'available',
        seller_id: 'dummy',
        created_at: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_girantra.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: AppTextStyles.subtitle,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _userAddress,
                          style: AppTextStyles.subtitle.copyWith(color: AppColors.text, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              session == null ? Icons.login : Icons.logout,
              color: Colors.black87,
            ),
            onPressed: () async {
              if (session == null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
                return;
              }
              await _authService.signOut();

              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=60',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: const [
                      Icon(Icons.search, size: 18, color: AppColors.mutedText),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cari pupuk atau hasil tani...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const FilterDialog(),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CategoryShortcut(
                label: 'Benih',
                icon: Icons.spa_outlined,
                onTap: () {},
              ),
              _CategoryShortcut(
                label: 'Pupuk',
                icon: Icons.eco_outlined,
                onTap: () {},
              ),
              _CategoryShortcut(
                label: 'Buah',
                icon: Icons.apple_outlined,
                onTap: () {},
              ),
              _CategoryShortcut(
                label: 'Sayuran',
                icon: Icons.grass_outlined,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lihat Produk Favorit',
                style: AppTextStyles.h2,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LikeScreen()),
                  );
                },
                child: Text(
                  'Lihat Selengkapnya >',
                  style: AppTextStyles.link.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<ProductModel>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              var products = snapshot.data ?? [];
              if (products.isEmpty) products = _dummyProducts();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryShortcut({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 22),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.subtitle.copyWith(color: AppColors.primaryDark)),
          ],
        ),
      ),
    );
  }
}


