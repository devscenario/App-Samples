import 'package:devscenario_app_instrumentation/devscenario_app_instrumentation.dart';
import 'package:flutter/widgets.dart';

import 'sample_prefs.dart';
import 'sample_strings.dart';

/// BCP-47 tag for each in-app language. Reported to the Dev Scenario in-app SDK so
/// E2E translation auto-detection sees the *custom* string-table switch — the
/// toggle does not change the OS / `PlatformDispatcher` locale, so without this
/// the SDK would report the device language.
String _bcp47(SampleLanguage language) {
  switch (language) {
    case SampleLanguage.english:
      return 'en';
    case SampleLanguage.georgian:
      return 'ka';
  }
}

/// Holds the in-app [SampleLanguage] for the whole sample tree and exposes the
/// resolved [SampleStrings] via an [InheritedWidget].
///
/// This is a lightweight, dependency-free alternative to a state-management
/// package — it matches how the rest of the sample uses plain `setState`. The
/// toggle drives displayed strings only; it does NOT change the OS locale.
class SampleLocaleScope extends StatefulWidget {
  const SampleLocaleScope({super.key, required this.child});

  /// Subtree below the scope. The active [SampleStrings] is read with
  /// [SampleLocale.of].
  final Widget child;

  static SampleLocaleScopeState of(BuildContext context) {
    final state = context.findAncestorStateOfType<SampleLocaleScopeState>();
    assert(state != null, 'No SampleLocaleScope found in the widget tree');
    return state!;
  }

  @override
  State<SampleLocaleScope> createState() => SampleLocaleScopeState();
}

class SampleLocaleScopeState extends State<SampleLocaleScope> {
  // Default English so existing English-asserting flows/tests keep passing.
  // The persisted choice (if any) is loaded asynchronously in initState and
  // applied via setState once available — until then this English default
  // renders synchronously on the first frame.
  SampleLanguage _language = SampleLanguage.english;

  SampleLanguage get language => _language;

  @override
  void initState() {
    super.initState();
    // Seed the SDK with the English default rendering on the first frame so the
    // in-app locale is reportable before any toggle.
    DevScenarioAppInstrumentation.setReportedLocale(_bcp47(_language));
    // Resolve the startup language asynchronously: saved choice -> system
    // locale seed (ka -> Georgian) -> English. English renders synchronously on
    // the first frame while this load is in flight, so nothing flashes/breaks
    // and tests with no saved pref stay on English.
    SamplePrefs.resolveInitialLanguage().then((resolved) {
      if (!mounted || resolved == _language) return;
      setState(() => _language = resolved);
      // Keep the SDK in lockstep with the resolved startup language.
      DevScenarioAppInstrumentation.setReportedLocale(_bcp47(resolved));
    });
  }

  void setLanguage(SampleLanguage language) {
    if (language == _language) return;
    setState(() => _language = language);
    // Report the new in-app language to the Dev Scenario SDK on every change so E2E
    // translation auto-detection tracks the live UI.
    DevScenarioAppInstrumentation.setReportedLocale(_bcp47(language));
    // Persist the choice (best-effort) so it survives a restart.
    SamplePrefs.saveLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    return SampleLocale(
      language: _language,
      strings: stringsFor(_language),
      child: widget.child,
    );
  }
}

/// Inherited holder so any descendant can read the active [SampleStrings] with
/// `SampleLocale.of(context)` and rebuild when the language changes.
class SampleLocale extends InheritedWidget {
  const SampleLocale({
    super.key,
    required this.language,
    required this.strings,
    required super.child,
  });

  final SampleLanguage language;
  final SampleStrings strings;

  /// Active string table. Falls back to English if no scope is present
  /// (e.g. a screen pumped directly in a widget test).
  static SampleStrings of(BuildContext context) {
    final locale =
        context.dependOnInheritedWidgetOfExactType<SampleLocale>();
    return locale?.strings ?? const EnStrings();
  }

  /// Active language, defaulting to English when no scope is present.
  static SampleLanguage languageOf(BuildContext context) {
    final locale =
        context.dependOnInheritedWidgetOfExactType<SampleLocale>();
    return locale?.language ?? SampleLanguage.english;
  }

  @override
  bool updateShouldNotify(SampleLocale oldWidget) =>
      language != oldWidget.language;
}
