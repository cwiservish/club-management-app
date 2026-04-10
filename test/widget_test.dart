import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:playbook365/app/app.dart';

void main() {
  testWidgets('App smoke test — launches without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: Playbook365App()),
    );
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
