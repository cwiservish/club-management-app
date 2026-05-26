class NotificationSettings {
  final int notificationSettingId;
  final int customerId;
  final int emailScheduleReminders;
  final int emailPlayerAvailability;
  final int mobileAlertsScheduleUpdates;
  final int mobileLiveScoreUpdates;
  final int mobileLiveGameEventMessages;

  const NotificationSettings({
    this.notificationSettingId = 0,
    this.customerId = 0,
    this.emailScheduleReminders = 3,
    this.emailPlayerAvailability = 3,
    this.mobileAlertsScheduleUpdates = 1,
    this.mobileLiveScoreUpdates = 1,
    this.mobileLiveGameEventMessages = 1,
  });

  // ─── UI Compatibility Mappings ─────────────────────────────────────────────
  bool get mobileAlerts => mobileAlertsScheduleUpdates == 1;
  bool get liveScore => mobileLiveScoreUpdates == 1;
  bool get liveMessages => mobileLiveGameEventMessages == 1;

  String get emailScheduleRemindersLabel => _mapEmailValue(emailScheduleReminders);
  String get emailPlayerAvailabilityLabel => _mapEmailValue(emailPlayerAvailability);

  static String _mapEmailValue(int value) {
    switch (value) {
      case 1:
        return 'Games';
      case 2:
        return 'Events';
      case 3:
        return 'Games and events';
      default:
        return 'Games and events';
    }
  }

  // ─── JSON Parsing with Full Null-Safety ─────────────────────────────────────
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      notificationSettingId: _parseInt(json['notification_setting_id']),
      customerId: _parseInt(json['customer_id']),
      emailScheduleReminders: _parseInt(json['email_schedule_reminders']),
      emailPlayerAvailability: _parseInt(json['email_player_availability']),
      mobileAlertsScheduleUpdates: _parseInt(json['mobile_alerts_schedule_updates']),
      mobileLiveScoreUpdates: _parseInt(json['mobile_live_score_updates']),
      mobileLiveGameEventMessages: _parseInt(json['mobile_live_game_event_messages']),
    );
  }

  Map<String, dynamic> toJson() => {
        'notification_setting_id': notificationSettingId,
        'customer_id': customerId,
        'email_schedule_reminders': emailScheduleReminders,
        'email_player_availability': emailPlayerAvailability,
        'mobile_alerts_schedule_updates': mobileAlertsScheduleUpdates,
        'mobile_live_score_updates': mobileLiveScoreUpdates,
        'mobile_live_game_event_messages': mobileLiveGameEventMessages,
      };

  // ─── Type-Safe Helpers ──────────────────────────────────────────────────────
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // ─── copyWith ───────────────────────────────────────────────────────────────
  NotificationSettings copyWith({
    int? notificationSettingId,
    int? customerId,
    int? emailScheduleReminders,
    int? emailPlayerAvailability,
    int? mobileAlertsScheduleUpdates,
    int? mobileLiveScoreUpdates,
    int? mobileLiveGameEventMessages,
  }) {
    return NotificationSettings(
      notificationSettingId: notificationSettingId ?? this.notificationSettingId,
      customerId: customerId ?? this.customerId,
      emailScheduleReminders: emailScheduleReminders ?? this.emailScheduleReminders,
      emailPlayerAvailability: emailPlayerAvailability ?? this.emailPlayerAvailability,
      mobileAlertsScheduleUpdates:
          mobileAlertsScheduleUpdates ?? this.mobileAlertsScheduleUpdates,
      mobileLiveScoreUpdates: mobileLiveScoreUpdates ?? this.mobileLiveScoreUpdates,
      mobileLiveGameEventMessages:
          mobileLiveGameEventMessages ?? this.mobileLiveGameEventMessages,
    );
  }
}
