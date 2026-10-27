import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/models/club_event.dart';
import '../services/event_detail_service.dart';

/// Result of the "Edit which events?" dialog. [scope] is 'one' or 'series'.
/// [seriesEdit] is the series' `session/detail` -> `data.edit` (null when not loaded).
class EditScopeChoice {
  final String scope;
  final Map<String, dynamic>? seriesEdit;
  const EditScopeChoice(this.scope, [this.seriesEdit]);
}

/// One date of a weekly / specific-dates series (a Single Session with a series code).
bool isSeriesMember(ClubEvent e) =>
    e.schedulingMode == 1 && e.code.isNotEmpty && e.recurringType != 1;

/// Asks which events to edit before the edit page opens. Not a series: answers 'one' without a dialog.
/// Returns null when the user closes the dialog or taps "Never mind".
Future<EditScopeChoice?> askEditScope(
    BuildContext context, WidgetRef ref, ClubEvent e) async {
  if (!isSeriesMember(e)) return const EditScopeChoice('one');

  // Fetch the series first so the dialog can describe it (weekly days / dates, range, count).
  Map<String, dynamic>? seriesEdit;
  final team = ref.read(selectedTeamProvider);
  if (team != null) {
    try {
      final detail = await ref
          .read(eventDetailServiceProvider)
          .fetchSessionDetail(teamUuid: team.uuid, code: e.code);
      if (detail['edit'] is Map)
        seriesEdit = Map<String, dynamic>.from(detail['edit'] as Map);
    } catch (_) {}
  }
  if (!context.mounted) return null;
  final summary = seriesSummary(e, seriesEdit);
  final choice = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final colors = AppColors.current;
      Widget option(String label, String value, {String? subtitle}) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity, minHeight: 50),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, value),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading15
                          .copyWith(color: colors.textPrimary),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14
                            .copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
      return AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
        title: Row(
          children: [
            Expanded(
              child: Text('Edit which events?',
                  style: AppTextStyles.heading18
                      .copyWith(color: colors.textPrimary)),
            ),
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx, 'cancel')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary,
                  style: AppTextStyles.body14
                      .copyWith(color: colors.textSecondary, height: 1.4)),
              const SizedBox(height: 16),
              option('This event only', 'one'),
              option('All upcoming events', 'series',
                  subtitle: '(past events are kept)'),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, 'cancel'),
                  child: Text('Never mind',
                      style: AppTextStyles.heading15
                          .copyWith(color: colors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (choice == null || choice == 'cancel') return null;
  return EditScopeChoice(choice, seriesEdit);
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

String _shortDate(DateTime d, {bool year = false}) =>
    '${_monthNames[d.month - 1]} ${d.day}${year ? ', ${d.year}' : ''}';

/// "This practice repeats (Weekly · Mon, Tue · Oct 26 – Oct 30, 2026 · 5 sessions). Choose what to change."
/// Built from `session/detail` -> `data.edit`; falls back to a plain sentence when it isn't available.
String seriesSummary(ClubEvent e, Map<String, dynamic>? edit) {
  const typeNames = {
    1: 'game',
    2: 'practice',
    3: 'scrimmage',
    4: 'team event',
    5: 'camp'
  };
  final what = typeNames[e.eventTypeKey] ?? 'event';
  if (edit == null) return 'This $what repeats. Choose what to change.';

  final recurring =
      int.tryParse(edit['recurring_type']?.toString() ?? '') ?? e.recurringType;
  final days = edit['days'] is List ? edit['days'] as List : const [];
  final parts = <String>[];
  var count = 0;

  if (recurring == 3) {
    final dates = days
        .map((d) => DateTime.tryParse(d.toString()))
        .whereType<DateTime>()
        .toList()
      ..sort();
    parts.add('Monthly');
    if (dates.isNotEmpty) {
      count = dates.length;
      final shown = dates.take(4).map((d) => _shortDate(d)).join(', ');
      parts.add(dates.length > 4 ? '$shown +${dates.length - 4} more' : shown);
      parts.add(dates.first.year == dates.last.year
          ? '${dates.first.year}'
          : '${dates.first.year} – ${dates.last.year}');
    }
  } else {
    parts.add('Weekly');
    final names = days
        .whereType<Map>()
        .map((d) => d['day']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .map((n) => n.length > 3 ? n.substring(0, 3) : n)
        .toList();
    if (names.isNotEmpty) parts.add(names.join(', '));
    final start =
        DateTime.tryParse(edit['session_start_date']?.toString() ?? '');
    final end = DateTime.tryParse(edit['session_end_date']?.toString() ?? '');
    if (start != null && end != null) {
      parts.add('${_shortDate(start)} – ${_shortDate(end, year: true)}');
      const weekdayShort = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      final wanted = names.map((n) => n.toLowerCase()).toSet();
      for (var d = DateUtils.dateOnly(start);
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))) {
        if (wanted.contains(weekdayShort[d.weekday - 1])) count++;
      }
    }
  }
  if (count > 0) parts.add('$count session${count == 1 ? '' : 's'}');
  return 'This $what repeats (${parts.join(' · ')}). Choose what to change.';
}
