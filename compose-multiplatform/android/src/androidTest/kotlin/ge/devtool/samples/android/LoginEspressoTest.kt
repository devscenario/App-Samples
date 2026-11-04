package ge.devtool.samples.android

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import ge.devtool.samples.ui.TestTags
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** Mirrors `flows/samples/units/login.ds`. */
@RunWith(AndroidJUnit4::class)
class LoginEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun loginFlow() = measure("LoginEspressoTest") {
        // Top-level `Login` tab tap → 1-2s DelayedScreenContent loader → LoginScreen.
        composeTestRule.onNodeWithText("Login").performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithTag(TestTags.LOGIN_EMAIL).fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithTag(TestTags.LOGIN_EMAIL).performTextInput("qa@example.com")
        composeTestRule.onNodeWithText("Login email typed: qa@example.com").assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.LOGIN_PASSWORD).performTextInput("Pass1234")
        composeTestRule.onNodeWithText("Login password typed: Pass1234").assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.LOGIN_REMEMBER, useUnmergedTree = true).performClick()
        composeTestRule.onNodeWithText("Sign in").performClick()
        composeTestRule.onNodeWithText("Login success for qa@example.com").assertIsDisplayed()
    }
}
