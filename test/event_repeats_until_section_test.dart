import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playbook365/features/event_details/widgets/event_repeats_until_section.dart';

void main() {
  group('EventRepeatsUntilSection Tests', () {
    testWidgets('renders No and Yes radio buttons with No selected by default', (tester) async {
      bool isRepeating = false;
      String repeatType = 'Weekly';
      final startDate = DateTime(2026, 10, 17);
      DateTime? repeatUntilDate;

      final weeklySlots = [
        WeeklySlotConfig(
          dayName: 'Mon',
          weekday: 1,
          isChecked: true,
          startTime: const TimeOfDay(hour: 17, minute: 0),
          endTime: const TimeOfDay(hour: 18, minute: 30),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: EventRepeatsUntilSection(
                    isRepeating: isRepeating,
                    onRepeatingChanged: (val) => setState(() => isRepeating = val),
                    repeatType: repeatType,
                    onRepeatTypeChanged: (val) => setState(() => repeatType = val),
                    startDate: startDate,
                    repeatUntilDate: repeatUntilDate,
                    onRepeatUntilDateChanged: (val) => setState(() => repeatUntilDate = val),
                    weeklySlots: weeklySlots,
                    onWeeklySlotsChanged: (_) {},
                    selectedMonthlyDates: {DateTime(2026, 10, 17)},
                    onMonthlyDatesChanged: (_) {},
                    selectedMonth: DateTime(2026, 10, 1),
                    onSelectedMonthChanged: (_) {},
                    defaultStartTime: const TimeOfDay(hour: 17, minute: 0),
                    defaultEndTime: const TimeOfDay(hour: 18, minute: 30),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Repeats Until'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      // Weekly slots are not visible when isRepeating is false
      expect(find.text('Repeat Until:'), findsNothing);

      // Tap 'Yes'
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Now repeating view is expanded
      // Weekly start date is always today, so there is no Start Date row.
      expect(find.text('Start Date:'), findsNothing);
      expect(find.text('Repeat Until:'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('05:00 PM'), findsOneWidget);
      expect(find.text('06:30 PM'), findsOneWidget);
    });

    testWidgets('renders Monthly calendar grid when Monthly is selected', (tester) async {
      bool isRepeating = true;
      String repeatType = 'Monthly';
      final startDate = DateTime(2026, 10, 17);
      Set<DateTime> selectedDays = {DateTime(2026, 10, 17)};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: EventRepeatsUntilSection(
                    isRepeating: isRepeating,
                    onRepeatingChanged: (_) {},
                    repeatType: repeatType,
                    onRepeatTypeChanged: (_) {},
                    startDate: startDate,
                    repeatUntilDate: null,
                    onRepeatUntilDateChanged: (_) {},
                    weeklySlots: const [],
                    onWeeklySlotsChanged: (_) {},
                    selectedMonthlyDates: selectedDays,
                    onMonthlyDatesChanged: (val) => setState(() => selectedDays = val),
                    selectedMonth: DateTime(2026, 10, 1),
                    onSelectedMonthChanged: (_) {},
                    defaultStartTime: const TimeOfDay(hour: 17, minute: 0),
                    defaultEndTime: const TimeOfDay(hour: 18, minute: 30),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Month/year are dropdowns now; the day grid zero-pads day numbers.
      expect(find.text('October'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('17'), findsOneWidget);
    });
  });
}
