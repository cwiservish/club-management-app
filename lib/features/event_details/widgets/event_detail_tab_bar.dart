import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/models/club_event.dart';
import '../models/event_detail_model.dart';

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class EventDetailTabBar extends ConsumerWidget {
  final String eventId;
  final EventDetailTab activeTab;
  final String from;
  final VoidCallback? onEditTap;
  final ClubEvent? initialEvent;

  const EventDetailTabBar({
    super.key,
    required this.eventId,
    required this.activeTab,
    this.from = 'home',
    this.onEditTap,
    this.initialEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final colors = AppColors.current;
    final tabExtra = (onEditTap != null || initialEvent != null)
        ? {
            if (initialEvent != null) 'event': initialEvent,
            if (onEditTap != null) 'onEditTap': onEditTap,
          }
        : null;

    return Container(
      color: colors.background,
      child: Row(
        children: [
          EventDetailTabItem(
            label:    'Details',
            isActive: activeTab == EventDetailTab.details,
            onTap:    () => context.replace('${AppRoutes.eventDetails(eventId)}?from=$from', extra: tabExtra),
            colors:   colors,
          ),
          EventDetailTabItem(
            label:    'Availability',
            isActive: activeTab == EventDetailTab.availability,
            onTap:    () => context.replace('${AppRoutes.eventAvailability(eventId)}?from=$from', extra: tabExtra),
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
