import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playbook365/core/network/api_client.dart';
import 'package:playbook365/features/event_details/models/new_event_dropdown_options_model.dart';
import 'package:playbook365/features/event_details/models/session_slot_models.dart';
import 'package:playbook365/features/event_details/services/event_detail_service.dart';
import 'package:playbook365/features/event_details/widgets/slot_board_sheet.dart';

void main() {
  // Removing a date needs no API call, so an unused Dio is enough.
  final dio = Dio();
  final service = EventDetailService(ApiClient(dio), dio);
  const venue = OurLocationVenue(venueId: 1, name: 'Fac', label: 'Fac', latitude: '', longitude: '', fields: []);

  SessionSlot row(String date, {bool clash = false}) => SessionSlot(
        date: date, startTime: '17:00', endTime: '18:30', venueId: 1, fieldId: 21,
        checked: true, isAvailable: !clash, isBlocking: clash,
        warnings: clash ? const ['Field already booked'] : const [],
      );

  testWidgets('a clashing date can be removed and the rest saved', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    List<SessionSlot>? saved;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              saved = await SlotBoardSheet.show(
                context,
                service: service,
                teamUuid: 't',
                venue: venue,
                board: SlotBoard(
                  slots: [row('2026-11-03'), row('2026-11-04', clash: true)],
                  hasConflicts: true,
                  conflictCount: 1,
                ),
                saveLabel: 'Save event',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    ElevatedButton saveButton() => tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save event'));
    expect(saveButton().onPressed, isNull); // blocked by the clash

    await tester.tap(find.text('Remove this date'));
    await tester.pumpAndSettle();
    expect(find.text('Removed — this date will not be saved'), findsOneWidget);
    expect(saveButton().onPressed, isNotNull);

    // Undo brings the clash back.
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNull);

    await tester.tap(find.text('Remove this date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save event'));
    await tester.pumpAndSettle();
    expect(saved?.map((s) => s.date).toList(), ['2026-11-03']);
  });

  group('changing a date', () {
    final next = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
    String d(int day) => '${next.year}-${next.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    List<SessionSlot>? saved;

    Future<void> Function() openWith(WidgetTester tester, _FakeService fake, SlotBoard board,
        {bool dateEditable = true}) {
      saved = null;
      return () async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  saved = await SlotBoardSheet.show(
                    context,
                    service: fake,
                    teamUuid: 't',
                    venue: venue,
                    board: board,
                    saveLabel: 'Save event',
                    dateEditable: dateEditable,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
      };
    }

    Future<void> pickDay(WidgetTester tester, Finder dateChip, int day) async {
      await tester.tap(dateChip);
      await tester.pumpAndSettle();
      await tester.tap(find.text('$day').last);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    ElevatedButton saveButton(WidgetTester tester) =>
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save event'));

    testWidgets('moves a clash to a free date: only that card is re-checked, rows re-sort, original_date is kept',
        (tester) async {
      final fake = _FakeService();
      final board = SlotBoard(
        slots: [row(d(12)), row(d(15), clash: true), row(d(18))],
        hasConflicts: true,
        conflictCount: 1,
      );
      await openWith(tester, fake, board)();
      expect(find.textContaining('1 of 3 dates clash at Fac. Change the date, time, or field for the red dates.'),
          findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);

      await pickDay(tester, find.byIcon(Icons.calendar_today_outlined).at(1), 20);

      expect(fake.checked.map((s) => s.date), [d(20)]); // only the moved card
      expect(find.textContaining('dates clash'), findsNothing); // header hidden at 0
      expect(saveButton(tester).onPressed, isNotNull);

      await tester.tap(find.text('Save event'));
      await tester.pumpAndSettle();
      // Sorted by date; the moved row keeps the date it was generated for.
      expect(saved!.map((s) => s.date), [d(12), d(18), d(20)]);
      expect(saved!.map((s) => s.originalDate), [d(12), d(18), d(15)]);
      expect(saved!.last.toSaveJson()['original_date'], d(15));
    });

    testWidgets('a date another card has shows the inline error, skips the re-check and blocks Save', (tester) async {
      final fake = _FakeService();
      final board = SlotBoard(slots: [row(d(12)), row(d(15), clash: true)], hasConflicts: true, conflictCount: 1);
      await openWith(tester, fake, board)();

      await pickDay(tester, find.byIcon(Icons.calendar_today_outlined).at(1), 12);
      expect(find.text('This date is already in your schedule. Pick a different date.'), findsOneWidget);
      expect(fake.checked, isEmpty);
      expect(saveButton(tester).onPressed, isNull);

      // Pick a free date: the error clears and the card is re-checked.
      await pickDay(tester, find.byIcon(Icons.calendar_today_outlined).at(1), 20);
      expect(find.text('This date is already in your schedule. Pick a different date.'), findsNothing);
      // The card left alone on the old date is re-checked as well.
      expect(fake.checked.map((s) => s.date), [d(20), d(12)]);
      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('date chips are hidden when dateEditable is false', (tester) async {
      final board = SlotBoard(slots: [row(d(15), clash: true)], hasConflicts: true, conflictCount: 1);
      await openWith(tester, _FakeService(), board, dateEditable: false)();
      expect(find.byIcon(Icons.calendar_today_outlined), findsNothing);
    });

    testWidgets('a locked card shows its label and has no date control', (tester) async {
      final locked = SessionSlot(
        date: d(15), startTime: '17:00', endTime: '18:30', venueId: 1, fieldId: 21,
        locked: true, lockedLabel: 'Moved from Wed, 11/18/2026',
      );
      final board = SlotBoard(slots: [row(d(12)), locked]);
      await openWith(tester, _FakeService(), board)();
      expect(find.text('Moved from Wed, 11/18/2026'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget); // only the editable card
    });
  });

  testWidgets('the only date cannot be removed', (tester) async {
    await openBoardOnly(tester, service, venue, SlotBoard(slots: [row('2026-11-04', clash: true)], hasConflicts: true));
    expect(find.text('Remove this date'), findsNothing);
  });
}

Future<void> openBoardOnly(WidgetTester tester, EventDetailService service, OurLocationVenue venue, SlotBoard board) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => SlotBoardSheet.show(context, service: service, teamUuid: 't', venue: venue, board: board),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Records field_availability calls and answers "available".
class _FakeService extends EventDetailService {
  _FakeService._(super.api, super.dio);
  factory _FakeService() {
    final dio = Dio();
    return _FakeService._(ApiClient(dio), dio);
  }

  final List<SessionSlot> checked = [];

  @override
  Future<SessionSlot> checkFieldAvailability({
    required String teamUuid,
    required int venueId,
    required int fieldId,
    required SessionSlot slot,
    List<int> excludeIds = const [],
  }) async {
    checked.add(slot);
    return slot.copyWith(checked: true, isAvailable: true, isBlocking: false, warnings: const []);
  }
}
