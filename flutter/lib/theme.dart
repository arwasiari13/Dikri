import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF3EFE7);
  static const bg2 = Color(0xFFECE6D9);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1F2A26);
  static const ink2 = Color(0xFF5C6661);
  static const ink3 = Color(0xFF9AA29C);
  static const sage = Color(0xFF3F6253);
  static const sage2 = Color(0xFF2B4438);
  static const sageSoft = Color(0xFFE7EFEA);
  static const brass = Color(0xFFB89763);
  static const line = Color(0x141F2A26);
  static const lineLight = Color(0x0A1F2A26);
  static const creamText = Color(0xFFF6F2E9);
}

class AppFonts {
  static TextStyle kufi({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double spacing = 0,
    double? height,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height,
      );

  static TextStyle arabic({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double spacing = 0,
    double? height,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height,
      );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.sage,
          surface: AppColors.bg,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        useMaterial3: true,
      );
}
