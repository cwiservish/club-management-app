import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // ── Headings (w700) ───────────────────────────────────────────────────────

  static TextStyle get heading20 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get heading18 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get heading16 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get heading15 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get heading14 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get heading13 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get heading12 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
      );

  static TextStyle get heading22 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
        height: 1.2,
      );

  // ── Body (w400) ───────────────────────────────────────────────────────────

  static TextStyle get body16 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray900,
        height: 1.3,
      );

  static TextStyle get body15 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray900,
        height: 1.4,
      );

  static TextStyle get body14 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray700,
        height: 1.3,
      );

  static TextStyle get body13 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray500,
        height: 1.4,
      );

  // ── Labels (w500) ─────────────────────────────────────────────────────────

  static TextStyle get label13 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.current.gray500,
      );

  static TextStyle get label12 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.current.gray500,
      );

  static TextStyle get label11 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.current.gray400,
      );

  // ── Special ───────────────────────────────────────────────────────────────

  static TextStyle get overline => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.current.gray500,
        letterSpacing: 0.8,
      );

  static TextStyle get dateNumber => TextStyle(
        fontFamily: fontFamily,
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: AppColors.current.gray900,
        height: 1.1,
      );
      
  static TextStyle get dateDay => TextStyle(
        fontFamily: fontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w400,
        color: AppColors.current.gray900,
        height: 1.0,
      );
    
  static TextStyle get buttonLabel => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.current.textSecondary,
        letterSpacing: 0.5,
      );
}
