/// Standard envelope that the Playbook365 API wraps all responses in:
///
/// Single item:
/// ```json
/// { "success": true, "message": "OK", "data": { ... } }
/// ```
///
/// List:
/// ```json
/// { "success": true, "data": [ ... ] }
/// ```
///
/// Paginated list:
/// ```json
/// {
///   "success": true,
///   "data": [ ... ],
///   "meta": { "page": 1, "perPage": 20, "total": 200, "lastPage": 10 }
/// }
/// ```
class ApiResponse<T> {
  final T data;
  final String? message;
  final bool success;

  const ApiResponse({
    required this.data,
    required this.success,
    this.message,
  });

  /// Parses the raw JSON map from Dio's [response.data].
  ///
  /// [fromData] converts the inner `data` field to [T].
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) fromData,
  ) {
    return ApiResponse(
      success: (json['success'] as bool?) ?? true,
      message: json['message'] as String?,
      data: fromData(json['data'] ?? json),
    );
  }

  @override
  String toString() => 'ApiResponse(success: $success, message: $message)';
}
