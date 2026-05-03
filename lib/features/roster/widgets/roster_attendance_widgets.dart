import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/attendance_record.dart';

// ─── Attendance Row ───────────────────────────────────────────────────────────

class RosterAttendanceRow extends StatelessWidget {
  final AttendanceRecord record;
  final bool isLast;

  const RosterAttendanceRow({
    super.key,
    required this.record,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.current.gray100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.eventType,
                  style: AppTextStyles.body15.copyWith(
                    color: AppColors.current.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.date,
                  style: AppTextStyles.body13.copyWith(
                    color: AppColors.current.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          RosterStatusBadge(status: record.status),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class RosterStatusBadge extends StatelessWidget {
  final AttendanceStatus status;

  const RosterStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == AttendanceStatus.none) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.current.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.current.gray300,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Icon(Icons.help_outline, size: 20, color: AppColors.current.gray400),
      );
    }

    Color bg;
    IconData icon;

    switch (status) {
      case AttendanceStatus.going:
        bg   = AppColors.current.rsvpGoing;
        icon = Icons.check;
        break;
      case AttendanceStatus.no:
        bg   = AppColors.current.rsvpNo;
        icon = Icons.close;
        break;
      case AttendanceStatus.maybe:
        bg   = AppColors.current.rsvpMaybe;
        icon = Icons.help_outline;
        break;
      default:
        bg   = AppColors.current.gray100;
        icon = Icons.help_outline;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: Colors.white),
    );
  }
}
