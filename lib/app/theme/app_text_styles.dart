import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // ── Headings ──────────────────────────────────────────────────────────────

  static TextStyle get h1 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get h2 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.current.gray900,
      );

  static TextStyle get h3 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.current.gray900,
      );

  // ── Body ──────────────────────────────────────────────────────────────────

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray900,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray700,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray500,
      );

  // ── Display ───────────────────────────────────────────────────────────────

  static TextStyle get displayLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.current.gray900,
        height: 1.2,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.current.gray900,
        height: 1.3,
      );

  // ── Headlines ─────────────────────────────────────────────────────────────

  static TextStyle get headlineLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  // ── Titles ────────────────────────────────────────────────────────────────

  static TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.current.gray900,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.current.gray700,
      );

  // ── Body variants ─────────────────────────────────────────────────────────

  static TextStyle get body16 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray900,
        height: 1.3,
      );

  static TextStyle get body14 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray700,
        height: 1.3,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray500,
        height: 1.4,
      );

  // ── Labels ────────────────────────────────────────────────────────────────

  static TextStyle get labelLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.current.gray700,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.current.gray500,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.current.gray400,
      );

  // ── Misc ──────────────────────────────────────────────────────────────────

  static TextStyle get overline => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.current.gray500,
      );

  static TextStyle get dateNumber => TextStyle(
        fontFamily: fontFamily,
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
        height: 1.1,
      );
}
