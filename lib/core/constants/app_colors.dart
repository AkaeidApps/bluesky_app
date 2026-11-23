import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Bluesky-inspired Sky Blue & Butterfly Gradients)
  static const Color primary = Color(0xFF0085FF);
  static const Color primaryDark = Color(0xFF0066CC);
  static const Color primaryLight = Color(0xFF4DA6FF);
  static const Color primarySurfaceLight = Color(0xFFE8F3FF);
  static const Color primarySurfaceDark = Color(0xFF13283E);

  // Secondary Accents
  static const Color accentCyan = Color(0xFF00C2FF);
  static const Color accentIndigo = Color(0xFF5856D6);

  // Social Interaction Colors
  static const Color like = Color(0xFFE0245E);
  static const Color likeSurface = Color(0xFFFDE8EF);
  static const Color repost = Color(0xFF00BA7C);
  static const Color repostSurface = Color(0xFFE6F8F2);
  static const Color reply = Color(0xFF0085FF);
  static const Color bookmark = Color(0xFF7856FF);

  // Neutrals - Light Theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightSurfaceHover = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFEEF2F6);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Neutrals - Dark Theme (Deep Navy-Slate)
  static const Color darkBackground = Color(0xFF0F141C);
  static const Color darkSurface = Color(0xFF182230);
  static const Color darkSurfaceHover = Color(0xFF222F42);
  static const Color darkBorder = Color(0xFF283648);
  static const Color darkDivider = Color(0xFF1E2A38);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Badges & Moderation
  static const Color verifiedBadge = Color(0xFF0085FF);
  static const Color warningBadge = Color(0xFFFEF3C7);
  static const Color warningBadgeText = Color(0xFF92400E);
  static const Color adultBadge = Color(0xFFFEE2E2);
  static const Color adultBadgeText = Color(0xFF991B1B);

  // Butterfly Brand Gradient
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF00C2FF), Color(0xFF0085FF), Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
