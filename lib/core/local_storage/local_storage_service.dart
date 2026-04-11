import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── LocalStorageService ──────────────────────────────────────────────────────

/// Raw secure storage wrapper.
///
/// Knows nothing about the app — only generic read/write/delete operations.
/// Feature code must never use this directly — go through [AppStorage].
class LocalStorageService {
  const LocalStorageService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> clearAll() => _storage.deleteAll();
}

