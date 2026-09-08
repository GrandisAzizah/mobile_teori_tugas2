import 'package:flutter/material.dart';

import 'theme/app_theme.dart'; // Untuk mengimport tema
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Program Aplikasi Kalkulator',
      theme: AppTheme.light(), // Nama tema yang kita buat
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      home: const LoginScreen(),
    );
  }
}
