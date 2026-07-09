import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/models/club_event.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../models/event_detail_model.dart';
import '../providers/event_detail_provider.dart';
import '../widgets/event_detail_tab_bar.dart';
import 'event_details_tab_page.dart';
import 'event_availability_tab_page.dart';

// ─── Event Detail Shell ────────────────────────────────────────────────────────
// Renders SubHeader + tab bar; delegates content to the active tab page.

class EventDetailPage extends ConsumerStatefulWidget {
  final String eventId;
  final EventDetailTab activeTab;
  final String from;
  final ClubEvent? initialEvent;
  final VoidCallback? onEditTap;

  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.activeTab,
    this.from = 'home',
    this.initialEvent,
    this.onEditTap,
  });

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    // Each time this page is pushed, sync the rawEvent so that RSVP counts
    // reflect any changes the user made on the home page since last visit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(eventDetailProvider(EventDetailArgs(widget.eventId, widget.initialEvent)).notifier)
          .syncRawEvent(widget.initialEvent);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final activeTeam = ref.watch(selectedTeamProvider);
    final isCoach = activeTeam?.isCoach ?? false;

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title:      'Event Details',
              rightText:  isCoach ? 'Edit' : null,
              onRightTap: isCoach
                  ? (widget.onEditTap ?? () => context.push(AppRoutes.eventEdit(widget.eventId), extra: {'event': widget.initialEvent, 'from': widget.from}))
                  : null,
            ),
            EventDetailTabBar(eventId: widget.eventId, activeTab: widget.activeTab, from: widget.from, onEditTap: widget.onEditTap, initialEvent: widget.initialEvent),
            Expanded(
              child: switch (widget.activeTab) {
                EventDetailTab.details      => EventDetailsTabPage(eventId: widget.eventId, initialEvent: widget.initialEvent),
                EventDetailTab.availability => EventAvailabilityTabPage(eventId: widget.eventId, initialEvent: widget.initialEvent),
              },
            ),
          ],
        ),
      ),
    );
  }
}
