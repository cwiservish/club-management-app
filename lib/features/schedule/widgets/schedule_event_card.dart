import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';

enum RsvpStatus { accepted, declined, unknown }

class ScheduleEventCard extends StatelessWidget {
  final ClubEvent event;
  final RsvpStatus? rsvpStatus;

  const ScheduleEventCard({super.key, required this.event, this.rsvpStatus});

  RsvpStatus _deriveStatus() {
    if (event.rsvpYes.isNotEmpty) return RsvpStatus.accepted;
    if (event.rsvpNo.isNotEmpty)  return RsvpStatus.declined;
    return RsvpStatus.unknown;
  }

  String _shortDay(int weekday) => const {
        DateTime.monday:    'MON',
        DateTime.tuesday:   'TUE',
        DateTime.wednesday: 'WED',
        DateTime.thursday:  'THU',
        DateTime.friday:    'FRI',
        DateTime.saturday:  'SAT',
        DateTime.sunday:    'SUN',
      }[weekday] ??
      '';

  String _fmtTime(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status      = rsvpStatus ?? _deriveStatus();
    final card        = colorScheme.surfaceContainerHighest;
    final sep         = colorScheme.surface;

    return Container(
      color: sep,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 85,
          child: Row(
            children: [
              // Date column
              _Col(
                width: 67,
                color: card,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${event.dateTime.day}',
                      style: AppTextStyles.dateNumber.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _shortDay(event.dateTime.weekday),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: sep),

              // Details column
              Expanded(
                child: Container(
                  color: card,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_fmtTime(event.dateTime)} - ${_fmtTime(event.endTime)}',
                        style: AppTextStyles.body16.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.title,
                        style: AppTextStyles.body14.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, color: sep),

              // RSVP column
              _Col(
                width: 55,
                color: card,
                child: _RsvpBox(status: status, colorScheme: colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Col extends StatelessWidget {
  final double width;
  final Color color;
  final Widget child;
  const _Col({required this.width, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: color,
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _RsvpBox extends StatelessWidget {
  final RsvpStatus status;
  final ColorScheme colorScheme;
  const _RsvpBox({required this.status, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Widget child;

    switch (status) {
      case RsvpStatus.accepted:
        bg    = const Color(0xFF0ACB97);
        child = const Icon(Icons.check, color: AppColors.white, size: 16);
      case RsvpStatus.declined:
        bg    = const Color(0xFFFF5858);
        child = const Icon(Icons.close, color: AppColors.white, size: 16);
      case RsvpStatus.unknown:
        bg    = colorScheme.surfaceContainer;
        child = Text(
          '?',
          style: AppTextStyles.titleMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        );
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outline),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
