import '../models/attendance_record.dart';

class AttendanceService {
  List<AttendanceRecord> getRecords() => const [
        AttendanceRecord(name: 'Liam Anderson', position: 'GK #1', attendancePct: 92, attended: 11, total: 12),
        AttendanceRecord(name: 'Noah Williams', position: 'DEF #4', attendancePct: 88, attended: 10, total: 12),
        AttendanceRecord(name: 'Ethan Brown', position: 'DEF #5', attendancePct: 100, attended: 12, total: 12),
        AttendanceRecord(name: 'Mason Jones', position: 'MID #8', attendancePct: 75, attended: 9, total: 12),
        AttendanceRecord(name: 'Oliver Davis', position: 'MID #10', attendancePct: 96, attended: 11, total: 12),
        AttendanceRecord(name: 'James Miller', position: 'FWD #9', attendancePct: 83, attended: 10, total: 12),
        AttendanceRecord(name: 'Lucas Wilson', position: 'FWD #11', attendancePct: 91, attended: 11, total: 12),
        AttendanceRecord(name: 'Henry Thomas', position: 'MID #6', attendancePct: 100, attended: 12, total: 12),
        AttendanceRecord(name: 'Aiden Taylor', position: 'DEF #3', attendancePct: 67, attended: 8, total: 12),
      ];
}
