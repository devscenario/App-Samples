import XCTest

/// The modal, system and hybrid units: modals (four units), network, files, webview.
extension SampleRegressionUITests {
    // modals.ds
    func unitModals() {
        d.scrollUntilVisible("Modals", maxScrolls: 6)
        d.tap("Modals")
        d.tap("Partial sheet")
        d.waitUntilVisible("Bottom sheet", timeout: 10)
        d.waitForAnimationToEnd()
        d.swipe(.down)
        d.assertContainsText("Bottom sheet dismissed")
        d.tap("Full sheet")
        d.waitForAnimationToEnd()
        d.scrollUntilVisible("Hide sheet", maxScrolls: 4)
        d.tap("Hide sheet")
        d.assertContainsText("Bottom sheet hidden with close action")
        d.tap("Alert dialog")
        d.waitUntilVisible("Session expired")
        d.waitForAnimationToEnd()
        d.tapPoint(xPercent: 50, yPercent: 92)
        d.waitUntilNotVisible(.text("Session expired"), timeout: 10)
        d.assertContainsText("Alert dialog dismissed")
        d.tap("Fullscreen dialog")
        d.waitUntilVisible("Fullscreen-like dialog")
        d.waitForAnimationToEnd()
        d.tapPoint(xPercent: 50, yPercent: 92)
        d.waitUntilNotVisible(.text("Fullscreen-like dialog"), timeout: 10)
        d.assertContainsText("Fullscreen dialog dismissed")
        backToHome()
    }

    // modals-swipes.ds
    func unitModalsSwipes() {
        d.scrollUntilVisible("Modals", maxScrolls: 6)
        d.tap("Modals")
        d.waitUntilVisible("Open dialogs and sheets, then swipe down or dismiss to validate hide commands.", timeout: 10)
        d.tap("Partial sheet")
        d.waitUntilVisible("Bottom sheet", timeout: 10)
        d.waitForAnimationToEnd()
        d.swipe(.down)
        d.assertContainsText("Bottom sheet dismissed")
        d.tap("Full sheet")
        d.waitUntilVisible("Bottom sheet", timeout: 10)
        d.waitForAnimationToEnd()
        d.swipe(from: .text("Drag handle"), .down, duration: RegressionDriver.flickDuration)
        d.assertContainsText("Bottom sheet dismissed")
        backToHome()
    }

    // modals-back.ds (its dialog half is `runIf: platform: android`: not run on iOS)
    func unitModalsBack() {
        d.scrollUntilVisible("Modals", maxScrolls: 6)
        d.tap("Modals")
        d.waitUntilVisible("Alert dialog")
        d.back()
        d.waitUntilVisible("Sample Screens")
    }

    // modals-code-sheet.ds
    func unitModalsCodeSheet() {
        d.scrollUntilVisible("Modals", maxScrolls: 6)
        d.tap("Modals")
        d.tap("Code sheet")
        d.tap(.id("sample.modals.verify.code"))
        d.inputText("1111")
        d.tap(.id("sample.modals.verify.submit"))
        d.assertContainsText("Code verified: 1111")
        backToHome()
    }

    // network.ds
    func unitNetwork() {
        d.scrollUntilVisible("Network", maxScrolls: 6)
        d.tap("Network")
        d.waitUntilVisible("Dev Scenario interceptor demo", timeout: 10)
        d.waitUntilVisible(.textRegex("^Auto request (done|failed).*"), timeout: 20)
        d.tap("POST jsonplaceholder /posts")
        d.waitUntilVisible(.textRegex("^POST +POST /posts$"), timeout: 10)
        d.tap("GET → 404 (force error)")
        d.waitUntilVisible(.textRegex("^GET +GET → 404$"), timeout: 10)
        backToHome()
    }

    // files.ds (the `runIf: platform: ios` picker path)
    func unitFiles() {
        RegressionFilePusher.push(name: "dev-scenario-sample.txt", content: "Dev Scenario sample file", bundleId: bundleId)
        d.scrollUntilVisible("Files", maxScrolls: 6)
        d.tap("Files")
        d.tap("Pick file")
        d.waitUntilVisible(.id("DOC.browsingModeTabBar"), timeout: 15)
        // The file's cell if the picker already lists it, else after one Browse tap, else walk to
        // the app's folder. Each check looks once, without waiting.
        let file = d.element(.id("dev-scenario-sample, txt"))
        if !file.exists {
            d.tap("Browse")
            d.waitForAnimationToEnd(outOfProcess: true)
            if !file.exists {
                d.tap("Browse")
                d.waitForAnimationToEnd(outOfProcess: true)
                d.tap(.id("DOC.sidebar.item.On My iPhone"))
                d.waitUntilVisible(.id("Dev Scenario Sample, Container"), timeout: 10)
                d.tap(.id("Dev Scenario Sample, Container"))
            }
        }
        d.waitUntilVisible(.id("dev-scenario-sample, txt"), timeout: 15)
        d.waitForAnimationToEnd(outOfProcess: true)
        d.tap(.id("dev-scenario-sample, txt"))
        d.waitUntilVisible("Selected file: dev-scenario-sample.txt", timeout: 10)
        backToHome()
    }

    // webview.ds
    func unitWebView() {
        d.scrollUntilVisible("WebView", maxScrolls: 8)
        d.tap("WebView")
        d.waitUntilVisible("Web checkout", timeout: 15)
        d.assertVisible("Last web event: page loaded")
        d.tap("Email")
        d.inputText("qa@shop.com")
        d.tap("Promo code")
        d.inputText("spring10")
        d.tap("Apply code")
        d.assertVisible("Code SPRING10 applied")
        d.assertVisible("Last web event: Code SPRING10 applied")
        d.tap("I agree to the terms")
        d.tap("Pay now")
        d.assertVisible("Payment confirmed for qa@shop.com")
        d.assertVisible("Last web event: payment confirmed")
        d.tap("Terms")
        d.waitUntilVisible("Terms of service")
        d.assertVisible("Last web event: opened terms")
        d.tap("Back to checkout")
        d.waitUntilVisible("Web checkout")
        d.scrollUntilVisible("Footer reached", maxScrolls: 10)
        backToHome()
    }
}
