import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';

final themeModeProvider =
    NotifierProvider<_ThemeModeNotifier, ThemeMode>(_ThemeModeNotifier.new);

class _ThemeModeNotifier extends Notifier<ThemeMode> {
  static late _ThemeModeNotifier _instance;

  static void setMode(ThemeMode mode) => _instance._apply(mode);
  static void toggle() => _instance._apply(
        _instance.state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      );

  @override
  ThemeMode build() {
    _instance = this;
    AppColors.setCurrent(AppColors.light);
    return ThemeMode.light;
  }

  void _apply(ThemeMode mode) {
    AppColors.setCurrent(mode == ThemeMode.dark ? AppColors.dark : AppColors.light);
    state = mode;
  }
}

// Call from anywhere without ref
void setAppTheme(ThemeMode mode) => _ThemeModeNotifier.setMode(mode);
void toggleAppTheme() => _ThemeModeNotifier.toggle();
