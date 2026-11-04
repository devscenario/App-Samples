package ge.devtool.samples.android

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTextInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import ge.devtool.samples.ui.TestTags
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** Mirrors `flows/samples/units/search.ds`. */
@RunWith(AndroidJUnit4::class)
class SearchEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun searchFlow() = measure("SearchEspressoTest") {
        composeTestRule.onNodeWithText("Search").performScrollTo().performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithTag(TestTags.SEARCH_QUERY).fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithTag(TestTags.SEARCH_QUERY).performTextInput("headphones")
        composeTestRule.onNodeWithText("Search query typed: headphones").assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.SEARCH_SUBMIT).performClick()
        composeTestRule.onNodeWithText("Search results for headphones: 2 items").assertIsDisplayed()
        composeTestRule.onNodeWithText("Wireless Headphones").assertIsDisplayed()
    }
}
