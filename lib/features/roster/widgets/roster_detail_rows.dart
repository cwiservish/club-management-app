import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class RosterInfoRow extends StatelessWidget {
  final String primary;
  final String? secondary;
  final VoidCallback? onTap;

  const RosterInfoRow({
    super.key,
    required this.primary,
    this.secondary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 77,
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.current.card, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (secondary != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondary!,
                      style: AppTextStyles.body13.copyWith(
                          color: AppColors.current.textPrimary.withOpacity(0.55)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.current.textPrimary.withOpacity(0.35), size: 20),
          ],
        ),
      ),
    );
  }
}

class RosterNavRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const RosterNavRow({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 77,
        decoration: BoxDecoration(
          color: AppColors.current.card,
          border: Border(
            bottom: BorderSide(color: AppColors.current.border, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary),
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.current.textPrimary.withOpacity(0.35), size: 20),
          ],
        ),
      ),
    );
  }
}

class RosterActionLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const RosterActionLink({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: AppColors.current.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          label,
          style: AppTextStyles.overline.copyWith(color: AppColors.current.primary),
        ),
      ),
    );
  }
}
