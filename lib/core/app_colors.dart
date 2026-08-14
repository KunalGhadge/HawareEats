import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary (HawareEats Signature Tomato / Coral Orange)
  static const Color primary = Color(0xFFFF6347);
  static const Color primaryDark = Color(0xFFE85A41);
  static const Color primaryLight = Color(0xFFFF9684);
  static const Color primarySoft = Color(0xFFFFF0ED);

  // Indicators & Badges
  static const Color indicatorActive = Color(0xFFFF826C);
  static const Color indicatorInactive = Color(0xFFFFCFC6);
  static const Color accentYellow = Color(0xFFFFB800);
  static const Color starYellow = Color(0xFFFFC107);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
  static const Color infoBlue = Color(0xFF2196F3);

  // Neutrals & Surfaces
  static const Color backgroundLight = Color(0xFFF9F8F4);
  static const Color surfaceWhite = Colors.white;
  static const Color cardBorder = Color(0xFFF0F0F0);
  static const Color inputBackground = Color(0xFFF8F9FA);

  // Typography
  static const Color textDark = Color(0xFF0D1217);
  static const Color textMuted = Color(0xFF989DA3);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Shadow
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x0F0D0A2C),
    blurRadius: 12,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}
