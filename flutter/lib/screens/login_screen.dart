import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../sample_validation.dart';
import '../test_tags.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = false;
  // Status resolver so the message re-localizes when the language toggles.
  String Function(SampleStrings)? _status;

  void _submit() {
    final email = _email.text.trim();
    final ok = isValidEmail(email) && _password.text.length >= 6;
    setState(() => _status =
        ok ? (s) => s.loginSuccess(email) : (s) => s.loginFailure);
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(strings.loginWelcome,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.loginEmail),
          controller: _email,
          decoration: InputDecoration(labelText: strings.loginEmail),
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
        if (_email.text.isNotEmpty)
          Text(strings.loginEmailTyped(_email.text),
              key: const ValueKey(TestTags.loginEmailPreview)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.loginPassword),
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(labelText: strings.loginPassword),
          onChanged: (_) => setState(() {}),
        ),
        if (_password.text.isNotEmpty)
          Text(strings.loginPasswordTyped(_password.text),
              key: const ValueKey(TestTags.loginPasswordPreview)),
        SwitchListTile(
          key: const ValueKey(TestTags.loginRemember),
          title: Text(strings.loginRememberMe),
          value: _remember,
          onChanged: (v) => setState(() => _remember = v),
        ),
        FilledButton(
          key: const ValueKey(TestTags.loginButton),
          onPressed: _submit,
          child: Text(strings.loginSignIn),
        ),
        const SizedBox(height: 12),
        Text(_status?.call(strings) ?? '',
            key: const ValueKey(TestTags.loginStatus)),
      ],
    );
  }
}
