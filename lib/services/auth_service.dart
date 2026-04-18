import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  // ========== SIGN IN ==========
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('Sign in berhasil!');
      return response.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // ========== SIGN UP (FIXED) ==========
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
      // STEP 1: Validasi email terlebih dahulu ke tabel users
      print('Checking if email already exists...');
      try {
        final existingUser = await supabase
            .from('users')
            .select('email')
            .eq('email', email)
            .maybeSingle();

        if (existingUser != null) {
          throw Exception(
            'Email sudah terdaftar. Silakan gunakan email lain atau login.',
          );
        }
      } catch (e) {
        if (e.toString().contains('Email sudah terdaftar')) {
          rethrow;
        }
        // Pengecualian lain seperti RLS diabaikan agar tetap mencoba auth.signUp()
      }

      // STEP 2: Create user di Supabase Auth
      print('Creating auth user...');
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

      // STEP 3: Check if user berhasil dibuat
      if (response.user == null) {
        throw Exception('Gagal membuat user di Supabase Auth');
      }

      // STEP 4: Cek identities untuk deteksi user sudah ada
      if (response.user!.identities != null &&
          response.user!.identities!.isEmpty) {
        throw Exception(
          'Email sudah terdaftar. Silakan gunakan email lain atau login.',
        );
      }

      // STEP 5: Insert user data ke public.users table
      print('Inserting user data to database...');
      try {
        await supabase.from('users').insert({
          'user_id': response.user!.id,
          'full_name': full_name,
          'email': email,
          'phone_number': phone_number,
          'address': address,
          'role': role,
          'account_status': account_status,
          // created_at dan updated_at akan otomatis dari DEFAULT now()
        });
        print('User data berhasil disimpan ke database!');
      } catch (e) {
        print('Gagal insert ke users table: $e');
        // Lempar error agar caller tahu ada masalah
        rethrow;
      }

      return response.user;
    } catch (e) {
      print('Error dalam signUp: $e');
      rethrow; // Lempar ke caller untuk handling
    }
  }

  // ========== SIGN OUT ==========
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print('Sign out berhasil!');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // ========== GET CURRENT USER ==========
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // ========== CHECK IF LOGGED IN ==========
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  // ========== RESET PASSWORD ==========
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      print('Reset password email sent!');
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // ========== UPDATE USER PROFILE ==========
  Future<void> updateProfile({
    required String full_name,
    String? phone_number,
    String? address,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await supabase
          .from('users')
          .update({
            'full_name': full_name,
            if (phone_number != null) 'phone_number': phone_number,
            if (address != null) 'address': address,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);

      print('Profile updated successfully!');
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // ========== GET USER PROFILE ==========
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final data = await supabase
          .from('users')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      return data;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}
