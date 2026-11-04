import XCTest

/// The .ds commands the sample regression uses, on XCUITest, with Dev Scenario's iOS semantics:
/// selector taps hit the element's centre, typing goes to the focused element, "visible" means the
/// element is in the accessibility tree, and the waits use the driver's timeouts. Gestures are in
/// `RegressionDriver+Gestures.swift`.
final class RegressionDriver {
    /// The driver's default wait for assertions and selector taps (`DEFAULT_WAIT_TIMEOUT_MS`).
    static let defaultWait: TimeInterval = 5
    /// `waitUntilVisible` without a timeout (`EXPLICIT_WAIT_FLOOR_MS`).
    static let explicitWait: TimeInterval = 10

    let app: XCUIApplication
    /// The Compose sample: XCUITest's idle sync doesn't cover its animations or flings, and it gets
    /// the one-finger pinch (see `pinch(on:inward:)`).
    let composeUi: Bool
    /// Set by typing: only then can the keyboard cover a tap target.
    private var keyboardMayBeUp = false
    /// When the last swipe or drag ended: a tap soon after it waits for its target to stop moving.
    var lastMotion = Date.distantPast

    init(app: XCUIApplication, composeUi: Bool) {
        self.app = app
        self.composeUi = composeUi
    }

    // MARK: Queries

    func element(_ selector: RegressionSelector) -> XCUIElement {
        app.descendants(matching: .any).matching(selector.predicate).firstMatch
    }

    func require(
        _ selector: RegressionSelector,
        timeout: TimeInterval = RegressionDriver.defaultWait,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCUIElement {
        let match = element(selector)
        if !poll(timeout: timeout, until: { match.exists }) {
            XCTFail("iOS element not visible: \(selector)", file: file, line: line)
        }
        return match
    }

    // MARK: Taps and text

    /// `tapOn: <selector>`: waits for the element, dismisses the keyboard when it covers the
    /// element, then taps the element's centre (no scrolling into view, like the driver). The tap
    /// goes to a screen coordinate from one frame read: an element-relative coordinate re-resolves
    /// the element several times while the tap is synthesized.
    func tap(_ selector: RegressionSelector, file: StaticString = #filePath, line: UInt = #line) {
        let target = require(selector, file: file, line: line)
        if keyboardMayBeUp { dismissKeyboardIfCovering(target) }
        if composeUi && Date().timeIntervalSince(lastMotion) < 3 { waitUntilStill(target) }
        let frame = target.frame
        point(x: frame.midX, y: frame.midY).tap()
    }

    func tap(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        tap(.text(text), file: file, line: line)
    }

    /// `tapOn: { point: "x%,y%" }`: a point relative to the app's frame.
    func tapPoint(xPercent: Double, yPercent: Double) {
        point(x: app.frame.width * xPercent / 100, y: app.frame.height * yPercent / 100).tap()
    }

    /// `inputText`: types into whatever has focus, as the driver does.
    func inputText(_ text: String) {
        app.typeText(text)
        keyboardMayBeUp = true
    }

    // MARK: Waits and assertions

    /// `assertVisible`: the element appears within the default wait.
    func assertVisible(_ selector: RegressionSelector, file: StaticString = #filePath, line: UInt = #line) {
        _ = require(selector, file: file, line: line)
    }

    func assertVisible(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        assertVisible(.text(text), file: file, line: line)
    }

    /// `waitFor`, with the unit's timeout or the driver's explicit-wait default.
    func waitUntilVisible(
        _ selector: RegressionSelector,
        timeout: TimeInterval = RegressionDriver.explicitWait,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        _ = require(selector, timeout: timeout, file: file, line: line)
    }

    func waitUntilVisible(
        _ text: String,
        timeout: TimeInterval = RegressionDriver.explicitWait,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        waitUntilVisible(.text(text), timeout: timeout, file: file, line: line)
    }

    /// `waitUntilNotVisible`: the element leaves the tree within the timeout.
    func waitUntilNotVisible(
        _ selector: RegressionSelector,
        timeout: TimeInterval = RegressionDriver.explicitWait,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let match = element(selector)
        if !poll(timeout: timeout, until: { !match.exists }) {
            XCTFail("iOS element still visible: \(selector)", file: file, line: line)
        }
    }

    /// `assertContainsText`: some element's text contains it (case-insensitive) within the default wait.
    func assertContainsText(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        let match = element(.containsText(text))
        if !poll(timeout: RegressionDriver.defaultWait, until: { match.exists }) {
            XCTFail("Text not found in iOS UI hierarchy: '\(text)'", file: file, line: line)
        }
    }

    /// `assertNotChecked`: polls until the element is neither selected nor a switch whose value is
    /// `1` (`IosWdaNode.checked`), within the default wait.
    func assertNotChecked(_ selector: RegressionSelector, file: StaticString = #filePath, line: UInt = #line) {
        let target = require(selector, file: file, line: line)
        if !poll(timeout: RegressionDriver.defaultWait, until: { !isChecked(target) }) {
            XCTFail("Element is checked/selected but should not be: \(selector)", file: file, line: line)
        }
    }

    /// `waitForAnimationToEnd`: XCUITest's own idle sync, which every query and action already waits
    /// for, covers the SwiftUI/UIKit sample's animations, so there it adds nothing. It doesn't cover
    /// Compose animations (a full sheet opens part-way, pauses, then expands) or a screen drawn by
    /// another process (`outOfProcess`, the system file picker): there it waits until three
    /// screenshots in a row match (about 0.25 s of stillness), capped at 3 s.
    func waitForAnimationToEnd(outOfProcess: Bool = false) {
        guard composeUi || outOfProcess else { return }
        let deadline = Date().addingTimeInterval(3)
        var previous = XCUIScreen.main.screenshot().pngRepresentation
        var still = 0
        while still < 3 && Date() < deadline {
            let next = XCUIScreen.main.screenshot().pngRepresentation
            still = next == previous ? still + 1 : 0
            previous = next
        }
    }

    // MARK: Helpers

    /// Checks `condition` right away, then every 50 ms (the WDA runner's `/waitFor` cadence) until it
    /// holds or `timeout` passes. `waitForExistence` isn't used: it checks first only after ~1 s.
    func poll(timeout: TimeInterval, until condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while true {
            if condition() { return true }
            if Date() >= deadline { return false }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
    }

    func point(x: CGFloat, y: CGFloat) -> XCUICoordinate {
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: x, dy: y))
    }

    /// The tap settle after a recent swipe on the Compose sample: the target's frame is re-read every
    /// 50 ms until two reads in a row match the one before (capped at 3 s). A tap during scroll
    /// momentum only stops the scroll, and XCUITest's idle wait doesn't cover a Compose fling.
    private func waitUntilStill(_ target: XCUIElement) {
        let deadline = Date().addingTimeInterval(3)
        var previous = target.frame
        var still = 0
        while still < 2 && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            let next = target.frame
            still = next.equalTo(previous) ? still + 1 : 0
            previous = next
        }
    }

    private func isChecked(_ element: XCUIElement) -> Bool {
        if element.isSelected { return true }
        let checkable: Set<XCUIElement.ElementType> = [.switch, .toggle, .checkBox]
        return checkable.contains(element.elementType) && (element.value as? String) == "1"
    }

    /// The driver's keyboard handling: a target under the keyboard's top edge gets the keyboard
    /// dismissed first (a submit key, else a drag down across its top edge, else a tap above it).
    private func dismissKeyboardIfCovering(_ target: XCUIElement) {
        let keyboard = app.keyboards.firstMatch
        guard keyboard.exists else {
            keyboardMayBeUp = false
            return
        }
        guard target.frame.maxY > keyboard.frame.minY else { return }
        let submitLabels = ["return", "done", "go", "search", "send", "next", "continue", "join",
                            "hide keyboard", "dismiss keyboard", "hidekeyboard"]
        let submit = keyboard.buttons.matching(NSPredicate(format: "label IN[c] %@", submitLabels)).firstMatch
        if submit.exists && submit.isHittable { submit.tap() }
        if keyboard.exists {
            let frame = keyboard.frame
            point(x: frame.midX, y: frame.minY - 24).press(
                forDuration: 0.05, thenDragTo: point(x: frame.midX, y: frame.maxY - 4)
            )
        }
        if keyboard.exists {
            point(x: keyboard.frame.midX, y: max(keyboard.frame.minY - 24, 60)).tap()
        }
        keyboardMayBeUp = keyboard.exists
    }
}
