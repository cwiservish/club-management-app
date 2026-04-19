import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/event_detail_provider.dart';
import '../models/event_player_model.dart';
import '../widgets/availability/player_group.dart';

class EventAvailabilityTabPage extends ConsumerWidget {
  final String eventId;

  const EventAvailabilityTabPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventDetailProvider(eventId));
    final notifier = ref.read(eventDetailProvider(eventId).notifier);
    final colors = AppColors.current;

    return ColoredBox(
      color: colors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PlayerGroup(
            title: 'GOING',
            players: state.goingPlayers,
            onNoteTap: (_) {},
            onStatusTap: (p) => _showStatusPicker(context, p, notifier),
          ),
          PlayerGroup(
            title: 'MAYBE',
            players: state.maybePlayers,
            onNoteTap: (_) {},
            onStatusTap: (p) => _showStatusPicker(context, p, notifier),
          ),
          PlayerGroup(
            title: 'NOT GOING',
            players: state.noPlayers,
            onNoteTap: (_) {},
            onStatusTap: (p) => _showStatusPicker(context, p, notifier),
          ),
          PlayerGroup(
            title: "HAVEN'T REPLIED",
            players: state.unrepliedPlayers,
            showMessageAll: true,
            onNoteTap: (_) {},
            onStatusTap: (p) => _showStatusPicker(context, p, notifier),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showStatusPicker(
    BuildContext context,
    EventPlayerModel player,
    EventDetailNotifier notifier,
  ) {
    final colors = AppColors.current;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
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
                      label: 'Going',
                      value: PlayerStatus.going,
                      current: player.status,
                      activeColor: colors.rsvpGoing,
                      onTap: (s) {
                        notifier.updatePlayerStatus(player.id, s);
                        Navigator.pop(context);
                      },
                    ),
                    VerticalDivider(width: 1, color: colors.border.withValues(alpha: 0.5)),
                    _StatusOption(
                      label: 'Maybe',
                      value: PlayerStatus.maybe,
                      current: player.status,
                      activeColor: colors.rsvpMaybe,
                      onTap: (s) {
                        notifier.updatePlayerStatus(player.id, s);
                        Navigator.pop(context);
                      },
                    ),
                    VerticalDivider(width: 1, color: colors.border.withValues(alpha: 0.5)),
                    _StatusOption(
                      label: 'No',
                      value: PlayerStatus.no,
                      current: player.status,
                      activeColor: colors.rsvpNo,
                      onTap: (s) {
                        notifier.updatePlayerStatus(player.id, s);
                        Navigator.pop(context);
                      },
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
}

class _StatusOption extends StatelessWidget {
  final String label;
  final PlayerStatus value;
  final PlayerStatus current;
  final Color activeColor;
  final ValueChanged<PlayerStatus> onTap;

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
    final colors = AppColors.current;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          color: isActive ? activeColor : colors.background,
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
