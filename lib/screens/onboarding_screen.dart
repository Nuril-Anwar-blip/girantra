import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/images/loading_img_1.png',
      // Warna orange 
      'baseColor': const Color(0xFFC46700),
      'circleColor': const Color(0xFFDD7800),
      // Posisi lingkaran melengkung
      'circleLeft': -150.0,
      'circleTop': -100.0,
    },
    {
      'image': 'assets/images/loading_img_2.png',
      // Warna kuning mustard
      'baseColor': const Color(0xFFB59E00),
      'circleColor': const Color(0xFFD5BC00),
      // Posisi lingkaran melengkung
      'circleLeft': 150.0,
      'circleTop': -200.0,
    },
    {
      'image': 'assets/images/loading_img_3.png',
      // Warna hijau
      'baseColor': const Color(0xFF1B5E20), // Hijau shade sesuai referensi
      'circleColor': const Color(0xFF2E7D32),
      // Posisi lingkaran melengkung
      'circleLeft': -200.0,
      'circleTop': 50.0,
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Tombol Next pada halaman terakhir (halaman 3) menuju Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ukuran lingkaran dinamis agar cukup menutupi layar sebagai background
    final double circleSize = MediaQuery.of(context).size.width * 2;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Warna Dasar Halaman (Animasi Warna)
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            color: _pages[_currentPage]['baseColor'],
          ),

          // 2. Ornamen Lingkaran Raksasa (Animasi Posisi dan Warna)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            left: _pages[_currentPage]['circleLeft'],
            top: _pages[_currentPage]['circleTop'],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: _pages[_currentPage]['circleColor'],
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. PageView Utama untuk Gambar dan Konten (jika ada text)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.asset(
                    _pages[index]['image'],
                    // Membatasi tinggi gambar maksimal 400 pixel atau lebar 80% layar
                    height: MediaQuery.of(context).size.height * 0.5, 
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // 4. Lapisan UI Navigasi (Indikator & Tombol Next/Back)
          Positioned(
            bottom: 50,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indikator Titik
                Row(
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                // Tombol Navigasi
                Row(
                  children: [
                    // Tombol Back (tidak muncul di halaman pertama)
                    if (_currentPage > 0)
                      GestureDetector(
                        onTap: _prevPage,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16), // Rounded seperti di figma
                          ),
                          child: const Icon(Icons.chevron_left,
                              color: Colors.black, size: 28),
                        ),
                      ),
                    
                    if (_currentPage > 0) const SizedBox(width: 12),
                    
                    // Tombol Next (muncul di semua halaman)
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.chevron_right,
                            color: Colors.black, size: 28),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
