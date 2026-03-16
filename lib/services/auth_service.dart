import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  // Sign In with Email and Password
  Future<User?> signInWithEmailPassword(String email, String password) async {
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
  Future<User?> signUpWithEmailPassword({
  required String full_name,
  required String email,
  required String password,
  required String phone_number,
  required String address,
  required String role,
  required String account_status,
}) async {
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

    return response.user;
  } catch (e) {
    print('Error signing up: $e');
    return null;
  }
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
      await supabase.from('users').update({
        'name': name,
        'email': email,
      }).eq('id', supabase.auth.currentUser!.id);
      print('✅ Update profile berhasil!');
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
}