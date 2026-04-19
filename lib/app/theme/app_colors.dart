import 'package:flutter/material.dart';

class AppColors {
  // ── Static current (updated by app.dart on every theme change) ────────────
  static AppColors _current = AppColors.light;
  static AppColors get current => _current;
  static void setCurrent(AppColors c) => _current = c;

  // ── Instance properties ───────────────────────────────────────────────────

  final Brightness brightness;

  // Theme-dependent surfaces
  final Color background;
  final Color card;
  final Color border;
  final Color surface;
  final Color headerBg;
  final Color sectionHeaderBg;

  // Text
  final Color textPrimary;
  final Color textSecondary;

  // Accents & semantic
  final Color primary;
  final Color primaryLight;
  final Color navActive;
  final Color actionAccent;
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
  final Color emerald;
  final Color pink;

  // RSVP status
  final Color rsvpGoing;
  final Color rsvpMaybe;
  final Color rsvpNo;
  final Color rsvpUnselected;
  final Color rsvpNoResponse;

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
    required this.headerBg,
    required this.sectionHeaderBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.primaryLight,
    required this.navActive,
    required this.actionAccent,
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
    required this.emerald,
    required this.pink,
    required this.rsvpGoing,
    required this.rsvpMaybe,
    required this.rsvpNo,
    required this.rsvpUnselected,
    required this.rsvpNoResponse,
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
    border: Color(0xFFD1D1D1),
    surface: Color(0xFFFFFFFF),
    headerBg: Color(0xFFFFFFFF),
    sectionHeaderBg: Color(0xFF008CFF),
    textPrimary: Color(0xFF20242A),
    textSecondary: Color(0xFF4E5663),
    primary: Color(0xFF008CFF),
    primaryLight: Color(0xFFEFF6FF),
    navActive: Color(0xFF008CFF),
    actionAccent: Color(0xFF008CFF),
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
    emerald: Color(0xFF10B981),
    pink: Color(0xFFEC4899),
    rsvpGoing: Color(0xFF0ACB97),
    rsvpMaybe: Color(0xFFFD8F4B),
    rsvpNo: Color(0xFFFF5858),
    rsvpUnselected: Color(0xFF4E5663),
    rsvpNoResponse: Color(0xFFD9D9D9),
    white: Color(0xFFFFFFFF),
    gray100: Color(0xFFF3F4F6),
    gray300: Color(0xFFD1D5DB),
    gray400: Color(0xFF9CA3AF),
    gray500: Color(0xFF6B7280),
    gray700: Color(0xFF4E5663),
    gray900: Color(0xFF20242A),
  );

  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF20242A),
    card: Color(0xFF2B3038),
    border: Color(0xFF4E5663),
    surface: Color(0xFF20242A),
    headerBg: Color(0xFF2B3038),
    sectionHeaderBg: Color(0xFF2B3038),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF94A3B8),
    primary: Color(0xFFF7CE03),
    primaryLight: Color(0xFF0A2540),
    navActive: Color(0xFFF7CE03),
    actionAccent: Color(0xFFFED52C),
    success: Color(0xFF00C853),
    successLight: Color(0xFF0A2E1A),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFFF5252),
    purple: Color(0xFF8B5CF6),
    purpleLight: Color(0xFF1E1040),
    indigo: Color(0xFF6366F1),
    sky: Color(0xFF0EA5E9),
    orange: Color(0xFFF97316),
    teal: Color(0xFF14B8A6),
    emerald: Color(0xFF10B981),
    pink: Color(0xFFEC4899),
    rsvpGoing: Color(0xFF0ACB97),
    rsvpMaybe: Color(0xFFFD8F4B),
    rsvpNo: Color(0xFFFF5858),
    rsvpUnselected: Color(0xFF20242A),
    rsvpNoResponse: Color(0xFF4E5663),
    white: Color(0xFFFFFFFF),
    gray100: Color(0xFF252B35),
    gray300: Color(0xFF475569),
    gray400: Color(0xFF64748B),
    gray500: Color(0xFF94A3B8),
    gray700: Color(0xFFCBD5E1),
    gray900: Color(0xFFF1F5F9),
  );
}
