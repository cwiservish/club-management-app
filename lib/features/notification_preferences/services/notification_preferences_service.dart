import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/notification_settings.dart';
import '../models/save_notification_models.dart';

class NotificationPreferencesService {
  final ApiClient _client;

  NotificationPreferencesService(this._client);

  Future<NotificationSettings?> fetchPreferences() async {
    try {
      // ── Print Request Details in proper JSON Format ──────────────────────────
      debugPrint('================ Playbook365 REQUEST LOG ================');
      final requestLog = {
        'method': 'POST',
        'url': '${ApiEndpoints.baseUrl}${ApiEndpoints.customerNotificationsList}',
        'headers': {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer [attached automatically via AuthInterceptor]'
        },
        'body': ''
      };
      const encoder = JsonEncoder.withIndent('  ');
      debugPrint(encoder.convert(requestLog));
      debugPrint('========================================================');

      final response = await _client.post(
        ApiEndpoints.customerNotificationsList,
        body: '',
      );

      // ── Print Response Details in proper JSON Format ─────────────────────────
      debugPrint('================ Playbook365 RESPONSE LOG ================');
      final responseLog = {
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data
      };
      debugPrint(encoder.convert(responseLog));
      debugPrint('=========================================================');

      if (response.success) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final grid = data['grid'];
          if (grid is Map<String, dynamic>) {
            return NotificationSettings.fromJson(grid);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching notification preferences: $e');
      rethrow;
    }
  }

  Future<SaveNotificationResponse> savePreferences(SaveNotificationRequest request) async {
    const endpoint = ApiEndpoints.customerNotificationsSave;
    final requestBody = request.toJson();

    // Print Request JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    try {
      final response = await _client.post(
        endpoint,
        body: requestBody,
      );

      // Construct response map for printing
      final rawResponseMap = {
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data,
      };

      // Print Response JSON in logs
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
      debugPrint('════════════════════════════════════════════════════════════════');

      final responseMap = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      return SaveNotificationResponse.fromJson({
        'success': response.success,
        'message': response.message ?? responseMap['message'] ?? '',
        ...responseMap,
      });
    } catch (e) {
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('════════════════════════════════════════════════════════════════');

      return SaveNotificationResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}
