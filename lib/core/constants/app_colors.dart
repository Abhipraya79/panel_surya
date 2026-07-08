import 'package:flutter/material.dart';

/// Centralized color system for Panel Care premium pink theme.
/// All colors follow Material Design 3 principles.
class AppColors {
  AppColors._();

  // ─── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE91E63);       // Pink 600
  static const Color primaryDark = Color(0xFFC2185B);   // Pink 700
  static const Color primaryLight = Color(0xFFF8BBD0);  // Pink 100
  static const Color primaryContainer = Color(0xFFFFE0EC); // Pink 50
  static const Color accent = Color(0xFFFF4081);         // Pink Accent 400

  // ─── Background & Surface ──────────────────────────────────────────────────
  static const Color background = Color(0xFFFFF8FB);    // Warm pinkish white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFCECF1);
  static const Color card = Color(0xFFFFFFFF);

  // ─── Semantic Colors ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color danger = Color(0xFFF44336);
  static const Color dangerLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ─── Sensor-specific accent colors ─────────────────────────────────────────
  static const Color tempPanel = Color(0xFFFF6B35);   // Orange for panel heat
  static const Color tempWater = Color(0xFF29B6F6);   // Light blue for water
  static const Color dustColor = Color(0xFFBCAAA4);   // Brownish for dust
  static const Color voltageColor = Color(0xFFFFCA28); // Yellow for voltage
  static const Color currentColor = Color(0xFF66BB6A); // Green for current
  static const Color powerColor = Color(0xFFAB47BC);   // Purple for power

  // ─── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Borders & Dividers ────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFF0D0DA);
  static const Color borderFocused = Color(0xFFE91E63);

  // ─── Icon Colors ───────────────────────────────────────────────────────────
  static const Color iconPrimary = Color(0xFFE91E63);
  static const Color iconMuted = Color(0xFFBDBDBD);
  static const Color iconLight = Color(0xFFFFFFFF);

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF0F5), Color(0xFFFCE4EC)],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0), Color(0xFFE91E63)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF0F5)],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF4CAF50)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFFC107)],
  );
}
