import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';
import '../../../core/models/club_event.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';
import '../../home/widgets/rsvp_player_selection_sheet.dart';
import 'my_rsvp_dialog.dart';
import 'schedule_tag_pill.dart';

class ScheduleEventCard extends ConsumerWidget {
  final ClubEvent event;
  final RsvpStatus? rsvpStatus;
  /// If provided, overrides the default navigation to event details.
  final VoidCallback? onTap;
  final bool showRsvp;
  final double horizontalPadding;

  const ScheduleEventCard({super.key, required this.event, this.rsvpStatus, this.onTap, this.showRsvp = true, this.horizontalPadding = 18});

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

  String _shortMonth(int month) => const [
        '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
      ][month];

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

      if (chosenStatus == null || !context.mounted) return;

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
      onTap: onTap ?? () => context.push('${AppRoutes.eventDetails(latestEvent.id)}?from=schedule', extra: latestEvent),
      child: Container(
        color: AppColors.current.surface,
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: horizontalPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
            IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date column
                _Col(
                  width: 74,
                  color: AppColors.current.card,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _shortMonth(event.dateTime.month),
                        style: AppTextStyles.overline.copyWith(
                          fontSize: 12,
                          color: AppColors.current.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${event.dateTime.day}',
                        style: AppTextStyles.dateNumber.copyWith(
                          fontSize: 24,
                          color: AppColors.current.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _shortDay(event.dateTime.weekday),
                        style: AppTextStyles.overline.copyWith(
                          fontSize: 12,
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
                        // Time
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 15,

                              color: AppColors.current.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                (latestEvent.startTimeLabel != null && latestEvent.startTimeLabel!.isNotEmpty)
                                    ? latestEvent.startTimeLabel!
                                    : _fmtTime(latestEvent.dateTime),
                                style: AppTextStyles.body13.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
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
                                    color: Colors.green.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Title
                        Text(
                          latestEvent.title,
                          style: AppTextStyles.body14.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.current.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Home/Away + league tag
                        Row(
                          children: [
                            if (latestEvent.homeAwayLabel != null && latestEvent.homeAwayLabel!.isNotEmpty) ...[
                              Text(
                                latestEvent.homeAwayLabel!,
                                style: AppTextStyles.body13.copyWith(
                                  color: AppColors.current.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (latestEvent.eventName?.isNotEmpty == true)
                              ScheduleTagPill(text: latestEvent.eventName!),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColors.current.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                latestEvent.location,
                                style: AppTextStyles.body13.copyWith(
                                  color: AppColors.current.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (showRsvp) ...[
                  Container(width: 1, color: AppColors.current.surface),

                  // RSVP column
                  GestureDetector(
                    onTap: latestEvent.status == 2 ? () {} : handleRsvpTap,
                    child: _Col(
                      width: 74,
                      color: AppColors.current.card,
                      child: _RsvpBox(status: status),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (latestEvent.status == 2)
            Container(
              width: double.infinity,
              color: AppColors.current.error,
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'Cancelled',
                textAlign: TextAlign.center,
                style: AppTextStyles.body13.copyWith(
                  height: 0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
