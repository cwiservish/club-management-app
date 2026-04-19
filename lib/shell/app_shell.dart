import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/common_providers/theme_provider.dart';
import '../core/widgets/app_bottom_nav_bar.dart';
import '../features/messages/providers/unread_count_provider.dart';

/// Playbook365 — App Shell
///
/// Root widget for the [StatefulShellRoute.indexedStack] builder.
/// Owns the bottom navigation bar and forwards tab-switch gestures
/// back to GoRouter's [StatefulNavigationShell].
///
/// The Messages badge count is read from [unreadCountProvider] so it
/// updates automatically whenever the provider's value changes.

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider); // rebuild shell + pages on theme change
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        messagesBadgeCount: unreadCount,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab again pops to the branch's initial route.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
