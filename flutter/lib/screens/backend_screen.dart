import 'package:flutter/material.dart';

import '../backend/backend_client.dart';
import '../backend/backend_strings.dart';
import '../sample_locale.dart';
import '../test_tags.dart';

/// Signs in against `test-backend` and places the
/// user's order, so flows can check app state that comes from a real backend.
/// Same tags and texts as the Compose `BackendScreen.kt` and SwiftUI
/// `BackendView.swift`.
class BackendScreen extends StatefulWidget {
  const BackendScreen({super.key, this.client});

  /// Injected in tests; otherwise a client on [defaultBackendUrl].
  final BackendClient? client;

  @override
  State<BackendScreen> createState() => _BackendScreenState();
}

class _BackendScreenState extends State<BackendScreen> {
  late final BackendClient _client =
      widget.client ?? BackendClient(defaultBackendUrl());
  final _username = TextEditingController();
  final _password = TextEditingController();
  BackendOutcome? _signIn;
  BackendOutcome? _order;
  bool _busy = false;

  String? get _session => switch (_signIn) {
    SignedIn(:final session) => session,
    _ => null,
  };

  Future<void> _run(Future<void> Function() call) async {
    setState(() => _busy = true);
    try {
      await call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInPressed() => _run(() async {
    final outcome = await _client.signIn(_username.text.trim(), _password.text);
    if (mounted) {
      setState(() {
        _signIn = outcome;
        _order = null;
      });
    }
  });

  Future<void> _orderCall(
    Future<BackendOutcome> Function(String session) call,
  ) => _run(() async {
    final outcome = await call(_session!);
    if (mounted) setState(() => _order = outcome);
  });

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    if (widget.client == null) _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = backendStringsOf(SampleLocale.of(context));
    final session = _session;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _client.baseUrl,
          key: const ValueKey(TestTags.backendUrl),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.backendUsername),
          controller: _username,
          decoration: InputDecoration(labelText: strings.username),
          // Usernames are typed exactly: no autocorrect or capitalization.
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.backendPassword),
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(labelText: strings.password),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey(TestTags.backendSignIn),
          onPressed: _busy ? null : _signInPressed,
          child: Text(strings.signIn, maxLines: 1),
        ),
        if (_signIn != null) ...[
          const SizedBox(height: 12),
          Text(
            _signIn!.text(strings),
            key: const ValueKey(TestTags.backendStatus),
          ),
        ],
        if (session != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            key: const ValueKey(TestTags.backendSubmit),
            onPressed: _busy ? null : () => _orderCall(_client.placeOrder),
            child: Text(strings.placeOrder, maxLines: 1),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const ValueKey(TestTags.backendRefresh),
            onPressed: _busy ? null : () => _orderCall(_client.refreshStatus),
            child: Text(strings.refresh, maxLines: 1),
          ),
          if (_order != null) ...[
            const SizedBox(height: 12),
            Text(
              _order!.text(strings),
              key: const ValueKey(TestTags.backendOrder),
            ),
          ],
        ],
      ],
    );
  }
}
