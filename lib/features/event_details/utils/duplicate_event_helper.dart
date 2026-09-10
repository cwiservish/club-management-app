import 'package:flutter/material.dart';
import '../../../core/models/club_event.dart';
import '../models/new_event_dropdown_options_model.dart';
import '../models/uniform_color.dart';

class DuplicateEventHelper {
  /// Returns the original event's title, falling back through titleRaw, title, eventName.
  static String getOriginalEventTitle(ClubEvent? e) {
    if (e == null) return '';
    if (e.titleRaw.trim().isNotEmpty) return e.titleRaw.trim();
    if (e.title.trim().isNotEmpty && e.title.trim().toLowerCase() != 'event') {
      return e.title.trim();
    }
    if (e.eventName != null && e.eventName!.trim().isNotEmpty) {
      return e.eventName!.trim();
    }
    return e.title.trim();
  }

  /// Checks whether all relevant event details between the original event [originalEvent]
  /// and the duplicated event form fields are 100% identical.
  static bool isDuplicatedEventIdentical({
    required ClubEvent originalEvent,
    required int schedulingTypeKey,
    required int eventTypeKey,
    required String location,
    required String notes,
    required bool isCancelled,
    required DateTime? selectedDate,
    required TimeOfDay startTime,
    required int durationMinutes,
    required int homeAwayKey,
    required int arrivalTimeKey,
    required String selectedOpponentId,
    required String newOpponentName,
    required String title,
    required NewEventUniformTemplate? selectedApiTemplate,
    required int topColorIndex,
    required int bottomColorIndex,
    required int socksColorIndex,
    required bool showSaveTemplateForm,
    required String templateName,
    required bool knowsSchedule,
    required DateTime? startDate,
    required DateTime? endDate,
    String latitude = '',
    String longitude = '',
  }) {
    final e = originalEvent;

    // 1. Scheduling mode
    if (schedulingTypeKey != e.schedulingMode) return false;

    // 2. Event type
    if (eventTypeKey != e.eventTypeKey) return false;

    // 3. Location
    if (location.trim() != e.location.trim()) return false;
    if (latitude.isNotEmpty && e.latitude != null && e.latitude!.isNotEmpty) {
      if (latitude.trim() != e.latitude!.trim()) return false;
    }
    if (longitude.isNotEmpty && e.longitude != null && e.longitude!.isNotEmpty) {
      if (longitude.trim() != e.longitude!.trim()) return false;
    }

    // 4. Notes / Description
    if (notes.trim() != (e.notes ?? '').trim()) return false;

    // 5. Cancelled state
    final originalIsCancelled = e.status == 2;
    if (isCancelled != originalIsCancelled) return false;

    // 6. Scheduling mode specific details
    if (schedulingTypeKey == 1) {
      // Single Session
      if (selectedDate == null) return false;
      final originalDate = DateUtils.dateOnly(e.dateTime);
      final currentDate = DateUtils.dateOnly(selectedDate);
      if (currentDate != originalDate) return false;

      if (startTime.hour != e.dateTime.hour || startTime.minute != e.dateTime.minute) {
        return false;
      }

      if (durationMinutes != e.duration.inMinutes) return false;

      final isGameOrScrimmage = eventTypeKey == 1 || eventTypeKey == 3;
      if (isGameOrScrimmage) {
        // Opponent
        if (e.opponentTeamId > 0) {
          if (selectedOpponentId != e.opponentTeamId.toString()) return false;
        } else if (e.opponent != null && e.opponent!.trim().isNotEmpty) {
          if (selectedOpponentId == '__new__') {
            if (newOpponentName.trim() != e.opponent!.trim()) return false;
          } else {
            return false;
          }
        } else {
          if (selectedOpponentId.isNotEmpty && selectedOpponentId != '__new__') return false;
          if (selectedOpponentId == '__new__' && newOpponentName.trim().isNotEmpty) return false;
        }

        // Home / Away
        if (homeAwayKey != e.homeAwayKey) return false;

        // Arrival early
        if (arrivalTimeKey != e.arrivalEarly) return false;
      } else {
        // Title (Practice, Team Event, Camp)
        final origTitle = getOriginalEventTitle(e);
        if (title.trim() != origTitle) return false;
      }

      // Uniforms
      if (e.uniformTemplateId > 0) {
        if (selectedApiTemplate == null || selectedApiTemplate.id != e.uniformTemplateId) {
          return false;
        }
      } else {
        if (selectedApiTemplate != null) return false;
        final currentTop = uniformColorToHex(kUniformColors[topColorIndex]).toLowerCase();
        final currentBottom = uniformColorToHex(kUniformColors[bottomColorIndex]).toLowerCase();
        final currentSocks = uniformColorToHex(kUniformColors[socksColorIndex]).toLowerCase();
        if (currentTop != e.uniformTopColor.trim().toLowerCase()) return false;
        if (currentBottom != e.uniformBottomColor.trim().toLowerCase()) return false;
        if (currentSocks != e.uniformSocksColor.trim().toLowerCase()) return false;
      }
      if (showSaveTemplateForm && templateName.trim().isNotEmpty) {
        return false;
      }
    } else {
      // Tournament / League (placeholder vs known schedule)
      if (!knowsSchedule) {
        // Title
        final origTitle = getOriginalEventTitle(e);
        if (title.trim() != origTitle) return false;

        // Dates
        if (startDate == null || endDate == null) return false;
        final origStartDate = e.startDate != null ? DateUtils.dateOnly(e.startDate!) : null;
        final origEndDate = e.endDate != null ? DateUtils.dateOnly(e.endDate!) : null;
        if (origStartDate == null || origEndDate == null) return false;
        if (DateUtils.dateOnly(startDate) != origStartDate) return false;
        if (DateUtils.dateOnly(endDate) != origEndDate) return false;
      } else {
        // Known schedule
        if (e.startDate != null || e.endDate != null) return false;
        if (selectedDate == null) return false;
        final originalDate = DateUtils.dateOnly(e.dateTime);
        final currentDate = DateUtils.dateOnly(selectedDate);
        if (currentDate != originalDate) return false;

        if (startTime.hour != e.dateTime.hour || startTime.minute != e.dateTime.minute) {
          return false;
        }

        if (durationMinutes != e.duration.inMinutes) return false;

        if (e.opponentTeamId > 0) {
          if (selectedOpponentId != e.opponentTeamId.toString()) return false;
        } else if (e.opponent != null && e.opponent!.trim().isNotEmpty) {
          if (selectedOpponentId == '__new__') {
            if (newOpponentName.trim() != e.opponent!.trim()) return false;
          } else {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// Resolves the duplicate event title according to duplicate event naming logic:
  /// - If 100% identical to original event, adds "Copy of - " before the original title.
  /// - If user modified even one detail, does not add "Copy of - " and keeps user's title.
  static String resolveDuplicateTitle({
    required ClubEvent originalEvent,
    required String currentTitle,
    required bool isIdentical,
  }) {
    if (isIdentical) {
      final orig = getOriginalEventTitle(originalEvent);
      final base = orig.isNotEmpty ? orig : (currentTitle.trim().isNotEmpty ? currentTitle.trim() : 'Event');
      return 'Copy of - $base';
    }
    return currentTitle.trim();
  }
}
