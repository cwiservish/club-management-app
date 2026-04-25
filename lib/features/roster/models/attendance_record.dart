enum AttendanceStatus { going, no, maybe, none }

class AttendanceRecord {
  final String id;
  final String date;
  final String eventType;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.id,
    required this.date,
    required this.eventType,
    required this.status,
  });
}
