import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class EventAssignmentTabPage extends StatelessWidget {
  const EventAssignmentTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return ColoredBox(
      color: colors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 48,
                color: colors.border,
              ),
              const SizedBox(height: 16),
              Text(
                'Assignments Info',
                style: AppTextStyles.heading18.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'This section is currently empty. Information about assignments will appear here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
