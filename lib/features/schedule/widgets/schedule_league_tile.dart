import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';
import 'schedule_tag_pill.dart';

class ScheduleLeagueTile extends StatelessWidget {
  final ClubEvent event;

  const ScheduleLeagueTile({super.key, required this.event});

  String _shortMonth(int month) => const [
        '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
      ][month];

  @override
  Widget build(BuildContext context) {
    const dateTextColor = Color(0xFF3B76E7);
    const dateBgColor = Color(0xFFE6E8FF);

    final pillLabel = event.schedulingModeLabel != null && event.schedulingModeLabel!.isNotEmpty
        ? '${event.schedulingModeLabel} · full schedule'
        : 'Full schedule';

    return GestureDetector(
      onTap: () => context.push('${AppRoutes.eventDetails(event.id)}?from=schedule', extra: event),
      child: Container(
        color: AppColors.current.surface,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date column
                Container(
                  width: 71,
                  color: dateBgColor,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _shortMonth(event.dateTime.month),
                        style: AppTextStyles.overline.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: dateTextColor,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        '${event.dateTime.day}',
                        style: AppTextStyles.overline.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: dateTextColor,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        event.eventDuration ?? '',
                        style: AppTextStyles.overline.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: dateTextColor,
                          height: 1.0,
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
                        ScheduleTagPill(text: pillLabel),
                        const SizedBox(height: 5),
                        Text(
                          event.title,
                          style: AppTextStyles.body14.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.current.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to see the whole league schedule',
                          style: AppTextStyles.body13.copyWith(
                            color: AppColors.current.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
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
                                event.location,
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
                Container(width: 1, color: AppColors.current.surface),

                // Chevron column
                Container(
                  width: 40,
                  color: AppColors.current.card,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.current.textSecondary,
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
