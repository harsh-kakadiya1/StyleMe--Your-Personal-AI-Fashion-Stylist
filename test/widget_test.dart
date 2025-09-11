// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:styleme/main.dart';

void main() {
  testWidgets('StyleMe app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StyleMeApp());

    // Verify that our app shows the correct title
    expect(find.text('STYLE ME'), findsOneWidget);
    expect(find.text('Main Content Area'), findsOneWidget);

    // Verify that the bottom navigation bar items are present
    expect(find.text('Make Pair'), findsOneWidget);
    expect(find.text('AI Suggestions'), findsOneWidget);
    expect(find.text('Add Clothes'), findsOneWidget);
    expect(find.text('Weekly Planner'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify that the main content area shows the placeholder text
    expect(
      find.text('Future dynamic content will appear here'),
      findsOneWidget,
    );
  });
}
