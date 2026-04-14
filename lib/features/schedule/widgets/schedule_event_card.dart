import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';

/// Three possible RSVP states shown on the card.
enum RsvpStatus { accepted, declined, unknown }

class ScheduleEventCard extends StatelessWidget {
  final ClubEvent event;

  /// Explicit override; when null the status is derived from [event].
  final RsvpStatus? rsvpStatus;

  const ScheduleEventCard({
    super.key,
    required this.event,
    this.rsvpStatus,
  });

  // ─── Helpers ────────────────────────────────────────────────────────────────

  RsvpStatus _deriveStatus() {
    if (event.rsvpYes.isNotEmpty) return RsvpStatus.accepted;
    if (event.rsvpNo.isNotEmpty) return RsvpStatus.declined;
    return RsvpStatus.unknown;
  }

  String _getShortDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:    return 'MON';
      case DateTime.tuesday:   return 'TUE';
      case DateTime.wednesday: return 'WED';
      case DateTime.thursday:  return 'THU';
      case DateTime.friday:    return 'FRI';
      case DateTime.saturday:  return 'SAT';
      case DateTime.sunday:    return 'SUN';
      default:                 return '';
    }
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // ─── RSVP indicator ─────────────────────────────────────────────────────────

  Widget _buildRsvpBox(RsvpStatus status, ColorScheme colorScheme) {
    final Color bgColor;
    final Widget icon;

    switch (status) {
      case RsvpStatus.accepted:
        bgColor = const Color(0xFF0ACB97); // Figma spec: #0ACB97 green
        icon = const Icon(Icons.check, color: AppColors.white, size: 18);
      case RsvpStatus.declined:
        bgColor = const Color(0xFFFF5858); // Figma spec: #FF5858 red
        icon = const Icon(Icons.close, color: AppColors.white, size: 18);
      case RsvpStatus.unknown:
        bgColor = colorScheme.surfaceContainer; // #D9D9D9 light / #4E5663 dark
        icon = Text(
          '?',
          style: AppTextStyles.titleMedium.copyWith(
            color: colorScheme.onSurface,
            fontSize: 18,
          ),
        );
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme   = theme.textTheme;
    final status      = rsvpStatus ?? _deriveStatus();

    final dayNum  = event.dateTime.day.toString();
    final dayName = _getShortDayName(event.dateTime.weekday);
    final timeRange =
        '${_formatTime(event.dateTime)} - ${_formatTime(event.endTime)}';

    // The card uses colorScheme.surfaceContainerHighest (#F4F4F4 light / #2B3038 dark)
    // with white separators between columns (colorScheme.surface).
    return Container(
      // White "gap" row between cards — 9 px top + 9 px bottom = 18 px spacing
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 85,
          child: Row(
            children: [
              // ── Date column ─────────────────────────────────────────────────
              Container(
                width: 67,
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayNum,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      dayName,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // 1 px white column separator
              Container(width: 1, color: colorScheme.surface),

              // ── Event details column ─────────────────────────────────────────
              Expanded(
                child: Container(
                  color: colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time range — bodyLarge weight
                      Text(
                        timeRange,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Event title
                      Text(
                        event.title,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Location
                      Text(
                        event.location,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // 1 px white column separator
              Container(width: 1, color: colorScheme.surface),

              // ── RSVP column ─────────────────────────────────────────────────
              Container(
                width: 55,
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: _buildRsvpBox(status, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
