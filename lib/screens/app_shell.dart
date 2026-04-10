import 'package:flutter/material.dart';

import '../widgets/shared_widgets.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'roster_screen.dart';
import 'messages_screens.dart';
import 'more_screen.dart';

/// Playbook365 — App Shell
/// Root widget that owns the bottom navigation and per-tab Navigator stacks.
/// Each tab maintains its own navigation history independently.

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // One NavigatorKey per tab so each tab has its own back-stack
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  // Unread message count — wire to your state management layer
  int get _unreadMessages => 6;

  Future<bool> _onWillPop() async {
    final nav = _navigatorKeys[_currentIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _Tab(navigatorKey: _navigatorKeys[0], child: const HomeScreen()),
            _Tab(navigatorKey: _navigatorKeys[1], child: const ScheduleScreen()),
            _Tab(navigatorKey: _navigatorKeys[2], child: const RosterScreen()),
            _Tab(navigatorKey: _navigatorKeys[3], child: const MessagesScreen()),
            _Tab(navigatorKey: _navigatorKeys[4], child: const MoreScreen()),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          messagesBadgeCount: _unreadMessages,
          onTap: (i) {
            if (_currentIndex == i) {
              // Double-tap: pop to root of this tab
              _navigatorKeys[i]
                  .currentState
                  ?.popUntil((route) => route.isFirst);
            } else {
              setState(() => _currentIndex = i);
            }
          },
        ),
      ),
    );
  }
}

/// Per-tab Navigator wrapper
class _Tab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _Tab({required this.navigatorKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
    );
  }
}
