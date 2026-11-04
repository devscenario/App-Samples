import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../test_tags.dart';

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});
  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  double _progress = 0.5;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return ListView(
      key: const ValueKey(TestTags.showcaseScroll),
      padding: const EdgeInsets.all(16),
      children: [
        Text(strings.showcaseTitle,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(strings.showcaseIntro),
        const SizedBox(height: 12),
        SwitchListTile(
          key: const ValueKey(TestTags.showcaseSwitch),
          title: Text(strings.showcaseEnableNotifications),
          value: _notifications,
          onChanged: (v) => setState(() => _notifications = v),
        ),
        const SizedBox(height: 12),
        Text(strings.showcaseProgress),
        LinearProgressIndicator(
          key: const ValueKey(TestTags.showcaseProgress),
          value: _progress,
          minHeight: 8,
        ),
        // Quarter steps: a drag settles on an exact value.
        Slider(
          key: const ValueKey(TestTags.showcaseSlider),
          value: _progress,
          divisions: 4,
          onChanged: (v) => setState(() => _progress = v),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < 12; i++)
          Container(
            height: 56,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: i.isEven
                ? Colors.indigo.withValues(alpha: 0.08)
                : Colors.teal.withValues(alpha: 0.08),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(strings.showcaseListElement(i + 1)),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
                onPressed: () {}, child: Text(strings.showcasePrimary)),
            const SizedBox(width: 12),
            OutlinedButton(
                onPressed: () {}, child: Text(strings.showcaseSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Text(strings.showcaseEnd,
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
