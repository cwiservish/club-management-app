import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class InvoiceFormField extends StatelessWidget {
  final String label;
  final String placeholder;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;
  final String? prefix;

  const InvoiceFormField({
    super.key,
    required this.label,
    required this.placeholder,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final isSingleLine = maxLines == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            style: AppTextStyles.heading13
                .copyWith(color: AppColors.current.gray700),
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.current.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Input
        Container(
          height: isSingleLine ? 44 : null,
          decoration: BoxDecoration(
            color: AppColors.current.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: isSingleLine
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (prefix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    prefix!,
                    style: AppTextStyles.body15.copyWith(
                      color: AppColors.current.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  style: AppTextStyles.body15
                      .copyWith(color: AppColors.current.textPrimary),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: AppTextStyles.body15
                        .copyWith(color: AppColors.current.gray400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: prefix != null ? 6 : 16,
                      vertical: isSingleLine ? 0 : 14,
                    ),
                    isCollapsed: isSingleLine,
                  ),
                  textAlignVertical:
                      isSingleLine ? TextAlignVertical.center : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
