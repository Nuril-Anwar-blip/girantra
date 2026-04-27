import 'package:flutter/material.dart';
import 'package:girantra/screens/onboarding/auth_gate.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';
import '../ui/app_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _emailErrorMessage;

  Future<void> _onRegister() async {
    setState(() => _emailErrorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        full_name: _fullNameController.text.trim(),
        phone_number: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        role: 'buyer',
        account_status: 'active',
      );

      if (!mounted) return;

      if (user != null) {
        print('✅ Registrasi berhasil! User ID: ${user.id}');

        // Navigasi ke AuthGate - akan auto-detect session dan masuk ke Home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      } else {
        // User terbuat tapi mungkin email verification diaktifkan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Registrasi berhasil!\nSilakan cek email untuk verifikasi akun.',
            ),
            duration: Duration(seconds: 3),
          ),
        );

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthGate()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error: $e');

      if (!mounted) return;

      String errorMsg = e.toString();

      if (errorMsg.contains('already registered') ||
          errorMsg.contains('Email sudah')) {
        setState(() => _emailErrorMessage = 'Email sudah terdaftar');
        _formKey.currentState!.validate();
      } else if (errorMsg.contains('Password')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password minimal 6 karakter'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi gagal: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
                                    'welcome to Girantra',
                                    style: AppTextStyles.subtitle,
                                  ),
                                ],
                              ),
                              Text(
                                'Register',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Full Name Field
                          TextFormField(
                            controller: _fullNameController,
                            decoration: authFieldDecoration(
                              hint: 'Full Name',
                              icon: Icons.person_outline,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Nama lengkap wajib diisi';
                              }
                              if (v.length < 3) {
                                return 'Nama minimal 3 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Phone Field
                          TextFormField(
                            controller: _phoneController,
                            decoration: authFieldDecoration(
                              hint: 'Phone Number',
                              icon: Icons.call_outlined,
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Nomor telepon wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Address Field
                          TextFormField(
                            controller: _addressController,
                            decoration: authFieldDecoration(
                              hint: 'Address',
                              icon: Icons.location_on_outlined,
                            ),
                            maxLines: 2,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Alamat wajib diisi';
                              }
                              if (v.length < 10) {
                                return 'Alamat terlalu pendek';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: authFieldDecoration(
                              hint: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (v) {
                              if (_emailErrorMessage != null) {
                                setState(() => _emailErrorMessage = null);
                                _formKey.currentState!.validate();
                              }
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Email wajib diisi';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+$',
                              ).hasMatch(v)) {
                                return 'Format email tidak valid';
                              }
                              if (_emailErrorMessage != null) {
                                return _emailErrorMessage;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            decoration: authFieldDecoration(
                              hint: 'Password',
                              icon: Icons.lock_outline,
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              if (v.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Register Button
                          PrimaryPillButton(
                            text: 'Register',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _onRegister,
                          ),

                          const SizedBox(height: 12),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.mutedText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Login',
                                  style: AppTextStyles.link.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
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
