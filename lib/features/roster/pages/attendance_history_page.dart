import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../providers/attendance_provider.dart';

class PlayerAttendanceScreen extends ConsumerWidget {
  const PlayerAttendanceScreen({super.key});

  static Color _color(int pct) => pct >= 90
      ? const Color(0xFF10B981)
      : pct >= 75
          ? const Color(0xFFF59E0B)
          : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(attendanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Player Attendance')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) => ListView(
          padding: const EdgeInsets.all(16),
          children: records.map((r) => _AttendanceCard(record: r)).toList(),
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceCard({required this.record});

  static Color _color(int pct) => pct >= 90
      ? const Color(0xFF10B981)
      : pct >= 75
          ? const Color(0xFFF59E0B)
          : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final color = _color(record.attendancePct);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827))),
                    Text(record.position,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              Text('${record.attendancePct}',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const Text('%',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF9CA3AF))),
              const SizedBox(width: 8),
              Text('${record.attended}/${record.total}',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: record.attendancePct / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
