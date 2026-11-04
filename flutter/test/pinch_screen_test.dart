import 'package:devtool_flutter_sample/screens/pinch_screen.dart';
import 'package:devtool_flutter_sample/test_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Pinch screen is a standard two-finger pinch, as in a photo viewer:
/// fingers apart zoom in, fingers together zoom out, one finger does nothing.
void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PinchScreen())),
    );
    await tester.pump();
  }

  String statusText(WidgetTester tester) {
    final widget = tester.widget<Text>(
      find.byKey(const ValueKey(TestTags.pinchStatus)),
    );
    return widget.data ?? '';
  }

  /// Two fingers level with the playground's centre, [from] px each side of it, moving to [to].
  Future<void> pinch(WidgetTester tester, double from, double to) async {
    final center = tester
        .getRect(find.byKey(const ValueKey(TestTags.pinchPlayground)))
        .center;
    final left = await tester.startGesture(center - Offset(from, 0), pointer: 1);
    final right = await tester.startGesture(center + Offset(from, 0), pointer: 2);
    const steps = 10;
    final step = (to - from) / steps;
    for (var i = 0; i < steps; i++) {
      await left.moveBy(Offset(-step, 0));
      await right.moveBy(Offset(step, 0));
      await tester.pump();
    }
    await left.up();
    await right.up();
    await tester.pump();
  }

  testWidgets('fingers apart zoom in', (tester) async {
    await pumpScreen(tester);
    expect(statusText(tester), contains('last: none'));
    await pinch(tester, 30, 120);
    expect(statusText(tester), contains('last: zoom in'));
  });

  testWidgets('fingers together zoom out', (tester) async {
    await pumpScreen(tester);
    await pinch(tester, 120, 30);
    expect(statusText(tester), contains('last: zoom out'));
  });

  testWidgets('one finger does not zoom', (tester) async {
    await pumpScreen(tester);
    final rect =
        tester.getRect(find.byKey(const ValueKey(TestTags.pinchPlayground)));
    final gesture = await tester.startGesture(rect.center - const Offset(100, 0));
    for (var i = 0; i < 8; i++) {
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();
    expect(statusText(tester), contains('last: none'));
  });
}
