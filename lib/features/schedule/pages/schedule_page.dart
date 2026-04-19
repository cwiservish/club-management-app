import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_event_card.dart';
import '../widgets/schedule_section_header.dart';
import '../../../core/models/club_event.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final state         = ref.watch(scheduleProvider);
    final groupedEvents = _groupEventsByMonth(state.filtered);
    final sortedMonths  = groupedEvents.keys.toList()
      ..sort((a, b) => (a.year != b.year)
          ? a.year.compareTo(b.year)
          : a.month.compareTo(b.month));

    return Scaffold(
      backgroundColor: AppColors.current.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: state.filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: sortedMonths.length,
                      itemBuilder: (context, index) {
                        final monthDate   = sortedMonths[index];
                        final monthEvents = groupedEvents[monthDate]!;
                        final monthName   = _getMonthName(monthDate.month);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScheduleSectionHeader(title: monthName),
                            Container(height: 9, color: AppColors.current.surface),
                            ...monthEvents.map((e) => ScheduleEventCard(event: e)),
                            Container(height: 12, color: AppColors.current.surface),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<ClubEvent>> _groupEventsByMonth(List<ClubEvent> events) {
    final Map<DateTime, List<ClubEvent>> groups = {};
    for (final event in events) {
      final monthDate = DateTime(event.dateTime.year, event.dateTime.month);
      groups.putIfAbsent(monthDate, () => []).add(event);
    }
    for (final month in groups.keys) {
      groups[month]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
    return groups;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 48,
              color: AppColors.current.textPrimary.withOpacity(0.25)),
          const SizedBox(height: 16),
          Text('No events scheduled',
              style: AppTextStyles.heading14.copyWith(
                  color: AppColors.current.textPrimary.withOpacity(0.45))),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'January', 'February', 'March',    'April',
      'May',     'June',     'July',     'August',
      'September','October', 'November', 'December',
    ];
    return names[month - 1];
  }
}
