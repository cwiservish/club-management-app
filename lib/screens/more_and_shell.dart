import 'package:flutter/material.dart';

// ── Import all screens (assuming all files are in lib/)
// home_screen.dart         → HomeScreen
// schedule_screen.dart     → ScheduleScreen
// roster_screen.dart       → RosterScreen
// messages_screens.dart    → MessagesScreen
// team_event_screens.dart  → TeamDetailScreen

// For this single-file shell we inline lightweight stand-ins for each screen
// so the app compiles. Replace each _ScreenShell with the real import.

void main() {
  runApp(const ClubManagementApp());
}

// ─── App Root ─────────────────────────────────────────────────────────────────

class ClubManagementApp extends StatelessWidget {
  const ClubManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playbook365',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const AppShell(),
    );
  }

  ThemeData _buildTheme() {
    const primary = Color(0xFF1A56DB);
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF3F4F6),
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}

// ─── App Shell (shared bottom nav) ───────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Keep pages alive when switching tabs
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  // ── Tab definitions ───────────────────────────────────────────────────────

  static const _tabs = [
    _TabItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _TabItem(
      label: 'Schedule',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    _TabItem(
      label: 'Roster',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
    ),
    _TabItem(
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      badgeCount: 6,
    ),
    _TabItem(
      label: 'More',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
    ),
  ];

  // ── Back button: pop within tab before exiting ────────────────────────────

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
            _TabNavigator(
              navigatorKey: _navigatorKeys[0],
              child: const HomeTab(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[1],
              child: const ScheduleTab(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[2],
              child: const RosterTab(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[3],
              child: const MessagesTab(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[4],
              child: const MoreTab(),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = i == _currentIndex;
              return _NavItem(
                tab: tab,
                isActive: isActive,
                onTap: () {
                  if (_currentIndex == i) {
                    // Double-tap: pop to root of this tab
                    _navigatorKeys[i]
                        .currentState
                        ?.popUntil((route) => route.isFirst);
                  } else {
                    setState(() => _currentIndex = i);
                  }
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Tab Navigator (each tab has its own navigation stack) ───────────────────

class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _TabNavigator({
    required this.navigatorKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
    );
  }
}

// ─── Nav Item Widget ──────────────────────────────────────────────────────────

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int badgeCount;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount = 0,
  });
}

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  static const _activeColor = Color(0xFF1A56DB);
  static const _inactiveColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? tab.activeIcon : tab.icon,
                    key: ValueKey(isActive),
                    color: isActive ? _activeColor : _inactiveColor,
                    size: 24,
                  ),
                ),
                if (tab.badgeCount > 0)
                  Positioned(
                    top: -5,
                    right: -8,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          tab.badgeCount > 99
                              ? '99+'
                              : '${tab.badgeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? _activeColor : _inactiveColor,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB SCREENS
// Replace each of these with: import 'screens/xyz_screen.dart'
// ══════════════════════════════════════════════════════════════════════════════

// ── Home Tab ──────────────────────────────────────────────────────────────────

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 👉 Replace with: HomeScreen()
    return _PlaceholderScreen(
      title: 'Home',
      icon: Icons.home,
      color: const Color(0xFF1A56DB),
      actions: [
        _QuickLink(
          label: 'Team Detail',
          icon: Icons.sports_soccer,
          color: const Color(0xFF1A56DB),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const TeamDetailPlaceholder(),
          )),
        ),
        _QuickLink(
          label: 'Event Detail',
          icon: Icons.calendar_today,
          color: const Color(0xFF10B981),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const EventDetailPlaceholder(),
          )),
        ),
        _QuickLink(
          label: 'Add Event',
          icon: Icons.add_circle_outline,
          color: const Color(0xFFF59E0B),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const EventFormPlaceholder(),
          )),
        ),
      ],
    );
  }
}

// ── Schedule Tab ──────────────────────────────────────────────────────────────

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 👉 Replace with: ScheduleScreen()
    return _PlaceholderScreen(
      title: 'Schedule',
      icon: Icons.calendar_today,
      color: const Color(0xFF10B981),
      actions: [
        _QuickLink(
          label: 'Event Detail',
          icon: Icons.event,
          color: const Color(0xFF1A56DB),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const EventDetailPlaceholder(),
          )),
        ),
        _QuickLink(
          label: 'New Event',
          icon: Icons.add,
          color: const Color(0xFF10B981),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const EventFormPlaceholder(),
          )),
        ),
      ],
    );
  }
}

// ── Roster Tab ────────────────────────────────────────────────────────────────

class RosterTab extends StatelessWidget {
  const RosterTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 👉 Replace with: RosterScreen()
    return _PlaceholderScreen(
      title: 'Roster',
      icon: Icons.people,
      color: const Color(0xFF8B5CF6),
      actions: [
        _QuickLink(
          label: 'Team Detail',
          icon: Icons.sports_soccer,
          color: const Color(0xFF1A56DB),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const TeamDetailPlaceholder(),
          )),
        ),
      ],
    );
  }
}

// ── Messages Tab ──────────────────────────────────────────────────────────────

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 👉 Replace with: MessagesScreen()
    return _PlaceholderScreen(
      title: 'Messages',
      icon: Icons.chat_bubble,
      color: const Color(0xFFF59E0B),
    );
  }
}

// ── More Tab ──────────────────────────────────────────────────────────────────

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoreScreen();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MORE SCREEN (full implementation — links to all sub-screens)
// ══════════════════════════════════════════════════════════════════════════════

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _blue = Color(0xFF1A56DB);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _purple = Color(0xFF8B5CF6);
  static const _red = Color(0xFFEF4444);
  static const _gray50 = Color(0xFFF9FAFB);
  static const _gray100 = Color(0xFFF3F4F6);
  static const _gray400 = Color(0xFF9CA3AF);
  static const _gray500 = Color(0xFF6B7280);
  static const _gray700 = Color(0xFF374151);
  static const _gray900 = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileCard(context),
                    const SizedBox(height: 20),
                    _buildSection('Team Management', [
                      _MoreItem(Icons.sports_soccer, 'Team Detail',
                          _blue, () => _push(context, const TeamDetailPlaceholder())),
                      _MoreItem(Icons.bar_chart_outlined, 'Statistics',
                          _green, () => _push(context, const StatisticsScreen())),
                      _MoreItem(Icons.people_outline, 'Player Attendance',
                          _purple, () => _push(context, const PlayerAttendanceScreen())),
                      _MoreItem(Icons.track_changes_outlined, 'Tracking',
                          _amber, () => _push(context, const TrackingScreen())),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Media & Files', [
                      _MoreItem(Icons.photo_library_outlined, 'Photos',
                          const Color(0xFF0EA5E9),
                          () => _push(context, const PhotosScreen())),
                      _MoreItem(Icons.folder_outlined, 'Files',
                          _amber, () => _push(context, const FilesScreen())),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Finance & Admin', [
                      _MoreItem(Icons.receipt_long_outlined, 'Invoicing',
                          _green, () => _push(context, const InvoicingScreen())),
                      _MoreItem(Icons.badge_outlined, 'Registration & Insurance',
                          _blue, () => _push(context, const RegistrationScreen())),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Settings', [
                      _MoreItem(Icons.notifications_outlined,
                          'Notification Preferences', _purple,
                          () => _push(context, const NotificationPrefsScreen())),
                      _MoreItem(Icons.person_outline, 'Edit Profile',
                          _gray500, () {}),
                      _MoreItem(Icons.help_outline, 'Help & Support',
                          _gray500, () {}),
                      _MoreItem(Icons.logout, 'Sign Out', _red, () {}),
                    ]),
                    const SizedBox(height: 20),
                    const Text(
                      'Playbook365 v1.0.0',
                      style: TextStyle(fontSize: 12, color: _gray400),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          Text(
            'More',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Text(
              'JD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jamie Davis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Parent · U14 Boys Premier',
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Colors.white70, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_MoreItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _gray400,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.vertical(
                      top: i == 0
                          ? const Radius.circular(14)
                          : Radius.zero,
                      bottom: isLast
                          ? const Radius.circular(14)
                          : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(item.icon,
                                color: item.color, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _gray700,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: _gray400, size: 18),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1, indent: 64, color: _gray100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoreItem(this.icon, this.label, this.color, this.onTap);
}

// ══════════════════════════════════════════════════════════════════════════════
// REMAINING SCREENS (Photos, Statistics, Files, Tracking,
// Invoicing, Registration, NotificationPrefs, PlayerAttendance)
// ══════════════════════════════════════════════════════════════════════════════

// ── Photos ────────────────────────────────────────────────────────────────────

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  int _selectedAlbum = 0;

  final _albums = const [
    'All Photos',
    'vs. Riverside FC',
    'Practice Mar 25',
    'Spring 2026',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Album filter
          Container(
            color: Colors.white,
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: _albums.length,
              itemBuilder: (_, i) {
                final isActive = i == _selectedAlbum;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAlbum = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF1A56DB)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _albums[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Photo grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 21,
              itemBuilder: (_, i) => _PhotoTile(index: i),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final int index;
  const _PhotoTile({required this.index});

  static const _colors = [
    Color(0xFF1A56DB), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFF8B5CF6), Color(0xFFEF4444), Color(0xFF0EA5E9),
    Color(0xFFF97316), Color(0xFF14B8A6), Color(0xFF6366F1),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Container(
      color: color.withOpacity(0.15),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Icon(Icons.image_outlined, color: color.withOpacity(0.4), size: 32),
          if (index == 0 || index == 5)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('NEW',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Statistics ────────────────────────────────────────────────────────────────

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tab,
          labelColor: const Color(0xFF1A56DB),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF1A56DB),
          tabs: const [Tab(text: 'Team'), Tab(text: 'Players')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildTeamStats(),
          _buildPlayerStats(),
        ],
      ),
    );
  }

  Widget _buildTeamStats() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statCard('Season Record', [
          _statRow('Wins', '8', const Color(0xFF10B981)),
          _statRow('Losses', '2', const Color(0xFFEF4444)),
          _statRow('Draws', '1', const Color(0xFFF59E0B)),
          _statRow('Win Rate', '73%', const Color(0xFF1A56DB)),
        ]),
        const SizedBox(height: 16),
        _statCard('Goals', [
          _statRow('Scored', '27', const Color(0xFF10B981)),
          _statRow('Conceded', '11', const Color(0xFFEF4444)),
          _statRow('Difference', '+16', const Color(0xFF1A56DB)),
          _statRow('Per Game Avg', '2.45', const Color(0xFF8B5CF6)),
        ]),
        const SizedBox(height: 16),
        _statCard('Discipline', [
          _statRow('Yellow Cards', '9', const Color(0xFFF59E0B)),
          _statRow('Red Cards', '1', const Color(0xFFEF4444)),
        ]),
      ],
    );
  }

  Widget _buildPlayerStats() {
    const players = [
      ('James Miller', '#9 FWD', 9, 4, 3),
      ('Oliver Davis', '#10 MID', 5, 8, 0),
      ('Lucas Wilson', '#11 FWD', 6, 3, 1),
      ('Henry Thomas', '#6 MID', 4, 6, 0),
      ('Ethan Brown', '#5 DEF', 2, 2, 1),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('Player',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280)))),
              Expanded(
                  child: Text('G',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280)))),
              Expanded(
                  child: Text('A',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280)))),
              Expanded(
                  child: Text('YC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280)))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...players.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.$1,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827))),
                        Text(p.$2,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Text('${p.$3}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981)))),
                  Expanded(
                      child: Text('${p.$4}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A56DB)))),
                  Expanded(
                      child: Text('${p.$5}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B)))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _statCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF6B7280))),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ── Files ─────────────────────────────────────────────────────────────────────

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  static const _files = [
    ('Lineup_Mar29.pdf', 'PDF', '245 KB', Color(0xFFEF4444)),
    ('Practice_Plan_Apr1.pdf', 'PDF', '180 KB', Color(0xFFEF4444)),
    ('Tournament_Registration.pdf', 'PDF', '512 KB', Color(0xFFEF4444)),
    ('Team_Photo_Spring.jpg', 'Image', '2.1 MB', Color(0xFF0EA5E9)),
    ('Season_Schedule.xlsx', 'Spreadsheet', '98 KB', Color(0xFF10B981)),
    ('Club_Waiver_2026.pdf', 'PDF', '320 KB', Color(0xFFEF4444)),
    ('Kit_Order_Form.docx', 'Document', '67 KB', Color(0xFF1A56DB)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          IconButton(
              icon: const Icon(Icons.upload_file_outlined),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _files.map((f) => _FileTile(file: f)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final (String, String, String, Color) file;
  const _FileTile({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: file.$4.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.insert_drive_file_outlined,
                color: file.$4, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.$1,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
                const SizedBox(height: 3),
                Text('${file.$2} • ${file.$3}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined,
                color: Color(0xFF9CA3AF), size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ── Tracking ──────────────────────────────────────────────────────────────────

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _trackCard('Season Goals', 27, 40, const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _trackCard('Training Sessions', 18, 24, const Color(0xFF1A56DB)),
          const SizedBox(height: 12),
          _trackCard('Team Attendance', 88, 100, const Color(0xFF8B5CF6)),
          const SizedBox(height: 12),
          _trackCard('Tournament Points', 25, 36, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _trackCard(
      String label, int current, int total, Color color) {
    final pct = current / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
              Text('$current / $total',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(pct * 100).round()}% of target',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ── Invoicing ─────────────────────────────────────────────────────────────────

class InvoicingScreen extends StatelessWidget {
  const InvoicingScreen({super.key});

  static const _invoices = [
    ('INV-001', 'Spring Registration', 'Oliver Davis', 150.00, 'Paid'),
    ('INV-002', 'Spring Registration', 'James Miller', 150.00, 'Paid'),
    ('INV-003', 'Kit Fee', 'Noah Williams', 65.00, 'Pending'),
    ('INV-004', 'Tournament Fee', 'Henry Thomas', 45.00, 'Overdue'),
    ('INV-005', 'Spring Registration', 'Lucas Wilson', 150.00, 'Paid'),
    ('INV-006', 'Kit Fee', 'Aiden Taylor', 65.00, 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF10B981);
    const amber = Color(0xFFF59E0B);
    const red = Color(0xFFEF4444);

    Color statusColor(String s) =>
        s == 'Paid' ? green : s == 'Pending' ? amber : red;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Invoicing'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Summary strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _invoiceStat('Total', '\$625', const Color(0xFF1A56DB)),
                _vDivider(),
                _invoiceStat('Collected', '\$450', green),
                _vDivider(),
                _invoiceStat('Pending', '\$130', amber),
                _vDivider(),
                _invoiceStat('Overdue', '\$45', red),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _invoices
                  .map((inv) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(inv.$2,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827))),
                                  const SizedBox(height: 3),
                                  Text(
                                      '${inv.$1} · ${inv.$3}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text('\$${inv.$4.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor(inv.$5)
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(inv.$5,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor(inv.$5))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _invoiceStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 32, color: const Color(0xFFF3F4F6));
}

// ── Registration & Insurance ──────────────────────────────────────────────────

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Registration & Insurance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _regCard('Team Registration', 'Spring 2026',
              'Registered', const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _regCard('Player Insurance', 'All Players',
              '16 / 16 Covered', const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _regCard('Tournament Registration', 'Spring Cup 2026',
              'Pending', const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _regCard('Background Checks', 'Coaching Staff',
              '2 / 2 Complete', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _regCard(
      String title, String subtitle, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(Icons.verified_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      ),
    );
  }
}

// ── Notification Preferences ──────────────────────────────────────────────────

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState
    extends State<NotificationPrefsScreen> {
  final Map<String, bool> _prefs = {
    'Game Reminders': true,
    'Practice Reminders': true,
    'New Messages': true,
    'RSVP Requests': true,
    'Team Announcements': true,
    'Invoice Reminders': false,
    'Photo Uploads': false,
    'File Shares': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _prefGroup('Events', ['Game Reminders', 'Practice Reminders', 'RSVP Requests']),
          const SizedBox(height: 16),
          _prefGroup('Communication', ['New Messages', 'Team Announcements']),
          const SizedBox(height: 16),
          _prefGroup('Finance & Files', ['Invoice Reminders', 'Photo Uploads', 'File Shares']),
        ],
      ),
    );
  }

  Widget _prefGroup(String title, List<String> keys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: keys.asMap().entries.map((e) {
              final isLast = e.key == keys.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(e.value,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF374151))),
                        ),
                        Switch(
                          value: _prefs[e.value] ?? false,
                          onChanged: (v) =>
                              setState(() => _prefs[e.value] = v),
                          activeColor: const Color(0xFF1A56DB),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        indent: 16,
                        color: Color(0xFFF3F4F6)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Player Attendance ─────────────────────────────────────────────────────────

class PlayerAttendanceScreen extends StatelessWidget {
  const PlayerAttendanceScreen({super.key});

  static const _data = [
    ('Liam Anderson', 'GK #1', 92, 11, 12),
    ('Noah Williams', 'DEF #4', 88, 10, 12),
    ('Ethan Brown', 'DEF #5', 100, 12, 12),
    ('Mason Jones', 'MID #8', 75, 9, 12),
    ('Oliver Davis', 'MID #10', 96, 11, 12),
    ('James Miller', 'FWD #9', 83, 10, 12),
    ('Lucas Wilson', 'FWD #11', 91, 11, 12),
    ('Henry Thomas', 'MID #6', 100, 12, 12),
    ('Aiden Taylor', 'DEF #3', 67, 8, 12),
  ];

  static Color _color(int pct) =>
      pct >= 90 ? const Color(0xFF10B981) : pct >= 75 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Player Attendance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _data
            .map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(p.$1,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827))),
                                Text(p.$2,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                          Text('${p.$3}',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _color(p.$3))),
                          const Text('%',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF))),
                          const SizedBox(width: 8),
                          Text('${p.$4}/${p.$5}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p.$3 / 100,
                          minHeight: 6,
                          backgroundColor:
                              const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _color(p.$3)),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PLACEHOLDER SCREENS (replace with real implementations)
// ══════════════════════════════════════════════════════════════════════════════

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_QuickLink> actions;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.color,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: color.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text(
                'Replace with $title screen',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...actions.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: a.onTap,
                          icon: Icon(a.icon, size: 18),
                          label: Text(a.label),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: a.color,
                            padding: const EdgeInsets.symmetric(
                                vertical: 13),
                          ),
                        ),
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLink {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickLink({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// Placeholder pass-throughs for screens defined in other files
class TeamDetailPlaceholder extends StatelessWidget {
  const TeamDetailPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      // 👉 Replace with: TeamDetailScreen()
      _PlaceholderScreen(
          title: 'Team Detail',
          icon: Icons.sports_soccer,
          color: const Color(0xFF1A56DB));
}

class EventDetailPlaceholder extends StatelessWidget {
  const EventDetailPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      // 👉 Replace with: EventDetailScreen()
      _PlaceholderScreen(
          title: 'Event Detail',
          icon: Icons.event,
          color: const Color(0xFF10B981));
}

class EventFormPlaceholder extends StatelessWidget {
  const EventFormPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      // 👉 Replace with: EventFormScreen()
      _PlaceholderScreen(
          title: 'Event Form',
          icon: Icons.edit_calendar_outlined,
          color: const Color(0xFFF59E0B));
}
