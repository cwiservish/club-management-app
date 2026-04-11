# Playbook365 — Flutter Club Management App

Latest Flutter SDK -> 3.38.5


## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app/                               # App-level setup
│   ├── app.dart                       # Root MaterialApp widget
│   ├── app_theme.dart                 # Colors, text styles, spacing, theme config
│   └── router/                        # go_router config
│       ├── app_router.dart            # Router instance + redirect logic
│       └── app_routes.dart            # Route name constants
├── shell/
│   └── app_shell.dart                 # Bottom nav shell with tab routing
├── core/                              # Shared infrastructure, no business logic
│   ├── constants/                     # App-wide static constants
│   ├── config/                        # Environment config (base URL, flags)
│   ├── enums/                         # Shared enums (UserRole, EventType, MemberRole, etc.)
│   ├── exceptions/                    # Typed exception classes (app / network / cache)
│   ├── local_storage/                 # Persistent storage abstraction
│   ├── models/                        # Shared data models used across features
│   ├── network/                       # Dio client + interceptors + response models
│   │   └── interceptors/              # Auth / logging / error interceptors
│   ├── common_providers/
│   │   └── current_user_provider.dart # Currently logged-in user state
│   ├── rbac/                          # Role-based access control
│   │   ├── permission_checker.dart    # Permission evaluation logic
│   │   └── role_guard.dart            # Widget-level role gating
│   ├── utils/                         # Date formatting, widget helpers
│   └── widgets/                       # Reusable widgets (StatCard, AppBottomNavBar, etc.)
└── features/                          # Each feature follows: models/ pages/ providers/ services/
    ├── auth/
    ├── home/
    ├── messages/
    ├── more/
    ├── roster/                        # Includes attendance sub-feature
    ├── schedule/                      # Includes event detail + form pages
    ├── splash/
    ├── team/
    ├── invoicing/
    ├── statistics/
    ├── photos/
    ├── files/
    ├── tracking/
    ├── registration/
    └── notifications/
```


## Figma Source
https://www.figma.com/make/d1kr0jsnxg9hbQfsuMBHAw/Club-Management-App
