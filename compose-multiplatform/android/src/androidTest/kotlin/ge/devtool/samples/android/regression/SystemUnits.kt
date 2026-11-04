package ge.devtool.samples.android.regression

import android.os.Build
import androidx.annotation.RequiresApi

// Network and system file picker units, each a step-for-step mirror of its .ds file in
// flows/samples/units/.

/** network.ds */
internal fun RegressionSteps.network() = with(ui) {
    scrollUntilVisible("Network", maxScrolls = 6)
    tapOn("Network")
    waitUntilVisible("Dev Scenario interceptor demo", timeoutMs = 10_000)
    waitUntilVisibleRegex("^Auto request (done|failed).*", timeoutMs = 20_000)
    tapOn("POST jsonplaceholder /posts")
    waitUntilVisibleRegex("^POST +POST /posts$", timeoutMs = 10_000)
    tapOn("GET → 404 (force error)")
    waitUntilVisibleRegex("^GET +GET → 404$", timeoutMs = 10_000)
    tapOn("Back")
    waitUntilVisible("Sample Screens")
}

/** files.ds (its `runIf: platform: android` block; the iOS block is skipped). */
@RequiresApi(Build.VERSION_CODES.S)
internal fun RegressionSteps.files() {
    system.pushFile(name = "dev-scenario-sample.txt", content = "Dev Scenario sample file")
    ui.scrollUntilVisible("Files", maxScrolls = 6)
    ui.tapOn("Files")
    ui.tapOn("Pick file")
    // runIf: platform: android
    system.waitUntilVisible("dev-scenario-sample.txt", timeoutMs = 15_000)
    system.tapOn("dev-scenario-sample.txt")
    ui.waitUntilVisible("Selected file: dev-scenario-sample.txt", timeoutMs = 10_000)
    // end runIf
    ui.tapOn("Back")
    ui.waitUntilVisible("Sample Screens")
}
