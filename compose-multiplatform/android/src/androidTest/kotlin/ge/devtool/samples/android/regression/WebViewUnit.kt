package ge.devtool.samples.android.regression

import androidx.test.espresso.web.assertion.WebViewAssertions.webMatches
import androidx.test.espresso.web.sugar.Web.onWebView
import androidx.test.espresso.web.webdriver.DriverAtoms.findElement
import androidx.test.espresso.web.webdriver.DriverAtoms.getText
import androidx.test.espresso.web.webdriver.DriverAtoms.webClick
import androidx.test.espresso.web.webdriver.DriverAtoms.webKeys
import androidx.test.espresso.web.webdriver.DriverAtoms.webScrollIntoView
import androidx.test.espresso.web.webdriver.Locator
import org.hamcrest.Matchers.equalTo

/**
 * webview.ds, written the way an Android app tests its WebView: Espresso-Web, the page's elements by
 * id, WebDriver atoms for typing, clicks and scrolling, `getText` (visible text) for checks. Each
 * page change is waited for through the native "Last web event" label it posts (Compose waits).
 */
internal fun RegressionSteps.webview() {
    ui.scrollUntilVisible("WebView", maxScrolls = 8)
    ui.tapOn("WebView")
    ui.waitUntilVisible("Last web event: page loaded", timeoutMs = 15_000)
    page("//section[@id='checkout']/h1", "Web checkout")

    onWebView().withElement(findElement(Locator.ID, "email")).perform(webKeys("qa@shop.com"))
    onWebView().withElement(findElement(Locator.ID, "promo")).perform(webKeys("spring10"))
    onWebView().withElement(findElement(Locator.ID, "apply")).perform(webClick())
    ui.assertVisible("Last web event: Code SPRING10 applied")
    page("//*[@id='promo-msg']", "Code SPRING10 applied")

    onWebView().withElement(findElement(Locator.ID, "agree")).perform(webClick())
    onWebView().withElement(findElement(Locator.ID, "pay")).perform(webClick())
    ui.assertVisible("Last web event: payment confirmed")
    page("//*[@id='pay-msg']", "Payment confirmed for qa@shop.com")

    onWebView().withElement(findElement(Locator.ID, "terms-link")).perform(webClick())
    ui.waitUntilVisible("Last web event: opened terms")
    page("//section[@id='terms']/h1", "Terms of service")

    onWebView().withElement(findElement(Locator.ID, "back-link")).perform(webClick())
    ui.waitUntilVisible("Last web event: opened checkout")
    page("//section[@id='checkout']/h1", "Web checkout")

    onWebView().withElement(findElement(Locator.ID, "footer")).perform(webScrollIntoView())
    page("//*[@id='footer']", "Footer reached")

    // Back to the start screen for the next unit.
    ui.tapOn("Back")
    ui.waitUntilVisible("Sample Screens")
}

/** The element at [xpath] shows [text] (visible text: an element in a hidden section has none). */
private fun page(xpath: String, text: String) {
    onWebView().withElement(findElement(Locator.XPATH, xpath)).check(webMatches(getText(), equalTo(text)))
}
