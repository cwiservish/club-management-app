import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/player_form_config.dart';
import '../../../features/roster/models/player_positions_models.dart';
import '../../../features/roster/providers/roster_provider.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class PlayerFormState {
  final List<PlayerPositionModel> positions;
  final PlayerPositionModel? selectedPosition;
  final bool isLoadingPositions;
  final String? positionsError;
  final bool isDropdownOpen;
  final bool isSaving;
  final XFile? pickedImage;
  final Uint8List? pickedImageBytes;

  const PlayerFormState({
    this.positions = const [],
    this.selectedPosition,
    this.isLoadingPositions = false,
    this.positionsError,
    this.isDropdownOpen = false,
    this.isSaving = false,
    this.pickedImage,
    this.pickedImageBytes,
  });

  PlayerFormState copyWith({
    List<PlayerPositionModel>? positions,
    PlayerPositionModel? selectedPosition,
    bool clearSelectedPosition = false,
    bool? isLoadingPositions,
    String? positionsError,
    bool clearPositionsError = false,
    bool? isDropdownOpen,
    bool? isSaving,
    XFile? pickedImage,
    Uint8List? pickedImageBytes,
  }) {
    return PlayerFormState(
      positions: positions ?? this.positions,
      selectedPosition: clearSelectedPosition ? null : (selectedPosition ?? this.selectedPosition),
      isLoadingPositions: isLoadingPositions ?? this.isLoadingPositions,
      positionsError: clearPositionsError ? null : (positionsError ?? this.positionsError),
      isDropdownOpen: isDropdownOpen ?? this.isDropdownOpen,
      isSaving: isSaving ?? this.isSaving,
      pickedImage: pickedImage ?? this.pickedImage,
      pickedImageBytes: pickedImageBytes ?? this.pickedImageBytes,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PlayerFormNotifier extends Notifier<PlayerFormState> {
  PlayerFormConfig? _config;

  @override
  PlayerFormState build() => const PlayerFormState();

  void init(PlayerFormConfig config) {
    _config = config;
    PlayerPositionModel? initialPosition;
    if (config.initialPositionLabel.isNotEmpty) {
      initialPosition = PlayerPositionModel(value: 0, key: 0, label: config.initialPositionLabel);
    }
    state = state.copyWith(selectedPosition: initialPosition);
    _fetchPositions();
  }

  Future<void> _fetchPositions() async {
    final teamUuid = _config?.teamUuid ?? '';
    if (teamUuid.isEmpty) {
      state = state.copyWith(positionsError: 'No active team selected');
      return;
    }

    state = state.copyWith(isLoadingPositions: true, clearPositionsError: true);

    try {
      final response = await ref.read(rosterServiceProvider).fetchPlayerPositions(teamUuid);
      if (response.success) {
        PlayerPositionModel? matched = state.selectedPosition;
        if (matched != null) {
          for (final p in response.positions) {
            if (p.label.toLowerCase() == matched!.label.toLowerCase()) {
              matched = p;
              break;
            }
          }
          // If no match found in edit mode, default to first
          if (matched == state.selectedPosition && (_config?.isEditMode ?? false) && response.positions.isNotEmpty) {
            matched = response.positions.first;
          }
        }
        state = state.copyWith(
          positions: response.positions,
          isLoadingPositions: false,
          selectedPosition: matched,
        );
      } else {
        state = state.copyWith(
          isLoadingPositions: false,
          positionsError: response.message?.isNotEmpty == true
              ? response.message!
              : 'Failed to fetch positions',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingPositions: false, positionsError: e.toString());
    }
  }

  Future<void> retryFetchPositions() => _fetchPositions();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      state = state.copyWith(pickedImage: image, pickedImageBytes: bytes);
    }
  }

  void toggleDropdown() {
    state = state.copyWith(isDropdownOpen: !state.isDropdownOpen);
  }

  void closeDropdown() {
    if (state.isDropdownOpen) {
      state = state.copyWith(isDropdownOpen: false);
    }
  }

  void selectPosition(PlayerPositionModel position) {
    state = state.copyWith(selectedPosition: position, isDropdownOpen: false);
  }

  /// Returns a success message on success, null on failure (sets positionsError for errors).
  /// Throws a [PlayerFormSaveException] with a user-facing message on error.
  Future<String> save({
    required String firstName,
    required String lastName,
    required String jersey,
  }) async {
    final config = _config!;
    state = state.copyWith(isSaving: true);

    String? imageBase64;
    final imageBytes = state.pickedImageBytes;
    final imageFile = state.pickedImage;
    if (imageBytes != null && imageFile != null) {
      final mimeType = imageFile.path.endsWith('.jpg') || imageFile.path.endsWith('.jpeg')
          ? 'image/jpeg'
          : 'image/png';
      imageBase64 = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    }

    try {
      final response = await ref.read(rosterServiceProvider).savePlayer(
        teamUuid: config.teamUuid,
        firstName: firstName,
        lastName: lastName,
        jersey: jersey,
        primaryPosition: state.selectedPosition!.key,
        playerId: config.playerId,
        imageBase64: imageBase64,
      );

      if (response.success) {
        ref.read(rosterProvider.notifier).refresh();
        config.onSuccess?.call();
        return response.message?.isNotEmpty == true ? response.message! : 'Player saved successfully';
      } else {
        throw PlayerFormSaveException(
          response.message?.isNotEmpty == true ? response.message! : 'Failed to save player',
        );
      }
    } catch (e) {
      if (e is PlayerFormSaveException) rethrow;
      throw PlayerFormSaveException(e.toString());
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

class PlayerFormSaveException implements Exception {
  final String message;
  const PlayerFormSaveException(this.message);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final playerFormProvider =
    NotifierProvider.autoDispose<PlayerFormNotifier, PlayerFormState>(
  PlayerFormNotifier.new,
);
