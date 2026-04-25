import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';

class RosterSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onSortTap;

  const RosterSectionHeader({
    super.key,
    required this.title,
    required this.count,
    this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    final sortBtnBg = AppColors.current.isDark
        ? AppColors.current.card
        : AppColors.current.primaryLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: AppColors.current.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                '${title.toUpperCase()} ($count)',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.current.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSortTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sortBtnBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomSvgIcon(
                        assetPath: AppAssets.sortIcon,
                        size: 14,
                        color: AppColors.current.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Sort',
                        style: AppTextStyles.heading13.copyWith(
                          color: AppColors.current.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: AppColors.current.border.withOpacity(0.5),
        ),
      ],
    );
  }
}
