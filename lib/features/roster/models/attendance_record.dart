class AttendanceRecord {
  final String name;
  final String position;
  final int attendancePct;
  final int attended;
  final int total;

  const AttendanceRecord({
    required this.name,
    required this.position,
    required this.attendancePct,
    required this.attended,
    required this.total,
  });
}
