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

/** Mirrors `flows/samples/units/profile.ds`. */
@RunWith(AndroidJUnit4::class)
class ProfileEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun profileFlow() = measure("ProfileEspressoTest") {
        composeTestRule.onNodeWithText("Profile").performScrollTo().performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithTag(TestTags.PROFILE_PHONE).fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithText("Profile name typed: QA Tester").assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.PROFILE_PHONE).performTextInput("5551234567")
        composeTestRule.onNodeWithText("Profile phone typed: 5551234567").assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.PROFILE_MARKETING, useUnmergedTree = true).performClick()
        composeTestRule.onNodeWithTag(TestTags.PROFILE_SAVE).performClick()
        composeTestRule.onNodeWithText("Profile saved for QA Tester").assertIsDisplayed()
    }
}
