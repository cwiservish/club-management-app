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
