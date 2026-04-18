import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/theme/app_colors.dart';

final themeModeProvider =
    NotifierProvider<_ThemeModeNotifier, ThemeMode>(_ThemeModeNotifier.new);

class _ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'themeMode';

  static _ThemeModeNotifier? _instance;

  static void setMode(ThemeMode mode) => _instance?._apply(mode);
  static void toggle() {
    final i = _instance;
    if (i == null) return;
    i._apply(i.state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  ThemeMode build() {
    _instance = this;
    AppColors.setCurrent(AppColors.light);
    // Async: restore persisted preference without blocking build
    Future(() async {
      final saved = await _storage.read(key: _key);
      if (saved == 'dark') _apply(ThemeMode.dark);
    });
    return ThemeMode.light;
  }

  void _apply(ThemeMode mode) {
    AppColors.setCurrent(mode == ThemeMode.dark ? AppColors.dark : AppColors.light);
    _storage.write(key: _key, value: mode == ThemeMode.dark ? 'dark' : 'light');
    state = mode;
  }
}

// Call from anywhere without ref
void setAppTheme(ThemeMode mode) => _ThemeModeNotifier.setMode(mode);
void toggleAppTheme() => _ThemeModeNotifier.toggle();
