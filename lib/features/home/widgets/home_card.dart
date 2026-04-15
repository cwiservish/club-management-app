import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/home_provider.dart';
import 'rsvp_row.dart';
import 'map_section.dart';

// ─── Home Card ────────────────────────────────────────────────────────────────
// Pure display widget — receives a pre-computed HomeCardViewModel.
// All RSVP toggle and count logic lives in HomeNotifier (home_provider.dart).

class HomeCard extends ConsumerWidget {
  final HomeCardViewModel viewModel;
  final VoidCallback? onEventDetails;

  const HomeCard({
    super.key,
    required this.viewModel,
    this.onEventDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── White top section ────────────────────────────────────────
              Container(
                width: double.infinity,
                color: colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.date,
                      style: AppTextStyles.body16
                          .copyWith(color: colorScheme.onSurface),
                    ),
                    Text(
                      viewModel.timeRange,
                      style: AppTextStyles.body16
                          .copyWith(color: colorScheme.onSurface),
                    ),
                    Text(
                      viewModel.type,
                      style: AppTextStyles.body16
                          .copyWith(color: colorScheme.onSurface),
                    ),
                    Text(
                      viewModel.location,
                      style: AppTextStyles.body16
                          .copyWith(color: colorScheme.onSurface),
                    ),

                    const SizedBox(height: 14),

                    // RSVP row — delegates tap to provider
                    RsvpRow(
                      goingCount: viewModel.goingCount,
                      maybeCount: viewModel.maybeCount,
                      noCount:    viewModel.noCount,
                      selected:   viewModel.selectedRsvp,
                      onSelect: (rsvp) => ref
                          .read(homeProvider.notifier)
                          .toggleRsvp(viewModel.id, rsvp),
                    ),

                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: onEventDetails,
                      child: Text(
                        'Event Details',
                        style: AppTextStyles.bodySmall.copyWith(
                          color:      colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Map section ──────────────────────────────────────────────
              const MapSection(),
            ],
          ),
        ),
      ),
    );
  }
}
