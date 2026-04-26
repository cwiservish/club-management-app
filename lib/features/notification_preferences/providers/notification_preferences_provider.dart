import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';

class NotificationPreferencesNotifier
    extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() => const NotificationSettings();

  void setMobileAlerts(bool value) =>
      state = state.copyWith(mobileAlerts: value);

  void setLiveScore(bool value) =>
      state = state.copyWith(liveScore: value);

  void setLiveMessages(bool value) =>
      state = state.copyWith(liveMessages: value);
}

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationSettings>(
  NotificationPreferencesNotifier.new,
);
