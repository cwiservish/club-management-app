// ignore_for_file: depend_on_referenced_packages
import 'package:test/test.dart';
import 'package:playbook365/features/roster/providers/attendance_provider.dart';

void main() {
  group('AttendanceHistoryState Tests', () {
    test('initial state values are set correctly', () {
      final state = AttendanceHistoryState.initial();
      expect(state.records, isEmpty);
      expect(state.page, 1);
      expect(state.hasMore, true);
      expect(state.isLoading, false);
      expect(state.isLoadingMore, false);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates fields correctly', () {
      final state = AttendanceHistoryState.initial();
      final records = [
        const AttendanceRecord(
          id: '1',
          date: 'Mar 1',
          eventType: 'Practice',
          status: AttendanceStatus.going,
        )
      ];

      final updatedState = state.copyWith(
        records: records,
        page: 2,
        hasMore: false,
        isLoading: true,
        isLoadingMore: true,
        errorMessage: 'Test error',
      );

      expect(updatedState.records, records);
      expect(updatedState.page, 2);
      expect(updatedState.hasMore, false);
      expect(updatedState.isLoading, true);
      expect(updatedState.isLoadingMore, true);
      expect(updatedState.errorMessage, 'Test error');
    });

    test('copyWith keeps existing fields when null is passed', () {
      const records = [
        AttendanceRecord(
          id: '1',
          date: 'Mar 1',
          eventType: 'Practice',
          status: AttendanceStatus.going,
        )
      ];
      final state = AttendanceHistoryState(
        records: records,
        page: 3,
        hasMore: false,
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Previous error',
      );

      final updatedState = state.copyWith();

      expect(updatedState.records, records);
      expect(updatedState.page, 3);
      expect(updatedState.hasMore, false);
      expect(updatedState.isLoading, false);
      expect(updatedState.isLoadingMore, false);
      expect(updatedState.errorMessage, 'Previous error');
    });
  });
}
