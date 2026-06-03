import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../models/event_detail_model.dart';
import '../widgets/event_detail_tab_bar.dart';
import 'event_details_tab_page.dart';
import 'event_availability_tab_page.dart';

// ─── Event Detail Shell ────────────────────────────────────────────────────────
// Renders SubHeader + tab bar; delegates content to the active tab page.

class EventDetailPage extends ConsumerWidget {
  final String eventId;
  final EventDetailTab activeTab;
  final String from;

  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.activeTab,
    this.from = 'home',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onRightTap: isCoach ? () => context.push('${AppRoutes.eventEdit(eventId)}?from=$from') : null,
            ),
            EventDetailTabBar(eventId: eventId, activeTab: activeTab, from: from),
            Expanded(
              child: switch (activeTab) {
                EventDetailTab.details      => EventDetailsTabPage(eventId: eventId),
                EventDetailTab.availability => EventAvailabilityTabPage(eventId: eventId),
              },
            ),
          ],
        ),
      ),
    );
  }
}
