import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../services/files_service.dart';

final _filesServiceProvider = Provider<FilesService>((_) => FilesService());

final filesProvider = Provider.autoDispose<List<FileItem>>((ref) {
  return ref.watch(_filesServiceProvider).getFiles();
});
