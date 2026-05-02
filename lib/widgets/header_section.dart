import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';

class LocationHeaderAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const LocationHeaderAppBar({super.key, required this.title, this.actions});

  @override
  State<LocationHeaderAppBar> createState() => _LocationHeaderAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LocationHeaderAppBarState extends State<LocationHeaderAppBar> {
  String _userAddress = '';
  String _userName = '';
  bool _isLoading = true;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      if (mounted) _loadUserData();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('full_name, address')
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _userName = data?['full_name'] ?? '';
        _userAddress = data?['address'] ?? 'Alamat belum diatur';
        _isLoading = false;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      titleSpacing: 16,
      title: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo_girantra.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.eco_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label kecil
                const Text(
                  'Lokasi Pengiriman',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                // Alamat
                _isLoading
                    ? Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                    : Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.accent,
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              _userAddress.isNotEmpty
                                  ? _userAddress
                                  : 'Atur lokasi Anda',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B1B1B),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Color(0xFF9E9E9E),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
      actions: widget.actions,
    );
  }
}
