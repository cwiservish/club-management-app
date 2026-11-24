import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_storage/app_storage.dart';
import '../models/team_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/token_storage.dart';

final userTeamsProvider = FutureProvider<List<Team>>((ref) async {
  final appStorage = ref.read(appStorageProvider);
  return await appStorage.readTeams();
});

/// Keeps the cached team list (team dropdown) in step with the server, so a team the user was
/// removed from stops showing up. The list is only replaced by a valid answer: a failed call,
/// no network or a malformed response keeps the cached teams.
class UserTeamsRefresher {
  final Ref _ref;
  UserTeamsRefresher(this._ref);

  /// Opening the app and coming back to it both ask; closely spaced asks are answered once.
  static const _minGap = Duration(seconds: 60);
  DateTime? _lastOk;
  Future<void>? _running;

  /// Fetches `team/list` and, when it differs from the cache, saves it and updates the dropdown.
  /// [force] skips the 60 s spacing (pull-to-refresh, login).
  Future<void> refresh({bool force = false}) {
    final running = _running;
    if (running != null) return running;
    final last = _lastOk;
    if (!force && last != null && DateTime.now().difference(last) < _minGap) return Future.value();
    return _running = _fetch().whenComplete(() => _running = null);
  }

  Future<void> _fetch() async {
    try {
      final storage = _ref.read(appStorageProvider);
      var token = _ref.read(authTokenProvider);
      if (token == null) {
        token = await storage.readToken();
        if (token == null) return; // signed out
        _ref.read(authTokenProvider.notifier).setToken(token);
      }

      final res = await _ref.read(apiClientProvider).post(
        ApiEndpoints.clubTeamsList,
        body: '',
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      final data = res.data;
      final grid = data is Map ? data['grid'] : null;
      if (!res.success || grid is! List) return; // not a real answer: keep what we have

      final teams = grid.whereType<Map>().map((e) => Team.fromJson(Map<String, dynamic>.from(e))).toList();
      _lastOk = DateTime.now();

      final cached = await storage.readTeams();
      if (_sameTeams(cached, teams)) return;

      await storage.saveTeams(teams);
      // Removed from every team: forget the selection too.
      if (teams.isEmpty) await storage.deleteSelectedTeamUuid();
      _ref.invalidate(userTeamsProvider);
    } catch (e) {
      debugPrint('[UserTeamsRefresher] Could not refresh teams: $e');
    }
  }

  bool _sameTeams(List<Team> a, List<Team> b) =>
      jsonEncode(a.map((t) => t.toJson()).toList()) == jsonEncode(b.map((t) => t.toJson()).toList());
}

final userTeamsRefresherProvider = Provider<UserTeamsRefresher>((ref) => UserTeamsRefresher(ref));
