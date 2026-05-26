import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/notification_settings.dart';
import '../models/save_notification_models.dart';
import '../services/notification_preferences_service.dart';

class NotificationPreferencesState {
  final NotificationSettings settings;
  final bool isLoading;
  final String? errorMessage;

  const NotificationPreferencesState({
    required this.settings,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationPreferencesState copyWith({
    NotificationSettings? settings,
    bool? isLoading,
    Object? errorMessage = const Object(),
  }) {
    return NotificationPreferencesState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == const Object()
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class NotificationPreferencesNotifier extends Notifier<NotificationPreferencesState> {
  @override
  NotificationPreferencesState build() {
    // Reactively fetch settings when building the notifier
    Future.microtask(() => loadSettings());
    return const NotificationPreferencesState(
      settings: NotificationSettings(),
      isLoading: true,
    );
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final settings = await ref.read(notificationPreferencesServiceProvider).fetchPreferences();
      if (settings != null) {
        state = state.copyWith(
          settings: settings,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to retrieve notification preferences',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadSettings();
  }

  Future<SaveNotificationResponse> _saveSettings(NotificationSettings newSettings) async {
    final previousSettings = state.settings;
    
    // Instantly update local state for real-time responsiveness
    state = state.copyWith(settings: newSettings);
    
    try {
      final request = SaveNotificationRequest(
        emailScheduleReminders: newSettings.emailScheduleReminders.toString(),
        emailPlayerAvailability: newSettings.emailPlayerAvailability.toString(),
        mobileAlertsScheduleUpdates: newSettings.mobileAlertsScheduleUpdates.toString(),
        mobileLiveScoreUpdates: newSettings.mobileLiveScoreUpdates.toString(),
        mobileLiveGameEventMessages: newSettings.mobileLiveGameEventMessages.toString(),
        id: newSettings.notificationSettingId.toString(),
      );
      
      final response = await ref.read(notificationPreferencesServiceProvider).savePreferences(request);
      
      if (!response.success) {
        // Rollback state if the update failed
        state = state.copyWith(settings: previousSettings);
      }
      return response;
    } catch (e) {
      // Rollback state on error
      state = state.copyWith(settings: previousSettings);
      return SaveNotificationResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<SaveNotificationResponse> setMobileAlerts(bool value) async {
    final newSettings = state.settings.copyWith(
      mobileAlertsScheduleUpdates: value ? 1 : 0,
    );
    return await _saveSettings(newSettings);
  }

  Future<SaveNotificationResponse> setLiveScore(bool value) async {
    final newSettings = state.settings.copyWith(
      mobileLiveScoreUpdates: value ? 1 : 0,
    );
    return await _saveSettings(newSettings);
  }

  Future<SaveNotificationResponse> setLiveMessages(bool value) async {
    final newSettings = state.settings.copyWith(
      mobileLiveGameEventMessages: value ? 1 : 0,
    );
    return await _saveSettings(newSettings);
  }

  Future<SaveNotificationResponse> setEmailScheduleReminders(int value) async {
    final newSettings = state.settings.copyWith(
      emailScheduleReminders: value,
    );
    return await _saveSettings(newSettings);
  }

  Future<SaveNotificationResponse> setEmailPlayerAvailability(int value) async {
    final newSettings = state.settings.copyWith(
      emailPlayerAvailability: value,
    );
    return await _saveSettings(newSettings);
  }
}

final notificationPreferencesServiceProvider = Provider<NotificationPreferencesService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return NotificationPreferencesService(apiClient);
});

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferencesState>(
  NotificationPreferencesNotifier.new,
);
