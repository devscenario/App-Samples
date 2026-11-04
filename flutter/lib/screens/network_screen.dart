import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

class _Result {
  _Result(this.label, this.method, this.url, {this.auto = false});
  final String label;
  final String method;
  final String url;
  // Marks the on-entry auto-fired request so its row label can be localized.
  final bool auto;
  bool inFlight = true;
  int? code;
  int? durationMs;
  String? error;
}

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});
  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final List<_Result> _results = [];
  // Auto-request status resolver so it re-localizes when the language toggles.
  String Function(SampleStrings) _autoStatus = (s) => s.networkAutoFiring;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _auto());
  }

  Future<void> _auto() async {
    final entry = _Result('Auto-fired on screen entry', 'GET',
        'https://jsonplaceholder.typicode.com/posts/1',
        auto: true);
    if (mounted) setState(() => _results.insert(0, entry));
    final sw = Stopwatch()..start();
    try {
      final r = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      sw.stop();
      if (mounted) {
        setState(() {
          entry.inFlight = false;
          entry.code = r.statusCode;
          entry.durationMs = sw.elapsedMilliseconds;
          _autoStatus = (s) =>
              s.networkAutoDone(r.statusCode, sw.elapsedMilliseconds);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          entry.inFlight = false;
          entry.error = '$e';
          _autoStatus = (s) => s.networkAutoFailed('$e');
        });
      }
    }
  }

  Future<void> _fire(String label, String method, String url,
      {Object? body}) async {
    final r = _Result(label, method, url);
    setState(() => _results.insert(0, r));
    final sw = Stopwatch()..start();
    try {
      final resp = method == 'POST'
          ? await http.post(Uri.parse(url),
              headers: {'content-type': 'application/json'},
              body: body == null ? null : jsonEncode(body))
          : await http.get(Uri.parse(url));
      sw.stop();
      setState(() {
        r.inFlight = false;
        r.code = resp.statusCode;
        r.durationMs = sw.elapsedMilliseconds;
      });
    } catch (e) {
      setState(() {
        r.inFlight = false;
        r.error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.networkDemoTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  strings.networkDemoBody,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_autoStatus(strings),
                      key: const ValueKey(TestTags.networkAutoStatus),
                      style: Theme.of(context).textTheme.labelSmall),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey(TestTags.networkBtnGetPost),
          onPressed: () => _fire('GET /posts/1', 'GET',
              'https://jsonplaceholder.typicode.com/posts/1'),
          child: Text(strings.networkBtnGetPost),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const ValueKey(TestTags.networkBtnPostBody),
          onPressed: () => _fire(
            'POST /posts',
            'POST',
            'https://jsonplaceholder.typicode.com/posts',
            body: {'title': 'devtool', 'body': 'hello', 'userId': 1},
          ),
          child: Text(strings.networkBtnPostBody),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey(TestTags.networkBtnHttpbin),
          onPressed: () => _fire(
              'GET httpbin', 'GET', 'https://httpbin.org/get?source=devtool-sample'),
          child: Text(strings.networkBtnHttpbin),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey(TestTags.networkBtn404),
          onPressed: () =>
              _fire('GET → 404', 'GET', 'https://httpbin.org/status/404'),
          child: Text(strings.networkBtn404),
        ),
        const SizedBox(height: 16),
        Column(
          key: const ValueKey(TestTags.networkResults),
          children: [
            for (final r in _results)
              Card(
                child: ListTile(
                  title: Text('${r.method}  ${_labelOf(r, strings)}'),
                  subtitle: Text(r.url),
                  trailing: r.inFlight
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(r.error != null
                          ? 'ERROR'
                          : '${r.code}  •  ${r.durationMs} ms'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // The auto entry shows a localized label; manual rows keep their short
  // request labels (effectively row identifiers, like the CMP sample).
  String _labelOf(_Result r, SampleStrings strings) =>
      r.auto ? strings.networkAutoLabel : r.label;
}
