import XCTest

/// XCUITest version of the same login flow the in-app SDK driver runs.
/// Acts as a benchmark for the "is XCUITest slow?" question and a
/// reference for what's reachable via the system accessibility daemon
/// (out-of-process) that the in-app SDK can't see in-process.
///
/// Mirrors the sample's login flow:
///   launchApp → home grid visible → tap Login cell → Welcome back →
///   type email → type password → tap Remember me → tap Sign in →
///   success status visible.
final class LoginUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testLoginFlow() throws {
        let totalStart = Date()
        let app = XCUIApplication()
        let launchStart = Date()
        app.launch()
        let launchMs = elapsedMs(launchStart)

        // Home grid — nav title lives in navigationBars, not staticTexts.
        let home = app.navigationBars["Sample Screens"]
        let homeStart = Date()
        XCTAssertTrue(home.waitForExistence(timeout: 4))
        let homeMs = elapsedMs(homeStart)

        // Tap Login cell. `HomeCellButton` is a `UIButton` subclass with
        // `accessibilityIdentifier = "sample.tab.login"`.
        let loginCell = app.buttons["sample.tab.login"]
        let cellTapStart = Date()
        XCTAssertTrue(loginCell.waitForExistence(timeout: 3),
                      "Cell not found. App tree:\n\(app.debugDescription)")
        loginCell.tap()
        let cellTapMs = elapsedMs(cellTapStart)

        // Wait for the Welcome back title on the pushed Login screen
        let welcomeStart = Date()
        let welcome = app.staticTexts["Welcome back"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 3))
        let welcomeMs = elapsedMs(welcomeStart)

        // Type into Email
        let email = app.textFields["sample.login.email"]
        let emailStart = Date()
        email.tap()
        email.typeText("qa@example.com")
        let emailMs = elapsedMs(emailStart)
        XCTAssertEqual(email.value as? String, "qa@example.com")

        // Type into Password
        let password = app.secureTextFields["sample.login.password"]
        let pwStart = Date()
        password.tap()
        password.typeText("Pass1234")
        let pwMs = elapsedMs(pwStart)

        // Tap the Remember-me row. The label is non-interactive
        // (`userInteractionEnabled = NO`) but `LoginViewController` adds a
        // `UITapGestureRecognizer` to the surrounding `UIStackView` that
        // flips the switch when the row is tapped. Assert the switch
        // actually transitioned from off → on so a future regression on
        // that recognizer fails this test instead of silently passing.
        let rememberLabel = app.staticTexts["Remember me"]
        let rememberSwitch = app.switches["sample.login.remember"]
        XCTAssertEqual(rememberSwitch.value as? String, "0", "switch should start off")
        let rememberStart = Date()
        XCTAssertTrue(rememberLabel.waitForExistence(timeout: 2))
        rememberLabel.tap()
        let rememberMs = elapsedMs(rememberStart)
        XCTAssertEqual(rememberSwitch.value as? String, "1",
                       "tapping the label area must toggle the switch")

        // Tap Sign in
        let signIn = app.buttons["Sign in"]
        let signInStart = Date()
        signIn.tap()
        let signInMs = elapsedMs(signInStart)

        let success = app.staticTexts["Login success for qa@example.com"]
        let successStart = Date()
        XCTAssertTrue(success.waitForExistence(timeout: 5))
        let successMs = elapsedMs(successStart)

        let totalMs = elapsedMs(totalStart)
        print("""
        =====================================================
        XCUITest LoginFlow timings (ms)
          launch:                \(launchMs)
          home grid visible:     \(homeMs)
          tap Login cell:        \(cellTapMs)
          Welcome back visible:  \(welcomeMs)
          tap+type email:        \(emailMs)
          tap+type password:     \(pwMs)
          tap Remember me:       \(rememberMs)
          tap Sign in:           \(signInMs)
          success label visible: \(successMs)
          --------------------------------------------
          TOTAL:                 \(totalMs)
        =====================================================
        """)
    }

    private func elapsedMs(_ start: Date) -> Int {
        Int(Date().timeIntervalSince(start) * 1000)
    }
}
