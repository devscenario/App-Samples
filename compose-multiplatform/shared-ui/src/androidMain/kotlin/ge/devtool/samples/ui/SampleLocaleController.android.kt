package ge.devtool.samples.ui

import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import java.util.Locale

/**
 * Android `actual`: drives the **AndroidX per-app locale** via
 * [AppCompatDelegate]. This is the platform-recommended mechanism for an in-app
 * language switch and is exactly what the devtool's `AppLanguageDetector` reads
 * back over `cmd locale get-app-locales <appId>`.
 *
 * `AppCompatDelegate.setApplicationLocales(...)` persists the choice itself
 * (AppCompat-backed storage on API < 33, the framework per-app locale on API
 * 33+) and recreates the visible activities to apply it — so no custom
 * preference key is needed. For this to take effect the host Activity must be an
 * `AppCompatActivity` with an AppCompat theme (see `compose-multiplatform/android`).
 */
internal actual object SampleLocaleController {

    actual fun current(): SampleLanguage {
        // Prefer the AppCompat per-app override (the value we set + what the
        // detector observes); fall back to the process default locale.
        val tag = AppCompatDelegate.getApplicationLocales()
            .takeUnless { it.isEmpty }
            ?.get(0)
            ?.language
            ?: Locale.getDefault().language
        return sampleLanguageForTag(tag)
    }

    actual fun apply(language: SampleLanguage) {
        // Recreates the foreground activity to apply the new locale; SampleApp's
        // `current()` re-seed on the recreated composition keeps UI + OS in sync.
        AppCompatDelegate.setApplicationLocales(
            LocaleListCompat.forLanguageTags(localeTag(language)),
        )
    }
}
