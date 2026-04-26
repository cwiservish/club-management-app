import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';
import '../models/invoice.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Search Field
// ══════════════════════════════════════════════════════════════════════════════

class InvoiceSearchField extends StatelessWidget {
  const InvoiceSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          CustomSvgIcon(
            assetPath: AppAssets.searchIcon,
            size: 18,
            color: AppColors.current.gray400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: AppTextStyles.heading14.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Search invoices...',
                hintStyle: AppTextStyles.heading14.copyWith(
                  color: AppColors.current.gray400,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Invoice List
// ══════════════════════════════════════════════════════════════════════════════

class InvoiceList extends StatelessWidget {
  final List<Invoice> invoices;
  const InvoiceList({super.key, required this.invoices});

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.current.gray100),
        ),
        alignment: Alignment.center,
        child: Text(
          'No invoices found for this filter.',
          style: AppTextStyles.body14.copyWith(
            color: AppColors.current.textSecondary,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.current.gray100),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: invoices.map((inv) => InvoiceRow(
                invoice: inv,
                isLast: inv == invoices.last,
              )).toList(),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Invoice Row
// ══════════════════════════════════════════════════════════════════════════════

class InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  final bool isLast;
  const InvoiceRow({super.key, required this.invoice, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.current.gray100)),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.current.card,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvgIcon(
                assetPath: AppAssets.fileTextIcon,
                size: 20,
                color: AppColors.current.gray500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        invoice.recipient,
                        style: AppTextStyles.body15.copyWith(
                          color: AppColors.current.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      invoice.amount,
                      style: AppTextStyles.body15.copyWith(
                        color: AppColors.current.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${invoice.id} • ${invoice.date}',
                        style: AppTextStyles.body13.copyWith(
                          color: AppColors.current.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InvoiceStatusBadge(status: invoice.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.more_vert, size: 20, color: AppColors.current.gray400),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Status Badge
// ══════════════════════════════════════════════════════════════════════════════

class InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  const InvoiceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case InvoiceStatus.paid:
        color = AppColors.current.rsvpGoing;
        label = 'PAID';
        break;
      case InvoiceStatus.pending:
        color = AppColors.current.rsvpMaybe;
        label = 'PENDING';
        break;
      case InvoiceStatus.overdue:
        color = AppColors.current.rsvpNo;
        label = 'OVERDUE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Form Field
// ══════════════════════════════════════════════════════════════════════════════

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.heading13.copyWith(
              color: AppColors.current.gray700,
            ),
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.current.rsvpNo),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.current.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
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
                  style: AppTextStyles.body15.copyWith(
                    color: AppColors.current.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: AppTextStyles.body15.copyWith(
                      color: AppColors.current.gray400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: prefix != null ? 6 : 16,
                      vertical: maxLines > 1 ? 14 : 0,
                    ),
                    isDense: maxLines == 1,
                    constraints: maxLines == 1
                        ? const BoxConstraints(minHeight: 44)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
