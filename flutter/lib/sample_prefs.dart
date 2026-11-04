import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

import 'sample_strings.dart';

/// Persistence for the in-app [SampleLanguage] choice.
///
/// Platform-idiomatic key/value storage via `shared_preferences`. We store only
/// the enum's [SampleLanguage.name] (`"english"` / `"georgian"`) under a single
/// string key. The chosen language drives both the displayed [SampleStrings]
/// tables AND `MaterialApp.locale` (`Locale('en')` / `Locale('ka')`).
///
/// Flutter has no OS per-app locale store like Android 13+/iOS, so app-level
/// persistence via `shared_preferences` is the recommended path: we persist the
/// choice ourselves and seed the first run from the system locale.
///
/// Load and save both default to / fall back on English so the absent-pref and
/// any-error paths render the same English copy that existing flows/tests
/// assert on.
class SamplePrefs {
  const SamplePrefs._();

  /// Storage key holding [SampleLanguage.name].
  static const String languageKey = 'sample_app_language';

  /// Reads the saved language, or `null` when nothing has been persisted yet,
  /// the stored value is unrecognized, or the platform store is unavailable
  /// (e.g. a widget test that didn't call `SharedPreferences.setMockInitialValues`).
  ///
  /// `null` lets the caller distinguish "no choice yet" (seed from the system
  /// locale) from an explicit saved choice.
  static Future<SampleLanguage?> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(languageKey);
      if (saved == null) return null;
      for (final lang in SampleLanguage.values) {
        if (lang.name == saved) return lang;
      }
      return null;
    } catch (_) {
      // No platform implementation registered (e.g. plain widget test) — treat
      // as "no saved choice" rather than surfacing a load error in the sample.
      return null;
    }
  }

  /// Resolves the language to show at startup: the saved choice if present,
  /// otherwise the [systemLanguage] seed (Geormian system locale -> Georgian),
  /// otherwise English. Used once on first frame after the async pref load.
  static Future<SampleLanguage> resolveInitialLanguage() async {
    return await loadLanguage() ?? systemLanguage();
  }

  /// Maps the current system locale to a [SampleLanguage] seed. A Georgian
  /// system locale (`ka`) seeds Georgian; everything else (including unknown
  /// locales) defaults to English.
  static SampleLanguage systemLanguage() {
    final code = ui.PlatformDispatcher.instance.locale.languageCode
        .toLowerCase();
    return code == 'ka' ? SampleLanguage.georgian : SampleLanguage.english;
  }

  /// Persists [language] as its [SampleLanguage.name]. Best-effort: a failure to
  /// write is swallowed so the in-memory toggle still works.
  static Future<void> saveLanguage(SampleLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(languageKey, language.name);
    } catch (_) {
      // Best-effort persistence; ignore store-unavailable errors.
    }
  }
}
