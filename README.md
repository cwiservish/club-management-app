# Playbook365 — Flutter Club Management App

Latest Flutter SDK -> 3.38.5

Converted from Figma Make design file by Claude.
Figma source: https://www.figma.com/make/d1kr0jsnxg9hbQfsuMBHAw/Club-Management-App

---


core/network/
api_endpoints.dart              ← all route constants, never hardcode strings in services
token_storage.dart              ← TokenNotifier / authTokenProvider (JWT in memory)
cancel_token_registry.dart      ← named CancelToken lifecycle, call cancelAll() in dispose()
models/
api_exception.dart            ← sealed hierarchy: Network / Auth / Forbidden / NotFound
/ Validation / Server / Cancelled / Parse / Generic
api_response.dart             ← ApiResponse<T> + PaginatedApiResponse<T> + PaginationMeta
interceptors/
auth_interceptor.dart         ← injects Bearer token; triggers setToken(null) on 401
Options.skipAuth() extension for public endpoints
logging_interceptor.dart      ← pretty request/response/error logs, debug-only
redacts Authorization header value
error_interceptor.dart        ← DioException → typed ApiException (must be last in chain)
api_client.dart                 ← ApiClient + apiClientProvider (Riverpod Provider)
get / getList / getPaginated / post / put / patch / delete / upload



## Project Structure

```
lib/
├── main.dart                          # App entry point
├── theme/
│   └── app_theme.dart                 # Colors, text styles, spacing, theme config
├── models/
│   ├── models.dart                    # All data models + enums
│   └── sample_data.dart               # Mock data (replace with API calls)
├── utils/
│   └── utils.dart                     # Date formatting, widget helpers
├── widgets/
│   └── shared_widgets.dart            # Reusable widgets (AppBottomNavBar, StatCard, etc.)
└── screens/
    ├── app_shell.dart                 # Root shell with IndexedStack + per-tab Navigator
    ├── home_screen.dart               # Home dashboard
    ├── schedule_screen.dart           # Schedule with week/month calendar + event list
    ├── roster_screen.dart             # Roster grid/list + player detail sheet
    ├── team_event_screens.dart        # TeamDetailScreen + EventDetailScreen + EventFormScreen
    ├── messages_screens.dart          # MessagesScreen + ChatDetailScreen
    ├── more_screen.dart               # More hub with navigation to all sub-screens
    ├── more_and_shell.dart            # Source file — extract secondary screens from here
    ├── statistics_screen.dart         # → extract StatisticsScreen from more_and_shell.dart
    ├── photos_screen.dart             # → extract PhotosScreen from more_and_shell.dart
    ├── files_screen.dart              # → extract FilesScreen from more_and_shell.dart
    ├── tracking_screen.dart           # → extract TrackingScreen from more_and_shell.dart
    ├── invoicing_screen.dart          # → extract InvoicingScreen from more_and_shell.dart
    ├── registration_screen.dart       # → extract RegistrationScreen from more_and_shell.dart
    ├── notification_prefs_screen.dart # → extract NotificationPrefsScreen from more_and_shell.dart
    └── player_attendance_screen.dart  # → extract PlayerAttendanceScreen from more_and_shell.dart
```

---

## Getting Started

```bash
flutter pub get
flutter run
```

Minimum Flutter SDK: **3.0.0**

---

## Developer Handoff Notes

### 1. Fonts
The app uses **Inter** font family. To enable it:
1. Download Inter from https://fonts.google.com/specimen/Inter
2. Place font files under `assets/fonts/`
3. Uncomment the fonts section in `pubspec.yaml`

### 2. Replacing Sample Data
All mock data lives in `lib/models/sample_data.dart`. Each screen accepts
data via constructor or reads from this file directly.
Connect to your backend by replacing the `sample*` variables with API calls.

### 3. Extracting Secondary Screens
The screens listed with `→ extract` above are fully implemented inside
`lib/screens/more_and_shell.dart`. To split them:
1. Find the class (e.g. `class StatisticsScreen`) in `more_and_shell.dart`
2. Cut the class and paste it into its own file (e.g. `statistics_screen.dart`)
3. Add `import '../theme/app_theme.dart';` and any other needed imports
4. The `more_screen.dart` imports are already wired correctly

### 4. Navigation
- The app uses a nested `Navigator` pattern (one per tab)
- Each screen has a standalone `main()` for isolated testing
- To navigate between screens: `Navigator.push(context, MaterialPageRoute(builder: (_) => TargetScreen()))`
- Double-tapping a bottom nav tab pops to root of that tab

### 5. State Management
Currently stateless / local setState only. Recommended next steps:
- Add **Riverpod** or **Provider** for shared state
- Add **go_router** for deep linking and named routes

### 6. Screens Inventory

| Screen | File | Status |
|--------|------|--------|
| Home Dashboard | `home_screen.dart` | ✅ Complete |
| Schedule (week/month) | `schedule_screen.dart` | ✅ Complete |
| Roster (grid + list) | `roster_screen.dart` | ✅ Complete |
| Team Detail | `team_event_screens.dart` | ✅ Complete |
| Event Detail | `team_event_screens.dart` | ✅ Complete |
| Event Form (add/edit) | `team_event_screens.dart` | ✅ Complete |
| Messages | `messages_screens.dart` | ✅ Complete |
| Chat Detail | `messages_screens.dart` | ✅ Complete |
| More Hub | `more_screen.dart` | ✅ Complete |
| Statistics | `more_and_shell.dart` | ✅ Needs extraction |
| Photos | `more_and_shell.dart` | ✅ Needs extraction |
| Files | `more_and_shell.dart` | ✅ Needs extraction |
| Tracking | `more_and_shell.dart` | ✅ Needs extraction |
| Invoicing | `more_and_shell.dart` | ✅ Needs extraction |
| Registration & Insurance | `more_and_shell.dart` | ✅ Needs extraction |
| Notification Preferences | `more_and_shell.dart` | ✅ Needs extraction |
| Player Attendance | `more_and_shell.dart` | ✅ Needs extraction |

### 7. Design Tokens
All colors, spacing, and typography live in `lib/theme/app_theme.dart`:
- `AppColors` — full palette
- `AppTextStyles` — Inter type scale
- `AppSpacing` — spacing constants
- `AppRadius` — border radius tokens
- `AppShadows` — elevation shadows
- `AppTheme.light` — Material 3 theme config

---

## Figma Source
https://www.figma.com/make/d1kr0jsnxg9hbQfsuMBHAw/Club-Management-App
