import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/home_provider.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
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
                        style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary)),
                    Text(viewModel.timeRange,
                        style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary)),
                    Text(viewModel.type,
                        style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary)),
                    Text(viewModel.location,
                        style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary)),

                    const SizedBox(height: 14),

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
                          color:      AppColors.current.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const MapSection(),
            ],
          ),
        ),
      ),
    );
  }
}
