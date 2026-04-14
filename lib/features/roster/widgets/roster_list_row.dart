import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/roster_member.dart';

/// A single 77-px roster list row: avatar circle + name/jersey + chevron.
class RosterListRow extends StatelessWidget {
  final RosterMember member;
  final VoidCallback onTap;

  const RosterListRow({super.key, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 77,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.surfaceContainerHighest,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                member.initials,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name + jersey / staff title
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: AppTextStyles.body16.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.jerseyNumber != null
                        ? '#${member.jerseyNumber}'
                        : member.staffTitle ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withOpacity(0.35),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
