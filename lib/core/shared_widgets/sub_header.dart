import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

// ─── Sub Header ───────────────────────────────────────────────────────────────
// Reusable 44 px sub-header for sub-pages.
// Left side defaults to chevron + "Back". Pass [leftIcon] + [leftLabel] to
// override (e.g. Icons.close + "Close" for the edit event sheet).

class SubHeader extends StatelessWidget {
  final String title;
  final bool showLeft;
  final IconData leftIcon;
  final String leftLabel;
  final VoidCallback? onLeftTap;
  final String? rightText;
  final VoidCallback? onRightTap;
  final Widget? rightWidget;

  const SubHeader({
    super.key,
    required this.title,
    this.showLeft = true,
    this.leftIcon = Icons.chevron_left,
    this.leftLabel = 'Back',
    this.onLeftTap,
    this.rightText,
    this.onRightTap,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.headerBg,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Centre title ──────────────────────────────────────────────────
          Text(
            title,
            style: AppTextStyles.heading16.copyWith(color: colors.textPrimary),
          ),

          // ── Left button ───────────────────────────────────────────────────
          if (showLeft)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onLeftTap ?? () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(leftIcon, size: 20, color: colors.textPrimary),
                      Text(
                        leftLabel,
                        style: AppTextStyles.body16.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Right: widget or text action ──────────────────────────────────
          if (rightWidget != null)
            Align(
              alignment: Alignment.centerRight,
              child: rightWidget!,
            )
          else if (rightText != null)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onRightTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    rightText!,
                    style: AppTextStyles.heading14.copyWith(
                      color: colors.actionAccent,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
