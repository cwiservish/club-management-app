import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/network/api_client.dart';
import '../models/file_item.dart';
import '../services/files_service.dart';

class FilesState {
  final List<FileItem> files;
  final bool isLoading;
  final String? errorMessage;
  final bool isUploading;

  const FilesState({
    required this.files,
    this.isLoading = false,
    this.errorMessage,
    this.isUploading = false,
  });

  FilesState copyWith({
    List<FileItem>? files,
    bool? isLoading,
    String? errorMessage,
    bool? isUploading,
  }) {
    return FilesState(
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class FilesNotifier extends Notifier<FilesState> {
  @override
  FilesState build() {
    final activeTeam = ref.watch(selectedTeamProvider);

    // Fetch reactively when team changes
    if (activeTeam != null) {
      Future.microtask(() => fetchFiles(activeTeam.uuid));
    }

    return FilesState(
      files: const [],
      isLoading: activeTeam != null,
      errorMessage: null,
      isUploading: false,
    );
  }

  /// Fetches files for the given team UUID.
  Future<void> fetchFiles(String uuid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await ref.read(filesServiceProvider).fetchFiles(uuid);
      if (response.success) {
        state = state.copyWith(files: response.data.grid, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message.isNotEmpty ? response.message : 'Failed to fetch files',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Pull-to-refresh implementation.
  Future<void> refresh() async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam != null) {
      await fetchFiles(activeTeam.uuid);
    }
  }

  /// Uploads / saves a new file from a local file path.
  Future<bool> uploadFile(String filePath) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      state = state.copyWith(errorMessage: 'No active team selected');
      return false;
    }

    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final response = await ref.read(filesServiceProvider).saveFile(
        uuid: activeTeam.uuid,
        teamId: activeTeam.teamId.toString(),
        filePath: filePath,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          files: [...state.files, response.data!],
          isUploading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: response.message.isNotEmpty ? response.message : 'Failed to upload file',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Removes / deletes a document by ID.
  Future<bool> deleteFile(int id) async {
    state = state.copyWith(errorMessage: null);
    try {
      final response = await ref.read(filesServiceProvider).removeFile(id);
      if (response.success) {
        state = state.copyWith(
          files: state.files.where((f) => f.id != id.toString()).toList(),
        );
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.message.isNotEmpty ? response.message : 'Failed to delete file',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

// ─── Riverpod Providers ──────────────────────────────────────────────────────

final filesServiceProvider = Provider<FilesService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return FilesService(apiClient);
});

final filesProvider = NotifierProvider<FilesNotifier, FilesState>(
  FilesNotifier.new,
);
