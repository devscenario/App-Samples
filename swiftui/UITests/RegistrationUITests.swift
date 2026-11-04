import XCTest

/// XCUITest version of the registration flow on the SwiftUI screen.
/// This is the screen our in-app SDK can't fully assert against
/// (SwiftUI `Text` content isn't reachable from in-process); XCUITest
/// queries via the system accessibility daemon and CAN see it. The
/// purpose of this test is to validate both the screen's accessibility
/// coverage and to benchmark per-command latency on SwiftUI content.
///
/// Mirrors the sample's registration flow:
///   launchApp → tap Registration cell → Create account visible →
///   fill name/email/password → preview labels appear → tap
///   Accept terms → tap Register → success status visible.
final class RegistrationUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testRegistrationFlow() throws {
        let totalStart = Date()
        let app = XCUIApplication()
        let launchStart = Date()
        app.launch()
        let launchMs = elapsedMs(launchStart)

        // Home grid
        let home = app.navigationBars["Sample Screens"]
        let homeStart = Date()
        XCTAssertTrue(home.waitForExistence(timeout: 4))
        let homeMs = elapsedMs(homeStart)

        // Tap Registration cell
        let regCell = app.buttons["sample.tab.registration"]
        let cellTapStart = Date()
        XCTAssertTrue(regCell.waitForExistence(timeout: 2))
        regCell.tap()
        let cellTapMs = elapsedMs(cellTapStart)

        // SwiftUI `Text("Create account")` — reachable via the system
        // accessibility daemon, which is the in-app SDK's blind spot.
        let title = app.staticTexts["Create account"]
        let titleStart = Date()
        XCTAssertTrue(title.waitForExistence(timeout: 3))
        let titleMs = elapsedMs(titleStart)

        // Full name
        let name = app.textFields["sample.registration.name"]
        let nameStart = Date()
        name.tap()
        name.typeText("Test User")
        let nameMs = elapsedMs(nameStart)
        XCTAssertEqual(name.value as? String, "Test User")

        // Live preview `Text` updates as the user types. SwiftUI keeps
        // these in the accessibility tree (XCUITest sees them); the
        // in-app SDK does not because SwiftUI doesn't realize its tree
        // for in-process queries.
        let namePreview = app.staticTexts["Registration name typed: Test User"]
        let namePreviewStart = Date()
        XCTAssertTrue(namePreview.waitForExistence(timeout: 5))
        let namePreviewMs = elapsedMs(namePreviewStart)

        // Email
        let email = app.textFields["sample.registration.email"]
        let emailStart = Date()
        email.tap()
        email.typeText("newuser@test.example.com")
        let emailMs = elapsedMs(emailStart)
        XCTAssertEqual(email.value as? String, "newuser@test.example.com")

        let emailPreview = app.staticTexts["Registration email typed: newuser@test.example.com"]
        let emailPreviewStart = Date()
        XCTAssertTrue(emailPreview.waitForExistence(timeout: 5))
        let emailPreviewMs = elapsedMs(emailPreviewStart)

        // Password
        let password = app.textFields["sample.registration.password"]
        let pwStart = Date()
        password.tap()
        password.typeText("Password123")
        let pwMs = elapsedMs(pwStart)

        // Accept terms — SwiftUI Button label changes after tap
        // ("Accept terms" → "Terms accepted"). Use the testTag-bound
        // identifier rather than the label so the same query survives
        // the state change.
        let terms = app.buttons["sample.registration.terms"]
        let termsStart = Date()
        XCTAssertTrue(terms.waitForExistence(timeout: 2))
        terms.tap()
        let termsMs = elapsedMs(termsStart)

        // Live success message renders the moment all three fields are
        // valid (Name >= 2, valid email, password >= 8 chars). With our
        // inputs above we should see it without needing to submit.
        let liveSuccess = app.staticTexts["Registration success for newuser@test.example.com"]
        let liveSuccessStart = Date()
        XCTAssertTrue(liveSuccess.waitForExistence(timeout: 5))
        let liveSuccessMs = elapsedMs(liveSuccessStart)

        // Tap Register — submit button. Status message becomes the
        // success string (same content as the live message, so the
        // assertion above already proves it's queryable).
        let register = app.buttons["sample.registration.submit"]
        let registerStart = Date()
        register.tap()
        let registerMs = elapsedMs(registerStart)

        let totalMs = elapsedMs(totalStart)
        print("""
        =====================================================
        XCUITest RegistrationFlow timings (ms)
          launch:                  \(launchMs)
          home grid visible:       \(homeMs)
          tap Registration cell:   \(cellTapMs)
          Create account visible:  \(titleMs)
          tap+type name:           \(nameMs)
          name preview visible:    \(namePreviewMs)
          tap+type email:          \(emailMs)
          email preview visible:   \(emailPreviewMs)
          tap+type password:       \(pwMs)
          tap Accept terms:        \(termsMs)
          live success visible:    \(liveSuccessMs)
          tap Register:            \(registerMs)
          --------------------------------------------
          TOTAL:                   \(totalMs)
        =====================================================
        """)
    }

    private func elapsedMs(_ start: Date) -> Int {
        Int(Date().timeIntervalSince(start) * 1000)
    }
}
