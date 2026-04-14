import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Developer: Dark/Light Mode Semantic Colors ────────────────────────────
  static const Color darkBg = Color(0xFF191C20);
  static const Color darkBorder = Color(0xFF333842);
  static const Color darkAccent = Color(0xFFF7CE03);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xB3FFFFFF); // white 0.7 opacity

  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF4F4F4);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightAccent = Color(0xFF008CFF);
  static const Color lightTextPrimary = Color(0xFF20242A);
  static const Color lightTextSecondary = Color(0x9920242A); // 0.6 opacity

  static const Color pending = Color(0xFF4B5563);

  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryMid = Color(0xFFBFDBFE);

  // ── Semantic (developer's values win on conflicts) ────────────────────────
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFF7ED);
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF5F3FF);

  // ── Extra Accents ─────────────────────────────────────────────────────────
  static const Color sky = Color(0xFF0EA5E9);
  static const Color orange = Color(0xFFF97316);
  static const Color teal = Color(0xFF14B8A6);
  static const Color indigo = Color(0xFF6366F1);

  // ── Neutral Grays (light mode) ────────────────────────────────────────────
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ── Surface (light) ───────────────────────────────────────────────────────
  static const Color white = Colors.white;
  static const Color background = gray50;
  static const Color surface = white;
  static const Color divider = gray100;

  // ── Surface (dark) ────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF2B3038); // developer's value
  static const Color darkDivider = Color(0xFF334155);
}
