package ge.devtool.samples.ui

import platform.Foundation.NSBundle
import platform.Foundation.NSLocale
import platform.Foundation.NSUserDefaults
import platform.Foundation.preferredLanguages

/**
 * iOS `actual`: drives the **per-app `AppleLanguages`** default. This is the
 * app's own preferences domain that the devtool's `AppLanguageDetector` reads
 * back via `defaults read <bundleId> AppleLanguages`.
 *
 * [current] reflects what the bundle is actually rendering in
 * (`preferredLocalizations`), falling back to the process preferred languages.
 *
 * CAVEAT: writing `AppleLanguages` to [NSUserDefaults] persists the choice, but
 * `NSBundle.preferredLocalizations` (and hence anything reading the bundle's
 * effective localization) only picks it up on the NEXT launch — UIKit resolves
 * the bundle localization once at startup. The kept [SampleStrings] tables keyed
 * by the live chooser state are what update the visible UI immediately.
 */
internal actual object SampleLocaleController {

    private const val APPLE_LANGUAGES_KEY = "AppleLanguages"

    actual fun current(): SampleLanguage {
        // What the bundle resolved at launch; fall back to the user's preferred
        // languages if the bundle reports nothing (e.g. no localized resources).
        @Suppress("UNCHECKED_CAST")
        val bundleTag = (NSBundle.mainBundle.preferredLocalizations as List<String>?)
            ?.firstOrNull()
        @Suppress("UNCHECKED_CAST")
        val tag = bundleTag
            ?: (NSLocale.preferredLanguages as List<String>?)?.firstOrNull()
        return sampleLanguageForTag(tag)
    }

    actual fun apply(language: SampleLanguage) {
        // Persist into the app's own AppleLanguages default. Takes effect for
        // `preferredLocalizations` on the NEXT launch (see class caveat).
        val defaults = NSUserDefaults.standardUserDefaults
        defaults.setObject(listOf(localeTag(language)), forKey = APPLE_LANGUAGES_KEY)
        defaults.synchronize()
    }
}
