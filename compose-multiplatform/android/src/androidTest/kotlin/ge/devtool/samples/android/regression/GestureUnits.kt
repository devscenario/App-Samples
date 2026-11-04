package ge.devtool.samples.android.regression

// Gesture units, each a step-for-step mirror of its .ds file in
// flows/samples/units/.

/** showcase.ds */
internal fun RegressionSteps.showcase() {
    ui.waitUntilVisible("Grid", timeoutMs = 10_000)
    gesture.scroll(from = "Grid", direction = Direction.LEFT)
    ui.waitUntilVisible("Showcase", timeoutMs = 10_000)
    ui.tapOn("Showcase")
    ui.waitUntilVisible("Component Showcase", timeoutMs = 10_000)
    ui.tapOn("Enable notifications")
    ui.assertNotChecked(id = "sample.showcase.switch")
    ui.assertVisibleId("sample.showcase.progress")
    gesture.swipe(from = ui.awaitId("sample.showcase.slider"), direction = Direction.RIGHT)
    gesture.scroll()
    ui.assertVisible("End of screen")
    ui.tapOn("Back")
    ui.waitUntilVisible("Sample Screens")
}

/** pinch.ds */
internal fun RegressionSteps.pinch() {
    ui.scrollUntilVisible("Pinch", maxScrolls = 6)
    ui.tapOn("Pinch")
    ui.waitUntilVisible("Pinch Playground", timeoutMs = 10_000)
    gesture.pinchIn()
    ui.assertContainsText("last: zoom out")
    gesture.pinchOut()
    ui.assertContainsText("last: zoom in")
    ui.tapOn("Back")
    ui.waitUntilVisible("Sample Screens")
}

/** drag-drop.ds */
internal fun RegressionSteps.dragDrop() {
    ui.scrollUntilVisible("Drag & Drop", maxScrolls = 6)
    ui.tapOn("Drag & Drop")
    gesture.dragAndDrop(from = "Alpha", to = "Drop Zone", durationMs = 40)
    ui.assertContainsText("Alpha dropped in zone")
    gesture.dragAndDrop(from = "Beta", to = "Drop Zone", durationMs = 40)
    ui.assertContainsText("Beta dropped in zone")
    gesture.dragAndDrop(from = "Gamma", to = "Drop Zone", durationMs = 40)
    ui.assertContainsText("Gamma dropped in zone")
    gesture.dragAndDrop(from = "Row One", to = "Row Two", durationMs = 40)
    ui.assertContainsText("moved")
    gesture.dragAndDrop(from = "Row Three", to = "Row Two", durationMs = 40)
    ui.assertContainsText("moved")
    ui.tapOn("Back")
    ui.waitUntilVisible("Sample Screens")
}
