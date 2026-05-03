import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';

export '../models/attendance_record.dart';

final attendanceServiceProvider =
    Provider<AttendanceService>((ref) => AttendanceService());

final attendanceProvider =
    Provider.autoDispose.family<List<AttendanceRecord>, String>((ref, memberId) {
  return ref.read(attendanceServiceProvider).getAttendance(memberId);
});
