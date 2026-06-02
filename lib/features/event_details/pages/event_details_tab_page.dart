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

import '../../home/providers/home_provider.dart';
import '../../../core/common_providers/selected_team_provider.dart';

class EventDetailsTabPage extends ConsumerWidget {
  final String eventId;

  const EventDetailsTabPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventDetailProvider(eventId));
    final notifier = ref.read(eventDetailProvider(eventId).notifier);
    final colors = AppColors.current;
    final activeTeam = ref.watch(selectedTeamProvider);
    final isCoach = activeTeam?.isCoach ?? false;

    if (state.isLoading) {
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
      onRefresh: () async {
        final activeTeam = ref.read(selectedTeamProvider);
        if (activeTeam != null) {
          await ref.read(homeProvider.notifier).fetchEvents(activeTeam.uuid);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 20),
        child: Column(
          children: [
            EventHeaderCard(event: state.event, scheduleGameId: state.rawEvent?.scheduleGameId),
            const SizedBox(height: 16),
            // Use the same counts shown on the home list page for this event.
            // homeProvider.viewModels already applies the same attendance_counts
            // arithmetic used on the list screen, so the numbers always match.
            Builder(builder: (context) {
              final homeVm = ref
                  .watch(homeProvider)
                  .viewModels
                  .cast<HomeCardViewModel?>()
                  .firstWhere((vm) => vm?.id == eventId, orElse: () => null);

              final goingCount = homeVm?.goingCount
                  ?? state.rawEvent?.rsvpYes.length
                  ?? state.goingPlayers.length;
              final maybeCount = homeVm?.maybeCount
                  ?? state.rawEvent?.rsvpMaybe.length
                  ?? state.maybePlayers.length;
              final noCount = homeVm?.noCount
                  ?? state.rawEvent?.rsvpNo.length
                  ?? state.noPlayers.length;

              return RsvpSection(
                selected: state.event.myRsvp,
                onSelect: handleRsvpTap,
                goingCount: goingCount,
                maybeCount: maybeCount,
                noCount: noCount,
              );
            }),
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
                  onPressed: () => context.push('${AppRoutes.eventEdit(eventId)}?duplicate=true'),
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
