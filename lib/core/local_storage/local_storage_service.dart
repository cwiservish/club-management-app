import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── LocalStorageService ──────────────────────────────────────────────────────

/// Raw secure storage wrapper.
///
/// Knows nothing about the app — only generic read/write/delete operations.
/// Feature code must never use this directly — go through [AppStorage].
class LocalStorageService {
  const LocalStorageService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[LocalStorageService] Error writing $key: $e');
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('[LocalStorageService] Error reading $key: $e');
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('[LocalStorageService] Error deleting $key: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[LocalStorageService] Error clearing all: $e');
    }
  }
}

