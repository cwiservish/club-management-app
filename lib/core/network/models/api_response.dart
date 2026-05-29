/// Unwrapped response from the Playbook365 API envelope:
/// ```json
/// { "success": true, "message": "OK", "data": { ... } }
/// { "success": true, "data": [ ... ] }
/// ```
///
/// [data] is the raw value of the `data` key — could be a Map, List, or null.
/// Each feature's service is responsible for casting and mapping it.
class ApiResponse {
  final dynamic data;
  final String? message;
  final bool success;
  final Map<String, dynamic> rawJson;

  const ApiResponse({
    required this.data,
    required this.success,
    this.message,
    this.rawJson = const {},
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: (json['success'] as bool?) ?? true,
      message: json['message'] as String?,
      data: json['data'],
      rawJson: json,
    );
  }

  @override
  String toString() => 'ApiResponse(success: $success, message: $message)';
}
