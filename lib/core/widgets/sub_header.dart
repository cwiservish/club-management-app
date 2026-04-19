import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

// ─── Sub Header ───────────────────────────────────────────────────────────────
// Reusable 44 px header for sub-pages (non-tab pages).
// Shows an optional back button on the left, a centred title, and an optional
// right-side text action.

class SubHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final String? rightText;
  final VoidCallback? onRightTap;

  const SubHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.rightText,
    this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.card,
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

          // ── Left: back button ─────────────────────────────────────────────
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack ?? () => Navigator.maybePop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_left, size: 20, color: colors.textPrimary),
                      Text(
                        'Back',
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

          // ── Right: text action ────────────────────────────────────────────
          if (rightText != null)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onRightTap,
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
