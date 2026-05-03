import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_empty_state.dart';
import '../widgets/schedule_event_card.dart';
import '../widgets/schedule_section_header.dart';

// ─── Schedule Screen ──────────────────────────────────────────────────────────
// Pure display — all grouping/sorting logic lives in ScheduleState.monthSections.

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final state    = ref.watch(scheduleProvider);
    final sections = state.monthSections;

    return Scaffold(
      backgroundColor: AppColors.current.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: sections.isEmpty
                  ? const ScheduleEmptyState()
                  : ListView.builder(
                      padding:   EdgeInsets.zero,
                      itemCount: sections.length,
                      itemBuilder: (_, i) {
                        final section = sections[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScheduleSectionHeader(title: section.monthName),
                            Container(height: 9, color: AppColors.current.surface),
                            ...section.events.map((e) => ScheduleEventCard(event: e)),
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
}
