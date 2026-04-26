class NotificationSettings {
  final bool mobileAlerts;
  final bool liveScore;
  final bool liveMessages;

  const NotificationSettings({
    this.mobileAlerts = true,
    this.liveScore = true,
    this.liveMessages = true,
  });

  NotificationSettings copyWith({
    bool? mobileAlerts,
    bool? liveScore,
    bool? liveMessages,
  }) {
    return NotificationSettings(
      mobileAlerts: mobileAlerts ?? this.mobileAlerts,
      liveScore: liveScore ?? this.liveScore,
      liveMessages: liveMessages ?? this.liveMessages,
    );
  }
}
