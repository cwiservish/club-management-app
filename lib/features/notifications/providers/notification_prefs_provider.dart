import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

class NotifPrefsNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    return Map.from(ref.read(notificationServiceProvider).getDefaultPrefs());
  }

  void toggle(String key) {
    state = {...state, key: !(state[key] ?? false)};
  }
}

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final notifPrefsProvider =
    NotifierProvider<NotifPrefsNotifier, Map<String, bool>>(NotifPrefsNotifier.new);
