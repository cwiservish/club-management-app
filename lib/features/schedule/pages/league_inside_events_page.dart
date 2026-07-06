import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../widgets/schedule_section_header.dart';
import '../widgets/schedule_tag_pill.dart';

class LeagueInsideEventsPage extends ConsumerWidget {
  final ClubEvent event;

  const LeagueInsideEventsPage({super.key, required this.event});

  String _fmtDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.current;

    final startStr = event.startDate != null ? _fmtDate(event.startDate!) : '';
    final endStr   = event.endDate   != null
        ? '${_fmtDate(event.endDate!)}, ${event.endDate!.year}'
        : '';
    final dateRange = [startStr, endStr].where((s) => s.isNotEmpty).join(' – ');
    final dateLine  = [
      if (dateRange.isNotEmpty) dateRange,
      if (event.location.isNotEmpty) event.location,
    ].join(' · ');

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: event.schedulingModeLabel ?? 'League Schedule',
              leftLabel: 'Schedule',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title + chip ────────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: AppTextStyles.heading20.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (event.schedulingModeLabel != null) ...[
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: ScheduleTagPill(text: event.schedulingModeLabel!),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // ── Date range + location ───────────────────────────────
                    if (dateLine.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dateLine,
                              style: AppTextStyles.body13.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // ── Description ─────────────────────────────────────────
                    Text(
                      'The whole league schedule lives here. Each game also shows on your main schedule, and final scores post as games finish.',
                      style: AppTextStyles.body13.copyWith(
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Section header ──────────────────────────────────────
                    ScheduleSectionHeader(
                      title: '${event.schedulingModeLabel ?? 'League'} schedule',
                    ),
                    const SizedBox(height: 8),

                    // ── Game list (empty for now) ───────────────────────────
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No games yet',
                          style: AppTextStyles.body14.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Add a game button ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.newEvent),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '+ Add a game',
                          style: AppTextStyles.heading15.copyWith(
                            color: colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
