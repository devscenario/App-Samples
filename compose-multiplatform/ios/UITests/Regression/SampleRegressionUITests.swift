import XCTest

/// Native XCUITest mirror of Dev Scenario's "Sample regression" scenario
/// (`flows/samples/scenarios/Sample regression.scenario.json`): the same
/// 18 units, in the same order, step for step on their iOS path, in ONE app launch. Each unit ends
/// back on the home grid through its own Back steps, as the .ds units do. Used as the native baseline
/// on the benchmark page.
///
/// Target app: the UI-test target's own app, `ge.devtool.samples.ios.native` or, built
/// with `COMPOSE_SAMPLE` (the Compose sample), `ge.devtool.samples.ios`. `SAMPLE_BUNDLE_ID`
/// in the runner's environment (`TEST_RUNNER_SAMPLE_BUNDLE_ID=… xcodebuild test …`) overrides it.
final class SampleRegressionUITests: XCTestCase {
    static let composeBundleId = "ge.devtool.samples.ios"
    #if COMPOSE_SAMPLE
    static let defaultBundleId = composeBundleId
    #else
    static let defaultBundleId = "ge.devtool.samples.ios.native"
    #endif

    var d: RegressionDriver!
    var bundleId = SampleRegressionUITests.defaultBundleId

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testSampleRegression() {
        bundleId = ProcessInfo.processInfo.environment["SAMPLE_BUNDLE_ID"] ?? Self.defaultBundleId
        let app = XCUIApplication(bundleIdentifier: bundleId)
        d = RegressionDriver(app: app, composeUi: bundleId == Self.composeBundleId)

        // launch.ds's launchApp: outside the timed run, like the build, install and boot.
        let launchStart = RegressionClock.now()
        app.launch()
        let launchMs = RegressionClock.millis(since: launchStart)

        let clock = RegressionClock(only: ProcessInfo.processInfo.environment["REGRESSION_UNITS"])
        clock.start()
        clock.unit("launch.ds", unitLaunch)
        clock.unit("login.ds", unitLogin)
        clock.unit("registration.ds", unitRegistration)
        clock.unit("checkout.ds", unitCheckout)
        clock.unit("grid.ds", unitGrid)
        clock.unit("list.ds", unitList)
        clock.unit("search.ds", unitSearch)
        clock.unit("profile.ds", unitProfile)
        clock.unit("showcase.ds", unitShowcase)
        clock.unit("pinch.ds", unitPinch)
        clock.unit("drag-drop.ds", unitDragDrop)
        clock.unit("modals.ds", unitModals)
        clock.unit("modals-swipes.ds", unitModalsSwipes)
        clock.unit("modals-back.ds", unitModalsBack)
        clock.unit("modals-code-sheet.ds", unitModalsCodeSheet)
        clock.unit("network.ds", unitNetwork)
        clock.unit("files.ds", unitFiles)
        clock.unit("webview.ds", unitWebView)
        clock.report(bundleId: bundleId, launchMs: launchMs, testCase: self)
    }

    /// The steps every unit ends with: back to the start screen for the next unit.
    func backToHome() {
        d.tap("Back")
        d.waitUntilVisible("Sample Screens")
    }

    // launch.ds (its launchApp is `app.launch()` above)
    func unitLaunch() {
        d.waitUntilVisible("Sample Screens", timeout: 15)
    }
}
