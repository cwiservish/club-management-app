import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class _NoHandleControls extends MaterialTextSelectionControls {
  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
    return const SizedBox.shrink();
  }

  @override
  Size getHandleSize(double textLineHeight) => Size.zero;

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) => Offset.zero;
}

final _noHandleControls = _NoHandleControls();

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool autofocus;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.autofocus = false,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionHandleColor: colors.primary,
        selectionColor: colors.primary.withValues(alpha: 0.2),
      ),
      child: TextField(
      controller: controller,
      autofocus: autofocus,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
      selectionControls: _noHandleControls,
      cursorColor: colors.primary,
      style: AppTextStyles.body16.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.body16.copyWith(color: colors.textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.isDark ? colors.background : colors.gray100,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      ),
    );
  }
}
