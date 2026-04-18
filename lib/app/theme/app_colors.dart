import 'package:flutter/material.dart';

class AppColors {
  // ── Static current (updated by app.dart on every theme change) ────────────
  static AppColors _current = AppColors.light;
  static AppColors get current => _current;
  static void setCurrent(AppColors c) => _current = c;

  // ── Instance properties ───────────────────────────────────────────────────

  final Brightness brightness;

  // Theme-dependent
  final Color background;
  final Color card;
  final Color border;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  // Accents & semantic
  final Color primary;
  final Color primaryLight;
  final Color success;
  final Color successLight;
  final Color warning;
  final Color error;
  final Color purple;
  final Color purpleLight;
  final Color indigo;
  final Color sky;
  final Color orange;
  final Color teal;

  // Neutrals
  final Color white;
  final Color gray100;
  final Color gray300;
  final Color gray400;
  final Color gray500;
  final Color gray700;
  final Color gray900;

  const AppColors({
    required this.brightness,
    required this.background,
    required this.card,
    required this.border,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.primaryLight,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.error,
    required this.purple,
    required this.purpleLight,
    required this.indigo,
    required this.sky,
    required this.orange,
    required this.teal,
    required this.white,
    required this.gray100,
    required this.gray300,
    required this.gray400,
    required this.gray500,
    required this.gray700,
    required this.gray900,
  });

  bool get isDark => brightness == Brightness.dark;

  // ── Palettes ──────────────────────────────────────────────────────────────

  static const AppColors light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFFFFFFF),
    card: Color(0xFFF4F4F4),
    border: Color(0xFFE5E5E5),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF20242A),
    textSecondary: Color(0x9920242A),
    primary: Color(0xFF008CFF),
    primaryLight: Color(0xFFEFF6FF),
    success: Color(0xFF00C853),
    successLight: Color(0xFFECFDF5),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFFF5252),
    purple: Color(0xFF8B5CF6),
    purpleLight: Color(0xFFF5F3FF),
    indigo: Color(0xFF6366F1),
    sky: Color(0xFF0EA5E9),
    orange: Color(0xFFF97316),
    teal: Color(0xFF14B8A6),
    white: Color(0xFFFFFFFF),
    gray100: Color(0xFFF3F4F6),
    gray300: Color(0xFFD1D5DB),
    gray400: Color(0xFF9CA3AF),
    gray500: Color(0xFF6B7280),
    gray700: Color(0xFF374151),
    gray900: Color(0xFF111827),
  );

  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF191C20),
    card: Color(0xFF2B3038),
    border: Color(0xFF333842),
    surface: Color(0xFF1E293B),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xB3FFFFFF),
    primary: Color(0xFF008CFF),
    primaryLight: Color(0xFFEFF6FF),
    success: Color(0xFF00C853),
    successLight: Color(0xFFECFDF5),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFFF5252),
    purple: Color(0xFF8B5CF6),
    purpleLight: Color(0xFFF5F3FF),
    indigo: Color(0xFF6366F1),
    sky: Color(0xFF0EA5E9),
    orange: Color(0xFFF97316),
    teal: Color(0xFF14B8A6),
    white: Color(0xFFFFFFFF),
    gray100: Color(0xFFF3F4F6),
    gray300: Color(0xFFD1D5DB),
    gray400: Color(0xFF9CA3AF),
    gray500: Color(0xFF6B7280),
    gray700: Color(0xFF374151),
    gray900: Color(0xFF111827),
  );
}
