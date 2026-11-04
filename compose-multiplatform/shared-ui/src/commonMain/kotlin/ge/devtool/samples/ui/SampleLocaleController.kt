package ge.devtool.samples.ui

/**
 * Drives the **OS-level per-app locale** (the platform-recommended mechanism)
 * from the in-app language chooser, instead of keeping the choice in in-memory
 * Compose state only.
 *
 * Why OS locale (and not a custom SharedPreferences/NSUserDefaults key): the OS
 * persists the per-app locale itself, and the devtool's flow-translation
 * auto-detection reads that exact location to learn what language the app is
 * rendering in (`AppLanguageDetector`):
 *
 *  - Android → `cmd locale get-app-locales <appId>`, which reflects
 *    `AppCompatDelegate.setApplicationLocales(...)`.
 *  - iOS → `defaults read <bundleId> AppleLanguages`, i.e. the app's own
 *    `AppleLanguages` default.
 *
 * The displayed text still comes from the kept [SampleStrings] En/Ka tables via
 * [LocalSampleStrings]; this controller only mirrors the same choice into the OS
 * locale so the chooser is both live AND detectable.
 *
 * [current] derives the active [SampleLanguage] from the platform's effective
 * locale (default [SampleLanguage.ENGLISH] for anything other than Georgian).
 * [apply] writes the chosen language into the OS per-app locale.
 */
internal expect object SampleLocaleController {
    fun current(): SampleLanguage
    fun apply(language: SampleLanguage)
}

/** BCP-47 language tag for [language] — the only two the sample ships. */
internal fun localeTag(language: SampleLanguage): String =
    if (language == SampleLanguage.GEORGIAN) "ka" else "en"

/**
 * Map a locale/language string (e.g. `ka`, `ka-GE`, `en-US`) to a
 * [SampleLanguage]. Georgian (`ka`) → [SampleLanguage.GEORGIAN]; everything else
 * — including null/blank — defaults to [SampleLanguage.ENGLISH]. Shared so both
 * actuals agree on the mapping.
 */
internal fun sampleLanguageForTag(tag: String?): SampleLanguage =
    if (tag?.trim()?.lowercase()?.startsWith("ka") == true) {
        SampleLanguage.GEORGIAN
    } else {
        SampleLanguage.ENGLISH
    }
