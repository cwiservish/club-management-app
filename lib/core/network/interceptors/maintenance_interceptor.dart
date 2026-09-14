import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../shared_widgets/maintenance_dialog.dart';

/// Interceptor that inspects responses for HTTP 503 (Service Unavailable / Maintenance).
/// When encountered, it triggers a global [MaintenanceDialog] to inform the user.
class MaintenanceInterceptor extends Interceptor {
  final void Function(String? message)? onMaintenance;

  const MaintenanceInterceptor({this.onMaintenance});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    if (statusCode == 503) {
      final message = _extractMessage(err.response?.data);
      debugPrint('[MaintenanceInterceptor] 503 Service Unavailable detected. Message: $message');

      if (onMaintenance != null) {
        onMaintenance!(message);
      } else {
        showMaintenanceDialog(message: message);
      }
    }

    handler.next(err);
  }

  String? _extractMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    for (final key in const ['message', 'error', 'detail', 'msg']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
