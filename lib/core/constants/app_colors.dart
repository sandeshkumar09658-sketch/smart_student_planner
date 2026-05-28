import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9D6BFF);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color secondary = Color(0xFF06D6A0);
  static const Color secondaryLight = Color(0xFF3BE0B0);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);

  // Urgency
  static const Color urgent = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color calm = Color(0xFF3B82F6);
  static const Color done = Color(0xFF06D6A0);

  // Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF12121F);
  static const Color cardLight = Color(0xFFF8F9FF);
  static const Color cardDark = Color(0xFF1C1C2E);
  static const Color bgLight = Color(0xFFF0EFFF);
  static const Color bgDark = Color(0xFF0A0A0F);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Glass effects
  static Color glassLight = Colors.white.withValues(alpha: 0.7);
  static Color glassDark = const Color(0xFF1E1E2E).withValues(alpha: 0.8);
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.3);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.18);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
