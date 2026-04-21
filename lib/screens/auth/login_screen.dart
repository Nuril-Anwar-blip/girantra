import 'package:flutter/material.dart';

import '../../services/auth_service_fixed.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../ui/app_widgets.dart';
import '../register_screen_fixed_v2.dart';
import '../navigation/buyer_navigation.dart'; 
import '../navigation/seller_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = await _authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    String? role;
    if (user != null) {
      role = await _authService.getUserRole(user.id);
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (user != null) {
      if (role == 'seller') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SellerNavigation()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal, periksa email/password.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 12,
              child: Image.asset(
                'assets/images/logo_girantra.png',
                width: 44,
                height: 44,
              ),
            ),
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/loading_img_3.png',
                  width: 260,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: RoundedWhiteSheet(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Hello!', style: AppTextStyles.h1),
                                  SizedBox(height: 4),
                                  Text(
                                    'Welcome to Girantra',
                                    style: AppTextStyles.subtitle,
                                  ),
                                ],
                              ),
                              Text(
                                'Login',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _emailController,
                            decoration: authFieldDecoration(
                              hint: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Wajib diisi';
                              }
                              if (!v.contains('@')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            decoration: authFieldDecoration(
                              hint: 'Password',
                              icon: Icons.lock_outline,
                            ),
                            obscureText: true,
                            validator: (v) => v != null && v.length >= 6
                                ? null
                                : 'Masukkan Password',
                          ),
                          const SizedBox(height: 2),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryDark,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {},
                              child: Text(
                                'Forgot Password',
                                style: AppTextStyles.link.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w500,
                                ),  
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          PrimaryPillButton(
                            text: 'Login',
                            isLoading: _isLoading,
                            onPressed: _onLogin,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.divider,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'or login with',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.divider,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: const Center(
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account? ',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.mutedText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Register',
                                  style: AppTextStyles.link.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w500,
                                  )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
