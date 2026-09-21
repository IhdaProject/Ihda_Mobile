import 'package:flutter/material.dart';

/// Placeholder palette (deep teal / gold, common for prayer-time apps).
/// Replace with exact Figma tokens once you export them - this file is the
/// single place all screens pull colors from.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF14B8A6); // Vibrant teal from design
  static const Color primaryDark = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color accent = Color(0xFFF59E0B); // Gold/Amber accent

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Colors.white;

  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color divider = Color(0xFFE2E8F0);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient waveGradient = LinearGradient(
    colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
