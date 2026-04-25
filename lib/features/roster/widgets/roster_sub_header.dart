import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';

class RosterSubHeader extends StatelessWidget {
  const RosterSubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.current.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Roster',
              style: AppTextStyles.heading18.copyWith(
                color: AppColors.current.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CustomSvgIcon(
                assetPath: AppAssets.searchIcon,
                size: 20,
                color: AppColors.current.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CustomSvgIcon(
                assetPath: AppAssets.filterIcon,
                size: 20,
                color: AppColors.current.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
