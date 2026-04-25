import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../models/attendance_record.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryPage extends ConsumerWidget {
  final String memberId;
  const AttendanceHistoryPage({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final records = ref.watch(attendanceProvider(memberId));

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: '',
              leftLabel: 'Player',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance History',
                      style: AppTextStyles.heading22.copyWith(
                        fontSize: 24,
                        color: AppColors.current.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.current.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.current.border.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: records.map((record) {
                          final isLast = record == records.last;
                          return _AttendanceRow(record: record, isLast: isLast);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final AttendanceRecord record;
  final bool isLast;
  const _AttendanceRow({required this.record, required this.isLast});

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
          _StatusBadge(status: record.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AttendanceStatus status;
  const _StatusBadge({required this.status});

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
        bg = AppColors.current.rsvpGoing;
        icon = Icons.check;
        break;
      case AttendanceStatus.no:
        bg = AppColors.current.rsvpNo;
        icon = Icons.close;
        break;
      case AttendanceStatus.maybe:
        bg = AppColors.current.rsvpMaybe;
        icon = Icons.help_outline;
        break;
      default:
        bg = AppColors.current.gray100;
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
