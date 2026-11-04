package ge.devtool.samples.android

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollToNode
import ge.devtool.samples.ui.TestTags
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** Mirrors `flows/samples/units/grid.ds`. */
@RunWith(AndroidJUnit4::class)
class GridEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun gridFlow() = measure("GridEspressoTest") {
        composeTestRule.onNodeWithText("Grid").performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithText("Product 1").fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithTag(TestTags.GRID_CONTAINER).performScrollToNode(hasText("Product 5"))
        composeTestRule.onNodeWithText("Product 5").assertIsDisplayed()
        composeTestRule.onNodeWithText("Product 5").performClick()
        composeTestRule.onNodeWithText("Product details").assertIsDisplayed()
        composeTestRule.onNodeWithText("Selected Product 5").assertIsDisplayed()
        composeTestRule.onNodeWithText("Price: \$31.99").assertIsDisplayed()
    }
}
