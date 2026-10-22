// ─── New Event Save Request ───────────────────────────────────────────────────
// Used for all 4 create-event flows in new_event_page.dart.
// The same POST /teams/event/save endpoint is used for all flows;
// only the values differ per flow.

class NewEventSaveRequest {
  final String teamUuid;
  final dynamic id;                     // null or "" for new events; event id for edit
  final int createdFrom;                // 1
  final int? organizationId;
  final String? organizationName;
  final int? teamId;
  final String? teamName;
  final int schedulingMode;             // 1=Single Session, 2=Tournament, 3=League
  final dynamic existingSchedulingMode; // null or "" default
  final int eventType;                  // key from API (1=Game, 2=Practice, etc.)
  final dynamic eventFrom;              // 0 default; 2 when adding game from a parent league/tournament
  final dynamic eventId;                // 0 default; parent ClubEvent.id when adding from league/tournament
  final int scheduleGameId;             // always 0
  final dynamic opponentTeamId;         // null or int / string
  final String opponentTeamName;        // name entered when adding new opponent
  final bool? allowForFutureGames;      // null when not adding new opponent
  final String title;                   // "" for Game/Scrimmage; event name for others
  final String sessionStartDate;        // "yyyy-MM-dd"
  final String? sessionEndDate;         // "yyyy-MM-dd"
  final String sessionDate;             // "yyyy-MM-dd" (fallback/alias)
  final String startTime;               // "HH:mm" 24h
  final String? endTime;                // "HH:mm" 24h
  final int duration;                   // total minutes
  final int recurringType;              // 1=Single, 2=Weekly, 3=Monthly/Dates
  final dynamic days;                   // List<Map<String, dynamic>> or List<String>
  final int homeAway;                   // key from API (1=Home, 2=Away, 0=None)
  final int arrivalEarly;               // key from API (0 = no set)
  final int locationType;               // 1=Our Facilities, 2=Saved Location, 3=Off-Site Address, 4=TBD
  final int? venueId;
  final int? fieldId;
  final int? savedLocationId;
  final String location;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? placeId;
  final String latitude;
  final String longitude;
  final dynamic uniformTemplateId;      // null or int/string
  final Map<String, dynamic>? uniform;  // {"top":..., "bottom":..., "socks":...}
  final String uniformTopColor;         // hex "#RRGGBB" or "" if no color
  final String uniformBottomColor;
  final String uniformSocksColor;
  final bool chooseComboAsTemplate;
  final String uniformTemplateName;     // "" unless saving new combo
  final String startDate;               // "" for single session
  final String endDate;                 // "" for single session
  final String notes;                   // optional
  final dynamic status;                 // 1, 2, or ""
  final int withCalendarRows;           // 1
  final bool isRepeating;
  final String repeatType;              // "weekly" or "monthly"
  final String repeatUntil;             // "yyyy-MM-dd"
  final List<Map<String, dynamic>>? repeatWeeklySlots;
  final List<int>? repeatMonthlyDays;
  final List<dynamic>? athleteIds;
  final List<dynamic>? playerIds;
  final List<dynamic>? staffIds;

  NewEventSaveRequest({
    required this.teamUuid,
    this.id = '',
    this.createdFrom = 1,
    this.organizationId,
    this.organizationName,
    this.teamId,
    this.teamName,
    required this.schedulingMode,
    this.existingSchedulingMode = '',
    required this.eventType,
    this.eventFrom = 0,
    this.eventId = 0,
    this.scheduleGameId = 0,
    this.opponentTeamId,
    this.opponentTeamName = '',
    this.allowForFutureGames,
    this.title = '',
    String? sessionStartDate,
    this.sessionEndDate,
    String? sessionDate,
    required this.startTime,
    this.endTime,
    required this.duration,
    int? recurringType,
    this.days,
    required this.homeAway,
    required this.arrivalEarly,
    int? locationType,
    this.venueId,
    this.fieldId,
    this.savedLocationId,
    required this.location,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.placeId,
    this.latitude = '',
    this.longitude = '',
    this.uniformTemplateId,
    this.uniform,
    this.uniformTopColor = '',
    this.uniformBottomColor = '',
    this.uniformSocksColor = '',
    this.chooseComboAsTemplate = false,
    this.uniformTemplateName = '',
    this.startDate = '',
    this.endDate = '',
    this.notes = '',
    this.status = 1,
    this.withCalendarRows = 1,
    this.isRepeating = false,
    this.repeatType = '',
    this.repeatUntil = '',
    this.repeatWeeklySlots,
    this.repeatMonthlyDays,
    this.athleteIds,
    this.playerIds,
    this.staffIds,
  })  : sessionStartDate = sessionStartDate ?? (sessionDate ?? ''),
        sessionDate = sessionDate ?? (sessionStartDate ?? ''),
        recurringType = recurringType ??
            (isRepeating
                ? (repeatType.toLowerCase() == 'monthly' ? 3 : 2)
                : 1),
        locationType = locationType ?? 1;

  Map<String, dynamic> toJson() {
    final effectiveOpponentId = (opponentTeamId != null &&
            opponentTeamId.toString().isNotEmpty &&
            opponentTeamId.toString() != '__new__')
        ? (int.tryParse(opponentTeamId.toString()) ?? opponentTeamId)
        : null;

    final map = <String, dynamic>{
      'id': id == '' ? null : id,
      'created_from': createdFrom,
      'team_uuid': teamUuid,
      'scheduling_mode': schedulingMode,
      'existing_scheduling_mode': existingSchedulingMode == '' ? null : existingSchedulingMode,
      'event_type': eventType,
      'event_from': eventFrom,
      'event_id': eventId,
      'schedule_game_id': scheduleGameId,
      'title': title,
      'duration': duration,
      'home_away': homeAway,
      'arrival_early': arrivalEarly,
      'location_type': locationType,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'status': status,
      'with_calendar_rows': withCalendarRows,
    };

    if (organizationId != null && organizationId! > 0) {
      map['organization_id'] = organizationId;
    }
    if (organizationName != null && organizationName!.isNotEmpty) {
      map['organization_name'] = organizationName;
    }
    if (teamId != null && teamId! > 0) {
      map['team_id'] = teamId;
    }
    if (teamName != null && teamName!.isNotEmpty) {
      map['team_name'] = teamName;
    }

    // Dates & Times
    if (sessionStartDate.isNotEmpty) {
      map['session_start_date'] = sessionStartDate;
      map['session_date'] = sessionStartDate;
    }
    if (sessionEndDate != null && sessionEndDate!.isNotEmpty) {
      map['session_end_date'] = sessionEndDate;
    }
    if (startTime.isNotEmpty) {
      map['start_time'] = startTime;
    }
    if (endTime != null && endTime!.isNotEmpty) {
      map['end_time'] = endTime;
    }

    // Recurrence
    map['recurring_type'] = recurringType;
    if (days != null) {
      map['days'] = days;
    } else if (isRepeating) {
      if (recurringType == 2 && repeatWeeklySlots != null) {
        map['days'] = repeatWeeklySlots;
      } else if (recurringType == 3 && repeatMonthlyDays != null) {
        map['days'] = repeatMonthlyDays;
      }
    }

    // Opponent
    map['opponent_team_id'] = effectiveOpponentId;
    if (opponentTeamName.isNotEmpty) {
      map['opponent_team_name'] = opponentTeamName;
    }
    if (allowForFutureGames != null) {
      map['allow_for_future_games'] = allowForFutureGames;
    }

    // Location specific fields
    if (locationType == 1) {
      if (venueId != null && venueId! > 0) {
        map['venue_id'] = venueId;
      }
      if (fieldId != null && fieldId! > 0) {
        map['field_id'] = fieldId;
      }
    } else if (locationType == 2) {
      if (savedLocationId != null && savedLocationId! > 0) {
        map['saved_location_id'] = savedLocationId;
      }
      if (address != null && address!.isNotEmpty) map['address'] = address;
      if (city != null && city!.isNotEmpty) map['city'] = city;
      if (state != null && state!.isNotEmpty) map['state'] = state;
      if (country != null && country!.isNotEmpty) map['country'] = country;
      if (postalCode != null && postalCode!.isNotEmpty) map['postal_code'] = postalCode;
      if (placeId != null && placeId!.isNotEmpty) map['place_id'] = placeId;
    } else if (locationType == 3) {
      if (address != null && address!.isNotEmpty) {
        map['address'] = address;
      } else if (location.isNotEmpty) {
        map['address'] = location;
      }
      if (city != null && city!.isNotEmpty) map['city'] = city;
      if (state != null && state!.isNotEmpty) map['state'] = state;
      if (country != null && country!.isNotEmpty) map['country'] = country;
      if (postalCode != null && postalCode!.isNotEmpty) map['postal_code'] = postalCode;
      if (placeId != null && placeId!.isNotEmpty) map['place_id'] = placeId;
    }

    // Uniform
    if (uniformTemplateId != null && uniformTemplateId.toString().isNotEmpty) {
      map['uniform_template_id'] = uniformTemplateId;
    } else {
      map['uniform_template_id'] = null;
    }

    if (uniform != null) {
      map['uniform'] = uniform;
    } else if (uniformTopColor.isNotEmpty || uniformBottomColor.isNotEmpty || uniformSocksColor.isNotEmpty) {
      map['uniform'] = {
        'top': uniformTopColor.isNotEmpty ? uniformTopColor : null,
        'bottom': uniformBottomColor.isNotEmpty ? uniformBottomColor : null,
        'socks': uniformSocksColor.isNotEmpty ? uniformSocksColor : null,
        'cap': null,
        'jersey': uniformTopColor.isNotEmpty ? uniformTopColor : null,
        'shoes': null,
        'helmet': null,
        'gloves': null,
      };
    }

    // Keep flat color fields for backward compatibility with tournament/league placeholder endpoints
    if (uniformTopColor.isNotEmpty) map['uniform_top_color'] = uniformTopColor;
    if (uniformBottomColor.isNotEmpty) map['uniform_bottom_color'] = uniformBottomColor;
    if (uniformSocksColor.isNotEmpty) map['uniform_socks_color'] = uniformSocksColor;

    map['choose_combo_as_template'] = chooseComboAsTemplate;
    map['uniform_template_name'] = uniformTemplateName;

    // Multiday / Tournament / League
    if (startDate.isNotEmpty) map['start_date'] = startDate;
    if (endDate.isNotEmpty) map['end_date'] = endDate;

    // Players and Staff
    final effectivePlayerIds = (playerIds ?? athleteIds ?? [])
        .map((id) => int.tryParse(id.toString()) ?? id)
        .toList();
    final effectiveStaffIds = (staffIds ?? [])
        .map((id) => int.tryParse(id.toString()) ?? id)
        .toList();

    map['player_ids'] = effectivePlayerIds;
    map['staff_ids'] = effectiveStaffIds;

    return map;
  }
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
