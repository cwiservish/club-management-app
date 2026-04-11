/// Base class for all app-level exceptions.
///
/// Every exception the app can throw extends this.
/// Catch [AppException] when you want to handle any known error generically.
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}
