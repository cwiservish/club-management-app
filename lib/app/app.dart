import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_colors.dart';
import 'theme/theme_provider.dart';
import 'router/app_router.dart';

class Playbook365App extends ConsumerWidget {
  const Playbook365App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Playbook365',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.current.primary,
          brightness: AppColors.current.brightness,
          primary: AppColors.current.primary,
          surface: AppColors.current.surface,
          onSurface: AppColors.current.textPrimary,
          surfaceContainerHighest: AppColors.current.card,
          surfaceContainer: AppColors.current.card,
          onSurfaceVariant: AppColors.current.textSecondary,
          outline: AppColors.current.border,
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.current.bg,
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
