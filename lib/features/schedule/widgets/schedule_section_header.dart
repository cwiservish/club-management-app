import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

class ScheduleSectionHeader extends StatelessWidget {
  final String title;

  const ScheduleSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 29,
      color: colorScheme.primary,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title, // Sentence case — as per Figma ("February", "March")
        style: AppTextStyles.headlineSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
