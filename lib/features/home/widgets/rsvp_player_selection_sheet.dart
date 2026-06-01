import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';

class RsvpPlayerSelectionSheet extends StatelessWidget {
  final List<ClubEventRsvpTarget> targets;
  final ValueChanged<ClubEventRsvpTarget> onSelected;

  const RsvpPlayerSelectionSheet({
    super.key,
    required this.targets,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(19, 20, 19, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SELECT PLAYER',
                style: AppTextStyles.label13.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
          const SizedBox(height: 12),
          Text(
            'Choose the player you want to change RSVP for:',
            style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: targets.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final target = targets[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  title: Text(
                    target.name,
                    style: AppTextStyles.heading15.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RsvpBox(attendance: target.attendance),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(target);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RsvpBox extends StatelessWidget {
  final dynamic attendance;
  const _RsvpBox({required this.attendance});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Widget child;
    final colors = AppColors.current;

    // Convert attendance to int representation safely
    final val = attendance is int
        ? attendance
        : (attendance != null ? int.tryParse(attendance.toString()) : null);

    if (val == 1) {
      bg    = colors.rsvpGoing;
      child = const Icon(Icons.check, color: Colors.white, size: 17);
    } else if (val == 0) {
      bg    = colors.rsvpNo;
      child = const Icon(Icons.close, color: Colors.white, size: 17);
    } else if (val == 2) {
      bg    = colors.rsvpMaybe;
      child = Text(
        '?',
        style: AppTextStyles.heading15.copyWith(
          color: Colors.white,
        ),
      );
    } else {
      bg    = colors.rsvpNoResponse;
      child = Text(
        '?',
        style: AppTextStyles.heading15.copyWith(
          color: colors.textPrimary,
        ),
      );
    }

    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF4E5663), width: 1),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
