import XCTest

/// The browsing and gesture units: grid, list, showcase, pinch, drag and drop.
extension SampleRegressionUITests {
    // grid.ds
    func unitGrid() {
        d.waitUntilVisible("Grid", timeout: 10)
        d.tap("Grid")
        d.waitUntilVisible("Product 1", timeout: 10)
        d.scrollUntilVisible("Product 5", maxScrolls: 3)
        d.assertVisible("Product 5")
        d.tap("Product 5")
        d.assertVisible("Product details")
        d.assertVisible("Selected Product 5")
        d.assertVisible("Price: $31.99")
        backToHome()
    }

    // list.ds
    func unitList() {
        d.waitUntilVisible("List", timeout: 10)
        d.tap("List")
        d.waitUntilVisible("Order #1001", timeout: 10)
        d.tap("Order #1001")
        d.assertVisible("Order details")
        d.assertVisible("Selected Order #1001")
        d.assertVisible("Total: $42.00")
        // A fast swipe flings past the target in this list: scroll slowly, as the .ds unit does.
        d.scrollUntilVisible("Order #1008", maxScrolls: 8, duration: RegressionDriver.swipeDuration)
        d.assertVisible("Order #1008")
        backToHome()
    }

    // showcase.ds
    func unitShowcase() {
        d.waitUntilVisible("Grid", timeout: 10)
        d.scroll(from: "Grid", .left)
        d.waitUntilVisible("Showcase", timeout: 10)
        d.tap("Showcase")
        d.waitUntilVisible("Component Showcase", timeout: 10)
        d.tap("Enable notifications")
        d.assertNotChecked(.id("sample.showcase.switch"))
        d.assertVisible(.id("sample.showcase.progress"))
        d.swipe(from: .id("sample.showcase.slider"), .right)
        d.scroll()
        d.assertVisible("End of screen")
        backToHome()
    }

    // pinch.ds
    func unitPinch() {
        d.scrollUntilVisible("Pinch", maxScrolls: 6)
        d.tap("Pinch")
        d.waitUntilVisible("Pinch Playground", timeout: 10)
        d.pinch(on: .id("sample.pinch.playground"), inward: true)  // pinchIn
        d.assertContainsText("last: zoom out")
        d.pinch(on: .id("sample.pinch.playground"), inward: false)  // pinchOut
        d.assertContainsText("last: zoom in")
        backToHome()
    }

    // drag-drop.ds
    func unitDragDrop() {
        d.scrollUntilVisible("Drag & Drop", maxScrolls: 6)
        d.tap("Drag & Drop")
        d.dragAndDrop("Alpha", to: "Drop Zone")
        d.assertContainsText("Alpha dropped in zone")
        d.dragAndDrop("Beta", to: "Drop Zone")
        d.assertContainsText("Beta dropped in zone")
        d.dragAndDrop("Gamma", to: "Drop Zone")
        d.assertContainsText("Gamma dropped in zone")
        d.dragAndDrop("Row One", to: "Row Two")
        d.assertContainsText("moved")
        d.dragAndDrop("Row Three", to: "Row Two")
        d.assertContainsText("moved")
        backToHome()
    }
}
