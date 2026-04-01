import 'package:flutter/material.dart';
import 'package:girantra/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32), // Background hex #2E7D32
      body: Center(
        child: Image.asset(
          'assets/images/logo_girantra.png', // Make sure to place logo.png in this folder
          width: 150,
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if logo.png is not yet added
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'assets/images/logo_girantra.png\nbelum ditemukan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
