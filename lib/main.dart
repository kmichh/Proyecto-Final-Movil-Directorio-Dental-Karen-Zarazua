import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_theme.dart';
import 'package:directorio_dental/features/auth/screens/auth_check_screen.dart';

void main() {
  runApp(const DirectorioDentalApp());
}

class DirectorioDentalApp extends StatelessWidget {
  const DirectorioDentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directorio Dental',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthCheckScreen(),
    );
  }
}
