package ge.devtool.samples.android.regression

// Sheet and dialog units, each a step-for-step mirror of its .ds file in
// flows/samples/units/.

/** modals.ds */
internal fun RegressionSteps.modals() {
    ui.scrollUntilVisible("Modals", maxScrolls = 6)
    ui.tapOn("Modals")

    ui.tapOn("Partial sheet")
    ui.waitUntilVisible("Bottom sheet", timeoutMs = 10_000)
    ui.waitForAnimationToEnd()
    gesture.swipe(Direction.DOWN)
    ui.assertContainsText("Bottom sheet dismissed")
    ui.tapOn("Full sheet")
    ui.waitForAnimationToEnd()
    ui.scrollUntilVisible("Hide sheet", maxScrolls = 4)
    ui.tapOn("Hide sheet")
    ui.assertContainsText("Bottom sheet hidden with close action")
    ui.tapOn("Alert dialog")
    ui.waitUntilVisible("Session expired")
    ui.waitForAnimationToEnd()
    gesture.tapOnPoint(xPercent = 50, yPercent = 92)
    ui.waitUntilNotVisible("Session expired", timeoutMs = 10_000)
    ui.assertContainsText("Alert dialog dismissed")
    ui.tapOn("Fullscreen dialog")
    ui.waitUntilVisible("Fullscreen-like dialog")
    ui.waitForAnimationToEnd()
    gesture.tapOnPoint(xPercent = 50, yPercent = 92)
    ui.waitUntilNotVisible("Fullscreen-like dialog", timeoutMs = 10_000)
    ui.assertContainsText("Fullscreen dialog dismissed")
    ui.tapOn("Back")
    ui.waitUntilVisible("Sample Screens")
}

/** modals-swipes.ds */
internal fun RegressionSteps.modalsSwipes() {
    ui.scrollUntilVisible("Modals", maxScrolls = 6)
    ui.tapOn("Modals")
    ui.waitUntilVisible(
        "Open dialogs and sheets, then swipe down or dismiss to validate hide commands.",
        timeoutMs = 10_000,
    )
    ui.tapOn("Partial sheet")
    ui.waitUntilVisible("Bottom sheet", timeoutMs = 10_000)
    ui.waitForAnimationToEnd()
    gesture.swipe(Direction.DOWN)
    ui.assertContainsText("Bottom sheet dismissed")
    ui.tapOn("Full sheet")
    ui.waitUntilVisible("Bottom sheet", timeoutMs = 10_000)
    ui.waitForAnimationToEnd()
    gesture.swipe(from = ui.awaitText("Drag handle"), direction = Direction.DOWN)
    ui.assertContainsText("Bottom sheet dismissed")
    ui.tapOn("Back")
    ui.waitUntilVisible("Sample Screens")
}

/** modals-back.ds (with its `runIf: platform: android` block). */
internal fun RegressionSteps.modalsBack() {
    ui.scrollUntilVisible("Modals", maxScrolls = 6)
    ui.tapOn("Modals")
    ui.waitUntilVisible("Alert dialog")
    // runIf: platform: android
    ui.tapOn("Alert dialog")
    ui.waitUntilVisible("Session expired")
    ui.waitForAnimationToEnd()
    ui.back()
    ui.waitUntilNotVisible("Session expired", timeoutMs = 10_000)
    ui.assertContainsText("Alert dialog dismissed")
    ui.tapOn("Fullscreen dialog")
    ui.waitUntilVisible("Fullscreen-like dialog")
    ui.waitForAnimationToEnd()
    ui.back()
    ui.waitUntilNotVisible("Fullscreen-like dialog", timeoutMs = 10_000)
    ui.assertContainsText("Fullscreen dialog dismissed")
    // end runIf
    ui.back()
    ui.waitUntilVisible("Sample Screens")
}

/** modals-code-sheet.ds */
internal fun RegressionSteps.modalsCodeSheet() {
    ui.scrollUntilVisible("Modals", maxScrolls = 6)
    ui.tapOn("Modals")
    ui.tapOn("Code sheet")
    ui.tapOnId("sample.modals.verify.code")
    ui.inputText("1111")
    ui.tapOnId("sample.modals.verify.submit")
    ui.assertContainsText("Code verified: 1111")
    ui.tapOn("Back")
    ui.waitUntilVisible("Sample Screens")
}
