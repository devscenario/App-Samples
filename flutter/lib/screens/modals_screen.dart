import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

class ModalsScreen extends StatefulWidget {
  const ModalsScreen({super.key});
  @override
  State<ModalsScreen> createState() => _ModalsScreenState();
}

class _ModalsScreenState extends State<ModalsScreen> {
  // Status resolver so the message re-localizes when the language toggles.
  String Function(SampleStrings) _status = (s) => s.modalsStatusNone;

  void _set(String Function(SampleStrings) resolver) =>
      setState(() => _status = resolver);

  Future<void> _openSheet({required bool full}) async {
    _set(full
        ? (s) => s.modalsStatusFullVisible
        : (s) => s.modalsStatusPartialVisible);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: full,
      builder: (ctx) {
        final strings = SampleLocale.of(ctx);
        return SizedBox(
          key: const ValueKey(TestTags.modalsSheet),
          height: full ? MediaQuery.of(ctx).size.height * 0.85 : 240,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.modalsBottomSheet,
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(strings.modalsSheetIntro),
                const SizedBox(height: 10),
                TextButton(
                  key: const ValueKey(TestTags.modalsSheetHide),
                  onPressed: () => Navigator.of(ctx).pop('hide'),
                  child: Text(strings.modalsHideSheet),
                ),
              ],
            ),
          ),
        );
      },
    );
    _set(result == 'hide'
        ? (s) => s.modalsStatusSheetHidden
        : (s) => s.modalsStatusSheetDismissed);
  }

  Future<void> _openAlert() async {
    _set((s) => s.modalsStatusAlertVisible);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final strings = SampleLocale.of(ctx);
        return AlertDialog(
          title: Text(strings.modalsAlertTitle),
          content: Text(strings.modalsAlertBody),
          actions: [
            TextButton(
              key: const ValueKey(TestTags.modalsAlertDismiss),
              onPressed: () => Navigator.of(ctx).pop('dismiss'),
              child: Text(strings.modalsDismiss),
            ),
            TextButton(
              key: const ValueKey(TestTags.modalsAlertConfirm),
              onPressed: () => Navigator.of(ctx).pop('confirm'),
              child: Text(strings.modalsConfirm),
            ),
          ],
        );
      },
    );
    if (result == 'confirm') {
      _set((s) => s.modalsStatusAlertConfirmed);
    } else {
      _set((s) => s.modalsStatusAlertHidden);
    }
  }

  Future<void> _openFullscreen() async {
    _set((s) => s.modalsStatusFullscreenVisible);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final strings = SampleLocale.of(ctx);
        return Dialog.fullscreen(
          key: const ValueKey(TestTags.modalsFullscreenDialog),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.modalsFullscreenTitle,
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(strings.modalsFullscreenBody),
                const SizedBox(height: 10),
                FilledButton(
                  key: const ValueKey(TestTags.modalsFullscreenClose),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(strings.modalsClose),
                ),
              ],
            ),
          ),
        );
      },
    );
    _set((s) => s.modalsStatusFullscreenHidden);
  }

  /// A sheet holding a text field, as in the Compose sample: typing reaches a field in a modal sheet.
  Future<void> _openVerifySheet() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _VerifyCodeSheet(),
    );
    if (code != null) _set((s) => s.modalsStatusCodeVerified(code));
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(strings.modalsTitle,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(strings.modalsIntro),
        const SizedBox(height: 12),
        Text(strings.modalsStatus(_status(strings)),
            key: const ValueKey(TestTags.modalsStatus)),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey(TestTags.modalsOpenPartialSheet),
          onPressed: () => _openSheet(full: false),
          child: Text(strings.modalsPartialSheet),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const ValueKey(TestTags.modalsOpenFullSheet),
          onPressed: () => _openSheet(full: true),
          child: Text(strings.modalsFullSheet),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey(TestTags.modalsOpenAlertDialog),
          onPressed: _openAlert,
          child: Text(strings.modalsAlertDialog),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey(TestTags.modalsOpenFullscreenDialog),
          onPressed: _openFullscreen,
          child: Text(strings.modalsFullscreenDialog),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey(TestTags.modalsOpenVerifySheet),
          onPressed: _openVerifySheet,
          child: Text(strings.modalsCodeSheet),
        ),
      ],
    );
  }
}

/// "Verify by code": an SMS code field and a Verify button that closes the sheet with the code.
class _VerifyCodeSheet extends StatefulWidget {
  const _VerifyCodeSheet();
  @override
  State<_VerifyCodeSheet> createState() => _VerifyCodeSheetState();
}

class _VerifyCodeSheetState extends State<_VerifyCodeSheet> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return Padding(
      key: const ValueKey(TestTags.modalsVerifySheet),
      // Keeps the field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.modalsVerifyByCode,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey(TestTags.modalsVerifyCode),
              controller: _code,
              decoration: InputDecoration(labelText: strings.modalsSmsCode),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            FilledButton(
              key: const ValueKey(TestTags.modalsVerifySubmit),
              onPressed: () => Navigator.of(context).pop(_code.text),
              child: Text(strings.modalsVerify),
            ),
          ],
        ),
      ),
    );
  }
}
