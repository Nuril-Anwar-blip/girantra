import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  final supabase = Supabase.instance.client;
  try {
    final res = await supabase.from('carts').select().limit(1);
    print('Carts table query successful: $res');
  } catch (e) {
    print('Error: $e');
  }
}
