import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_colors.dart';
import '../core/common_providers/theme_provider.dart';
import 'router/app_router.dart';

class Playbook365App extends ConsumerWidget {
  const Playbook365App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Playbook365',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.current.background,
      ),
      builder: (_, child) => KeyedSubtree(
        key: ValueKey(themeMode),
        child: child!,
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
