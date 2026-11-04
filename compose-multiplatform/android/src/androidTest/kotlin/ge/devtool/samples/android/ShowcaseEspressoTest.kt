package ge.devtool.samples.android

import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assert
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsOff
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollToNode
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeRight
import androidx.test.ext.junit.runners.AndroidJUnit4
import ge.devtool.samples.ui.TestTags
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** Mirrors `flows/samples/units/showcase.ds`. */
@RunWith(AndroidJUnit4::class)
class ShowcaseEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun showcaseFlow() = measure("ShowcaseEspressoTest") {
        composeTestRule.onNodeWithText("Showcase").performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithText("Component Showcase").fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithText("Enable notifications").performClick()
        composeTestRule.onNodeWithTag(TestTags.SHOWCASE_SWITCH).assertIsOff()

        composeTestRule.onNodeWithTag(TestTags.SHOWCASE_PROGRESS).assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.SHOWCASE_SLIDER).performTouchInput { swipeRight() }
        composeTestRule.onNodeWithTag(TestTags.SHOWCASE_PROGRESS).assert(progressIs(1f))

        composeTestRule.onNodeWithTag(TestTags.SHOWCASE_SCROLL).performScrollToNode(hasText("End of screen"))
        composeTestRule.onNodeWithText("End of screen").assertIsDisplayed()
    }

    private fun progressIs(value: Float) =
        SemanticsMatcher.expectValue(SemanticsProperties.ProgressBarRangeInfo, ProgressBarRangeInfo(value, 0f..1f))
}
