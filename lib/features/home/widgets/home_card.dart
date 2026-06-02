import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/club_event.dart';
import '../models/home_models.dart';
import '../providers/home_provider.dart';
import 'rsvp_player_selection_sheet.dart';
import 'rsvp_row.dart';
import 'map_section.dart';

// ─── Home Card ────────────────────────────────────────────────────────────────

class HomeCard extends ConsumerWidget {
  final HomeCardViewModel viewModel;
  final VoidCallback? onEventDetails;

  const HomeCard({
    super.key,
    required this.viewModel,
    this.onEventDetails,
  });

  // ── RSVP handling ──────────────────────────────────────────────────────────

  Future<void> _handleRsvpTap(
    BuildContext context,
    WidgetRef ref,
    HomeRsvp rsvp,
  ) async {
    final notifier = ref.read(homeProvider.notifier);

    // If player selection is required AND there are multiple targets, show sheet.
    if (viewModel.requiresPlayerSelection && viewModel.rsvpTargets.length > 1) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => RsvpPlayerSelectionSheet(
          targets: viewModel.rsvpTargets,
          onSelected: (target) => _saveRsvp(context, ref, notifier, rsvp, target),
        ),
      );
      return;
    }

    // Single target (or no player-selection requirement) — use first target or
    // fall back to a local-only toggle when no targets are available.
    if (viewModel.rsvpTargets.isNotEmpty) {
      await _saveRsvp(context, ref, notifier, rsvp, viewModel.rsvpTargets.first);
    } else {
      // Fallback: local optimistic toggle only (no server call possible)
      notifier.toggleRsvp(viewModel.id, rsvp);
    }
  }

  Future<void> _saveRsvp(
    BuildContext context,
    WidgetRef ref,
    HomeNotifier notifier,
    HomeRsvp rsvp,
    ClubEventRsvpTarget target,
  ) async {
    // Look up the full ClubEvent for the notifier call
    final event = ref.read(homeProvider).events.firstWhere(
      (e) => e.id == viewModel.id,
      orElse: () => throw StateError('Event ${viewModel.id} not found'),
    );

    final result = await notifier.saveEventRsvp(
      event: event,
      target: target,
      rsvp: rsvp,
    );

    if (!result.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.current.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.current.card,
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(viewModel.date,
                            style: AppTextStyles.heading18.copyWith(color: AppColors.current.textPrimary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(viewModel.timeRange,
                            style: AppTextStyles.heading18.copyWith(color: AppColors.current.textPrimary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10), // Spacing between time and event name
                        Text(viewModel.type,
                            style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary)),
                        const SizedBox(height: 2),
                        Text(viewModel.location,
                            style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary)),

                        const SizedBox(height: 14),

                        RsvpRow(
                          goingCount: viewModel.goingCount,
                          maybeCount: viewModel.maybeCount,
                          noCount:    viewModel.noCount,
                          selected:   viewModel.selectedRsvp,
                          onSelect: (rsvp) => _handleRsvpTap(context, ref, rsvp),
                        ),

                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: onEventDetails,
                          child: Text(
                            'Event Details',
                            style: AppTextStyles.body13.copyWith(
                              color:      AppColors.current.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  MapSection(
                    latitude:  viewModel.latitude,
                    longitude: viewModel.longitude,
                    location:  viewModel.location,
                  ),
                ],
              ),
              if (viewModel.scheduleGameId != null)
                Positioned(
                  top: 20,
                  right: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Event Game',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:Colors.green,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
