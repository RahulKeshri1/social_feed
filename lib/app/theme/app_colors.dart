import 'package:flutter/material.dart';

/// Curated color palette for the Social Feed app.
/// Uses HSL-based harmonious colors for a premium dark-mode look.
abstract final class AppColors {
  // ── Primary ──
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // ── Accent ──
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF8FA5);

  // ── Surfaces (Dark Mode) ──
  static const Color scaffoldDark = Color(0xFF0D0D12);
  static const Color cardDark = Color(0xFF1A1A2E);
  static const Color cardDarkElevated = Color(0xFF222240);
  static const Color surfaceDark = Color(0xFF16162A);

  // ── Surfaces (Light Mode) ──
  static const Color scaffoldLight = Color(0xFFF5F5FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF0F0F8);

  // ── Text ──
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF9090A8);
  static const Color textTertiary = Color(0xFF606078);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textDarkSecondary = Color(0xFF606078);

  // ── Status ──
  static const Color liked = Color(0xFFFF3B5C);
  static const Color likedGlow = Color(0x40FF3B5C);
  static const Color success = Color(0xFF00C48C);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFBE21);

  // ── Shadow ──
  static const Color shadowDark = Color(0xFF000000);
  static const Color shadowPrimary = Color(0x306C63FF);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF8B5CF6)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardDark, Color(0xFF1E1E38)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF2A2A48),
      Color(0xFF1A1A2E),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
