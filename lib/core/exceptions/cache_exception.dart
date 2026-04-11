import 'app_exception.dart';

/// Thrown when a local storage or cache operation fails.
///
/// Examples: reading from SharedPreferences, writing to secure storage,
/// parsing a locally cached JSON file.
///
/// Kept separate from [NetworkException] so callers can distinguish
/// "API is down" from "local data is corrupted/missing".
class CacheException extends AppException {
  const CacheException(super.message);

  @override
  String toString() => 'CacheException: $message';
}
