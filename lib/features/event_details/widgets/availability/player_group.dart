import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/event_player_model.dart';
import 'player_row.dart';

class PlayerGroup extends StatelessWidget {
  final String title;
  final List<EventPlayerModel> players;
  final bool showMessageAll;
  final VoidCallback? onMessageAll;
  final void Function(EventPlayerModel)? onNoteTap;
  final void Function(EventPlayerModel)? onStatusTap;

  const PlayerGroup({
    super.key,
    required this.title,
    required this.players,
    this.showMessageAll = false,
    this.onMessageAll,
    this.onNoteTap,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();

    final colors = AppColors.current;

    return Column(
      children: [
        // ── Group header ────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 12),
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(
              top: BorderSide(color: colors.border.withValues(alpha: 0.5)),
              bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title (${players.length})',
                style: AppTextStyles.overline.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showMessageAll)
                GestureDetector(
                  onTap: onMessageAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.message_outlined, size: 14, color: colors.actionAccent),
                        const SizedBox(width: 4),
                        Text(
                          'Message All',
                          style: AppTextStyles.label13.copyWith(
                            color: colors.actionAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Player rows ─────────────────────────────────────────────────────
        Container(
          color: colors.card,
          child: Column(
            children: players
                .map((p) => PlayerRow(
                      player: p,
                      onNoteTap: onNoteTap != null ? () => onNoteTap!(p) : null,
                      onStatusTap: onStatusTap != null ? () => onStatusTap!(p) : null,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
