import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../seller/dashboard_seller_screen.dart';
import '../seller/product_seller_screen.dart';
import '../profile/profile_screen.dart';

class SellerNavigation extends StatefulWidget {
  const SellerNavigation({super.key});

  @override
  State<SellerNavigation> createState() => _SellerNavigationState();
}

class _SellerNavigationState extends State<SellerNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardSellerScreen(),
    ProductSellerScreen(),
    Center(child: Text('Halaman Pengiriman (Segera Hadir)', style: TextStyle(fontFamily: 'Montserrat'))),
    ProfileScreen(), // Reuse profile screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Pengiriman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
