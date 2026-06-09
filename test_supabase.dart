import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final client = Supabase.instance.client;

  try {
    final response = await client
        .from('transactions')
        .select('*, products (*), logistics (*)')
        .limit(1);
    print("Success: $response");
  } catch (e) {
    print("Error: $e");
  }
}
