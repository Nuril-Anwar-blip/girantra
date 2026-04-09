import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  // Sign In with Email and Password
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign Up with Email, Password, and additional fields
  Future<User?> signUp({
    required String full_name,
    required String email,
    required String password,
    required String phone_number,
    required String address,
    required String role,
    required String account_status,
  }) async {
    // 1. Validasi email terlebih dahulu ke tabel users (jika role anon bisa baca)
    try {
      final existingUser = await supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Email sudah terdaftar. Silakan gunakan email lain atau login.');
      }
    } catch (e) {
      if (e.toString().contains('Email sudah terdaftar')) {
        rethrow;
      }
      // Pengecualian lain seperti RLS diabaikan agar tetap mencoba auth.signUp()
    }

    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': full_name,
        'phone_number': phone_number,
        'address': address,
        'role': role,
        'account_status': account_status,
      },
    );

    // Proteksi tambahan: jika identities kosong, artinya user sudah ada namun proteksi enumerasi aktif
    if (response.user != null &&
        response.user!.identities != null &&
        response.user!.identities!.isEmpty) {
      throw Exception('Email sudah terdaftar. Silakan gunakan email lain atau login.');
    }

    // Memasukkan data tambahan ke tabel 'users' di public schema
    if (response.user != null) {
      try {
        await supabase.from('users').insert({
          'user_id': response.user!.id,
          'full_name': full_name,
          'email': email,
          'phone_number': phone_number,
          'address': address,
          'role': role,
          'account_status': account_status,
        });
      } catch (e) {
        print('Gagal memasukkan data ke tabel users: $e');
        // Error tidak dilempar agar user tetap berhasil terbuat di auth.users
        // (meskipun disarankan memantaunya lewat log terminal)
      }
    }

    // Kalau email confirmation aktif, biasanya session/user bisa null tergantung setting.
    // Maka UI akan menampilkan pesan yang sesuai saat `user == null`.
    return response.user;
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print('✅ Sign out berhasil!');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      print('✅ Reset password berhasil!');
    } catch (e) {
      print('Error resetting password: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile(String name, String email) async {
    try {
      await supabase
          .from('users')
          .update({'name': name, 'email': email})
          .eq('id', supabase.auth.currentUser!.id);
      print('✅ Update profile berhasil!');
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
}
