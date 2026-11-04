package ge.devtool.samples.android

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.pinch
import androidx.test.ext.junit.runners.AndroidJUnit4
import ge.devtool.samples.ui.TestTags
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** Mirrors `flows/samples/units/pinch.ds`. */
@RunWith(AndroidJUnit4::class)
class PinchEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun pinchFlow() = measure("PinchEspressoTest") {
        composeTestRule.onNodeWithText("Pinch").performScrollTo().performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithText("Pinch Playground").fetchSemanticsNodes().isNotEmpty()
        }

        val playground = composeTestRule.onNodeWithTag(TestTags.PINCH_PLAYGROUND)
        // pinchIn: fingers start spread, end close together.
        playground.performTouchInput {
            pinch(
                start0 = center + Offset(-200f, 0f),
                end0 = center + Offset(-20f, 0f),
                start1 = center + Offset(200f, 0f),
                end1 = center + Offset(20f, 0f),
            )
        }
        composeTestRule.onNodeWithText("last: zoom out", substring = true).assertIsDisplayed()

        // pinchOut: fingers start close, end spread.
        playground.performTouchInput {
            pinch(
                start0 = center + Offset(-20f, 0f),
                end0 = center + Offset(-200f, 0f),
                start1 = center + Offset(20f, 0f),
                end1 = center + Offset(200f, 0f),
            )
        }
        composeTestRule.onNodeWithText("last: zoom in", substring = true).assertIsDisplayed()
    }
}
