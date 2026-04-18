import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class RosterSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final String actionLabel;

  const RosterSectionHeader({
    super.key,
    required this.title,
    required this.count,
    this.actionLabel = 'Sort',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29,
      color: AppColors.current.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '$title ($count)',
            style: AppTextStyles.heading16.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            actionLabel,
            style: AppTextStyles.overline.copyWith(
              color: const Color(0xFFFED52C),
            ),
          ),
        ],
      ),
    );
  }
}
