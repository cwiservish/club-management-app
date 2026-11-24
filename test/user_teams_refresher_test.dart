import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playbook365/core/common_providers/selected_team_provider.dart';
import 'package:playbook365/core/common_providers/user_teams_provider.dart';
import 'package:playbook365/core/local_storage/app_storage.dart';
import 'package:playbook365/core/models/team_model.dart';
import 'package:playbook365/core/network/api_client.dart';
import 'package:playbook365/core/network/models/api_response.dart';

class _FakeStorage extends AppStorage {
  List<Team> teams;
  String? selected;
  int saves = 0;
  _FakeStorage(this.teams, this.selected);

  @override
  Future<String?> readToken() async => 'token';
  @override
  Future<List<Team>> readTeams() async => teams;
  @override
  Future<void> saveTeams(List<Team> t) async {
    saves++;
    teams = t;
  }

  @override
  Future<String?> readSelectedTeamUuid() async => selected;
  @override
  Future<void> saveSelectedTeamUuid(String uuid) async => selected = uuid;
  @override
  Future<void> deleteSelectedTeamUuid() async => selected = null;
}

class _FakeApi extends ApiClient {
  ApiResponse response;
  int calls = 0;
  _FakeApi(this.response) : super(Dio());

  @override
  Future<ApiResponse> post(String path, {Object? body, CancelToken? cancelToken, Options? options}) async {
    calls++;
    return response;
  }
}

Map<String, dynamic> _team(String uuid) => {'uuid': uuid, 'name': 'Team $uuid', 'team_id': uuid.hashCode};
ApiResponse _grid(List<String> uuids) =>
    ApiResponse(success: true, data: {'grid': uuids.map(_team).toList()});
List<Team> _teams(List<String> uuids) => uuids.map((u) => Team.fromJson(_team(u))).toList();

void main() {
  ProviderContainer setup(_FakeStorage storage, _FakeApi api) {
    final c = ProviderContainer(overrides: [
      appStorageProvider.overrideWithValue(storage),
      apiClientProvider.overrideWithValue(api),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  test('a team the user was removed from leaves the list, and the selection moves to the first team', () async {
    SelectedTeamNotifier.setInitialUuid('b');
    final storage = _FakeStorage(_teams(['a', 'b']), 'b');
    final c = setup(storage, _FakeApi(_grid(['a'])));
    expect((await c.read(userTeamsProvider.future)).map((t) => t.uuid), ['a', 'b']);
    expect(c.read(selectedTeamProvider)?.uuid, 'b');

    await c.read(userTeamsRefresherProvider).refresh(force: true);

    expect((await c.read(userTeamsProvider.future)).map((t) => t.uuid), ['a']);
    expect(c.read(selectedTeamProvider)?.uuid, 'a');
    await Future<void>.delayed(Duration.zero);
    expect(storage.selected, 'a'); // remembered for the next launch
  });

  test('a failed or malformed answer keeps the cached teams', () async {
    final storage = _FakeStorage(_teams(['a', 'b']), 'a');
    final api = _FakeApi(const ApiResponse(success: false, data: null));
    final c = setup(storage, api);

    await c.read(userTeamsRefresherProvider).refresh(force: true);
    api.response = const ApiResponse(success: true, data: {'unexpected': 1});
    await c.read(userTeamsRefresherProvider).refresh(force: true);

    expect(storage.teams.map((t) => t.uuid), ['a', 'b']);
    expect(storage.saves, 0);
  });

  test('a valid empty list (removed from every team) clears the teams and the selection', () async {
    final storage = _FakeStorage(_teams(['a']), 'a');
    final c = setup(storage, _FakeApi(_grid([])));

    await c.read(userTeamsRefresherProvider).refresh(force: true);

    expect(storage.teams, isEmpty);
    expect(storage.selected, isNull);
  });

  test('an unchanged list is not rewritten, and closely spaced asks call the API once', () async {
    final storage = _FakeStorage(_teams(['a', 'b']), 'a');
    final api = _FakeApi(_grid(['a', 'b']));
    final c = setup(storage, api);
    final refresher = c.read(userTeamsRefresherProvider);

    await refresher.refresh();
    await refresher.refresh(); // within 60 s: skipped
    expect(api.calls, 1);
    expect(storage.saves, 0);

    await refresher.refresh(force: true);
    expect(api.calls, 2);
  });
}
