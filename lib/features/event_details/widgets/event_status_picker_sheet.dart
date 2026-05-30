import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/event_player_model.dart';
import '../providers/event_detail_provider.dart';

// ─── Status Picker Sheet ──────────────────────────────────────────────────────
// Bottom sheet content for changing a player's attendance status.

class EventStatusPickerSheet extends StatelessWidget {
  final EventPlayerModel player;
  final EventDetailNotifier notifier;

  const EventStatusPickerSheet({
    super.key,
    required this.player,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Padding(
      padding: const EdgeInsets.fromLTRB(19, 20, 19, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${player.name}'s Attendance",
            style: AppTextStyles.overline.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  _StatusOption(
                    label:       'Going',
                    value:       PlayerStatus.going,
                    current:     player.status,
                    activeColor: colors.rsvpGoing,
                    onTap: (s) async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      final result = await notifier.updatePlayerStatus(player.id, s);
                      if (!result.success) {
                        messenger.showSnackBar(SnackBar(
                          content: Text(result.message),
                          backgroundColor: colors.error,
                        ));
                      }
                    },
                  ),
                  VerticalDivider(
                    width: 1,
                    color: colors.border.withValues(alpha: 0.5),
                  ),
                  _StatusOption(
                    label:       'Maybe',
                    value:       PlayerStatus.maybe,
                    current:     player.status,
                    activeColor: colors.rsvpMaybe,
                    onTap: (s) async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      final result = await notifier.updatePlayerStatus(player.id, s);
                      if (!result.success) {
                        messenger.showSnackBar(SnackBar(
                          content: Text(result.message),
                          backgroundColor: colors.error,
                        ));
                      }
                    },
                  ),
                  VerticalDivider(
                    width: 1,
                    color: colors.border.withValues(alpha: 0.5),
                  ),
                  _StatusOption(
                    label:       'No',
                    value:       PlayerStatus.no,
                    current:     player.status,
                    activeColor: colors.rsvpNo,
                    onTap: (s) async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      final result = await notifier.updatePlayerStatus(player.id, s);
                      if (!result.success) {
                        messenger.showSnackBar(SnackBar(
                          content: Text(result.message),
                          backgroundColor: colors.error,
                        ));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Option ────────────────────────────────────────────────────────────

class _StatusOption extends StatelessWidget {
  final String label;
  final PlayerStatus value;
  final PlayerStatus current;
  final Color activeColor;
  final Function(PlayerStatus) onTap;

  const _StatusOption({
    required this.label,
    required this.value,
    required this.current,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == value;
    final colors   = AppColors.current;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          color: isActive ? activeColor : colors.card,
          child: Text(
            label,
            style: AppTextStyles.heading14.copyWith(
              color: isActive ? Colors.white : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
