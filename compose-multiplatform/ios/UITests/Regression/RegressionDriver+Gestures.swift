import XCTest

/// Swipes, scrolls, the system back, drag and drop and pinch, with the start and end points of Dev
/// Scenario's iOS driver (`IosGestureExecutor`). The movement itself is XCUITest's own
/// `press(forDuration:thenDragTo:withVelocity:thenHoldForDuration:)` and `pinch(withScale:velocity:)`,
/// timed for speed: the shortest press, drag and hold each gesture needs, not the driver's timing.
extension RegressionDriver {
    enum Direction { case up, down, left, right }

    /// The driver's default swipe duration (`DEFAULT_SWIPE_DURATION_SECONDS`).
    static let swipeDuration: TimeInterval = 0.35
    /// A quick flick for the two swipes that hand over to a system or sheet gesture (`back`, a sheet's
    /// drag handle). XCUITest's press-then-drag brings the finger to rest before lifting, so a slow
    /// drag ends too slowly to complete the gesture (at 0.35 s they worked only part of the time).
    static let flickDuration: TimeInterval = 0.1
    /// The `duration: 150` the regression's `scrollUntilVisible` steps ask for.
    static let fastScrollDuration: TimeInterval = 0.15

    /// `scroll` with no arguments, and each `scrollUntilVisible` step: a swipe up from 80% to 20% of
    /// the screen height, at mid-width.
    func scroll(duration: TimeInterval = RegressionDriver.swipeDuration) {
        let frame = app.frame
        drag(from: (frame.midX, frame.height * 0.8), to: (frame.midX, frame.height * 0.2), duration: duration)
    }

    /// `swipe: <direction>` (no anchor): from the screen centre to 5% from that edge.
    func swipe(_ direction: Direction) {
        swipe(fromPoint: (app.frame.midX, app.frame.midY), direction)
    }

    /// `swipe: { from: <selector>, direction: … }`: from the element's centre to 5% from the edge.
    func swipe(
        from selector: RegressionSelector,
        _ direction: Direction,
        duration: TimeInterval = RegressionDriver.swipeDuration,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let anchor = require(selector, file: file, line: line).frame
        swipe(fromPoint: (anchor.midX, anchor.midY), direction, duration: duration)
    }

    private func swipe(
        fromPoint start: (CGFloat, CGFloat),
        _ direction: Direction,
        duration: TimeInterval = RegressionDriver.swipeDuration
    ) {
        let frame = app.frame
        switch direction {
        case .up: drag(from: start, to: (start.0, frame.height * 0.05), duration: duration)
        case .down: drag(from: start, to: (start.0, frame.height * 0.95), duration: duration)
        case .left: drag(from: start, to: (frame.width * 0.05, start.1), duration: duration)
        case .right: drag(from: start, to: (frame.width * 0.95, start.1), duration: duration)
        }
    }

    /// `scroll: { from: <text>, direction: … }`: scroll geometry (start at the anchor or the 20% inset,
    /// whichever is further along) from the first element with that text (else containing it).
    func scroll(from text: String, _ direction: Direction, file: StaticString = #filePath, line: UInt = #line) {
        var anchorElement = element(.text(text))
        if !anchorElement.exists { anchorElement = element(.containsText(text)) }
        guard anchorElement.exists else {
            XCTFail("Scroll origin selector is not visible: text \"\(text)\"", file: file, line: line)
            return
        }
        let anchor = anchorElement.frame, frame = app.frame
        let x = min(max(anchor.midX, 0), frame.width), y = min(max(anchor.midY, 0), frame.height)
        let left = frame.width * 0.2, right = frame.width * 0.8
        let top = frame.height * 0.2, bottom = frame.height * 0.8
        switch direction {
        case .up: drag(from: (x, max(y, bottom)), to: (x, top))
        case .down: drag(from: (x, min(y, top)), to: (x, bottom))
        case .left: drag(from: (max(x, right), y), to: (left, y))
        case .right: drag(from: (min(x, left), y), to: (right, y))
        }
    }

    /// `scrollUntilVisible` (direction UP, no anchor): up to `maxScrolls` swipes up across the middle
    /// 60% of the screen, each lasting `duration`, until the element is in the tree with its centre
    /// on screen.
    func scrollUntilVisible(
        _ selector: RegressionSelector,
        maxScrolls: Int,
        duration: TimeInterval = RegressionDriver.fastScrollDuration,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for _ in 0..<maxScrolls {
            if isOnScreen(selector) { return }
            scroll(duration: duration)
        }
        if !isOnScreen(selector) {
            XCTFail("Element not found after \(maxScrolls) scrolls: \(selector)", file: file, line: line)
        }
    }

    func scrollUntilVisible(
        _ text: String,
        maxScrolls: Int,
        duration: TimeInterval = RegressionDriver.fastScrollDuration,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        scrollUntilVisible(.text(text), maxScrolls: maxScrolls, duration: duration, file: file, line: line)
    }

    /// `back` on iOS: a swipe from the left edge, at mid-height, to 60% of the width, as a flick
    /// (`flickDuration`).
    func back() {
        let frame = app.frame
        drag(from: (0, frame.midY), to: (frame.width * 0.6, frame.midY), duration: RegressionDriver.flickDuration)
    }

    /// `dragAndDrop` (the unit's 40 ms): both samples pick an item up on touch-down (a drag gesture,
    /// not a long-press drag session) and drop it where the touch lifts, so it is the shortest
    /// press-then-drag that works on both: a 0.05 s press, a fast drag and a 0.05 s hold on the target.
    func dragAndDrop(_ from: String, to target: String, file: StaticString = #filePath, line: UInt = #line) {
        let start = require(.text(from), file: file, line: line).frame
        let end = require(.text(target), file: file, line: line).frame
        point(x: start.midX, y: start.midY).press(
            forDuration: 0.05,
            thenDragTo: point(x: end.midX, y: end.midY),
            withVelocity: XCUIGestureVelocity(1500),
            thenHoldForDuration: 0.05
        )
        lastMotion = Date()
    }

    /// `pinchIn` (`inward` true) / `pinchOut`: XCUITest's own two-finger pinch on `selector`, as a
    /// person pinches in a photo viewer. `pinchIn` brings the fingers together (zoom out), `pinchOut`
    /// spreads them (zoom in).
    func pinch(on selector: RegressionSelector, inward: Bool, file: StaticString = #filePath, line: UInt = #line) {
        let target = require(selector, file: file, line: line)
        target.pinch(withScale: inward ? 0.5 : 2, velocity: inward ? -8 : 8)
        lastMotion = Date()
    }

    // MARK: Helpers

    /// One-finger drag from `start` to `end`: a 0.05 s touch-down, then XCUITest's press-then-drag at
    /// distance / `duration`, with no hold at the end. XCUITest decides the touch path; it is not the
    /// driver's timed 60 Hz path.
    func drag(from start: (CGFloat, CGFloat), to end: (CGFloat, CGFloat), duration: TimeInterval = RegressionDriver.swipeDuration) {
        let distance = hypot(end.0 - start.0, end.1 - start.1)
        point(x: start.0, y: start.1).press(
            forDuration: 0.05,
            thenDragTo: point(x: end.0, y: end.1),
            withVelocity: XCUIGestureVelocity(max(distance / CGFloat(duration), 1)),
            thenHoldForDuration: 0
        )
        lastMotion = Date()
    }

    private func isOnScreen(_ selector: RegressionSelector) -> Bool {
        let match = element(selector)
        guard match.exists else { return false }
        let frame = match.frame
        return app.frame.contains(CGPoint(x: frame.midX, y: frame.midY))
    }
}
