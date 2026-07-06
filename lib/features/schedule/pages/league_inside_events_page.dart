import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/models/club_event.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
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
    final startStr = event.startDate != null ? _fmtDate(event.startDate!) : '';
    final endStr   = event.endDate != null
        ? '${_fmtDate(event.endDate!)}, ${event.endDate!.year}'
        : '';
    final dateRange = [startStr, endStr].where((s) => s.isNotEmpty).join(' – ');
    final dateLine  = [
      if (dateRange.isNotEmpty) dateRange,
      if (event.location.isNotEmpty) event.location,
    ].join(' · ');

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                    // ── Title + chip ─────────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF20242A),
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

                    // ── Date range + location ────────────────────────────────
                    if (dateLine.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF4E5663),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dateLine,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4E5663),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // ── Description ──────────────────────────────────────────
                    const Text(
                      'The whole league schedule lives here. Each game also shows on your main schedule, and final scores post as games finish. (Official standings are kept by your league, not in the app.)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4E5663),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Section header ───────────────────────────────────────
                    Text(
                      '${(event.schedulingModeLabel ?? 'League').toUpperCase()} SCHEDULE',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4E5663),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Game list (empty for now) ────────────────────────────
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No games yet',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4E5663),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Add a game button ────────────────────────────────────
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.newEvent),
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '+ Add a game',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
