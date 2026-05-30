import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class EventEditInlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool borderBottom;
  final bool enabled;

  const EventEditInlineField({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
    this.borderBottom = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.label12.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 4),
            TextField(
              controller:  controller,
              enabled:     enabled,
              cursorColor: colors.primary,
              style: AppTextStyles.body16.copyWith(
                color:      colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText:      placeholder,
                hintStyle:     AppTextStyles.body16.copyWith(color: colors.gray300),
                isDense:       true,
                contentPadding: EdgeInsets.zero,
                border:        InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

