import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';

final attendanceServiceProvider =
    Provider<AttendanceService>((ref) => AttendanceService());

final attendanceProvider = FutureProvider<List<AttendanceRecord>>((ref) async {
  return ref.read(attendanceServiceProvider).getRecords();
});
