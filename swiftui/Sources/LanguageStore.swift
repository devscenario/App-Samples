import Combine
import Foundation

#if canImport(DevScenarioAppInstrumentation)
import DevScenarioAppInstrumentation
#endif

/// Single source of truth for the in-app language toggle, shared by the UIKit
/// home grid + Storyboard controllers AND the SwiftUI detail screens.
///
/// - SwiftUI screens observe it as an `ObservableObject` via `@ObservedObject`
///   (`store.strings.*` re-renders when `language` changes).
/// - UIKit observes it via the Combine `$language` publisher (or the
///   `languageDidChange` notification) to refresh nav titles + the grid.
///
/// The initial value is derived from the OS-recommended locale
/// (`Bundle.main.preferredLocalizations.first`, with `Locale` fallbacks) — the
/// OS is the source of truth for which language to launch in, so there is no
/// custom read key. On change we write the OS per-app locale store
/// (`AppleLanguages` in `UserDefaults`) so the choice survives — and is honored
/// by the system — on the next launch.
///
/// An unrecognized / non-Georgian OS locale falls back to `.english`, so
/// existing E2E flows and the XCUITest parity tests (which assert on English
/// copy) keep passing.
final class LanguageStore: ObservableObject {

    /// Shared singleton so UIKit and SwiftUI read/write the same state.
    static let shared = LanguageStore()

    /// Posted after `language` changes so non-SwiftUI observers (the home
    /// grid, Storyboard controllers) can refresh their `UIView` content.
    static let languageDidChange = Notification.Name("ge.devtool.samples.languageDidChange")

    /// OS per-app locale store key. Writing `[tag]` here makes the system
    /// launch the app in that language on the *next* launch.
    private static let appleLanguagesKey = "AppleLanguages"

    @Published var language: SampleLanguage {
        didSet {
            guard oldValue != language else { return }
            // Persist to the OS-recommended locale store. NOTE: this only takes
            // effect — i.e. `Bundle.main.preferredLocalizations` only reflects
            // the new value — on the NEXT launch. The live UI this session is
            // driven entirely by the in-memory `@Published language` + the
            // `SampleStrings` tables below, refreshed via the publisher /
            // `languageDidChange` notification.
            UserDefaults.standard.set([language.localeTag], forKey: Self.appleLanguagesKey)
            UserDefaults.standard.synchronize()
            // Report the live in-app language to the Dev Scenario SDK so E2E
            // translation auto-detection tracks the *custom* string-table switch
            // this session (the bundle's `.lproj` only updates next launch).
            reportLocaleToDevScenario()
            NotificationCenter.default.post(name: Self.languageDidChange, object: self)
        }
    }

    /// Active string table derived from `language`. SwiftUI views read this
    /// through the observed object; UIKit reads it on each refresh pass.
    var strings: SampleStrings {
        switch language {
        case .english: return EnStrings()
        case .georgian: return KaStrings()
        }
    }

    private init() {
        // Derive the launch language from the OS-recommended locale. Locale is
        // the source of truth, so there is no custom read key. A `ka`-prefixed
        // tag → Georgian; anything else (including no locale) → English.
        language = SampleLanguage(localeTag: Self.osLocaleTag)
        // Seed the Dev Scenario SDK with the launch language so the in-app locale is
        // reportable before any toggle.
        reportLocaleToDevScenario()
    }

    /// Push the active language's BCP-47 tag to the Dev Scenario in-app SDK (no-op
    /// when the SDK isn't linked — i.e. release builds).
    private func reportLocaleToDevScenario() {
        #if canImport(DevScenarioAppInstrumentation)
        DevScenarioAppInstrumentation.setReportedLocale(language.localeTag)
        #endif
    }

    /// Best-available OS locale tag: the bundle's resolved localization first
    /// (this is the value the system actually launched the app with), then the
    /// raw `Locale` preferences as fallbacks.
    private static var osLocaleTag: String {
        if let resolved = Bundle.main.preferredLocalizations.first {
            return resolved
        }
        // Fallbacks (effectively unreachable since the bundle always resolves a
        // localization). `Locale.current.languageCode` is back-deployable to the
        // iOS 15 minimum; the iOS 16 `language.languageCode?.identifier` form
        // would not compile here.
        return Locale.current.languageCode
            ?? Locale.preferredLanguages.first
            ?? "en"
    }
}

private extension SampleLanguage {

    /// BCP-47-ish tag written into the `AppleLanguages` OS store.
    var localeTag: String {
        switch self {
        case .english: return "en"
        case .georgian: return "ka"
        }
    }

    /// Maps an OS locale tag to a `SampleLanguage`: a `ka`-prefixed tag (e.g.
    /// `ka`, `ka-GE`) → `.georgian`, everything else → `.english`.
    init(localeTag tag: String) {
        self = tag.lowercased().hasPrefix("ka") ? .georgian : .english
    }
}
