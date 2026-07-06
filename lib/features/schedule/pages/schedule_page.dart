import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_empty_state.dart';
import '../widgets/event_list_tile.dart';
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
    final colors   = AppColors.current;

    Widget content;
    if (state.errorMessage != null && sections.isEmpty) {
      content = Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.rsvpNo),
              const SizedBox(height: 16),
              Text(
                'Failed to load schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(scheduleProvider.notifier).refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    } else if (state.isLoading && sections.isEmpty) {
      content = Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
        ),
      );
    } else if (sections.isEmpty) {
      content = const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: ScheduleEmptyState(),
        ),
      );
    } else {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: sections.length,
        itemBuilder: (_, i) {
          final section = sections[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduleSectionHeader(title: section.monthName),
              Container(height: 9, color: colors.surface),
              ...section.events.map((e) => ScheduleEventCard(event: e)),
              Container(height: 12, color: colors.surface),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(scheduleProvider.notifier).refresh(),
                color: colors.primary,
                backgroundColor: colors.card,
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
