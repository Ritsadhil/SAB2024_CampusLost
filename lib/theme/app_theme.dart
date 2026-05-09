import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1D3EAC);
  static const Color primaryLight = Color(0xFF4A6FD4);
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8A8A9A);
  static const Color inputBorder = Color(0xFFE0E0E8);
  static const Color inputFill = Color(0xFFF8F8FC);

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          background: background,
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: background,
        useMaterial3: true,
      );
}
