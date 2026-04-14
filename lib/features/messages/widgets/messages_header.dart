import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

/// The 53-px messages-specific header bar matching the Figma spec:
/// person icon  |  "12 Girls ECNL RL ▼" team selector button  |  + icon
class MessagesHeader extends StatelessWidget {
  final String teamName;
  final VoidCallback? onTeamTap;
  final VoidCallback? onComposeTap;

  const MessagesHeader({
    super.key,
    this.teamName = '12 Girls ECNL RL',
    this.onTeamTap,
    this.onComposeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 53,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Person / profile icon — left
          Icon(
            Icons.person_outline,
            color: colorScheme.onSurface,
            size: 24,
          ),

          const Spacer(),

          // Team dropdown button — center (#F4F4F4 bg, 190px wide)
          GestureDetector(
            onTap: onTeamTap,
            child: Container(
              height: 37,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    teamName,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.onSurface,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Compose / + icon — right
          GestureDetector(
            onTap: onComposeTap,
            child: Icon(
              Icons.add,
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
