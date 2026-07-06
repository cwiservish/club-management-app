// ─── New Event Save Request ───────────────────────────────────────────────────
// Used for all 4 create-event flows in new_event_page.dart.
// The same POST /teams/event/save endpoint is used for all flows;
// only the values differ per flow.

class NewEventSaveRequest {
  final String teamUuid;
  final dynamic id;                   // "" for new events
  final int schedulingMode;           // 1=Single Session, 2=Tournament, 3=League
  final dynamic existingSchedulingMode; // "" default
  final int eventType;                // key from API (1=Game, 2=Practice, etc.)
  final dynamic eventFrom;            // 0 default; true when adding game from a parent league/tournament
  final dynamic eventId;              // 0 default; parent ClubEvent.id when adding from league/tournament
  final int scheduleGameId;           // always 0
  final String opponentTeamId;        // "" until teams API populates
  final String opponentTeamName;      // name entered when adding new opponent
  final bool? allowForFutureGames;    // null when not adding new opponent
  final String title;                 // "" for Game/Scrimmage; event name for others
  final String sessionDate;           // "yyyy-MM-dd" for single session
  final String startTime;             // "HH:mm" 24h
  final int duration;                 // total minutes
  final int homeAway;                 // key from API
  final int arrivalEarly;             // key from API (0 = no set)
  final String location;
  final String latitude;
  final String longitude;
  final String uniformTemplateId;     // "" when no template selected
  final String uniformTopColor;       // hex "#RRGGBB" or "" if no color
  final String uniformBottomColor;
  final String uniformSocksColor;
  final bool chooseComboAsTemplate;
  final String uniformTemplateName;   // "" unless saving new combo
  final String startDate;             // "" for single session
  final String endDate;               // "" for single session
  final String notes;                 // optional
  final dynamic status;               // "" default

  const NewEventSaveRequest({
    required this.teamUuid,
    this.id = '',
    required this.schedulingMode,
    this.existingSchedulingMode = '',
    required this.eventType,
    this.eventFrom = 0,
    this.eventId = 0,
    this.scheduleGameId = 0,
    this.opponentTeamId = '',
    this.opponentTeamName = '',
    this.allowForFutureGames,
    this.title = '',
    required this.sessionDate,
    required this.startTime,
    required this.duration,
    required this.homeAway,
    required this.arrivalEarly,
    required this.location,
    this.latitude = '',
    this.longitude = '',
    this.uniformTemplateId = '',
    this.uniformTopColor = '',
    this.uniformBottomColor = '',
    this.uniformSocksColor = '',
    this.chooseComboAsTemplate = false,
    this.uniformTemplateName = '',
    this.startDate = '',
    this.endDate = '',
    this.notes = '',
    this.status = '',
  });

  Map<String, dynamic> toJson() => {
    'team_uuid': teamUuid,
    'id': id,
    'scheduling_mode': schedulingMode,
    'existing_scheduling_mode': existingSchedulingMode,
    'event_type': eventType,
    'event_from': eventFrom,
    'event_id': eventId,
    'schedule_game_id': scheduleGameId,
    'opponent_team_id': opponentTeamId,
    'opponent_team_name': opponentTeamName,
    'allow_for_future_games': allowForFutureGames,
    'title': title,
    'session_date': sessionDate,
    'start_time': startTime,
    'duration': duration,
    'home_away': homeAway,
    'arrival_early': arrivalEarly,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'uniform_template_id': uniformTemplateId,
    'uniform_top_color': uniformTopColor,
    'uniform_bottom_color': uniformBottomColor,
    'uniform_socks_color': uniformSocksColor,
    'choose_combo_as_template': chooseComboAsTemplate,
    'uniform_template_name': uniformTemplateName,
    'start_date': startDate,
    'end_date': endDate,
    'notes': notes,
    'status': status,
  };
}

// ─── Response ─────────────────────────────────────────────────────────────────
// Reuses the same success/message shape as other save endpoints.

class NewEventSaveResponse {
  final bool success;
  final String message;

  const NewEventSaveResponse({required this.success, required this.message});

  factory NewEventSaveResponse.fromJson(Map<String, dynamic> json) {
    return NewEventSaveResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}
