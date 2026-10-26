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
import '../../../core/common_providers/event_refresh_provider.dart';
import '../models/new_event_dropdown_options_model.dart';
import '../services/event_detail_service.dart';
import '../widgets/slot_board_sheet.dart';

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
    // Status 5 = draft saved by a coach; a manager confirms it.
    final isDraft = (state.rawEvent?.status ?? initialEvent?.status ?? 1) == 5;
    final isManager = activeTeam?.isManager ?? false;

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
      if (rawEvent != null && !rawEvent.canRsvp) return;
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

    Future<void> confirmDraft() async {
      final event = state.rawEvent ?? initialEvent;
      final team = activeTeam;
      if (event == null || team == null) return;
      final service = ref.read(eventDetailServiceProvider);

      // A recurring draft: confirm just this date or every draft of the series.
      var useSeries = false;
      if (event.recurringType != 1 && event.code.isNotEmpty) {
        final choice = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm recurring event'),
            content: const Text('Confirm this date only, or every draft date of the series?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, 'one'), child: const Text('This date only')),
              TextButton(onPressed: () => Navigator.pop(ctx, 'series'), child: const Text('All dates')),
            ],
          ),
        );
        if (choice == null || !context.mounted) return;
        useSeries = choice == 'series';
      }
      final id = event.dbId;
      final code = useSeries ? event.code : null;

      // Our Facilities: show the board so the manager sees any clash before confirming.
      if (event.locationType == 1) {
        try {
          final board = await service.generateSlots({
            'team_uuid': team.uuid,
            if (code != null) 'code': code else 'id': id,
            'for_confirm': 1,
          });
          if (!context.mounted) return;
          final ok = await SlotBoardSheet.show(
            context,
            service: service,
            teamUuid: team.uuid,
            venue: OurLocationVenue(
              venueId: event.venueId ?? 0,
              name: event.location,
              label: event.location,
              latitude: event.latitude ?? '',
              longitude: event.longitude ?? '',
              fields: const [],
            ),
            board: board,
            saveLabel: 'Confirm',
            readOnly: true,
          );
          if (ok == null || !context.mounted) return;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
          return;
        }
      }

      final result = await service.confirmSession(teamUuid: team.uuid, id: code == null ? id : null, code: code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success
              ? 'Confirmed - families will be notified'
              : (result.message.isNotEmpty ? result.message : 'Could not confirm')),
          backgroundColor: result.success ? AppColors.current.success : AppColors.current.error,
        ),
      );
      if (result.success) {
        ref.read(eventRefreshSignalProvider.notifier).signal();
        // The detail page holds its own copy of the row: clear the Draft state now so the
        // banner, Confirm button and RSVP buttons update without leaving the page.
        notifier.syncRawEvent(event.copyWith(status: 1, canRsvp: event.rsvpTargets.isNotEmpty));
        await notifier.refresh();
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
            if (isDraft) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Draft: Waiting for approval',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF8A6D00)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isManager
                          ? 'This session was saved by a coach. Confirm it to hold the field and open RSVPs.'
                          : 'A manager needs to approve this session. RSVP opens once it is approved.',
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF8A6D00), height: 1.35),
                    ),
                    if (isManager) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: confirmDraft,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5BD1F),
                          foregroundColor: const Color(0xFF1A1D20),
                          elevation: 0,
                        ),
                        child: const Text('Confirm session', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            RsvpSection(
              selected: state.event.myRsvp,
              onSelect: handleRsvpTap,
              goingCount: state.goingCount,
              maybeCount: state.maybeCount,
              noCount: state.noCount,
              enabled: !isCancelled && !isDraft && (state.rawEvent?.canRsvp ?? true),
            ),
            const SizedBox(height: 16),
            LogisticsSection(
              event: state.event,
            ),
            const SizedBox(height: 40),
        ],
      ),
    ),
  );
}
}
