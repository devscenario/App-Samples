package ge.devtool.samples.android

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipe
import androidx.test.ext.junit.runners.AndroidJUnit4
import ge.devtool.samples.ui.TestTags
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** Mirrors `flows/samples/units/drag-drop.ds`. */
@RunWith(AndroidJUnit4::class)
class DragDropEspressoTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun dragDropFlow() = measure("DragDropEspressoTest") {
        composeTestRule.onNodeWithTag(TestTags.TAB_DRAG_DROP, useUnmergedTree = true).performScrollTo().performClick()
        composeTestRule.waitUntil(timeoutMillis = 10_000) {
            composeTestRule.onAllNodesWithText("Alpha").fetchSemanticsNodes().isNotEmpty()
        }

        dragChipToDropZone(chipTag = TestTags.DRAG_ITEM_ALPHA, name = "Alpha")
        dragChipToDropZone(chipTag = TestTags.DRAG_ITEM_BETA, name = "Beta")
        dragChipToDropZone(chipTag = TestTags.DRAG_ITEM_GAMMA, name = "Gamma")
    }

    private fun dragChipToDropZone(chipTag: String, name: String) {
        val chipNode = composeTestRule.onNodeWithTag(chipTag).fetchSemanticsNode()
        val zoneNode = composeTestRule.onNodeWithTag(TestTags.DRAG_DROP_TARGET).fetchSemanticsNode()
        val chipCenterInRoot = chipNode.positionInRoot + Offset(
            chipNode.size.width / 2f,
            chipNode.size.height / 2f,
        )
        val zoneCenterInRoot = zoneNode.positionInRoot + Offset(
            zoneNode.size.width / 2f,
            zoneNode.size.height / 2f,
        )

        composeTestRule.onNodeWithTag(chipTag).performTouchInput {
            // performTouchInput coords are local to the chip; convert root→local
            // by subtracting the chip's position-in-root.
            val from = Offset(chipNode.size.width / 2f, chipNode.size.height / 2f)
            val to = zoneCenterInRoot - chipNode.positionInRoot
            swipe(start = from, end = to, durationMillis = 600)
        }

        composeTestRule.waitUntil(timeoutMillis = 5_000) {
            composeTestRule
                .onAllNodesWithText("$name dropped in zone", substring = true)
                .fetchSemanticsNodes()
                .isNotEmpty()
        }
    }
}
