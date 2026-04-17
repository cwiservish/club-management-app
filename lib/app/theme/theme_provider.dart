import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';

final themeModeProvider =
    NotifierProvider<_ThemeModeNotifier, ThemeMode>(_ThemeModeNotifier.new);

class _ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    AppColors.setCurrent(AppColors.light);
    return ThemeMode.light;
  }

  void setMode(ThemeMode mode) {
    AppColors.setCurrent(mode == ThemeMode.dark ? AppColors.dark : AppColors.light);
    state = mode;
  }
}
