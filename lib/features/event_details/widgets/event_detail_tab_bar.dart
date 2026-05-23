import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../models/event_detail_model.dart';

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class EventDetailTabBar extends ConsumerWidget {
  final String eventId;
  final EventDetailTab activeTab;

  const EventDetailTabBar({
    super.key,
    required this.eventId,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final colors = AppColors.current;

    return Container(
      color: colors.background,
      child: Row(
        children: [
          EventDetailTabItem(
            label:    'Details',
            isActive: activeTab == EventDetailTab.details,
            onTap:    () => context.replace(AppRoutes.eventDetails(eventId)),
            colors:   colors,
          ),
          EventDetailTabItem(
            label:    'Availability',
            isActive: activeTab == EventDetailTab.availability,
            onTap:    () => context.replace(AppRoutes.eventAvailability(eventId)),
            colors:   colors,
          ),
        ],
      ),
    );
  }
}

// ─── Tab Item ─────────────────────────────────────────────────────────────────

class EventDetailTabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppColors colors;

  const EventDetailTabItem({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTextStyles.body14.copyWith(
                  color: isActive
                      ? colors.actionAccent
                      : colors.textSecondary,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isActive
                      ? colors.actionAccent
                      : Colors.transparent,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
