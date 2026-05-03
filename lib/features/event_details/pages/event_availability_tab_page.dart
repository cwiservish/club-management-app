import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/event_detail_provider.dart';
import '../models/event_player_model.dart';
import '../widgets/availability/player_group.dart';
import '../widgets/dialogs/text_input_dialog.dart';
import '../widgets/event_status_picker_sheet.dart';

class EventAvailabilityTabPage extends ConsumerWidget {
  final String eventId;

  const EventAvailabilityTabPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(eventDetailProvider(eventId));
    final notifier = ref.read(eventDetailProvider(eventId).notifier);
    final colors   = AppColors.current;

    void showNote(EventPlayerModel p) => showTextInputDialog(
          context,
          title:       p.hasNote ? 'Edit Note' : 'Add Note',
          subtitle:    'Adding note for ${p.name}',
          initialText: p.note,
          placeholder: 'Type note here...',
          primaryLabel: 'Save',
          onConfirm: (text) => notifier.updatePlayerNote(p.id, text),
        );

    void showMessageAll() => showTextInputDialog(
          context,
          title:       'Message All',
          subtitle:    "Send a message to players who haven't replied.",
          initialText: "Please update your availability for ${state.event.date} ${state.event.name}",
          placeholder: 'Type message here...',
          primaryLabel: 'Send',
          primaryIcon: Icon(
            Icons.message_outlined,
            size:  16,
            color: AppColors.current.isDark
                ? AppColors.current.gray900
                : Colors.white,
          ),
          onConfirm: (_) {}, // TODO: wire to messages feature
        );

    void showStatusPicker(EventPlayerModel player) {
      showModalBottomSheet(
        context: context,
        backgroundColor: colors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => EventStatusPickerSheet(
          player:   player,
          notifier: notifier,
        ),
      );
    }

    return ColoredBox(
      color: colors.card,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PlayerGroup(
            title:       'GOING',
            players:     state.goingPlayers,
            onNoteTap:   showNote,
            onStatusTap: showStatusPicker,
          ),
          PlayerGroup(
            title:       'MAYBE',
            players:     state.maybePlayers,
            onNoteTap:   showNote,
            onStatusTap: showStatusPicker,
          ),
          PlayerGroup(
            title:       'NOT GOING',
            players:     state.noPlayers,
            onNoteTap:   showNote,
            onStatusTap: showStatusPicker,
          ),
          PlayerGroup(
            title:          "HAVEN'T REPLIED",
            players:        state.unrepliedPlayers,
            showMessageAll: true,
            onMessageAll:   showMessageAll,
            onNoteTap:      showNote,
            onStatusTap:    showStatusPicker,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
