import 'dart:convert';

import 'package:devtool_flutter_sample/backend/backend_client.dart';
import 'package:devtool_flutter_sample/screens/backend_screen.dart';
import 'package:devtool_flutter_sample/test_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Backend screen states against a fake of `test-backend`.
void main() {
  const baseUrl = 'http://backend.test';
  var status = 'Placed';

  http.Client fakeBackend() => MockClient((request) async {
    final path = request.url.path;
    if (path == '/app/login') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'jdoe' && body['password'] == 'sample-pass') {
        return http.Response(
          jsonEncode({'session': 's-1', 'username': 'jdoe'}),
          200,
        );
      }
      return http.Response('{"error":"invalid_credentials"}', 401);
    }
    if (request.headers['X-Session'] != 's-1') {
      return http.Response('{}', 401);
    }
    if (path == '/app/orders') return http.Response('{}', 200);
    if (path == '/app/orders/current') {
      return http.Response(jsonEncode({'status': status}), 200);
    }
    return http.Response('', 404);
  });

  Future<void> pumpScreen(WidgetTester tester, http.Client client) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BackendScreen(client: BackendClient(baseUrl, client: client)),
        ),
      ),
    );
  }

  String textOf(WidgetTester tester, String tag) =>
      tester.widget<Text>(find.byKey(ValueKey(tag))).data ?? '';

  Future<void> signIn(WidgetTester tester, String user, String pass) async {
    await tester.enterText(
      find.byKey(const ValueKey(TestTags.backendUsername)),
      user,
    );
    await tester.enterText(
      find.byKey(const ValueKey(TestTags.backendPassword)),
      pass,
    );
    await tester.tap(find.byKey(const ValueKey(TestTags.backendSignIn)));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the base URL and only sign-in before signing in', (
    tester,
  ) async {
    await pumpScreen(tester, fakeBackend());
    expect(textOf(tester, TestTags.backendUrl), baseUrl);
    expect(find.byKey(const ValueKey(TestTags.backendStatus)), findsNothing);
    expect(find.byKey(const ValueKey(TestTags.backendSubmit)), findsNothing);
  });

  testWidgets('wrong credentials keep the order buttons hidden', (
    tester,
  ) async {
    await pumpScreen(tester, fakeBackend());
    await signIn(tester, 'jdoe', 'nope');
    expect(
      textOf(tester, TestTags.backendStatus),
      'Wrong username or password',
    );
    expect(find.byKey(const ValueKey(TestTags.backendSubmit)), findsNothing);
  });

  testWidgets('signs in, places and refreshes the order', (tester) async {
    status = 'Shipped';
    await pumpScreen(tester, fakeBackend());
    await signIn(tester, ' jdoe ', 'sample-pass');
    expect(textOf(tester, TestTags.backendStatus), 'Signed in as jdoe');

    await tester.tap(find.byKey(const ValueKey(TestTags.backendSubmit)));
    await tester.pumpAndSettle();
    expect(textOf(tester, TestTags.backendOrder), 'Order placed');

    await tester.tap(find.byKey(const ValueKey(TestTags.backendRefresh)));
    await tester.pumpAndSettle();
    expect(textOf(tester, TestTags.backendOrder), 'Status: Shipped');
  });

  testWidgets('an unreachable backend says so', (tester) async {
    await pumpScreen(
      tester,
      MockClient((_) async => throw http.ClientException('down')),
    );
    await signIn(tester, 'jdoe', 'sample-pass');
    expect(textOf(tester, TestTags.backendStatus), 'Backend unreachable');
  });
}
