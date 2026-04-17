import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:girantra/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveLastActiveTime();
    } else if (state == AppLifecycleState.resumed) {
      _checkTimeoutOnResume();
    }
  }

  Future<void> _saveLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_active_time', DateTime.now().toIso8601String());
  }

  Future<void> _checkTimeoutOnResume() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString('last_active_time');
    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      final difference = DateTime.now().difference(lastActive);
      // Timeout 15 menit
      if (difference.inMinutes >= 15) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          await Supabase.instance.client.auth.signOut();
        }
      }
    }
  }

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Girantra',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}