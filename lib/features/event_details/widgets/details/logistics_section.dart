import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/event_detail_model.dart';

class LogisticsSection extends StatelessWidget {
  final EventDetailModel event;
  final VoidCallback onAssignmentsTap;

  const LogisticsSection({
    super.key,
    required this.event,
    required this.onAssignmentsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _LogisticsRow(
            icon: Icons.location_on_outlined,
            iconBgColor: colors.primaryLight,
            iconColor: colors.actionAccent,
            label: 'Location',
            value: event.locationName,
            subtitle: event.locationAddress,
            showArrow: true,
            borderBottom: true,
          ),
          _LogisticsRow(
            icon: Icons.person_outline,
            label: 'Uniform',
            value: event.uniform,
            borderBottom: true,
          ),
          _LogisticsRow(
            icon: Icons.swap_horiz,
            label: 'Home / Away',
            value: event.homeAway,
            borderBottom: true,
          ),
          _LogisticsRow(
            icon: Icons.star_border,
            label: 'Opponent',
            value: event.opponent,
            borderBottom: true,
          ),
          _LogisticsRow(
            icon: Icons.access_time,
            label: 'Arrival Time',
            value: event.arrivalTime,
            borderBottom: true,
          ),
          _LogisticsRow(
            icon: Icons.assignment_outlined,
            iconBgColor: colors.primaryLight,
            iconColor: colors.actionAccent,
            label: 'My Assignments',
            value: 'View or Add Tasks',
            showArrow: true,
            borderBottom: false,
            onTap: onAssignmentsTap,
          ),
        ],
      ),
    );
  }
}

class _LogisticsRow extends StatelessWidget {
  final IconData icon;
  final Color? iconBgColor;
  final Color? iconColor;
  final String label;
  final String value;
  final String? subtitle;
  final bool showArrow;
  final bool borderBottom;
  final VoidCallback? onTap;

  const _LogisticsRow({
    required this.icon,
    this.iconBgColor,
    this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.showArrow = false,
    this.borderBottom = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final resolvedIconBg = iconBgColor ?? colors.gray100;
    final resolvedIconColor = iconColor ?? colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: resolvedIconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: resolvedIconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.label12.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
