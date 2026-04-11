import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/club_file.dart';
import '../services/files_service.dart';

final filesServiceProvider = Provider<FilesService>((ref) => FilesService());

final filesProvider = FutureProvider<List<ClubFile>>((ref) async {
  return ref.read(filesServiceProvider).getFiles();
});
