import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../home/widgets/rsvp_player_selection_sheet.dart';
import '../providers/event_detail_provider.dart';
import '../widgets/details/event_header_card.dart';
import '../widgets/details/rsvp_section.dart';
import '../widgets/details/logistics_section.dart';

import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/models/club_event.dart';

class EventDetailsTabPage extends ConsumerWidget {
  final String eventId;
  final ClubEvent? initialEvent;

  const EventDetailsTabPage({super.key, required this.eventId, this.initialEvent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventDetailProvider(EventDetailArgs(eventId, initialEvent)));
    final notifier = ref.read(eventDetailProvider(EventDetailArgs(eventId, initialEvent)).notifier);
    final colors = AppColors.current;
    final activeTeam = ref.watch(selectedTeamProvider);
    final isCoach = activeTeam?.isCoach ?? false;
    final isCancelled = (state.rawEvent?.status ?? initialEvent?.status ?? 1) == 2;

    // Only block the UI on the very first load when there is no data to show yet
    if (state.isLoading && state.rawEvent == null) {
      return ColoredBox(
        color: colors.card,
        child: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
          ),
        ),
      );
    }

    Future<void> handleRsvpTap(String rsvpValue) async {
      final rawEvent = state.rawEvent;
      if (rawEvent == null) {
        notifier.setRsvp(rsvpValue);
        return;
      }

      if (rawEvent.requiresPlayerSelection && rawEvent.rsvpTargets.length > 1) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => RsvpPlayerSelectionSheet(
            targets: rawEvent.rsvpTargets,
            onSelected: (target) async {
              final result = await notifier.saveEventRsvp(
                target: target,
                rsvp: rsvpValue,
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
        return;
      }

      if (rawEvent.rsvpTargets.isNotEmpty) {
        final result = await notifier.saveEventRsvp(
          target: rawEvent.rsvpTargets.first,
          rsvp: rsvpValue,
        );
        if (!result.success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.current.error,
            ),
          );
        }
      } else {
        notifier.setRsvp(rsvpValue);
      }
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 20),
        child: Column(
          children: [
            EventHeaderCard(event: state.event, scheduleGameId: state.rawEvent?.scheduleGameId),
            const SizedBox(height: 16),
            RsvpSection(
              selected: state.event.myRsvp,
              onSelect: handleRsvpTap,
              goingCount: state.goingCount,
              maybeCount: state.maybeCount,
              noCount: state.noCount,
              enabled: !isCancelled,
            ),
            const SizedBox(height: 16),
            LogisticsSection(
              event: state.event,
            ),
            if (isCoach) ...[
              const SizedBox(height: 20),
              // ── Duplicate Event button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.eventEdit(eventId),
                    extra: {'event': state.rawEvent, 'duplicate': true},
                  ),
                  icon: Icon(Icons.copy_outlined, size: 18, color: colors.textSecondary),
                  label: Text(
                    'Duplicate Event',
                    style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border),
                    backgroundColor: colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
        ],
      ),
    ),
  );
}
}
