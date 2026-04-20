import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:girantra/services/auth_service_fixed.dart'; // Sesuaikan package name

void main() {
  // 1. Inisialisasi Supabase khusus untuk testing
  setUpAll(() async {
    // Supabase menggunakan shared_preferences di balik layar. 
    // Saat unit test, kita perlu mock shared_preferences agar tidak error.
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(  
      url: 'https://kjzqnftqkhssnugqybak.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtqenFuZnRxa2hzc251Z3F5YmFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0Nzk3MzksImV4cCI6MjA4OTA1NTczOX0.MzLlosXvt4swcY5kbhyQYtGJfJNDIZEyKkUCBLYoqWw',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
  });

  test('Mencoba Sign Up Tanpa UI', () async {
    final authService = AuthService();

    // 2. Jalankan method yang ingin dites
    final user = await authService.signUp(
      full_name: "Budi Petani",
      email: "budi.test${DateTime.now().millisecondsSinceEpoch}@gmail.com", // Email unik tiap tes
      password: "password123",
      phone_number: "08123456789",
      address: "Boyolali",
      role: "seller",
      account_status: "active",
    );

    // 3. Cek hasilnya (Assertion)
    expect(user, isNotNull); // Tes lulus jika user tidak null
    print('✅ Berhasil daftar! ID User: ${user?.id}');
  });
}