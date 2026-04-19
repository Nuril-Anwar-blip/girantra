import 'package:flutter/material.dart';
import 'package:girantra/screens/buyer/cart_screen.dart';
import 'package:girantra/screens/buyer/like_screen.dart';
import 'package:girantra/screens/auth/register_screen.dart';
import 'package:girantra/screens/seller/register_seller_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLoading = true;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildProfileCard(context),
                      const SizedBox(height: 16),
                      _buildHistoryCard(context),
                      const SizedBox(height: 16),
                      _buildActivityCard(context),
                      const SizedBox(height: 16),
                      _buildSellerRegister(context),
                      const Spacer(),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (userData != null && mounted) {
          setState(() {
            _nameController.text = userData['full_name'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _avatarUrl = '${Supabase.instance.client.storage.from('avatars').getPublicUrl('${user.id}/profile.jpg')}?t=${DateTime.now().millisecondsSinceEpoch}';
            _isLoading = false;
          });
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
        )
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.mutedText, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.subtitle,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Profil Singkat'),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                    ? Image.network(
                        _avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, size: 28, color: Colors.grey[400]),
                      )
                    : Icon(Icons.person, size: 28, color: Colors.grey[400]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isNotEmpty ? _nameController.text : 'User',
                      style: AppTextStyles.productName,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _emailController.text.isNotEmpty ? _emailController.text : 'Belum ada email',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuItem(Icons.edit_outlined, 'Edit Profile', () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
            setState(() {
              _isLoading = true;
            });
            _fetchUserData();
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Riwayat'),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.receipt_long_outlined, 'Riwayat Transaksi', () {}),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Aktivitas Saya'),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.shopping_cart_outlined, 'Keranjang Saya', () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            }),
          const SizedBox(height: 8),
          _buildMenuItem(Icons.favorite, 'Favorit Saya', () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LikeScreen(),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSellerRegister(BuildContext context){
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Daftar Menjadi Penjual'),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.storefront, 'Daftar Menjadi Penjual', () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegisterSellerScreen(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
              final session = Supabase.instance.client.auth.currentSession;
              final authService = AuthService();

              if (session == null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
                return;
              }
              await authService.signOut();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }
}
