import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_data.dart';
import '../services/settings_service.dart';

final settingsServiceProvider =
    Provider<SettingsService>((ref) => SettingsService());

final settingsProvider = FutureProvider<SettingsData>((ref) async {
  return ref.read(settingsServiceProvider).getSettingsData();
});
