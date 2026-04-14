import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

/// A 77-px info row used in the member detail screen.
/// Shows [primary] text (large) + [secondary] text (small) + a right chevron.
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    style: AppTextStyles.body16.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (secondary != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondary!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
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

/// A highlighted nav row (grey bg + bottom border) — e.g. "Statistics".
class RosterNavRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const RosterNavRow({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 77,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(color: colorScheme.outline, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body16.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
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

/// Small inline link text — "+ Add Family Member".
class RosterActionLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const RosterActionLink({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          label,
          style: AppTextStyles.overline.copyWith(color: primary),
        ),
      ),
    );
  }
}
