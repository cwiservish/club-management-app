# Playbook365 Club Management App — project notes

Flutter app (`name: playbook365`, Android package `com.playbook365.clubManagement`).
State: Riverpod (`flutter_riverpod`), routing: `go_router`, HTTP: `dio` via `ApiClient`.
Read this file first; it records what exists, how it behaves, API facts we confirmed, and what
is planned. Update it whenever a feature or API fact changes.

---

## 1. Layout

```
lib/
  main.dart, app/ (app.dart, router/, theme/)
  shell/app_shell.dart           bottom nav (hidden on routes ending in /edit)
  core/                          config, network (ApiClient, endpoints, interceptors), models, enums,
                                 local_storage (AppStorage), rbac, shared_widgets, common_providers
  features/
    auth/                        FusionAuth login (auth_service.dart, auth_provider.dart)
    home/                        upcoming sessions (home_service.dart, home_provider.dart)
    schedule/                    month-wise events, league schedule
    event_details/               add/edit event, detail, availability, RSVP
    roster/                      players, staff, player profile, attendance
    messages/                    TalkJS chat (channels + DMs)
    photos/ files/ notification_preferences/ settings/ statistics/ invoice/ tracking/ splash/
config/env.json                  API + FusionAuth + Google Maps keys (read at startup)
docs: this file
```

Key files for events: `features/event_details/pages/add_edit_event_page.dart` (one big page used for
add / edit), `widgets/event_location_tab_view.dart`, `widgets/event_repeats_until_section.dart`,
`models/new_event_save_request_model.dart`, `models/new_event_dropdown_options_model.dart`,
`models/uniform_color.dart`, `providers/event_add_edit_provider.dart`, `services/event_detail_service.dart`.

---

## 2. Environment & login

- `config/env.json`: `API_BASE_URL` = `https://qa.sportid.app/apps/club`, `FUSIONAUTH_BASE_URL`,
  `FUSIONAUTH_TENANT_ID`, `FUSIONAUTH_API_KEY`, `GOOGLE_MAPS_API_KEY`, `RADAR_API_KEY`.
  Keep the tenant id exactly 36 chars (a stray trailing char broke login once).
- **Login sends NO `applicationId`** (`/api/login` body = `loginId`, `password`; headers: api key + tenant id).
  FusionAuth still returns a JWT. `FUSIONAUTH_APP_ID` is in env but unused.
- Test users (QA): `semul-staff1@example.com` (org role 2), `alinarodrick@example.com` (org role 1), password `password`.
- Cloudflare blocks scripted clients with non-browser UAs; plain `curl` works for QA probes.

---

## 3. Roles & access

- `Team.isCoach` (core/models/team_model.dart) = API `is_coach` **OR** `organization_role_id` in {1, 2, 3}
  (organization staff get coach rights). `organizationRoleId` and `roleLabel` (`role_label`) are stored and cached.
- Everything coach-only reads `isCoach`: + menu (Event / Player), Edit on event detail, coach controls.
  Others only get Chat.
- Account drawer shows the API `role_label` (e.g. "Organization Staff"); fallback `role`, then COACH / PARENT.
- Hot-reload safety: new final fields on long-lived models are null-safe getters (`Team.roleLabel`,
  `NewEventDropdownOptions.uniformItems`). Do the same when adding fields.

---

## 4. Add / edit event (add_edit_event_page.dart)

Scheduling types: 1 Single Session, 2 Tournament, 3 League (`_schedulingTypeKey`).

**Single Session** — tabs Details / Location / Uniform / RSVP.
- Event types come from API (Game, Practice, Scrimmage, Team Event, Camp).
- Repeat: Weekly (recurring_type 2, `days:[{day,start_time,end_time}]`) or Monthly (3, list of `yyyy-MM-dd`).
  Weekly: start is always **today** (no start-date row), "Repeat Until" max = 1 year (server rule).
  Monthly: month/year dropdowns + calendar, past dates blocked, no upper cap.
- Date pickers block past dates; upper bound 2100-12-31.

**Tournament / League** — card with "Do you know the game schedule?":
- "Not yet — placeholder": title, start/end date, location, notes.
- "Yes, I have it": same four tabs as Single Session (event type hidden, always a Game, no repeat) and saves as a
  single game session (`scheduling_mode 1`, `event_type 1`, `event_from` 2 when inside a parent).
- Both use the same location selector as Single Session.

**Location (type → `location_type`)**: 1 Our Facilities (venue + **required field**), 2 Saved Location,
3 Off-Site Address (Google Places → address, city, state, country, postal_code, place_id, lat/lng), 4 TBD.
- The tab row is built from dropdown option `location_types` (labels and count from the API, keys 1-4 map to the forms; unknown keys are skipped; empty list = four defaults).
- Facilities come from dropdown option `venues` (fallback `our_locations`). `venues` field names already
  include the facility name — `_venueFieldName()` avoids "FAC - FAC - Field".
- The Field dropdown always ends with a static **TBD** option (`OurLocationField.tbd`, `field_id` 0, sent as `field_id: 0`); it satisfies the required field, saves the facility name as location text and skips the conflict board (nothing to clash-check).
- Validation: `_facilityFieldError()` ("Select a field at the facility").

**Uniform**: items from API `uniform_items` (top, bottom, socks, cap …), palette from API `uniform_colors`
(`applyUniformPalette` replaces `kUniformColors`; defaults mirror the server palette). Save sends
`uniform: {item: "#hex"|null}`; selecting a template sends only `uniform_template_id`.

**RSVP**: players/staff from roster. Staff list on this page is requested with `staff_type: "team"`;
the roster notifier remembers the filter and ignores stale responses; the Roster tab is refreshed unfiltered
when the page closes. IDs sent: `player_ids` = player id, `staff_ids` = staff **`customer_id`**
(server rejects the staff row id). If the RSVP tab is never opened, "everyone invited" is applied at save time.

**Validation (no toasts for missing fields)**: `_validateForm()` runs at the start of `_doSave`. It collects every missing
field for the current mode (Single Session, Tournament/League placeholder, or a Tournament/League game) into `_fieldErrors`
(id -> message), highlights each one (red border + tint + message), switches to the tab of the first error and scrolls to it
(`_keyFor(id)` GlobalKeys + `Scrollable.ensureVisible`). Ids: title, opponent, opponentName, startDate, endDate, repeatUntil,
repeatDays, repeatDates, facility, field, savedLocation, address, templateName. Errors clear when the user edits/selects the
field. Input helpers `_buildTextField / _buildPickerField / _buildDropdownField` take `errorId`; `EventLocationTabView` takes
`errors` + `fieldKeyFor`; `EventRepeatsUntilSection` takes `repeatUntilError / daysError / datesError` + keys.
Server errors and "no active team" still use a toast/dialog.

**Save results**: `NewEventSaveResponse` carries `status` (5 = draft) and `conflicts[]`.
`EventAddEditNotifier.lastSaveWasDraft` / `lastSaveConflicts` expose them. A draft shows
"Saved as draft: Waiting for approval".

**Edit**: prefill from `ClubEvent`; the edit route is under the shell so the shell hides the nav
bar for paths ending `/edit`.

---

## 5. Roster

- `RosterMember.id` = **uuid** (profile / attendance APIs need it). `apiId` = numeric id for event APIs
  (player id; staff customer_id → staff id fallback).
- `RosterNotifier.fetchPlayers(teamUuid, {staffType})` + `refresh({staffType})`; `_fetchSeq` drops stale fetches.
- `ChatMember.name` falls back to email when the server name is empty.

---

## 6. Confirmed API facts (QA)

- All responses are HTTP 200 `{success, message, data}`; branch on `success`.
- `GET teams/event/session/dropdownoptions?team_uuid=` returns: location_types, our_locations, venues,
  saved_locations, timezones, teams, uniform_templates, scheduling_types (map), recurring_types, event_types,
  home_away_options, arrival_time_selection, organizations, uniform_colors, uniform_items, weekdays.
  (Old `/teams/event/dropdownoptions` 404s — `ApiEndpoints.eventDropdownOptions` now points at the session one.)
- `POST team/staff/list` accepts `staff_type` ("team" | "organization"); default returns org staff (ids collide with team staff ids).
- `POST teams/event/save`: `staff_ids` must be integers matching staff `customer_id`; type 1 needs `venue_id` + `field_id`.
- `arrival_time` in event lists is filled even when `arrival_early` is 0 — only trust it when `arrival_early > 0`.
- `POST team/player/profile` needs the player **uuid**.

### Session/location guide (from the Postman collection `ClubAppAPis.postman_collection.json`)

- Types: 1 facility (venue_id + field_id required, **clash-checked**), 2 saved location, 3 off-site, 4 TBD.
- Recurrence `recurring_type`: 1 one date, 2 weekly (`session_end_date` ≤ 1 year, `days:[{day,start_time,end_time?}]`),
  3 specific dates (`days:["yyyy-MM-dd"]`).
- Target: `id` = one session (one date of a series keeps its date), `code` = whole series from today on.
- Status: 1 scheduled, 2 cancelled, 5 draft (coach save = draft unless club setting; manager = scheduled).
- **Conflict board (type 1)**: `teams/event/session/generate_slots` (same body as save, no slots) →
  rows `{date,start_time,end_time,venue_id,field_id,checked,is_available,is_blocking,warnings,message,locked?}` +
  `has_conflicts`, `conflict_count`, `exclude_ids`. Recheck one edited row with
  `teams/event/session/field_availability` (`team_uuid, location_type, venue_id, field_id, date, start_time, end_time, exclude_ids`).
  Save with `slots:[{date,start_time,end_time,field_id}]` (omit `locked` rows). On clash: `success:false`, nothing saved,
  `data.conflicts[]`.
- Edit cases: A one-off (`id`), B one date of series (`id`, one-row `slots`, date can't change), C whole series (`code`,
  prefill via `teams/event/session/detail` → `data.edit`, always from today). No location sent = keep stored location.
- Cancel / reinstate: `teams/event/session/status` `{id|code, status 2|1}`. Delete: `teams/event/remove` `{scheduling_mode:1, id|code}`.
  Confirm drafts (manager): `generate_slots {for_confirm:1}` then `teams/event/session/confirm`; keep `kept_slots` when saving a changed board.
- Other collection endpoints: `team_staff_and_players`, `team_opponents`, `location/list|save`, session-attendee, gallery, files, chat.

---

## 7. Session conflict board & recurring edits (built)

Decisions: staff/player selection unchanged; weekly max 1 year and starts today; board only for location type 1;
board applies to **sessions** (Single Session and games inside a Tournament/League), not the Tournament/League
placeholder; coaches' saves show "Saved as draft"; managers (organization role 1/2/3, `Team.isManager`) confirm drafts.

**Phase 1 (done, verified on emulator)**: field required for type 1; weekly start = today + 1-year cap; draft message;
`NewEventSaveResponse` parses `status` + `conflicts`.

**Phase 2 - board (done, verified on emulator)**
- Models: `models/session_slot_models.dart` (`SessionSlot`, `SlotBoard`, `SlotApiException`).
- API (`EventDetailService`): `generateSlots(body)`, `checkFieldAvailability(...)`; endpoints in `ApiEndpoints`.
- UI: `widgets/slot_board_sheet.dart` (bottom sheet: row per date, Available/Clash/Locked chips, change time or field -> only
  that row is re-checked, Save disabled while any row clashes). `readOnly` mode is used for the manager confirm board.
- Flow: `_submitSession` in `add_edit_event_page.dart` -> for `locationType == 1` calls `_reviewBoard` (generate_slots, then
  the sheet; one clash-free date skips the sheet) -> sets `request.slots` -> saves. If the server still returns
  `data.conflicts` the fresh board is shown again (max 3 tries).

**Phase 3 - edit (done; series edit verified on emulator, "this date only" save not yet exercised)**
- `ClubEvent` now carries `code`, `recurringType`, `venueId`, `fieldId`, `locationType` (parsed in home_service and schedule_response).
- Editing a session that belongs to a series (`code` set and `recurringType != 1`) asks **This date only / All upcoming**
  (`askEditScope` in `utils/edit_scope_dialog.dart`, shown by Event Details -> Edit BEFORE the form opens and passed as route extra `editScope` / `seriesEdit`; the page's `_askEditScope` only asks itself when opened without it. Dialog "Edit which events?" with a generated summary such as "This practice repeats (Weekly · Mon, Tue · Oct 26 – Oct 30, 2026 · 5 sessions)", built from `session/detail` by `code`; monthly lists the dates). "All upcoming" loads `session/detail` by `code` -> `data.edit` into the repeat section
  (`_loadSeriesForEdit`) and saves with `code` (no `id`), start date = today. "This date only" keeps the date
  locked and always sends its single `slots` row (case B).
- Request: `NewEventSaveRequest.slots` and `.code` (set after construction).

**Phase 4 - cancel / delete / draft / confirm (cancel, reinstate, series delete verified on emulator; draft + confirm need a coach-only login to test)**
- Cancel / reinstate use `teams/event/session/status` (`EventDetailService.setSessionStatus`) with the same this-date/series choice;
  Tournament/League keep the old toggle behaviour. Delete sends `code` for a series (`EventDeleteRequest.code`); it shows one red-button confirm and reuses the "Edit which events?" choice (`_chosenScope`) instead of asking this date / series again.
- Draft (status 5): "Draft - waiting for manager" pill on Home cards and a banner on Schedule tiles; Event Details shows a
  Draft banner, RSVP disabled; managers get **Confirm session** (board in read-only mode for type 1, then
  `teams/event/session/confirm`; series asks this date / all dates).

**Phase 5 - tests**: `test/session_slots_test.dart` (board parsing, draft/conflicts, request shapes) and
`test/event_repeats_until_section_test.dart` pass (`flutter test`). Still to do: emulator walk-through of edit-series,
cancel, delete and confirm with real QA data.

## 7b. Session row flags (Oct 2026 backend change, built)

- **Title**: required wherever the Title field is shown (Practice / Team Event / Camp sessions and the Tournament/League placeholder). Game / Scrimmage show Opponent instead, so no title check there. (The server can still default a missing title, but the app no longer relies on it.) The title is prefilled with the event type label (`_applyTypeTitle` / `_autoTitle`): on Add Event open for the preselected Practice, on each chip tap and when switching back to Single Session; switching to Tournament / League clears it; a title the user typed is never overwritten.
- **Uniform**: rows carry `uniform_details` (`ClubEvent.uniformDetails`); Event Details shows swatch + "Top: Black", swatch only when `color_label` is empty. Old hex fields remain the fallback (tournament/league rows have `[]`). Never send `uniform_details` back.
- **RSVP**: `can_rsvp` -> `ClubEvent.canRsvp` (missing = true). Home `RsvpRow(enabled:)`, Schedule tile and Event Details dim/disable buttons when false. Targets come from top-level `rsvp_targets` (fallback `my_rsvp.targets`); picker when more than one. Availability screen is untouched.
- **One-day type-1 session**: `generate_slots` then the Check availability sheet with the single row (only one date of a series with no clash still skips the sheet).
- **Series edit ("All upcoming")**: `session/detail` by `code` -> `data.edit` also fills `location_type/venue_id/field_id` (facility + field) and start time/duration, so unchanged edits send them back and each date keeps its own field.
- **One occurrence ("This date only")**: `session/detail` by `id` -> `can_change_date` / `can_change_recurrence` (unreadable = false). False hides Repeats and disables the Date picker.
- Not yet verified against live QA data (response shape of those flags assumed top-level in `data`).

## 8. Testing on the Android emulator (what worked)

- App runs from Android Studio (hot restart needed for state/const changes; a hot reload is not enough).
- Drive it with adb: `adb shell input tap/swipe/text/keyevent`, `adb exec-out screencap -p`, and capture the app's
  API log with `adb logcat -v time flutter:I AndroidRuntime:E '*:S'` (request/response bodies are logged).
- Screen is 1080x2400; screenshots downscaled to 900 high are ×2.667 for taps. Press Back only once after typing
  (the second press leaves the page).
- Never use `parentNavigatorKey: rootNavigatorKey` on routes inside the shell branch (go_router asserts and the app
  won't start) — hide the nav bar in `AppShell` instead.
- QA test events created during probing are named `api_probe_*` / `Retest_Practice` / `League_QA` (remove from web app).

---

## 9. Known open items

- Confirm with backend that `staff_ids` = staff `customer_id` is intended (works today).
- `recurring_types`, `weekdays`, `organizations` in dropdown options are parsed by nobody (unused).
- Verified on emulator: edit whole series (code, board, 13 slots), cancel + reinstate one date (`session/status`), delete series (`remove` with code).
- Not yet exercised: "This date only" save with its single `slots` row, draft banner/Confirm (needs a user whose saves are drafts).
- QA test data: `api_probe_*`, `Board_Weekly` series, `Retest_Practice`, `League_QA` on team Wyld Stallyns 12U Blue.
