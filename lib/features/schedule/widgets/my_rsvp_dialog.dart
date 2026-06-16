import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';
import '../providers/schedule_provider.dart';

/// Dialog that lets the user pick Going / Maybe / No for an event.
///
/// When player-selection is required *and* there are multiple targets the dialog
/// pops itself with the chosen status string so the call-site can present the
/// player-selection bottom-sheet.  In all other cases it saves the RSVP to the
/// server directly and then pops itself.
class MyRsvpDialog extends ConsumerWidget {
  final ClubEvent event;

  const MyRsvpDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find latest state of event from provider
    final scheduleState = ref.watch(scheduleProvider);
    final latestEvent = scheduleState.events.firstWhere((e) => e.id == event.id, orElse: () => event);

    // Derive current user status
    String currentStatus = 'unknown';
    if (latestEvent.rsvpYes.contains('me')) currentStatus = 'going';
    else if (latestEvent.rsvpNo.contains('me')) currentStatus = 'no';
    else if (latestEvent.rsvpMaybe.contains('me')) currentStatus = 'maybe';

    final colors = AppColors.current;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MY RSVP',
                  style: AppTextStyles.label13.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.gray400,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Row(
                  children: [
                    _buildSegment(
                      context,
                      ref,
                      label: '${latestEvent.rsvpYes.length} Going',
                      value: 'going',
                      currentStatus: currentStatus,
                      latestEvent: latestEvent,
                    ),
                    Container(width: 1, color: colors.border.withValues(alpha: 0.5)),
                    _buildSegment(
                      context,
                      ref,
                      label: '${latestEvent.rsvpMaybe.length} Maybe',
                      value: 'maybe',
                      currentStatus: currentStatus,
                      latestEvent: latestEvent,
                    ),
                    Container(width: 1, color: colors.border.withValues(alpha: 0.5)),
                    _buildSegment(
                      context,
                      ref,
                      label: '${latestEvent.rsvpNo.length} No',
                      value: 'no',
                      currentStatus: currentStatus,
                      latestEvent: latestEvent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String value,
    required String currentStatus,
    required ClubEvent latestEvent,
  }) {
    final colors = AppColors.current;
    final isActive = currentStatus == value;

    Color getBgColor() {
      if (!isActive) return colors.card;
      if (value == 'going') return colors.rsvpGoing;
      if (value == 'maybe') return colors.rsvpMaybe;
      if (value == 'no') return colors.rsvpNo;
      return colors.card;
    }

    Color getTextColor() {
      if (isActive) return Colors.white;
      return colors.textSecondary;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final needsPlayerSelection =
              latestEvent.requiresPlayerSelection && latestEvent.rsvpTargets.length > 1;

          if (needsPlayerSelection) {
            // Return the chosen status to the call-site; it will handle player selection.
            Navigator.of(context).pop(value);
            return;
          }

          // Single target or no player selection required — save directly.
          final notifier = ref.read(scheduleProvider.notifier);

          if (latestEvent.rsvpTargets.isNotEmpty) {
            final result = await notifier.saveEventRsvp(
              event: latestEvent,
              target: latestEvent.rsvpTargets.first,
              status: value,
            );

            if (!result.success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: AppColors.current.error,
                ),
              );
            }
          } else {
            // Fallback: local-only update when no targets are present.
            notifier.updateRsvp(latestEvent.id, value);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: getBgColor(),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body14.copyWith(
              color: getTextColor(),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
