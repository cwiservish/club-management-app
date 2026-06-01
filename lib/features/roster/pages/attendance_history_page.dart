import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/attendance_provider.dart';
import '../widgets/roster_attendance_widgets.dart';

class AttendanceHistoryPage extends ConsumerStatefulWidget {
  final String memberId;
  const AttendanceHistoryPage({super.key, required this.memberId});

  @override
  ConsumerState<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends ConsumerState<AttendanceHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      // Fetch when within 200 pixels of the bottom
      if (maxScroll - currentScroll <= 200) {
        ref.read(attendanceProvider(widget.memberId).notifier).fetchNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final state = ref.watch(attendanceProvider(widget.memberId));

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            const SubHeader(title: '', leftLabel: 'Player'),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.current.primary,
                onRefresh: () => ref.read(attendanceProvider(widget.memberId).notifier).refresh(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance History',
                        style: AppTextStyles.heading22.copyWith(
                          fontSize: 24,
                          color: AppColors.current.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContent(state),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AttendanceHistoryState state) {
    if (state.isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.current.primary,
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.records.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.current.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load attendance history',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.current.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.current.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.current.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => ref.read(attendanceProvider(widget.memberId).notifier).refresh(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.records.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 64,
                color: AppColors.current.gray400,
              ),
              const SizedBox(height: 16),
              Text(
                'No attendance records found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.current.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.current.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.current.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: state.records.map((record) {
              return RosterAttendanceRow(
                record: record,
                isLast: record == state.records.last && !state.isLoadingMore && state.errorMessage == null,
              );
            }).toList(),
          ),
        ),
        if (state.isLoadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.current.primary,
                ),
              ),
            ),
          ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Error loading more: ${state.errorMessage}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.current.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.current.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => ref.read(attendanceProvider(widget.memberId).notifier).fetchNextPage(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
