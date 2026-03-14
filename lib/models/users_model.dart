import 'package:supabase_flutter/supabase_flutter.dart';

class UsersModel {
  static final supabase = Supabase.instance.client;

  // Fungsi untuk mengambil data dan mengecek koneksi
  static Future<void> testConnectionAndFetchUsers() async {
    try {
      // Mengambil data dari tabel 'users'
      final data = await supabase.from('users').select();
      print('📦 Data Users: $data');
    } catch (e) {
      print('❌ ERROR: $e');
    }
  }
}