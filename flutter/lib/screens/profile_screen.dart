import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController(text: 'QA Tester');
  final _phone = TextEditingController();
  bool _marketing = true;
  // Status resolver so the message re-localizes when the language toggles.
  String Function(SampleStrings)? _status;

  void _save() {
    final name = _name.text.trim();
    setState(() {
      if (name.length < 2) {
        _status = (s) => s.profileFailureName;
      } else if (_phone.text.trim().length < 7) {
        _status = (s) => s.profileFailurePhone;
      } else {
        _status = (s) => s.profileSaved(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(strings.profileTitle,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.profileName),
          controller: _name,
          decoration: InputDecoration(labelText: strings.profileDisplayName),
          onChanged: (_) => setState(() {}),
        ),
        Text(strings.profileNameTyped(_name.text),
            key: const ValueKey(TestTags.profileNamePreview)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey(TestTags.profilePhone),
          controller: _phone,
          decoration: InputDecoration(labelText: strings.profilePhone),
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
        ),
        if (_phone.text.isNotEmpty)
          Text(strings.profilePhoneTyped(_phone.text),
              key: const ValueKey(TestTags.profilePhonePreview)),
        SwitchListTile(
          key: const ValueKey(TestTags.profileMarketing),
          title: Text(strings.profileMarketingEmails),
          value: _marketing,
          onChanged: (v) => setState(() => _marketing = v),
        ),
        FilledButton(
          key: const ValueKey(TestTags.profileSave),
          onPressed: _save,
          child: Text(strings.profileSave),
        ),
        const SizedBox(height: 12),
        Text(_status?.call(strings) ?? '',
            key: const ValueKey(TestTags.profileStatus)),
      ],
    );
  }
}
