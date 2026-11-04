package ge.devtool.samples.android.regression

import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.filters.SdkSuppress
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import ge.devtool.samples.android.MainActivity
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Native mirror of the Dev Scenario scenario "Sample regression"
 * (flows/samples/scenarios/Sample regression.scenario.json): its 18 units
 * in order, in one app launch, each ending on the home screen. Timing goes to logcat
 * ([TIMING_LOG_TAG]) and to [TIMING_FILE_NAME] in the app's files dir. The [UNITS_ARGUMENT]
 * instrumentation argument runs a subset (every unit starts and ends on the home screen).
 */
@RunWith(AndroidJUnit4::class)
@SdkSuppress(minSdkVersion = 31)
class SampleRegressionNativeTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<MainActivity>()

    /** [SystemSteps] turns UiAutomator's process-wide idle wait off; other tests get it back. */
    private var previousWaitForIdleTimeout = 0L

    @Before
    fun saveUiAutomatorIdleTimeout() {
        previousWaitForIdleTimeout = Configurator.getInstance().waitForIdleTimeout
    }

    @After
    fun restoreUiAutomatorIdleTimeout() {
        Configurator.getInstance().waitForIdleTimeout = previousWaitForIdleTimeout
    }

    @Test
    fun sampleRegression() {
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        val device = UiDevice.getInstance(instrumentation)
        val ui = ComposeSteps(composeRule)
        val steps = RegressionSteps(ui, GestureSteps(ui, device), SystemSteps(composeRule, device, instrumentation))
        val timing = RegressionTiming(
            "Sample regression (native)",
            instrumentation.targetContext,
            RegressionTiming.selectedUnits(InstrumentationRegistry.getArguments()),
        )
        var failure: Throwable? = null
        timing.start()
        try {
            steps.runAll(timing)
        } catch (t: Throwable) {
            failure = t
            throw t
        } finally {
            timing.finish(failure)
        }
    }

    private fun RegressionSteps.runAll(timing: RegressionTiming) = with(timing) {
        unit("launch", "samples/units/launch.ds") { launch() }
        unit("login", "samples/units/login.ds") { login() }
        unit("registration", "samples/units/registration.ds") { registration() }
        unit("checkout", "samples/units/checkout.ds") { checkout() }
        unit("grid", "samples/units/grid.ds") { grid() }
        unit("list", "samples/units/list.ds") { list() }
        unit("search", "samples/units/search.ds") { search() }
        unit("profile", "samples/units/profile.ds") { profile() }
        unit("showcase", "samples/units/showcase.ds") { showcase() }
        unit("pinch", "samples/units/pinch.ds") { pinch() }
        unit("drag-drop", "samples/units/drag-drop.ds") { dragDrop() }
        unit("modals", "samples/units/modals.ds") { modals() }
        unit("modals-swipes", "samples/units/modals-swipes.ds") { modalsSwipes() }
        unit("modals-back", "samples/units/modals-back.ds") { modalsBack() }
        unit("modals-code-sheet", "samples/units/modals-code-sheet.ds") { modalsCodeSheet() }
        unit("network", "samples/units/network.ds") { network() }
        unit("files", "samples/units/files.ds") { files() }
        unit("webview", "samples/units/webview.ds") { webview() }
    }
}
