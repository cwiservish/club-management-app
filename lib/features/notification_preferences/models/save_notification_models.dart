// ─── Shared Crash-Proof Parsing Helpers ────────────────────────────────────────

String _parseString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
  }
  return false;
}

// ─── Models ───────────────────────────────────────────────────────────────────

class SaveNotificationRequest {
  final String emailScheduleReminders;
  final String emailPlayerAvailability;
  final String mobileAlertsScheduleUpdates;
  final String mobileLiveScoreUpdates;
  final String mobileLiveGameEventMessages;
  final String id;

  const SaveNotificationRequest({
    required this.emailScheduleReminders,
    required this.emailPlayerAvailability,
    required this.mobileAlertsScheduleUpdates,
    required this.mobileLiveScoreUpdates,
    required this.mobileLiveGameEventMessages,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'email_schedule_reminders': emailScheduleReminders,
      'email_player_availability': emailPlayerAvailability,
      'mobile_alerts_schedule_updates': mobileAlertsScheduleUpdates,
      'mobile_live_score_updates': mobileLiveScoreUpdates,
      'mobile_live_game_event_messages': mobileLiveGameEventMessages,
      'id': id,
    };
  }
}

class SaveNotificationResponse {
  final bool success;
  final String message;

  const SaveNotificationResponse({
    required this.success,
    required this.message,
  });

  factory SaveNotificationResponse.fromJson(Map<String, dynamic> json) {
    return SaveNotificationResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
    );
  }
}
