import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';
import '../../home/widgets/rsvp_player_selection_sheet.dart';
import 'my_rsvp_dialog.dart';

class ScheduleEventCard extends ConsumerWidget {
  final ClubEvent event;
  final RsvpStatus? rsvpStatus;

  const ScheduleEventCard({super.key, required this.event, this.rsvpStatus});

  RsvpStatus _deriveStatus(ClubEvent e) {
    if (e.rsvpYes.contains('me')) return RsvpStatus.accepted;
    if (e.rsvpNo.contains('me'))  return RsvpStatus.declined;
    if (e.rsvpMaybe.contains('me')) return RsvpStatus.maybe;
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Always read the latest event from the provider so RSVP status stays fresh.
    final latestEvent = ref.watch(scheduleProvider).events
        .firstWhere((e) => e.id == event.id, orElse: () => event);
    final status = rsvpStatus ?? _deriveStatus(latestEvent);

    Future<void> handleRsvpTap() async {
      final chosenStatus = await showDialog<String>(
        context: context,
        builder: (_) => MyRsvpDialog(event: latestEvent),
      );

      // Dialog returns a non-null status only when player selection is needed.
      if (chosenStatus == null || !context.mounted) return;

      // Show player selection sheet.
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => RsvpPlayerSelectionSheet(
          targets: latestEvent.rsvpTargets,
          onSelected: (target) async {
            final result = await ref.read(scheduleProvider.notifier).saveEventRsvp(
              event: latestEvent,
              target: target,
              status: chosenStatus,
            );
            if (!result.success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: AppColors.current.error,
                ),
              );
            }
          },
        ),
      );
    }
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.eventDetails(event.id)}?from=schedule'),
      child: Container(
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
                      const SizedBox(height: 8),
                      Text(
                        _shortDay(event.dateTime.weekday),
                        style: AppTextStyles.dateDay.copyWith(
                          color: AppColors.current.textPrimary,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                (event.timeLabel != null && event.timeLabel!.isNotEmpty)
                                    ? event.timeLabel!
                                    : '${_fmtTime(event.dateTime)} - ${_fmtTime(event.endTime)}',
                                style: AppTextStyles.body16.copyWith(
                                  color: AppColors.current.textPrimary,
                                ),
                              ),
                            ),
                            if (event.scheduleGameId != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color:Colors.green.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ],
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
                          style: AppTextStyles.body13.copyWith(
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
                GestureDetector(
                  onTap: handleRsvpTap,
                  child: _Col(
                    width: 60,
                    color: AppColors.current.card,
                    child: _RsvpBox(status: status),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────────

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
        child = Icon(Icons.check, color: AppColors.current.white, size: 17);
      case RsvpStatus.declined:
        bg    = AppColors.current.rsvpNo;
        child = Icon(Icons.close, color: AppColors.current.white, size: 17);
      case RsvpStatus.maybe:
        bg    = AppColors.current.rsvpMaybe;
        child = Text(
          '?',
          style: AppTextStyles.heading15.copyWith(
            color: AppColors.current.white,
          ),
        );
      case RsvpStatus.unknown:
        bg    = AppColors.current.rsvpNoResponse;
        child = Text(
          '?',
          style: AppTextStyles.heading15.copyWith(
            color: AppColors.current.textPrimary,
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
