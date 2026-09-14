import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playbook365/app/theme/app_colors.dart';
import 'package:playbook365/core/network/interceptors/maintenance_interceptor.dart';
import 'package:playbook365/core/shared_widgets/maintenance_dialog.dart';
import 'package:playbook365/core/utils/navigator_key.dart';

void main() {
  group('MaintenanceInterceptor Tests', () {
    test('calls onMaintenance callback when receiving 503 status code with custom message', () async {
      String? interceptedMessage;
      final interceptor = MaintenanceInterceptor(
        onMaintenance: (message) {
          interceptedMessage = message;
        },
      );

      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.httpClientAdapter = _MockHttpClientAdapter(
        statusCode: 503,
        responseData: {'message': 'Scheduled server maintenance in progress until 04:00 AM UTC.'},
      );

      try {
        await dio.get('https://api.example.com/test');
      } catch (_) {
        // Expected DioException
      }

      expect(interceptedMessage, 'Scheduled server maintenance in progress until 04:00 AM UTC.');
    });

    test('calls onMaintenance callback when receiving 503 status code with detail message', () async {
      String? interceptedMessage;
      final interceptor = MaintenanceInterceptor(
        onMaintenance: (message) {
          interceptedMessage = message;
        },
      );

      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.httpClientAdapter = _MockHttpClientAdapter(
        statusCode: 503,
        responseData: {'detail': 'System upgrade in progress.'},
      );

      try {
        await dio.get('https://api.example.com/test');
      } catch (_) {
        // Expected DioException
      }

      expect(interceptedMessage, 'System upgrade in progress.');
    });

    test('does not trigger onMaintenance when receiving 200 OK or other error codes like 404', () async {
      bool called = false;
      final interceptor = MaintenanceInterceptor(
        onMaintenance: (message) {
          called = true;
        },
      );

      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.httpClientAdapter = _MockHttpClientAdapter(
        statusCode: 404,
        responseData: {'message': 'Not found'},
      );

      try {
        await dio.get('https://api.example.com/test');
      } catch (_) {
        // Expected DioException
      }

      expect(called, isFalse);
    });
  });

  group('MaintenanceDialog Widget Tests', () {
    testWidgets('renders MaintenanceDialog with default message and elements', (tester) async {
      AppColors.setCurrent(AppColors.light);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MaintenanceDialog(),
          ),
        ),
      );

      expect(find.text('Application Under Maintenance'), findsOneWidget);
      expect(
        find.text('The app is currently under maintenance. Please try again after some time.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.engineering_rounded), findsOneWidget);
      expect(find.text('Okay, Got It'), findsOneWidget);
    });

    testWidgets('renders MaintenanceDialog with custom backend message in dark mode', (tester) async {
      AppColors.setCurrent(AppColors.dark);

      const customMsg = 'Database migration in progress. We will be back online shortly.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MaintenanceDialog(
              message: customMsg,
            ),
          ),
        ),
      );

      expect(find.text('Application Under Maintenance'), findsOneWidget);
      expect(find.text(customMsg), findsOneWidget);
      expect(find.text('Okay, Got It'), findsOneWidget);
    });

    testWidgets('triggers onDismiss callback when Okay button is tapped', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaintenanceDialog(
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Okay, Got It'));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('showMaintenanceDialog opens dialog via rootNavigatorKey and prevents duplicates', (tester) async {
      AppColors.setCurrent(AppColors.light);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: const Scaffold(
            body: Text('Main Screen'),
          ),
        ),
      );

      expect(find.text('Main Screen'), findsOneWidget);
      expect(find.text('Application Under Maintenance'), findsNothing);

      // Trigger first maintenance dialog
      showMaintenanceDialog(
        message: 'Server maintenance 1',
        onDismiss: () {},
      );
      await tester.pumpAndSettle();

      expect(find.text('Application Under Maintenance'), findsOneWidget);
      expect(find.text('Server maintenance 1'), findsOneWidget);

      // Attempt to trigger duplicate maintenance dialog while already showing
      showMaintenanceDialog(
        message: 'Server maintenance 2',
        onDismiss: () {},
      );
      await tester.pumpAndSettle();

      // Should only show one dialog
      expect(find.text('Application Under Maintenance'), findsOneWidget);
      expect(find.text('Server maintenance 1'), findsOneWidget);
      expect(find.text('Server maintenance 2'), findsNothing);

      // Tap Dismiss / Okay
      await tester.tap(find.text('Okay, Got It'));
      await tester.pumpAndSettle();

      expect(find.text('Application Under Maintenance'), findsNothing);
    });
  });
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> responseData;

  _MockHttpClientAdapter({
    required this.statusCode,
    required this.responseData,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bodyString = responseData.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    final jsonStr = '{$bodyString}';
    return ResponseBody.fromString(
      jsonStr,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
