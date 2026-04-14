import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

/// Blue 29-px section header used on the roster list.
/// Shows [title] + member [count] on the left, and a [actionLabel] on the right.
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
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      height: 29,
      color: primary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '$title ($count)',
            style: AppTextStyles.headlineSmall.copyWith(
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
