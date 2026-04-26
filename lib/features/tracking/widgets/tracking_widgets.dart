import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';
import '../models/tracking_assignment.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Section Label
// ══════════════════════════════════════════════════════════════════════════════

class TrackingSectionLabel extends StatelessWidget {
  final String title;
  const TrackingSectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.heading14.copyWith(
        color: AppColors.current.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Assignment List
// ══════════════════════════════════════════════════════════════════════════════

class TrackingAssignmentList extends StatelessWidget {
  final List<TrackingAssignment> assignments;
  const TrackingAssignmentList({super.key, required this.assignments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TrackingSectionLabel(title: 'Next Event Assignments'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.current.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.current.gray100),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: assignments.map((a) => TrackingAssignmentRow(
                    assignment: a,
                    isLast: a == assignments.last,
                  )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Assignment Row
// ══════════════════════════════════════════════════════════════════════════════

class TrackingAssignmentRow extends StatelessWidget {
  final TrackingAssignment assignment;
  final bool isLast;
  const TrackingAssignmentRow({
    super.key,
    required this.assignment,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = assignment.status == AssignmentStatus.completed;
    final statusColor =
        isDone ? AppColors.current.rsvpGoing : AppColors.current.gray400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.current.gray100)),
      ),
      child: Row(
        children: [
          // Left: title + assignee
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: AppTextStyles.body15.copyWith(
                    color: AppColors.current.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.body13.copyWith(
                      color: AppColors.current.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Assigned to: '),
                      TextSpan(
                        text: assignment.assignee,
                        style: AppTextStyles.body13.copyWith(
                          color: AppColors.current.gray700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: status
          Row(
            children: [
              Text(
                isDone ? 'Done' : 'Pending',
                style: AppTextStyles.heading13.copyWith(color: statusColor),
              ),
              const SizedBox(width: 6),
              CustomSvgIcon(
                assetPath: isDone
                    ? AppAssets.checkCircleIcon
                    : AppAssets.clockIcon,
                size: 20,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
