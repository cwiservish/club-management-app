import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_storage/app_storage.dart';
import '../models/team_model.dart';

final userTeamsProvider = FutureProvider<List<Team>>((ref) async {
  final appStorage = ref.read(appStorageProvider);
  return await appStorage.readTeams();
});
