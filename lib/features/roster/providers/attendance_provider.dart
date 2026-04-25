import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';

final attendanceProvider =
    Provider.autoDispose.family<List<AttendanceRecord>, String>((ref, memberId) {
  return const [
    AttendanceRecord(id: '1', date: 'Feb 27', eventType: 'Practice', status: AttendanceStatus.going),
    AttendanceRecord(id: '2', date: 'Feb 28', eventType: 'Practice', status: AttendanceStatus.no),
    AttendanceRecord(id: '3', date: 'Mar 27', eventType: 'Practice', status: AttendanceStatus.maybe),
    AttendanceRecord(id: '4', date: 'Mar 28', eventType: 'Practice', status: AttendanceStatus.none),
    AttendanceRecord(id: '5', date: 'Mar 30', eventType: 'Game • @ OKC Energy 12G RL', status: AttendanceStatus.going),
    AttendanceRecord(id: '6', date: 'Apr 2',  eventType: 'Practice', status: AttendanceStatus.going),
    AttendanceRecord(id: '7', date: 'Apr 5',  eventType: 'Game • vs Tulsa FC 12G', status: AttendanceStatus.no),
  ];
});
