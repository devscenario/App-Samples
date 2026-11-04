package ge.devtool.samples.android

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performScrollToNode
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipe
import androidx.test.ext.junit.runners.AndroidJUnit4
import ge.devtool.samples.ui.TestTags
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** Mirrors `flows/samples/units/modals.ds`. */
@RunWith(AndroidJUnit4::class)
class ModalsEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun modalsFlow() = measure("ModalsEspressoTest") {
        composeTestRule.onNodeWithText("Modals").performScrollTo().performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithText("Partial sheet").fetchSemanticsNodes().isNotEmpty()
        }

        // Partial sheet → swipe down to dismiss.
        composeTestRule.onNodeWithText("Partial sheet").performClick()
        composeTestRule.waitUntil(timeoutMillis = 5_000) {
            composeTestRule.onAllNodesWithText("Bottom sheet").fetchSemanticsNodes().isNotEmpty()
        }
        // ModalBottomSheet only fling-dismisses when the drag clears the
        // velocity threshold. Swipe on the sheet itself with a short duration
        // (= high velocity) over its full height to overshoot the dismiss
        // threshold reliably.
        composeTestRule.onNodeWithTag(TestTags.MODALS_SHEET).performTouchInput {
            swipe(
                start = androidx.compose.ui.geometry.Offset(centerX, top + 20f),
                end = androidx.compose.ui.geometry.Offset(centerX, bottom + height),
                durationMillis = 150,
            )
        }
        composeTestRule.waitUntil(timeoutMillis = 5_000) {
            composeTestRule.onAllNodesWithText("Bottom sheet dismissed", substring = true).fetchSemanticsNodes().isNotEmpty()
        }

        // Full sheet → scroll inside the sheet to "Hide sheet", tap it.
        composeTestRule.onNodeWithText("Full sheet").performClick()
        composeTestRule.waitUntil(timeoutMillis = 5_000) {
            composeTestRule.onAllNodesWithText("Bottom sheet").fetchSemanticsNodes().isNotEmpty()
        }
        composeTestRule.onNodeWithTag(TestTags.MODALS_SHEET).performScrollToNode(hasText("Hide sheet"))
        composeTestRule.onNodeWithText("Hide sheet").performClick()
        composeTestRule.waitUntil(timeoutMillis = 5_000) {
            composeTestRule.onAllNodesWithText("Bottom sheet hidden with close action", substring = true).fetchSemanticsNodes().isNotEmpty()
        }

        // Alert dialog → back dismisses.
        composeTestRule.onNodeWithText("Alert dialog").performClick()
        composeTestRule.onNodeWithText("Session expired").assertIsDisplayed()
        androidx.test.platform.app.InstrumentationRegistry.getInstrumentation().sendKeyDownUpSync(android.view.KeyEvent.KEYCODE_BACK)
        composeTestRule.waitUntil(timeoutMillis = 5_000) {
            composeTestRule.onAllNodesWithText("Session expired").fetchSemanticsNodes().isEmpty()
        }
        composeTestRule.onNodeWithText("Alert dialog dismissed", substring = true).assertIsDisplayed()

        // Fullscreen dialog → back dismisses.
        composeTestRule.onNodeWithText("Fullscreen dialog").performClick()
        composeTestRule.onNodeWithText("Fullscreen-like dialog").assertIsDisplayed()
        androidx.test.platform.app.InstrumentationRegistry.getInstrumentation().sendKeyDownUpSync(android.view.KeyEvent.KEYCODE_BACK)
        composeTestRule.waitUntil(timeoutMillis = 5_000) {
            composeTestRule.onAllNodesWithText("Fullscreen-like dialog").fetchSemanticsNodes().isEmpty()
        }
        composeTestRule.onNodeWithText("Fullscreen dialog dismissed", substring = true).assertIsDisplayed()
    }
}
