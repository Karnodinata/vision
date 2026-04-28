import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart'; // ← uncomment ini

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Maukkan URL dan Anon Key Anda di sini
  await Supabase.initialize(
    url:
        'https://keginmdkkgtvaxchtjug.supabase.co', // Gunakan URL dari screenshot Anda
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtlZ2lubWRra2d0dmF4Y2h0anVnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1ODkwOTEsImV4cCI6MjA4NzE2NTA5MX0.KGiNU8S1oLpJ1fep8p9uqVTFg0OwPRvxduGqzHLz3BU', // Masukkan Anon Key Anda
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    return MaterialApp(
      title: 'V.I.S.I.O.N Awdy Farm',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Arahkan ke DashboardScreen jika session ada, LoginScreen jika tidak
      home: session != null
          ? const DashboardScreen() // ← ganti placeholder dengan ini
          : const LoginScreen(),
    );
  }
}
