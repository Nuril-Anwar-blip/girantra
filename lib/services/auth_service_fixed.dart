import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  /// Sign In dengan Email dan Password
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
      rethrow; // Lempar error agar bisa ditangani di UI
    }
  }

  /// Sign Up dengan Email, Password, dan data tambahan
  /// PENTING: Pastikan Supabase RLS policy sudah dikonfigurasi dengan benar
  Future<User?> signUp({
    required String full_name,
    required String email,
    required String password,
    required String phone_number,
    required String address,
    required String role,
    required String account_status,
  }) async {
    try {
      // Step 1: Coba sign up ke auth.users (dibuat oleh Supabase secara otomatis)
      print('📝 Proses sign up untuk email: $email');
      
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

      final user = response.user;
      
      if (user == null) {
        throw Exception('Sign up gagal: User tidak terbuat');
      }

      print('✅ User auth terbuat: ${user.id}');

      // Step 2: Insert data ke tabel 'users' (dengan RLS policy yang tepat)
      try {
        await supabase.from('users').insert({
          'user_id': user.id,
          'full_name': full_name,
          'email': email,
          'phone_number': phone_number,
          'address': address,
          'role': role,
          'account_status': account_status,
        });
        
        print('✅ Data user berhasil disimpan ke tabel users');
      } catch (e) {
        // Jika insert ke users gagal, session tetap valid tapi data belum lengkap
        print('⚠️ Insert ke users gagal: $e');
        print('⚠️ User auth sudah terbuat, tapi data di tabel users belum lengkap');
        
        // Jangan throw error, user tetap bisa login
        // Tapi log untuk monitoring
      }

      return user;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      
      // Handle error message yang lebih friendly
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

  /// Sign Out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print('✅ Sign out berhasil!');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      print('✅ Reset password berhasil! Cek email Anda.');
    } catch (e) {
      print('❌ Error resetting password: $e');
      rethrow;
    }
  }

  /// Update user profile (email & password bukan bisa diubah di sini)
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

  /// Get user profile dari tabel users
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