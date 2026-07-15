import 'package:flutter/foundation.dart';

/// Configuration model for the shared PlayerFormSheet.
/// Pass [playerId] to enter edit mode; omit it (null) for add mode.
class PlayerFormConfig {
  /// null = add mode, non-null = edit mode
  final int? playerId;
  final String teamUuid;
  final String initialFirstName;
  final String initialLastName;
  final String initialJersey;

  /// Human-readable position label (e.g. "Goalkeeper") used to pre-select
  /// the position after the dropdown list is fetched from the API.
  final String initialPositionLabel;

  /// Existing photo URL shown in edit mode when no new image has been picked.
  final String? existingPhotoUrl;

  final bool isEditable;

  /// Fallback initials shown in the avatar when there is no photo.
  final String initials;

  /// Called after a successful save (in addition to the roster refresh that
  /// PlayerFormSheet always performs). Use this to invalidate feature-specific
  /// providers (e.g. the player profile provider on the detail page).
  final VoidCallback? onSuccess;

  const PlayerFormConfig({
    this.playerId,
    required this.teamUuid,
    this.initialFirstName = '',
    this.initialLastName = '',
    this.initialJersey = '',
    this.initialPositionLabel = '',
    this.existingPhotoUrl,
    this.isEditable = true,
    this.initials = '',
    this.onSuccess,
  });

  bool get isEditMode => playerId != null;
}
