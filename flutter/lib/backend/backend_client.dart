import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'backend_strings.dart';

/// Default base URL on an Android emulator: the host's loopback.
const String androidDefaultBackendUrl = 'http://10.0.2.2:8095';

/// Default base URL on an iOS simulator, which shares the host's network.
const String iosDefaultBackendUrl = 'http://localhost:8095';

/// Build-time override, e.g. `--dart-define=BACKEND_URL=http://localhost:8095`.
const String _backendUrlOverride = String.fromEnvironment('BACKEND_URL');

/// The base URL the Backend screen talks to on this platform.
String defaultBackendUrl() {
  if (_backendUrlOverride.isNotEmpty) return _backendUrlOverride;
  return defaultTargetPlatform == TargetPlatform.android
      ? androidDefaultBackendUrl
      : iosDefaultBackendUrl;
}

/// What a backend call ended with, independent of the display language.
sealed class BackendOutcome {
  const BackendOutcome();

  String text(BackendStrings strings) => switch (this) {
    SignedIn(:final username) => strings.signedIn(username),
    WrongCredentials() => strings.wrongCredentials,
    Unreachable() => strings.unreachable,
    OrderPlaced() => strings.orderPlaced,
    OrderStatus(:final status) => strings.status(status),
    NoOrder() => strings.noOrder,
  };
}

class SignedIn extends BackendOutcome {
  const SignedIn(this.session, this.username);
  final String session;
  final String username;
}

class WrongCredentials extends BackendOutcome {
  const WrongCredentials();
}

class Unreachable extends BackendOutcome {
  const Unreachable();
}

class OrderPlaced extends BackendOutcome {
  const OrderPlaced();
}

class OrderStatus extends BackendOutcome {
  const OrderStatus(this.status);
  final String status;
}

class NoOrder extends BackendOutcome {
  const NoOrder();
}

/// The app's side of `test-backend`: sign-in and the current
/// order. Mirrors `shared-ui` `BackendClient.kt`.
class BackendClient {
  BackendClient(this.baseUrl, {http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const _sessionHeader = 'X-Session';
  static const _timeout = Duration(seconds: 12);

  Future<BackendOutcome> signIn(String username, String password) async {
    final reply = await _call(
      'POST',
      '/app/login',
      body: {'username': username, 'password': password},
    );
    if (reply == null) return const Unreachable();
    if (reply.code != 200) return const WrongCredentials();
    final session = reply.json['session'];
    final name = reply.json['username'];
    if (session is! String || name is! String) return const Unreachable();
    return SignedIn(session, name);
  }

  Future<BackendOutcome> placeOrder(String session) async {
    final reply = await _call(
      'POST',
      '/app/orders',
      body: const {},
      session: session,
    );
    if (reply == null) return const Unreachable();
    return reply.code == 200 ? const OrderPlaced() : const NoOrder();
  }

  Future<BackendOutcome> refreshStatus(String session) async {
    final reply = await _call('GET', '/app/orders/current', session: session);
    if (reply == null) return const Unreachable();
    final status = reply.json['status'];
    if (reply.code == 200 && status is String) {
      return OrderStatus(status);
    }
    return const NoOrder();
  }

  void close() => _client.close();

  /// Status code and JSON object of one call, or null when the backend can't
  /// be reached.
  Future<_Reply?> _call(
    String method,
    String path, {
    Map<String, String>? body,
    String? session,
  }) async {
    final uri = Uri.tryParse(baseUrl + path);
    if (uri == null) return null;
    final headers = <String, String>{
      if (body != null) 'content-type': 'application/json',
      _sessionHeader: ?session,
    };
    try {
      final response = method == 'POST'
          ? await _client
                .post(uri, headers: headers, body: jsonEncode(body))
                .timeout(_timeout)
          : await _client.get(uri, headers: headers).timeout(_timeout);
      return _Reply(response.statusCode, _jsonObject(response.body));
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _jsonObject(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }
}

class _Reply {
  const _Reply(this.code, this.json);
  final int code;
  final Map<String, dynamic> json;
}
