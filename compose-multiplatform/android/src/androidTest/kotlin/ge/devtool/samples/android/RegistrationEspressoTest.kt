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

/** Mirrors `flows/samples/units/registration.ds`. */
@RunWith(AndroidJUnit4::class)
class RegistrationEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun registrationFlow() = measure("RegistrationEspressoTest") {
        composeTestRule.onNodeWithText("Registration").performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithTag(TestTags.REG_NAME).fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithTag(TestTags.REG_NAME).performTextInput("Test User")
        composeTestRule.onNodeWithText("Registration name typed: Test User").assertIsDisplayed()

        composeTestRule.onNodeWithTag(TestTags.REG_EMAIL).performTextInput("newuser@test.example.com")
        composeTestRule.onNodeWithText("Registration email typed: newuser@test.example.com").assertIsDisplayed()

        composeTestRule.onNodeWithTag(TestTags.REG_PASSWORD).performTextInput("Password123")
        composeTestRule.onNodeWithText("Registration password typed: Password123").assertIsDisplayed()
        composeTestRule.onNodeWithText("Registration success for newuser@test.example.com").assertIsDisplayed()

        composeTestRule.onNodeWithTag(TestTags.REG_SUBMIT).performScrollTo().performClick()
    }
}
