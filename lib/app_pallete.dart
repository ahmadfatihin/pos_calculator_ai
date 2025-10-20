import 'package:flutter/material.dart';

/// App-wide color tokens so the UI looks consistent.
class AppPalette {
  // Greens (from dark -> light)
  static const green900 = Color(0xFF1B5E20);
  static const green800 = Color(0xFF2E7D32);
  static const green600 = Color(0xFF43A047);
  static const green400 = Color(0xFF66BB6A);

  // Neutrals
  static const bg = Color(0xFFF7F7F8);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF17202A);
  static const textMuted = Color(0xFF7D8790);

  // Accents
  static const danger = Color(0xFFEF5350);

  // Header gradient
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green900, green800, green600],
  );

  // Soft shadow used across cards
  static List<BoxShadow> shadow = [
    BoxShadow(
      color: Colors.black.withOpacity(.06),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];
}
