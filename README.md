# Playbook365 — Flutter Club Management App

Latest Flutter SDK -> 3.38.5

creds
Vishal@cwiser.com
Cwiser@123
Ritu0909@-1


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

SIMPLE TASK PROMPT POST PROCESSING PROMPT

{
"success": true,
"message": "",
"data": {
"player": {
"player_id": 1179,
"uuid": "a63a415b-f211-46d6-843b-41fb377cf21d",
"name": "jarish jackson"
},
"team": {
"team_id": 547,
"uuid": "6848b97e-60de-4bfa-8c2a-786fe0c73219",
"name": "New club Team 2"
},
"grid": [
{
"id": 19,
"team_event_session_id": 19,
"uuid": "0da4f1cc-dc04-49cd-ae41-daf63b636c9b",
"team_event_session_uuid": "0da4f1cc-dc04-49cd-ae41-daf63b636c9b",
"event_from": 0,
"event_id": 0,
"event_type": 1,
"schedule_game_id": 0,
"event_name": "",
"name": "Test 22",
"display_name": "Test 22",
"event_date": "2026-07-06",
"session_date": "2026-07-06",
"date_label": "Jul 6",
"start_time": "15:06:00",
"end_time": null,
"time_label": "3:06 PM",
"location": "Gillis van Ledenberchstraat",
"location_details": "",
"team": "Test 22",
"opponent_team_id": 4,
"opponent_team_name": "Test 22",
"team_event_session_attendee_id": 6,
"attendance": 2,
"attendance_notes": "test"
}
],
"items": [
{
"id": 19,
"team_event_session_id": 19,
"uuid": "0da4f1cc-dc04-49cd-ae41-daf63b636c9b",
"team_event_session_uuid": "0da4f1cc-dc04-49cd-ae41-daf63b636c9b",
"event_from": 0,
"event_id": 0,
"event_type": 1,
"schedule_game_id": 0,
"event_name": "",
"name": "Test 22",
"display_name": "Test 22",
"event_date": "2026-07-06",
"session_date": "2026-07-06",
"date_label": "Jul 6",
"start_time": "15:06:00",
"end_time": null,
"time_label": "3:06 PM",
"location": "Gillis van Ledenberchstraat",
"location_details": "",
"team": "Test 22",
"opponent_team_id": 4,
"opponent_team_name": "Test 22",
"team_event_session_attendee_id": 6,
"attendance": 2,
"attendance_notes": "test"
}
],
"total": 1,
"pagination": {
"total": 1,
"per_page": 50,
"current_page": 1,
"last_page": 1,
"is_last_page": true
}
}
}



AI MESSAGE TO RECREATE UI FROM FIGMA FILES


- Match every background, card, border, text, icon, and accent color exactly
- Use AppColors.current.xxx — never hardcode hex values
- If a required color doesn't exist in AppColors, add it to both light and dark palettes first

ICONS
- Match every icon exactly to the Figma design
- Prefer existing SVG assets in assets/svgs/ via CustomSvgIcon
- If an icon doesn't exist, create a new SVG file using the exact lucide-react path data, add it to AppAssets, then use it
- Never substitute a similar-looking Material Icon as a replacement

TEXT
- Match font size, font weight, line height, letter spacing, and color exactly
- Use AppTextStyles.xxx where a matching style exists
- For one-off sizes/weights not in AppTextStyles, use inline TextStyle with fontFamily: 'Inter'

DIMENSIONS & SPACING
- Match padding, margin, gap, border radius, and height/width values exactly (convert px → logical pixels 1:1)
- Use SizedBox and EdgeInsets — no magic numbers without a comment explaining the source

LAYOUT
- Match the exact layout structure (Row, Column, Stack, etc.) as shown in Figma
- Respect alignment, flex/expanded behaviour, and scroll direction

THEME
- Every widget must work correctly in both light and dark mode
- Test color usage against both AppColors.light and AppColors.dark palettes

COMPONENTS
- Reuse existing shared widgets (AppHeader, AppBottomNavBar, etc.) where the Figma uses them
- Do not duplicate existing widget logic — extend or parameterise instead

PROJECT CONVENTIONS
- Widgets are dumb — no business logic inside widgets
- Follow the feature folder structure: models/, pages/, providers/, services/, widgets/
- Prefix all feature files with the feature name