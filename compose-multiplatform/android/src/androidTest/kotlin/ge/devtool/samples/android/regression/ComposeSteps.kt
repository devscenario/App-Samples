package ge.devtool.samples.android.regression

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.platform.ViewRootForTest
import androidx.compose.ui.semantics.SemanticsNode
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.state.ToggleableState
import androidx.compose.ui.test.ComposeTimeoutException
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.SemanticsNodeInteraction
import androidx.compose.ui.test.hasScrollAction
import androidx.compose.ui.test.hasSetTextAction
import androidx.compose.ui.test.hasTestTag
import androidx.compose.ui.test.isFocused
import androidx.compose.ui.test.isRoot
import androidx.compose.ui.test.junit4.ComposeTestRule
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipe
import androidx.test.espresso.Espresso
import ge.devtool.samples.android.regression.TextSelectors.hasSelectorText
import ge.devtool.samples.android.regression.TextSelectors.hasTextMatching

/** Default budget of a tap / assertion and of a `waitUntil*` without `timeout:` (Dev Scenario: 10 s). */
internal const val DEFAULT_WAIT_MS = 10_000L

/**
 * `scrollUntilVisible` step: drag 80% → 20% of the scroll container in the unit's `duration = 150ms`.
 * Injected on Compose's virtual clock: it costs frames, not wall-clock time.
 */
private const val SCROLL_STEP_DURATION_MS = 150L
private const val SCROLL_FROM = 0.8f
private const val SCROLL_TO = 0.2f

/**
 * The .ds commands, against the app's own (Compose) window, named after the command they
 * implement. Every lookup waits up to its budget for the node, the way each Dev Scenario command
 * polls the hierarchy.
 */
internal class ComposeSteps(private val rule: ComposeTestRule) {

    fun tapOn(text: String) {
        awaitText(text, DEFAULT_WAIT_MS).performClick()
    }

    fun tapOnId(id: String) {
        awaitId(id).performClick()
    }

    /** `inputText`: types into the focused field. */
    fun inputText(text: String) {
        awaitNode("focused text field", isFocused() and hasSetTextAction(), null, DEFAULT_WAIT_MS)
            .performTextInput(text)
    }

    fun assertVisible(text: String) = waitUntilVisible(text, DEFAULT_WAIT_MS)

    fun assertVisibleId(id: String) {
        awaitNode("id=$id", hasTestTag(id), null, DEFAULT_WAIT_MS, requireDisplayed = true)
    }

    /** `assertContainsText`: some node on screen contains the text. */
    fun assertContainsText(text: String) = waitUntilVisible(text, DEFAULT_WAIT_MS)

    fun waitUntilVisible(text: String, timeoutMs: Long = DEFAULT_WAIT_MS) {
        awaitNode("text~$text", hasSelectorText(text), text, timeoutMs, requireDisplayed = true)
    }

    fun waitUntilVisibleRegex(pattern: String, timeoutMs: Long = DEFAULT_WAIT_MS) {
        awaitNode("textRegex=$pattern", hasTextMatching(pattern), null, timeoutMs, requireDisplayed = true)
    }

    fun waitUntilNotVisible(text: String, timeoutMs: Long = DEFAULT_WAIT_MS) {
        val matcher = hasSelectorText(text)
        waitFor("text~$text to disappear", timeoutMs) {
            rule.onAllNodes(matcher).fetchSemanticsNodes(atLeastOneRootRequired = false).none { it.isDisplayed() }
        }
    }

    fun assertNotChecked(id: String) {
        val matcher = hasTestTag(id) and SemanticsMatcher.expectValue(
            SemanticsProperties.ToggleableState, ToggleableState.Off,
        )
        awaitNode("id=$id not checked", matcher, null, DEFAULT_WAIT_MS)
    }

    /** `waitForAnimationToEnd`: Compose test's idle sync waits for running animations. */
    fun waitForAnimationToEnd() = rule.waitForIdle()

    /** `back`: the system Back key. */
    fun back() = Espresso.pressBack()

    /**
     * `scrollUntilVisible`: up to [maxScrolls] drags inside the largest scrollable container until
     * the target's centre is inside it.
     */
    fun scrollUntilVisible(text: String, maxScrolls: Int, durationMs: Long = SCROLL_STEP_DURATION_MS) {
        val matcher = hasSelectorText(text)
        repeat(maxScrolls) {
            if (isScrolledIntoView(matcher, text)) return
            scrollContainer().performTouchInput {
                swipe(
                    start = Offset(width / 2f, height * SCROLL_FROM),
                    end = Offset(width / 2f, height * SCROLL_TO),
                    durationMillis = durationMs,
                )
            }
        }
        if (!isScrolledIntoView(matcher, text)) {
            throw AssertionError("Element not found after $maxScrolls scrolls: text~$text")
        }
    }

    /** The node a text selector resolves to (for gestures anchored on it). */
    fun awaitText(text: String, timeoutMs: Long = DEFAULT_WAIT_MS): SemanticsNodeInteraction =
        awaitNode("text~$text", hasSelectorText(text), text, timeoutMs)

    fun awaitId(id: String): SemanticsNodeInteraction = awaitNode("id=$id", hasTestTag(id), null, DEFAULT_WAIT_MS)

    /**
     * Root of the Compose window that has input focus (a dialog or sheet window over the activity's
     * while one is open): the window a whole-screen gesture lands in.
     */
    fun focusedRoot(): SemanticsNodeInteraction {
        val roots = rule.onAllNodes(isRoot())
        val nodes = roots.fetchSemanticsNodes()
        val index = nodes.indexOfFirst { (it.root as? ViewRootForTest)?.view?.hasWindowFocus() == true }
        if (index < 0 && nodes.size > 1) throw AssertionError("No focused window among ${nodes.size} Compose roots")
        return roots[maxOf(index, 0)]
    }

    private fun awaitNode(
        description: String,
        matcher: SemanticsMatcher,
        exactTarget: String?,
        timeoutMs: Long,
        requireDisplayed: Boolean = false,
    ): SemanticsNodeInteraction {
        var index: Int? = null
        waitFor(description, timeoutMs) {
            val nodes = rule.onAllNodes(matcher).fetchSemanticsNodes(atLeastOneRootRequired = false)
            index = TextSelectors.pickIndex(nodes, exactTarget) { !requireDisplayed || it.isDisplayed() }
            index != null
        }
        return rule.onAllNodes(matcher)[index!!]
    }

    private fun waitFor(description: String, timeoutMs: Long, condition: () -> Boolean) {
        try {
            rule.waitUntil(timeoutMs) { condition() }
        } catch (e: ComposeTimeoutException) {
            throw AssertionError("Timed out after $timeoutMs ms waiting for $description", e)
        }
    }

    private fun isScrolledIntoView(matcher: SemanticsMatcher, text: String): Boolean {
        val nodes = rule.onAllNodes(matcher).fetchSemanticsNodes(atLeastOneRootRequired = false)
        val node = TextSelectors.pickIndex(nodes, text)?.let { nodes[it] } ?: return false
        val center = node.screenCenter()
        val container = largestScrollable() ?: return node.isDisplayed()
        return node.isDisplayed() && container.screenBounds().contains(center)
    }

    private fun largestScrollable(): SemanticsNode? = rule.onAllNodes(hasScrollAction())
        .fetchSemanticsNodes(atLeastOneRootRequired = false)
        .maxByOrNull { it.size.width.toLong() * it.size.height }

    private fun scrollContainer(): SemanticsNodeInteraction {
        val nodes = rule.onAllNodes(hasScrollAction()).fetchSemanticsNodes(atLeastOneRootRequired = false)
        val index = nodes.indices.maxByOrNull { nodes[it].size.width.toLong() * nodes[it].size.height }
            ?: throw AssertionError("No scrollable container on screen")
        return rule.onAllNodes(hasScrollAction())[index]
    }
}
