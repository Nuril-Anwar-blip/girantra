import 'package:flutter/material.dart';

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

    if (!mounted) return;

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
        Navigator.of(context).pop();
      } else {
        // Sering terjadi kalau Supabase butuh email verification:
        // user bisa dibuat tapi session belum aktif.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registrasi berhasil. Silakan cek email untuk verifikasi.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11); // Menghapus tulisan "Exception: " agar lebih rapi
      }
      
      if (errorMsg.contains('Email sudah terdaftar')) {
        setState(() => _emailErrorMessage = errorMsg);
        _formKey.currentState!.validate(); // Trigger ulang validasi untuk menampilkan error di textbox
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registrasi gagal: $errorMsg')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                              const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fullNameController,
                            decoration: authFieldDecoration(
                              hint: 'Full Name',
                              icon: Icons.person_outline,
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _phoneController,
                            decoration: authFieldDecoration(
                              hint: 'Phone Number',
                              icon: Icons.call_outlined,
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _addressController,
                            decoration: authFieldDecoration(
                              hint: 'Address',
                              icon: Icons.location_on_outlined,
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 10),
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
                              if (v == null || v.isEmpty) return 'Wajib diisi';
                              if (_emailErrorMessage != null) return _emailErrorMessage;
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            decoration: authFieldDecoration(
                              hint: 'Password',
                              icon: Icons.lock_outline,
                            ),
                            obscureText: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Wajib diisi';
                              if (v.length < 6) return 'Minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          PrimaryPillButton(
                            text: 'Register',
                            isLoading: _isLoading,
                            onPressed: _onRegister,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Login',
                                  style: AppTextStyles.link,
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
