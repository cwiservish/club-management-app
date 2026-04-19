import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/event_player_model.dart';

class PlayerRow extends StatelessWidget {
  final EventPlayerModel player;
  final VoidCallback? onNoteTap;
  final VoidCallback? onStatusTap;

  const PlayerRow({
    super.key,
    required this.player,
    this.onNoteTap,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // ── Avatar ────────────────────────────────────────────────────────
          _Avatar(name: player.name, imageUrl: player.imageUrl),
          const SizedBox(width: 16),

          // ── Name + note ───────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: player.name,
                        style: AppTextStyles.heading15.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '  #${player.number}',
                        style: AppTextStyles.body14.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (player.hasNote) ...[
                  Text(
                    player.note,
                    style: AppTextStyles.body13.copyWith(
                      color: colors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: onNoteTap,
                    child: Text(
                      'Edit Note',
                      style: AppTextStyles.label11.copyWith(
                        color: colors.actionAccent,
                      ),
                    ),
                  ),
                ] else
                  GestureDetector(
                    onTap: onNoteTap,
                    child: Text(
                      '+ Add Note',
                      style: AppTextStyles.label13.copyWith(
                        color: colors.actionAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── Status badge ──────────────────────────────────────────────────
          GestureDetector(
            onTap: onStatusTap,
            child: _StatusBadge(status: player.status),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _Avatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.gray300,
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: imageUrl != null
          ? Image.network(imageUrl!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial(name, colors))
          : _initial(name, colors),
    );
  }

  Widget _initial(String name, AppColors colors) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final PlayerStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    Color bg;
    Color iconColor = Colors.white;
    IconData icon;

    switch (status) {
      case PlayerStatus.going:
        bg = colors.rsvpGoing;
        icon = Icons.check;
      case PlayerStatus.maybe:
        bg = colors.rsvpMaybe;
        icon = Icons.help_outline;
      case PlayerStatus.no:
        bg = colors.rsvpNo;
        icon = Icons.close;
      case PlayerStatus.none:
        bg = colors.rsvpUnselected.withValues(alpha: 0.15);
        iconColor = colors.textSecondary;
        icon = Icons.help_outline;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: status == PlayerStatus.none
            ? Border.all(
                color: colors.border,
                width: 1,
                style: BorderStyle.solid,
              )
            : null,
      ),
      child: Icon(icon, size: 18, color: iconColor),
    );
  }
}
