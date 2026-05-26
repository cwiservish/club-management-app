import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/network/api_client.dart';
import '../models/photo_item.dart';
import '../services/photos_service.dart';

class PhotosState {
  final List<PhotoItem> photos;
  final bool isLoading;
  final String? errorMessage;
  final bool isUploading;

  const PhotosState({
    required this.photos,
    this.isLoading = false,
    this.errorMessage,
    this.isUploading = false,
  });

  PhotosState copyWith({
    List<PhotoItem>? photos,
    bool? isLoading,
    String? errorMessage,
    bool? isUploading,
  }) {
    return PhotosState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class PhotosNotifier extends Notifier<PhotosState> {
  @override
  PhotosState build() {
    final activeTeam = ref.watch(selectedTeamProvider);

    // Fetch reactively
    if (activeTeam != null) {
      Future.microtask(() => fetchPhotos(activeTeam.uuid));
    }

    return PhotosState(
      photos: const [],
      isLoading: activeTeam != null,
      errorMessage: null,
      isUploading: false,
    );
  }

  /// Fetches photos for the given team UUID.
  Future<void> fetchPhotos(String uuid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await ref.read(photosServiceProvider).fetchPhotos(uuid);
      if (response.success) {
        state = state.copyWith(photos: response.data.grid, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message.isNotEmpty ? response.message : 'Failed to fetch photos',
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
      await fetchPhotos(activeTeam.uuid);
    }
  }

  /// Uploads / saves a new photo from a local image file path.
  Future<bool> uploadPhoto(String imagePath) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      state = state.copyWith(errorMessage: 'No active team selected');
      return false;
    }

    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final response = await ref.read(photosServiceProvider).savePhoto(
        uuid: activeTeam.uuid,
        teamId: activeTeam.teamId.toString(),
        imagePath: imagePath,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          photos: [...state.photos, response.data!],
          isUploading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: response.message.isNotEmpty ? response.message : 'Failed to upload photo',
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

  /// Removes / deletes a photo by ID.
  Future<bool> deletePhoto(int id) async {
    state = state.copyWith(errorMessage: null);
    try {
      final response = await ref.read(photosServiceProvider).removePhoto(id);
      if (response.success) {
        state = state.copyWith(
          photos: state.photos.where((p) => p.id != id).toList(),
        );
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.message.isNotEmpty ? response.message : 'Failed to delete photo',
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

final photosServiceProvider = Provider<PhotosService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PhotosService(apiClient);
});

final photosProvider = NotifierProvider<PhotosNotifier, PhotosState>(
  PhotosNotifier.new,
);
