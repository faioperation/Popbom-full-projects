import 'package:flutter/material.dart';

class AppColors {
  // Common Brand Colors
  static const Color primary = Color(0xFF22D36B);
  static const Color secondary = Color(0xFF6DF844);
  static const Color accent = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);

  // Light Colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightText = Colors.black;
  static const Color lightHint = Color(0xFF8E8E8E);

  // Dark Colors
  static const Color darkBackground = Color(0xFF0E0E0E);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
  static const Color darkHint = Color(0xFFAAAAAA);

  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF22D36B), Color(0xFF6DF844)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF22D36B), Color(0xFF00E676)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0E0E0E), Color(0xFF1E1E1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
