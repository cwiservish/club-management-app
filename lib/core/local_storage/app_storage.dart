import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../models/team_model.dart';
import 'local_storage_service.dart'; // LocalStorageService used inside AppStorage

// ─── Storage Keys ─────────────────────────────────────────────────────────────

abstract final class _Keys {
  static const authToken = 'auth_token';
  static const currentUser = 'current_user';
  static const userTeams = 'user_teams';
}

// ─── AppStorage ───────────────────────────────────────────────────────────────

/// Named middleware between feature services and [LocalStorageService].
///
/// Feature services talk to this — never to [LocalStorageService] directly.
/// All keys are private to this file so no feature can accidentally
/// read/write raw storage keys.
class AppStorage {
  final _storage = const LocalStorageService();

  // ─── Token ──────────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) =>
      _storage.write(_Keys.authToken, token);

  Future<String?> readToken() => _storage.read(_Keys.authToken);

  Future<void> deleteToken() => _storage.delete(_Keys.authToken);

  // ─── User ────────────────────────────────────────────────────────────────────

  Future<void> saveUser(AppUser user) =>
      _storage.write(_Keys.currentUser, jsonEncode(user.toJson()));

  Future<AppUser?> readUser() async {
    final raw = await _storage.read(_Keys.currentUser);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> deleteUser() => _storage.delete(_Keys.currentUser);

  // ─── Teams ───────────────────────────────────────────────────────────────────

  Future<void> saveTeams(List<Team> teams) =>
      _storage.write(_Keys.userTeams, jsonEncode(teams.map((t) => t.toJson()).toList()));

  Future<List<Team>> readTeams() async {
    final raw = await _storage.read(_Keys.userTeams);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deleteTeams() => _storage.delete(_Keys.userTeams);

  // ─── Clear all (logout) ──────────────────────────────────────────────────────

  Future<void> clearAll() => _storage.clearAll();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final appStorageProvider = Provider<AppStorage>((ref) {
  return AppStorage();
});
