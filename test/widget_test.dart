// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:zentick/main.dart';

void main() {
  testWidgets('ZenTick timer app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZenTickApp());

    // Verify that our timer shows the default time.
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('ZenTick'), findsOneWidget);

    // Verify that Start button is present
    expect(find.text('Start'), findsOneWidget);
  });
}
