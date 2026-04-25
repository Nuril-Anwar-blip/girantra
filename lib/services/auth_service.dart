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
      if (response.user != null) {
        print('✅ Login berhasil! User ID: ${response.user!.id}');
      }
      return response.user;
    } catch (e) {
      print('❌ Error signing in: $e');
      rethrow;
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

    try {
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
          print('✅ Data user berhasil disimpan ke tabel users');
        } catch (e) {
          print('Gagal memasukkan data ke tabel users: $e');
          // Error tidak dilempar agar user tetap berhasil terbuat di auth.users
        }
      }

      return response.user;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      if (e.message.contains('already registered')) {
        throw Exception('Email sudah terdaftar. Silakan gunakan email lain atau login.');
      } else if (e.message.contains('Password')) {
        throw Exception('Password minimal 6 karakter');
      }
      rethrow;
    } catch (e) {
      print('❌ Unexpected error during signup: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print('✅ Sign out berhasil!');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
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
      print('✅ Reset password berhasil! Cek email Anda.');
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // Get user role
  Future<String> getUserRole(String userId) async {
    try {
      final data = await supabase
          .from('users')
          .select('role')
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null && data['role'] != null) {
        return data['role'] as String;
      }
      return 'buyer'; // default fallback
    } catch (e) {
      print('Error getting user role: $e');
      return 'buyer';
    }
  }

  // Update user profile (email & password bukan bisa diubah di sini)
  Future<bool> updateUserProfile({
    required String full_name,
    required String phone_number,
    required String address,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak login');

      await supabase
          .from('users')
          .update({
            'full_name': full_name,
            'phone_number': phone_number,
            'address': address,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ Profile berhasil diupdate!');
      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }

  // Get user profile dari tabel users
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }
}
