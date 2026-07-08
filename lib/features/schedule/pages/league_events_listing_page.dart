import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../models/league_detail_models.dart';
import '../providers/league_detail_provider.dart';
import '../widgets/event_list_tile.dart';
import '../widgets/schedule_tag_pill.dart';

class LeagueEventsListingPage extends ConsumerStatefulWidget {
  final ClubEvent? event;

  const LeagueEventsListingPage({super.key, this.event});

  @override
  ConsumerState<LeagueEventsListingPage> createState() => _LeagueEventsListingPageState();
}

class _LeagueEventsListingPageState extends ConsumerState<LeagueEventsListingPage> {

  LeagueDetailArgs? _args;
  bool _refreshing = true;
  ClubEvent? _event;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) _event = widget.event;
    final dbId = _event?.dbId;
    if (dbId != null) {
      _args = LeagueDetailArgs(
        eventDbId: dbId,
        schedulingMode: _event!.schedulingMode,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(leagueDetailProvider(_args!));
        if (mounted) setState(() => _refreshing = false);
      });
    } else {
      _refreshing = false;
    }
  }

  @override
  void didUpdateWidget(LeagueEventsListingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update _event when a real (non-null) event is provided.
    // On theme-change rebuilds GoRouter passes null extra → keep existing _event.
    if (widget.event != null) _event = widget.event;
  }

  String _fmtDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month]} ${dt.day}';
  }

  @override
  void reassemble() {
    super.reassemble();
    if (_args != null) {
      setState(() => _refreshing = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(leagueDetailProvider(_args!));
        if (mounted) setState(() => _refreshing = false);
      });
    }
  }

  Future<void> _refresh() async {
    if (_args == null) return;
    ref.invalidate(leagueDetailProvider(_args!));
    // Wait for the provider to finish loading
    await ref.read(leagueDetailProvider(_args!).future).catchError((_) {});
  }

  Widget _buildGameList() {
    if (_refreshing || _args == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    final state = ref.watch(leagueDetailProvider(_args!));

    return state.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (_, __) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load games',
                style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => ref.invalidate(leagueDetailProvider(_args!)),
                child: Text(
                  'Retry',
                  style: AppTextStyles.body14.copyWith(color: AppColors.current.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (result) => result.childSessions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No games yet',
                  style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
                ),
              ),
            )
          : Column(
              children: result.childSessions.map((childEvent) => ScheduleEventCard(
                event: childEvent,
                horizontalPadding: 0,
              )).toList(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    if (event == null) return const SizedBox.shrink();
    final startStr = event.startDate != null ? _fmtDate(event.startDate!) : '';
    final endStr   = event.endDate != null
        ? '${_fmtDate(event.endDate!)}, ${event.endDate!.year}'
        : '';
    final dateRange = [startStr, endStr].where((s) => s.isNotEmpty).join(' – ');
    final dateLine  = [
      if (dateRange.isNotEmpty) dateRange,
      if (event.location.isNotEmpty) event.location,
    ].join(' · ');

    final colors = AppColors.current;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: event.schedulingModeLabel ?? 'League Schedule',
              leftLabel: 'Schedule',
              rightText: 'Edit',
              onRightTap: () => context.push(
                AppRoutes.eventEdit(event.dbId?.toString() ?? ''),
                extra: {'event': event, 'from': 'schedule'},
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                              style: AppTextStyles.heading20.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
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
                            Icon(Icons.calendar_today_outlined, size: 14, color: colors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dateLine,
                                style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),

                      // ── Description ──────────────────────────────────────────
                      Text(
                        'The whole league schedule lives here. Each game also shows on your main schedule, and final scores post as games finish. (Official standings are kept by your league, not in the app.)',
                        style: AppTextStyles.body13.copyWith(color: colors.textSecondary, height: 1.45),
                      ),
                      const SizedBox(height: 20),

                      // ── Section header ───────────────────────────────────────
                      Text(
                        '${(event.schedulingModeLabel ?? 'League').toUpperCase()} SCHEDULE',
                        style: AppTextStyles.heading14.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 8),

                      // ── Game list ────────────────────────────────────────────
                      _buildGameList(),

                      const SizedBox(height: 12),

                      // ── Add a game button ────────────────────────────────────
                      GestureDetector(
                        onTap: () => context.push(
                          AppRoutes.newEvent,
                          extra: {
                            'origin': 'schedule',
                            'defaultSchedulingTypeKey': 1,
                            'defaultEventTypeKey': 1,
                            'parentEvent': event,
                            'title': 'Add Game',
                          },
                        ),
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+ Add a game',
                            style: AppTextStyles.heading16.copyWith(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
