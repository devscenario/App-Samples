import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../sample_validation.dart';
import '../test_tags.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _terms = false;
  // Resolver for the submitted status, re-localized on language change.
  String Function(SampleStrings)? _submitted;
  // True only when the last submit succeeded (drives the button label).
  bool _submittedOk = false;

  bool get _liveValid =>
      _name.text.trim().length >= 2 &&
      isValidEmail(_email.text.trim()) &&
      _password.text.length >= 8;

  void _clearSubmit() {
    _submitted = null;
    _submittedOk = false;
  }

  String _statusOf(SampleStrings s) {
    if (_submitted != null) return _submitted!(s);
    return _liveValid ? s.regSuccess(_email.text.trim()) : '';
  }

  void _submit() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    setState(() {
      if (name.length < 2) {
        _submitted = (s) => s.regFailureName;
        _submittedOk = false;
      } else if (!isValidEmail(email)) {
        _submitted = (s) => s.regFailureEmail;
        _submittedOk = false;
      } else if (_password.text.length < 8) {
        _submitted = (s) => s.regFailurePassword;
        _submittedOk = false;
      } else {
        _submitted = (s) => s.regSuccess(email);
        _submittedOk = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(strings.regCreateAccount,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.regName),
          controller: _name,
          decoration: InputDecoration(labelText: strings.regFullName),
          onChanged: (_) => setState(_clearSubmit),
        ),
        if (_name.text.isNotEmpty)
          Text(strings.regNameTyped(_name.text),
              key: const ValueKey(TestTags.regNamePreview)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.regEmail),
          controller: _email,
          decoration: InputDecoration(labelText: strings.regEmail),
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(_clearSubmit),
        ),
        if (_email.text.isNotEmpty)
          Text(strings.regEmailTyped(_email.text),
              key: const ValueKey(TestTags.regEmailPreview)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.regPassword),
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(labelText: strings.regPassword),
          onChanged: (_) => setState(_clearSubmit),
        ),
        if (_password.text.isNotEmpty)
          Text(strings.regPasswordTyped(_password.text),
              key: const ValueKey(TestTags.regPasswordPreview)),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey(TestTags.regTerms),
          onPressed: () => setState(() => _terms = !_terms),
          child: Text(_terms ? strings.regTermsAccepted : strings.regAcceptTerms),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const ValueKey(TestTags.regSubmit),
          onPressed: _submit,
          child: Text(
            _submittedOk ? _submitted!(strings) : strings.regRegister,
          ),
        ),
        const SizedBox(height: 12),
        Text(_statusOf(strings), key: const ValueKey(TestTags.regStatus)),
      ],
    );
  }
}
