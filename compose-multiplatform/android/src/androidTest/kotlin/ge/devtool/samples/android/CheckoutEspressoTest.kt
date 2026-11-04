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

/** Mirrors `flows/samples/units/checkout.ds`. */
@RunWith(AndroidJUnit4::class)
class CheckoutEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun checkoutFlow() = measure("CheckoutEspressoTest") {
        composeTestRule.onNodeWithText("Checkout").performScrollTo().performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithTag(TestTags.CHECKOUT_ADDRESS).fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithText("Order summary").assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.CHECKOUT_ADDRESS).performTextInput("42 Test Street")
        composeTestRule.onNodeWithText("Checkout address typed: 42 Test Street").assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.CHECKOUT_DELIVERY, useUnmergedTree = true).performClick()
        composeTestRule.onNodeWithText("Payment: Visa •••• 4242").assertIsDisplayed()
        composeTestRule.onNodeWithTag(TestTags.CHECKOUT_PLACE_ORDER).performClick()
        composeTestRule.onNodeWithText("Order placed for 42 Test Street").assertIsDisplayed()
    }
}
