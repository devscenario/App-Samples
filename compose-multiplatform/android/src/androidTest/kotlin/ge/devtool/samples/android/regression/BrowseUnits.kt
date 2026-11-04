package ge.devtool.samples.android.regression

// Lazy grid / list units, each a step-for-step mirror of its .ds file in
// flows/samples/units/.

/** grid.ds */
internal fun RegressionSteps.grid() = with(ui) {
    waitUntilVisible("Grid", timeoutMs = 10_000)
    tapOn("Grid")
    waitUntilVisible("Product 1", timeoutMs = 10_000)
    scrollUntilVisible("Product 5", maxScrolls = 3)
    assertVisible("Product 5")
    tapOn("Product 5")
    assertVisible("Product details")
    assertVisible("Selected Product 5")
    assertVisible("Price: $31.99")
    tapOn("Back")
    waitUntilVisible("Sample Screens")
}

/** list.ds */
internal fun RegressionSteps.list() = with(ui) {
    waitUntilVisible("List", timeoutMs = 10_000)
    tapOn("List")
    waitUntilVisible("Order #1001", timeoutMs = 10_000)
    tapOn("Order #1001")
    assertVisible("Order details")
    assertVisible("Selected Order #1001")
    assertVisible("Total: $42.00")
    // A fast swipe flings past the target in this list: scroll slowly, as the .ds unit does.
    scrollUntilVisible("Order #1008", maxScrolls = 8, durationMs = 600)
    assertVisible("Order #1008")
    tapOn("Back")
    waitUntilVisible("Sample Screens")
}
