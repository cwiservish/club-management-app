import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../models/event_dropdown_options_models.dart';
import '../services/event_detail_service.dart';

import '../models/event_save_models.dart';
import '../models/event_delete_models.dart';

class EventEditState {
  final List<TimezoneModel> timezones;
  final TimezoneModel? selectedTimezone;
  final bool isLoadingTimezones;
  final String? timezonesError;
  final bool isTimezoneDropdownOpen;

  final bool isSaving;
  final String? saveError;
  final String? saveSuccessMessage;

  const EventEditState({
    this.timezones = const [],
    this.selectedTimezone,
    this.isLoadingTimezones = false,
    this.timezonesError,
    this.isTimezoneDropdownOpen = false,
    this.isSaving = false,
    this.saveError,
    this.saveSuccessMessage,
  });

  EventEditState copyWith({
    List<TimezoneModel>? timezones,
    TimezoneModel? selectedTimezone,
    bool? isLoadingTimezones,
    Object? timezonesError = const Object(),
    bool? isTimezoneDropdownOpen,
    bool? isSaving,
    Object? saveError = const Object(),
    Object? saveSuccessMessage = const Object(),
  }) {
    return EventEditState(
      timezones: timezones ?? this.timezones,
      selectedTimezone: selectedTimezone ?? this.selectedTimezone,
      isLoadingTimezones: isLoadingTimezones ?? this.isLoadingTimezones,
      timezonesError: identical(timezonesError, const Object())
          ? this.timezonesError
          : (timezonesError as String?),
      isTimezoneDropdownOpen:
          isTimezoneDropdownOpen ?? this.isTimezoneDropdownOpen,
      isSaving: isSaving ?? this.isSaving,
      saveError: identical(saveError, const Object())
          ? this.saveError
          : (saveError as String?),
      saveSuccessMessage: identical(saveSuccessMessage, const Object())
          ? this.saveSuccessMessage
          : (saveSuccessMessage as String?),
    );
  }
}

class EventEditNotifier extends Notifier<EventEditState> {
  @override
  EventEditState build() {
    final activeTeam = ref.watch(selectedTeamProvider);
    if (activeTeam != null) {
      Future.microtask(() => fetchTimezonesForTeam(activeTeam.uuid));
    }
    return const EventEditState(isLoadingTimezones: true);
  }

  Future<void> fetchTimezones() async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam != null) {
      await fetchTimezonesForTeam(activeTeam.uuid);
    } else {
      state = state.copyWith(
        timezonesError: 'No active team selected',
        isLoadingTimezones: false,
      );
    }
  }

  Future<void> fetchTimezonesForTeam(String teamUuid) async {
    state = state.copyWith(
      isLoadingTimezones: true,
      timezonesError: null,
    );

    try {
      final eventService = ref.read(eventDetailServiceProvider);
      final request = EventDropdownOptionsRequest(teamUuid: teamUuid);
      final response = await eventService.fetchEventDropdownOptions(request);

      if (response.success) {
        TimezoneModel? initialSelection;
        if (response.timezones.isNotEmpty) {
          initialSelection = response.timezones.firstWhere(
            (t) => t.key.toLowerCase().trim() == 'america/chicago',
            orElse: () => response.timezones.firstWhere(
              (t) => t.label.toLowerCase().trim() == 'america/chicago',
              orElse: () => response.timezones.firstWhere(
                (t) =>
                    t.label.toLowerCase().contains('central') ||
                    t.key.toLowerCase().contains('central'),
                orElse: () => response.timezones.first,
              ),
            ),
          );
        }
        state = state.copyWith(
          timezones: response.timezones,
          selectedTimezone: initialSelection,
          isLoadingTimezones: false,
        );
      } else {
        state = state.copyWith(
          timezonesError: response.message.isNotEmpty
              ? response.message
              : 'Failed to fetch timezones',
          isLoadingTimezones: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        timezonesError: e.toString(),
        isLoadingTimezones: false,
      );
    }
  }

  Future<void> refreshTimezones() async {
    await fetchTimezones();
  }

  void toggleTimezoneDropdown() {
    state = state.copyWith(
      isTimezoneDropdownOpen: !state.isTimezoneDropdownOpen,
    );
  }

  void selectTimezone(TimezoneModel tz) {
    state = state.copyWith(
      selectedTimezone: tz,
      isTimezoneDropdownOpen: false,
    );
  }

  /// Sends the formatted payload to create/save the event.
  Future<bool> saveEvent({
    dynamic id,
    required String eventName,
    required String startTime,
    required String timezone,
    required bool timeTbd,
    required int duration,
    required String location,
    required String latitude,
    required String longitude,
    required String locationDetails,
    required int arrivalEarly,
    required bool trackAvailability,
    required String flagColor,
    required String uniformColor,
    required String opponent,
    required String extraLabel,
    required String notes,
    required int status,
    required bool notificationEnabled,
  }) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      state = state.copyWith(saveError: 'No active team selected');
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      saveError: null,
      saveSuccessMessage: null,
    );

    final request = EventSaveRequest(
      teamUuid: activeTeam.uuid,
      eventName: eventName,
      id: id,
      startTime: startTime,
      timezone: timezone,
      timeTbd: timeTbd,
      duration: duration,
      location: location,
      latitude: latitude,
      longitude: longitude,
      locationDetails: locationDetails.isNotEmpty ? locationDetails : null,
      arrivalEarly: arrivalEarly,
      trackAvailability: trackAvailability,
      flagColor: flagColor,
      uniformColor: uniformColor,
      opponent: opponent,
      extraLabel: extraLabel,
      notes: notes,
      status: status,
      notificationEnabled: notificationEnabled,
    );

    try {
      final eventService = ref.read(eventDetailServiceProvider);
      final response = await eventService.saveEvent(request);

      if (response.success) {
        state = state.copyWith(
          isSaving: false,
          saveSuccessMessage:
              response.message.isNotEmpty ? response.message : 'Event saved successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          saveError:
              response.message.isNotEmpty ? response.message : 'Failed to save event',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: e.toString(),
      );
      return false;
    }
  }

  /// Deletes the event permanently.
  Future<bool> deleteEvent(dynamic id, {int schedulingMode = 1}) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      state = state.copyWith(saveError: 'No active team selected');
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      saveError: null,
      saveSuccessMessage: null,
    );

    final request = EventDeleteRequest(
      teamUuid: activeTeam.uuid,
      id: id,
      schedulingMode: schedulingMode,
    );

    try {
      final eventService = ref.read(eventDetailServiceProvider);
      final response = await eventService.deleteEvent(request);

      if (response.success) {
        state = state.copyWith(
          isSaving: false,
          saveSuccessMessage:
              response.message.isNotEmpty ? response.message : 'Event deleted successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          saveError:
              response.message.isNotEmpty ? response.message : 'Failed to delete event',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: e.toString(),
      );
      return false;
    }
  }
}

final eventEditProvider =
    NotifierProvider<EventEditNotifier, EventEditState>(EventEditNotifier.new);
