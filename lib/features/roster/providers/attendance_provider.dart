import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import 'roster_provider.dart'; // contains rosterServiceProvider
import '../models/attendance_record.dart';

export '../models/attendance_record.dart';

final attendanceProvider =
    FutureProvider.autoDispose.family<List<AttendanceRecord>, String>((ref, playerUuid) async {
  final activeTeam = ref.watch(selectedTeamProvider);
  if (activeTeam == null) {
    return const [];
  }

  final response = await ref
      .watch(rosterServiceProvider)
      .fetchPlayerAttendanceHistory(activeTeam.uuid, playerUuid);

  if (!response.success || response.data == null) {
    throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load attendance history');
  }

  final grid = response.data!.grid;
  return grid.map((event) {
    final opponent = event.opponent;
    final eventType = (opponent != null && opponent.isNotEmpty)
        ? '${event.eventName} • $opponent'
        : event.eventName;

    AttendanceStatus status;
    switch (event.attendance) {
      case 1:
        status = AttendanceStatus.going;
        break;
      case 2:
        status = AttendanceStatus.maybe;
        break;
      case 0:
        status = AttendanceStatus.no;
        break;
      default:
        status = AttendanceStatus.none;
    }

    return AttendanceRecord(
      id: event.uuid.isNotEmpty ? event.uuid : event.id.toString(),
      date: event.dateLabel,
      eventType: eventType,
      status: status,
    );
  }).toList();
});

