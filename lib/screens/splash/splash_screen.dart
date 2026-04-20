import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:girantra/screens/onboarding/onboarding_screen.dart';
import 'package:girantra/screens/onboarding/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      await _checkSessionAndNavigate();
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString('last_active_time');

    bool isTimeout = false;
    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      final difference = DateTime.now().difference(lastActive);
      // Timeout 15 menit
      if (difference.inMinutes >= 15) {
        isTimeout = true;
      }
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      if (isTimeout) {
        // Token kedaluwarsa, hapus session dan paksa login ulang
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      } else {
        // Token valid, langsung Bypass Onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    } else {
      // Sama sekali belum login, langsung ke Onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
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
