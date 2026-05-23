import 'dart:convert';
import 'package:flutter/services.dart';

// ─── EnvironmentConfig ────────────────────────────────────────────────────────

/// Runtime environment configuration loaded from the single JSON asset.
///
/// Initialise once in [main] before [runApp]:
/// ```dart
/// await EnvironmentConfig.load();
/// ```
abstract final class EnvironmentConfig {
  EnvironmentConfig._();

  // ─── Public values ────────────────────────────────────────────────────────

  static String get baseUrl => _values['API_BASE_URL'] as String;
  static int get timeoutSeconds => int.parse(_values['API_TIMEOUT_SECONDS'] as String);
  static bool get enableLogging => (_values['ENABLE_LOGGING'] as String) == 'true';
  static String get fusionAuthBaseUrl => _values['FUSIONAUTH_BASE_URL'] as String? ?? '';
  static String get fusionAuthAppId => _values['FUSIONAUTH_APP_ID'] as String? ?? '';
  static String get fusionAuthTenantId => _values['FUSIONAUTH_TENANT_ID'] as String? ?? '';
  static String get fusionAuthApiKey => _values['FUSIONAUTH_API_KEY'] as String? ?? '';

  static Map<String, dynamic> _values = {};

  // ─── Loader ───────────────────────────────────────────────────────────────

  /// Must be called once in [main] before [runApp].
  static Future<void> load() async {
    const path = 'config/env.json';
    final raw = await rootBundle.loadString(path);
    _values = json.decode(raw) as Map<String, dynamic>;
  }
}
