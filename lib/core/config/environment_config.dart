import 'dart:convert';
import 'package:flutter/services.dart';

// ─── Environment enum ─────────────────────────────────────────────────────────

enum AppEnvironment { dev, staging, prod }

// ─── EnvironmentConfig ────────────────────────────────────────────────────────

/// Runtime environment configuration loaded from the matching JSON asset.
///
/// Initialise once in [main] before [runApp]:
/// ```dart
/// await EnvironmentConfig.load();
/// ```
///
/// Select environment at the command line:
/// ```bash
/// flutter run   --dart-define=ENV=dev
/// flutter run   --dart-define=ENV=staging
/// flutter build --dart-define=ENV=prod
/// ```
///
/// If no ENV is passed the value of [_selectedEnv] is used as the fallback.
abstract final class EnvironmentConfig {
  EnvironmentConfig._();

  // ─── Default environment ──────────────────────────────────────────────────
  // Change this to AppEnvironment.staging or AppEnvironment.prod to switch
  // the fallback used when no --dart-define=ENV=... flag is provided.

  static const _selectedEnv = AppEnvironment.dev;


  // ─── Public values ────────────────────────────────────────────────────────

  static String get baseUrl => _values['API_BASE_URL'] as String;
  static int get timeoutSeconds => int.parse(_values['API_TIMEOUT_SECONDS'] as String);
  static bool get enableLogging => (_values['ENABLE_LOGGING'] as String) == 'true';

  static Map<String, dynamic> _values = {};

  // ─── Loader ───────────────────────────────────────────────────────────────

  /// Must be called once in [main] before [runApp].
  static Future<void> load() async {
    // --dart-define=ENV=dev overrides _selectedEnv; falls back if not set.
    const envName = String.fromEnvironment('ENV');
    final env = _resolve(envName);

    final path = _assetPath(env);
    final raw = await rootBundle.loadString(path);
    _values = json.decode(raw) as Map<String, dynamic>;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static AppEnvironment _resolve(String name) {
    switch (name) {
      case _ when name == AppEnvironment.staging.name:
        return AppEnvironment.staging;
      case _ when name == AppEnvironment.prod.name:
        return AppEnvironment.prod;
      case _ when name == AppEnvironment.dev.name:
        return AppEnvironment.dev;
      default:
        return _selectedEnv;
    }
  }

  static String _assetPath(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
        return 'config/env.dev.json';
      case AppEnvironment.staging:
        return 'config/env.staging.json';
      case AppEnvironment.prod:
        return 'config/env.prod.json';
    }
  }
}
