import 'package:flutter/material.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../../../core/shared_widgets/textfield/app_text_field.dart';
import '../widgets/event_edit_danger_card.dart';
import '../widgets/event_edit_form_card.dart';
import '../widgets/event_edit_inline_field.dart';
import '../widgets/event_edit_list_row.dart';
import '../widgets/event_edit_notify_card.dart';
import '../widgets/event_edit_toggle_row.dart';

// ─── Edit Event Page ──────────────────────────────────────────────────────────

class EventEditPage extends StatefulWidget {
  final String eventId;

  const EventEditPage({super.key, required this.eventId});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  bool _notifyTeam = true;
  bool _timeTbd    = false;
  bool _trackAvail = true;
  bool _canceled   = false;

  final _notesController           = TextEditingController();
  final _eventNameController       = TextEditingController(text: 'Practice');
  final _locationDetailsController = TextEditingController();
  final _extraLabelController      = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _eventNameController.dispose();
    _locationDetailsController.dispose();
    _extraLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title:      'Edit Event',
              leftIcon:   Icons.close,
              leftLabel:  'Close',
              onLeftTap:  () => Navigator.maybePop(context),
              rightText:  'Save',
              onRightTap: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(19, 20, 19, 40),
                children: [
                  // ── Notify Team ──────────────────────────────────────────────
                  EventEditNotifyCard(
                    value:     _notifyTeam,
                    onChanged: (v) => setState(() => _notifyTeam = v),
                  ),
                  const SizedBox(height: 20),

                  // ── Basic Details ────────────────────────────────────────────
                  EventEditFormCard(
                    icon:  Icons.calendar_today_outlined,
                    title: 'Basic Details',
                    children: [
                      EventEditInlineField(
                        label:        'Event Name',
                        controller:   _eventNameController,
                        placeholder:  'e.g. Game, Practice, Tournament',
                        borderBottom: true,
                      ),
                      EventEditListRow(label: 'Date/Time',  value: '03/25/26  6:00 PM'),
                      EventEditListRow(label: 'Time Zone',  value: 'Central Time (US & C...)'),
                      EventEditToggleRow(
                        label:     'Time TBD',
                        value:     _timeTbd,
                        onChanged: (v) => setState(() => _timeTbd = v),
                      ),
                      EventEditListRow(label: 'Duration', value: '1 Hour 30 Minutes', borderBottom: false),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Location ─────────────────────────────────────────────────
                  EventEditFormCard(
                    icon:  Icons.location_on_outlined,
                    title: 'Location',
                    children: [
                      EventEditListRow(label: 'Location', value: 'Gillis-Rother Soccer C...'),
                      EventEditInlineField(
                        label:        'Location Details',
                        controller:   _locationDetailsController,
                        placeholder:  'e.g. Field #5, Turf Field',
                        borderBottom: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Logistics & Settings ─────────────────────────────────────
                  EventEditFormCard(
                    icon:  Icons.settings_outlined,
                    title: 'Logistics & Settings',
                    children: [
                      EventEditListRow(label: 'Arrive Early', value: '15 Minutes'),
                      EventEditToggleRow(
                        label:     'Track Availability',
                        value:     _trackAvail,
                        onChanged: (v) => setState(() => _trackAvail = v),
                      ),
                      EventEditListRow(label: 'Flag Color', value: 'Blackberry'),
                      EventEditInlineField(
                        label:        'Extra Label',
                        controller:   _extraLabelController,
                        placeholder:  'Optional secondary label',
                        borderBottom: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Notes ────────────────────────────────────────────────────
                  EventEditFormCard(
                    icon:  Icons.align_horizontal_left_outlined,
                    title: 'Notes',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AppTextField(
                          controller: _notesController,
                          hintText:   'Add any additional details or instructions for the team...',
                          minLines:   4,
                          maxLines:   8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Danger Zone ──────────────────────────────────────────────
                  EventEditDangerCard(
                    canceled:          _canceled,
                    onCanceledChanged: (v) => setState(() => _canceled = v),
                    onDelete:          () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
