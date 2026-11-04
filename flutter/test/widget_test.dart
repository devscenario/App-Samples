import 'package:devtool_flutter_sample/sample_app.dart';
import 'package:devtool_flutter_sample/test_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home grid renders a tile per sample screen', (tester) async {
    await tester.pumpWidget(const SampleApp());
    await tester.pump();

    expect(find.byKey(const ValueKey(TestTags.homeGrid)), findsOneWidget);
    // First-row tiles are built in the test viewport (GridView is lazy).
    expect(find.text('Login'), findsOneWidget);
    expect(find.byKey(const ValueKey(TestTags.tabLogin)), findsOneWidget);
  });

  testWidgets('tapping a tile navigates to the detail screen with a back button',
      (tester) async {
    await tester.pumpWidget(const SampleApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey(TestTags.tabLogin)));
    await tester.pumpAndSettle(const Duration(seconds: 2)); // past the loader

    expect(find.byKey(const ValueKey(TestTags.navBack)), findsOneWidget);
    expect(find.byKey(const ValueKey(TestTags.navTitle)), findsOneWidget);
    expect(find.byKey(const ValueKey(TestTags.loginEmail)), findsOneWidget);
  });
}
