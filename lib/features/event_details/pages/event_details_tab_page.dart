import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/event_detail_provider.dart';
import '../widgets/details/event_header_card.dart';
import '../widgets/details/rsvp_section.dart';
import '../widgets/details/logistics_section.dart';

class EventDetailsTabPage extends ConsumerWidget {
  final String eventId;

  const EventDetailsTabPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventDetailProvider(eventId));
    final notifier = ref.read(eventDetailProvider(eventId).notifier);
    final colors = AppColors.current;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 20),
      child: Column(
        children: [
          EventHeaderCard(event: state.event),
          const SizedBox(height: 16),
          RsvpSection(
            selected: state.event.myRsvp,
            onSelect: notifier.setRsvp,
          ),
          const SizedBox(height: 16),
          LogisticsSection(
            event: state.event,
            onAssignmentsTap: () =>
                context.go(AppRoutes.eventAssignments(eventId)),
          ),
          const SizedBox(height: 20),
          // ── Duplicate Event button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.copy_outlined, size: 18, color: colors.textSecondary),
              label: Text(
                'Duplicate Event',
                style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.border),
                backgroundColor: colors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
