import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Medical Blue Theme
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);

  // Secondary Colors - Medical Green Theme
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF005B4F);

  // Accent Colors
  static const Color accent = Color(0xFF26A69A);
  static const Color accentLight = Color(0xFF64D8CB);
  static const Color accentDark = Color(0xFF00766C);

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Application Status Colors
  static const Color statusDraft = Color(0xFF9E9E9E);
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusUnderReview = Color(0xFF2196F3);
  static const Color statusApproved = Color(0xFF4CAF50);
  static const Color statusRejected = Color(0xFFF44336);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  static const Color divider = Color(0xFFEEEEEE);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Color
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
}