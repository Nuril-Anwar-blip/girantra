import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';

class LocationHeaderAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const LocationHeaderAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  State<LocationHeaderAppBar> createState() => _LocationHeaderAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LocationHeaderAppBarState extends State<LocationHeaderAppBar> {
  String _userAddress = 'Memuat...';
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) _loadUserAddress();
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
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
          if (mounted) setState(() => _userAddress = data['address']);
        } else {
          if (mounted) setState(() => _userAddress = 'Alamat tidak diatur');
        }
      } catch (e) {
        if (mounted) setState(() => _userAddress = 'Gagal memuat alamat');
      }
    } else {
      if (mounted) setState(() => _userAddress = 'Belum login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/images/logo_girantra.png', width: 40, height: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyles.subtitle),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _userAddress,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
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
      actions: widget.actions,
    );
  }
}
