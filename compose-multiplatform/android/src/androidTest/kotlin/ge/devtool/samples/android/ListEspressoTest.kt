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

/** Mirrors `flows/samples/units/list.ds`. */
@RunWith(AndroidJUnit4::class)
class ListEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun listFlow() = measure("ListEspressoTest") {
        composeTestRule.onNodeWithText("List").performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithText("Order #1001").fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithText("Order #1001").performClick()
        composeTestRule.onNodeWithText("Order details").assertIsDisplayed()
        composeTestRule.onNodeWithText("Selected Order #1001").assertIsDisplayed()
        composeTestRule.onNodeWithText("Total: \$42.00").assertIsDisplayed()

        composeTestRule.onNodeWithTag(TestTags.LIST_CONTAINER).performScrollToNode(hasText("Order #1008"))
        composeTestRule.onNodeWithText("Order #1008").assertIsDisplayed()
    }
}
