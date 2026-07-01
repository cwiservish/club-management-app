import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/config/environment_config.dart';
import '../models/event_dropdown_options_models.dart';
import '../models/event_detail_model.dart';
import '../models/event_player_model.dart';
import '../models/event_save_models.dart';
import '../models/event_delete_models.dart';
import '../models/event_availability_models.dart';
import '../models/new_event_dropdown_options_model.dart';
import '../models/new_event_save_request_model.dart';

class EventDetailService {
  final ApiClient _apiClient;
  final Dio _dio;

  EventDetailService(this._apiClient, this._dio);

  EventDetailModel getEventDetail(String eventId) {
    return const EventDetailModel(
      id:              '1',
      name:            'Practice',
      date:            'Monday, March 23, 2026',
      timeRange:       '6:00 PM \u2013 7:30 PM',
      locationName:    'Gillis-Rother Soccer Complex - Field 12',
      locationAddress: '1001 E Robinson St, Norman, OK 73071',
      uniform:         'White / Green',
      homeAway:        'Home',
      opponent:        'OKC Energy FC',
      arrivalTime:     '12:15 PM',
      myRsvp:          'no',
    );
  }

  List<EventPlayerModel> getEventPlayers(String eventId) {
    return const [
      EventPlayerModel(id: 1, name: 'Kinsley Weston',   number: '1',  status: PlayerStatus.going, note: ''),
      EventPlayerModel(id: 2, name: 'Kinley Kirkes',    number: '5',  status: PlayerStatus.going, note: ''),
      EventPlayerModel(id: 3, name: 'Mila Chaisson',    number: '10', status: PlayerStatus.going, note: ''),
      EventPlayerModel(id: 4, name: 'Scarlett Garling', number: '12', status: PlayerStatus.going, note: 'Running 5 mins late'),
      EventPlayerModel(id: 5, name: 'Nene Randolph',    number: '61', status: PlayerStatus.going, note: ''),
      EventPlayerModel(id: 6, name: 'Rose Hall',        number: '11', status: PlayerStatus.none,  note: ''),
      EventPlayerModel(id: 7, name: 'Emma Smith',       number: '4',  status: PlayerStatus.none,  note: ''),
    ];
  }

  /// Fetches timezone and dropdown options for the given team.
  Future<EventDropdownOptionsResponse> fetchEventDropdownOptions(EventDropdownOptionsRequest request) async {
    final queryParams = request.toJson();

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.eventDropdownOptions}');
    debugPrint('[API Request Query Parameters]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(queryParams));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.get(
      ApiEndpoints.eventDropdownOptions,
      queryParameters: queryParams,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] GET ${ApiEndpoints.eventDropdownOptions}');
    debugPrint('[success]: ${response.success}');
    debugPrint('[message]: ${response.message}');
    debugPrint('[data type]: ${response.data.runtimeType}');

    // Print full raw data to reveal actual structure
    try {
      debugPrint('[data full]:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
    } catch (_) {
      debugPrint('[data raw]: ${response.data}');
    }

    // Print top-level keys if data is a map
    if (response.data is Map) {
      final dataMap = response.data as Map;
      debugPrint('[data keys]: ${dataMap.keys.toList()}');
      for (final key in dataMap.keys) {
        final val = dataMap[key];
        debugPrint('  [$key] => type: ${val.runtimeType}, value: ${val is List ? "List(${val.length})" : val}');
      }
    }
    debugPrint('════════════════════════════════════════════════════════════════');

    return EventDropdownOptionsResponse.fromJson({
      'success': response.success,
      'message': response.message,
      // The API returns {"timezones":[...]} with no nested "data" key,
      // so we pass rawJson directly as the data payload.
      'data': response.data ?? response.rawJson,
    });
  }

  /// Saves / adds / edits an event.
  Future<EventSaveResponse> saveEvent(EventSaveRequest request) async {
    final body = request.toJson();
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.eventSave}');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(body));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      ApiEndpoints.eventSave,
      body: body,
    );

    final rawResponseMap = {
      'success': response.success,
      'message': response.message ?? '',
      'data': response.data,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST ${ApiEndpoints.eventSave}');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
    debugPrint('════════════════════════════════════════════════════════════════');

    return EventSaveResponse.fromJson(rawResponseMap);
  }

  /// Creates a new event (all 4 flows from new_event_page).
  Future<NewEventSaveResponse> saveNewEvent(NewEventSaveRequest request) async {
    final body = request.toJson();
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.eventSave}');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(body));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(ApiEndpoints.eventSave, body: body);

    final rawResponseMap = {
      'success': response.success,
      'message': response.message ?? '',
      'data': response.data,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST ${ApiEndpoints.eventSave}');
    debugPrint('[success]: ${response.success}');
    debugPrint('[message]: ${response.message}');
    debugPrint('════════════════════════════════════════════════════════════════');

    return NewEventSaveResponse.fromJson(rawResponseMap);
  }

  /// Deletes / removes an event.
  Future<EventDeleteResponse> deleteEvent(EventDeleteRequest request) async {
    final body = request.toJson();
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.eventRemove}');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(body));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      ApiEndpoints.eventRemove,
      body: body,
    );

    final rawResponseMap = {
      'success': response.success,
      'message': response.message ?? '',
      'data': response.data,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST ${ApiEndpoints.eventRemove}');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
    debugPrint('════════════════════════════════════════════════════════════════');

    return EventDeleteResponse.fromJson(rawResponseMap);
  }

  /// Fetches event availability from API.
  Future<EventAvailabilityResponse> fetchEventAvailability(EventAvailabilityRequest request) async {
    final body = request.toJson();

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.eventAvailability}');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(body));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      ApiEndpoints.eventAvailability,
      body: body,
    );

    final rawResponseMap = {
      'success': response.success,
      'message': response.message ?? '',
      'data': response.data,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST ${ApiEndpoints.eventAvailability}');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
    debugPrint('════════════════════════════════════════════════════════════════');

    return EventAvailabilityResponse.fromJson(rawResponseMap);
  }

  /// Saves event attendee notes to API.
  Future<EventAttendeeSaveResponse> saveEventAttendee(EventAttendeeSaveRequest request) async {
    final body = request.toJson();

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.eventAttendeeSave}');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(body));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      ApiEndpoints.eventAttendeeSave,
      body: body,
    );

    final rawResponseMap = {
      'success': response.success,
      'message': response.message ?? '',
      'data': response.data,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST ${ApiEndpoints.eventAttendeeSave}');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
    debugPrint('════════════════════════════════════════════════════════════════');

    return EventAttendeeSaveResponse.fromJson(rawResponseMap);
  }

  /// Fetches dropdown options for the new event / session form.
  Future<NewEventDropdownOptions> fetchNewEventDropdownOptions(String? teamUuid) async {
    final queryParams = <String, dynamic>{};
    if (teamUuid != null && teamUuid.isNotEmpty) {
      queryParams['team_uuid'] = teamUuid;
    }

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.newEventDropdownOptions}');
    debugPrint('[API Request Query Parameters]: $queryParams');
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.get(
      ApiEndpoints.newEventDropdownOptions,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] GET ${ApiEndpoints.newEventDropdownOptions}');
    debugPrint('[success]: ${response.success}');
    debugPrint('[message]: ${response.message}');
    debugPrint('════════════════════════════════════════════════════════════════');

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return NewEventDropdownOptions.fromJson(data);
    }
    // Fallback: try rawJson directly (some endpoints return data at root level)
    return NewEventDropdownOptions.fromJson(response.rawJson);
  }

  /// Searches Google Places Autocomplete API with a robust Radar Autocomplete fallback.
  Future<List<Map<String, dynamic>>> fetchPlacesAutocomplete(String input) async {
    final googleApiKey = EnvironmentConfig.googleMapsApiKey;
    if (googleApiKey.isNotEmpty) {
      try {
        const url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
        final response = await _dio.get(url, queryParameters: {
          'input': input,
          'key': googleApiKey,
          'types': 'establishment|geocode',
        });

        if (response.statusCode == 200 && response.data != null) {
          final predictions = response.data['predictions'];
          if (predictions is List && predictions.isNotEmpty) {
            return predictions.map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
      } catch (e) {
        debugPrint('[Google Places] Autocomplete error: $e. Falling back to Radar.');
      }
    }

    // Fallback to Radar Autocomplete API
    final radarApiKey = EnvironmentConfig.radarApiKey;
    if (radarApiKey.isNotEmpty) {
      try {
        final url = 'https://api.radar.io/v1/search/autocomplete';
        final response = await _dio.get(
          url,
          queryParameters: {
            'query': input,
          },
          options: Options(
            headers: {
              'Authorization': radarApiKey,
            },
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final addresses = response.data['addresses'] as List?;
          if (addresses != null) {
            return addresses.map((addr) {
              final map = Map<String, dynamic>.from(addr as Map);
              final placeLabel = map['placeLabel']?.toString() ?? '';
              final addressLabel = map['addressLabel']?.toString() ?? '';
              return {
                'name': placeLabel.isNotEmpty ? placeLabel : addressLabel,
                'description': addressLabel,
                'latitude': map['latitude']?.toString() ?? '',
                'longitude': map['longitude']?.toString() ?? '',
              };
            }).toList();
          }
        }
      } catch (e) {
        debugPrint('[Radar] Autocomplete error: $e');
      }
    }

    return [];
  }

  /// Fetches place geometry details from Place ID.
  Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId) async {
    final apiKey = EnvironmentConfig.googleMapsApiKey;
    if (apiKey.isNotEmpty) {
      try {
        const url = 'https://maps.googleapis.com/maps/api/place/details/json';
        final response = await _dio.get(url, queryParameters: {
          'place_id': placeId,
          'key': apiKey,
          'fields': 'geometry',
        });

        if (response.statusCode == 200 && response.data != null) {
          final result = response.data['result'];
          if (result is Map<String, dynamic>) {
            return result;
          }
        }
      } catch (e) {
        debugPrint('[Google Places] Place details error: $e');
      }
    }
    return null;
  }
}

final eventDetailServiceProvider = Provider<EventDetailService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventDetailService(apiClient, Dio());
});
