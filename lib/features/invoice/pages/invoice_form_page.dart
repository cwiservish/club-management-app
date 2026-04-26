import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';

class InvoiceFormPage extends StatelessWidget {
  const InvoiceFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(title: 'New Invoice', leftLabel: 'Cancel'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Form card ────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.current.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.current.gray300.withOpacity(0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FormField(
                            label: 'Recipient Name',
                            placeholder: 'e.g. John Doe',
                            required: true,
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            label: 'Email Address',
                            placeholder: 'john@example.com',
                            required: true,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            label: 'Phone Number',
                            placeholder: '(555) 123-4567',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            label: 'Amount',
                            placeholder: '0.00',
                            required: true,
                            keyboardType: TextInputType.number,
                            prefix: '\$',
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            label: 'Description',
                            placeholder: 'What is this invoice for?',
                            required: true,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ── Send button ──────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.maybePop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.current.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Send Invoice',
                          style: AppTextStyles.heading16
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private form field ────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final String placeholder;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;
  final String? prefix;

  const _FormField({
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
