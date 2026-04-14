import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

/// Blue 29-px section header inside the member detail screen
/// (e.g. "Contact Information"). No action label on the right.
class RosterDetailSectionHeader extends StatelessWidget {
  final String title;

  const RosterDetailSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29,
      color: Theme.of(context).colorScheme.primary,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

/// Blue 29-px top-bar inside the detail screen: "< Rosters" + optional action.
class RosterDetailTopBar extends StatelessWidget {
  final String backLabel;
  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onBack;

  const RosterDetailTopBar({
    super.key,
    this.backLabel = 'Rosters',
    this.actionLabel = 'Edit',
    this.actionColor = const Color(0xFFFED52C),
    this.onBack,
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
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                Text(
                  backLabel,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (actionLabel != null)
            Text(
              actionLabel!,
              style: AppTextStyles.overline.copyWith(
                color: actionColor,
              ),
            ),
        ],
      ),
    );
  }
}
