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
    final status = rsvpStatus ?? _deriveStatus();

    return Container(
      color: AppColors.current.surface,
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
                color: AppColors.current.card,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${event.dateTime.day}',
                      style: AppTextStyles.dateNumber.copyWith(
                        color: AppColors.current.textPrimary,
                      ),
                    ),
                    Text(
                      _shortDay(event.dateTime.weekday),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.current.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: AppColors.current.surface),

              // Details column
              Expanded(
                child: Container(
                  color: AppColors.current.card,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_fmtTime(event.dateTime)} - ${_fmtTime(event.endTime)}',
                        style: AppTextStyles.body16.copyWith(
                          color: AppColors.current.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.title,
                        style: AppTextStyles.body14.copyWith(
                          color: AppColors.current.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.current.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, color: AppColors.current.surface),

              // RSVP column
              _Col(
                width: 55,
                color: AppColors.current.card,
                child: _RsvpBox(status: status),
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
  const _RsvpBox({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Widget child;

    switch (status) {
      case RsvpStatus.accepted:
        bg    = AppColors.current.rsvpGoing;
        child = Icon(Icons.check, color: AppColors.current.white, size: 16);
      case RsvpStatus.declined:
        bg    = AppColors.current.rsvpNo;
        child = Icon(Icons.close, color: AppColors.current.white, size: 16);
      case RsvpStatus.unknown:
        bg    = AppColors.current.rsvpNoResponse;
        child = Text(
          '?',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.current.textPrimary,
          ),
        );
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.current.border),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
