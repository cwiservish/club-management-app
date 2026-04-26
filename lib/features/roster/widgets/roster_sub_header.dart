import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';

class RosterSubHeader extends ConsumerWidget {
  const RosterSubHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
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
