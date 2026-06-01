import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import 'roster_provider.dart'; // contains rosterServiceProvider
import '../models/attendance_record.dart';

export '../models/attendance_record.dart';

class AttendanceHistoryState {
  final List<AttendanceRecord> records;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  const AttendanceHistoryState({
    required this.records,
    required this.page,
    required this.hasMore,
    required this.isLoading,
    required this.isLoadingMore,
    this.errorMessage,
  });

  factory AttendanceHistoryState.initial() {
    return const AttendanceHistoryState(
      records: [],
      page: 1,
      hasMore: true,
      isLoading: false,
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  AttendanceHistoryState copyWith({
    List<AttendanceRecord>? records,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return AttendanceHistoryState(
      records: records ?? this.records,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage, // Allows setting to null explicitly if we want
    );
  }
}

class AttendanceHistoryNotifier extends Notifier<AttendanceHistoryState> {
  final String playerUuid;
  AttendanceHistoryNotifier(this.playerUuid);

  @override
  AttendanceHistoryState build() {
    final activeTeam = ref.watch(selectedTeamProvider);
    if (activeTeam != null) {
      // Load first page reactively when team changes or is first selected
      Future.microtask(() => fetchNextPage(isRefresh: true));
    }
    return AttendanceHistoryState.initial().copyWith(isLoading: activeTeam != null);
  }

  Future<void> fetchNextPage({bool isRefresh = false}) async {
    // If not refreshing, and we already know there's no more, or we're loading, do nothing.
    if (!isRefresh && (!state.hasMore || state.isLoadingMore || state.isLoading)) {
      return;
    }

    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) return;

    final nextPage = isRefresh ? 1 : state.page + 1;

    if (isRefresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);
    }

    try {
      final response = await ref.read(rosterServiceProvider).fetchPlayerAttendanceHistory(
        activeTeam.uuid,
        playerUuid,
        page: nextPage,
        limit: 20,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load attendance history');
      }

      final grid = response.data!.grid;
      final newRecords = grid.map((event) {
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

      final allRecords = isRefresh ? newRecords : [...state.records, ...newRecords];
      final total = response.data!.total;
      
      // We have more if the total records count on the server exceeds the number of records we have loaded
      // AND we actually received some records in the current page (to avoid infinite loops on misaligned totals)
      final hasMore = allRecords.length < total && newRecords.isNotEmpty;

      state = state.copyWith(
        records: allRecords,
        page: nextPage,
        hasMore: hasMore,
        isLoading: false,
        isLoadingMore: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await fetchNextPage(isRefresh: true);
  }
}

final attendanceProvider =
    NotifierProvider.family<AttendanceHistoryNotifier, AttendanceHistoryState, String>(
  AttendanceHistoryNotifier.new,
);
