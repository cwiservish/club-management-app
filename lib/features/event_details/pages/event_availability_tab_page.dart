import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/event_detail_provider.dart';
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

    void showNote(EventPlayerModel p) {
      final canEditNote = state.canUpdateAllPlayers && p.canUpdate;
      if (!canEditNote) return;

      showTextInputDialog(
        context,
        title:       p.hasNote ? 'Edit Note' : 'Add Note',
        subtitle:    'Adding note for ${p.name}',
        initialText: p.note,
        placeholder: 'Type note here...',
        primaryLabel: 'Save',
        onConfirm: (text) async {
          final result = await notifier.updatePlayerNote(p.id, text);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result.message,
                  style: TextStyle(
                    color: colors.isDark ? colors.gray900 : Colors.white,
                  ),
                ),
                backgroundColor: result.success ? colors.success : colors.error,
              ),
            );
          }
        },
      );
    }

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

    if (state.isLoading && state.players.isEmpty) {
      return ColoredBox(
        color: colors.card,
        child: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.players.isEmpty) {
      return ColoredBox(
        color: colors.card,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => notifier.refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.isDark ? colors.gray900 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: colors.card,
      child: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        color: colors.primary,
        backgroundColor: colors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            PlayerGroup(
              title:       'GOING',
              players:     state.goingPlayers,
              canUpdateAllPlayers: state.canUpdateAllPlayers,
              onNoteTap:   showNote,
              onStatusTap: showStatusPicker,
            ),
            PlayerGroup(
              title:       'MAYBE',
              players:     state.maybePlayers,
              canUpdateAllPlayers: state.canUpdateAllPlayers,
              onNoteTap:   showNote,
              onStatusTap: showStatusPicker,
            ),
            PlayerGroup(
              title:       'NOT GOING',
              players:     state.noPlayers,
              canUpdateAllPlayers: state.canUpdateAllPlayers,
              onNoteTap:   showNote,
              onStatusTap: showStatusPicker,
            ),
            PlayerGroup(
              title:          "HAVEN'T REPLIED",
              players:        state.unrepliedPlayers,
              canUpdateAllPlayers: state.canUpdateAllPlayers,
              showMessageAll: true,
              onMessageAll:   showMessageAll,
              onNoteTap:      showNote,
              onStatusTap:    showStatusPicker,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
