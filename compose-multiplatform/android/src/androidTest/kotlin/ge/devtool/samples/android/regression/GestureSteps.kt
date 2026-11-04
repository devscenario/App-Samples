package ge.devtool.samples.android.regression

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.test.SemanticsNodeInteraction
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.pinch
import androidx.compose.ui.test.swipe
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.UiDevice
import kotlin.math.max
import kotlin.math.min

internal enum class Direction { UP, DOWN, LEFT, RIGHT }

/**
 * Duration of swipes, scrolls and pinch strokes (Dev Scenario's default). Compose's touch injection
 * runs on the test's virtual clock, so it costs frames, not wall-clock time.
 */
private const val FLING_MS = 100L
private const val PINCH_FAR = 0.35f
private const val PINCH_NEAR = 0.08f
private const val PINCH_MS = 250L

/**
 * Gestures with Dev Scenario's geometry, through Compose's touch injection (`performTouchInput`):
 * a gesture anchored on a node goes to that node's window, a whole-screen gesture to the focused
 * Compose window ([ComposeSteps.focusedRoot]), with points given in screen coordinates. A tap at a
 * screen point is injected through UiAutomation ([injectTap]), so it also reaches the area around
 * a dialog, which belongs to the dialog's window but not to its Compose content.
 */
internal class GestureSteps(private val compose: ComposeSteps, private val device: UiDevice) {

    private val width get() = device.displayWidth.toFloat()
    private val height get() = device.displayHeight.toFloat()

    /** `scroll` (no arguments): a fling from 80% to 20% of the screen height, centred. */
    fun scroll() = screenSwipe(Offset(width / 2, height * 0.8f), Offset(width / 2, height * 0.2f), FLING_MS)

    /** `scroll: { from: <text>, direction }`: from the element, content dragged toward [direction]. */
    fun scroll(from: String, direction: Direction) {
        val node = compose.awaitText(from)
        val c = node.fetchSemanticsNode().screenCenter()
        val (left, right) = width * 0.15f to width * 0.85f
        val (top, bottom) = height * 0.15f to height * 0.85f
        val (start, end) = when (direction) {
            Direction.UP -> Offset(c.x, max(c.y, bottom)) to Offset(c.x, top)
            Direction.DOWN -> Offset(c.x, min(c.y, top)) to Offset(c.x, bottom)
            Direction.LEFT -> Offset(max(c.x, right), c.y) to Offset(left, c.y)
            Direction.RIGHT -> Offset(min(c.x, left), c.y) to Offset(right, c.y)
        }
        node.swipeOnScreen(start, end, FLING_MS)
    }

    /** `swipe: { from: <text> | fromId: <id>, direction }`: from the element's centre to 5% off that edge. */
    fun swipe(from: SemanticsNodeInteraction, direction: Direction) {
        val c = from.fetchSemanticsNode().screenCenter()
        val end = when (direction) {
            Direction.UP -> Offset(c.x, height * 0.05f)
            Direction.DOWN -> Offset(c.x, height * 0.95f)
            Direction.LEFT -> Offset(width * 0.05f, c.y)
            Direction.RIGHT -> Offset(width * 0.95f, c.y)
        }
        from.swipeOnScreen(c, end, FLING_MS)
    }

    /** `swipe: <DIRECTION>` across the screen (DOWN starts low, at 75%, to grab a partial sheet). */
    fun swipe(direction: Direction) {
        val (cx, cy) = width / 2 to height / 2
        val (start, end) = when (direction) {
            Direction.UP -> Offset(cx, height * 0.9f) to Offset(cx, height * 0.1f)
            Direction.DOWN -> Offset(cx, height * 0.75f) to Offset(cx, height * 0.95f)
            Direction.LEFT -> Offset(width * 0.9f, cy) to Offset(width * 0.1f, cy)
            Direction.RIGHT -> Offset(width * 0.1f, cy) to Offset(width * 0.9f, cy)
        }
        screenSwipe(start, end, FLING_MS)
    }

    /**
     * `pinchIn`: two fingers level with the screen centre move together, from 35% to 8% of the
     * shorter screen side away from it, over 250 ms, as Dev Scenario's pinch does.
     */
    fun pinchIn() = screenPinch(PINCH_FAR, PINCH_NEAR)

    /** `pinchOut`: the two fingers spread from 8% to 35%. */
    fun pinchOut() = screenPinch(PINCH_NEAR, PINCH_FAR)

    /** `dragAndDrop: { from, to, duration }`: a press-move-release from centre to centre. */
    fun dragAndDrop(from: String, to: String, durationMs: Long) {
        val source = compose.awaitText(from)
        val target = compose.awaitText(to).fetchSemanticsNode().screenCenter()
        source.swipeOnScreen(source.fetchSemanticsNode().screenCenter(), target, durationMs)
    }

    /** `tapOn: { point: "x%,y%" }`: a tap at screen percentages. */
    fun tapOnPoint(xPercent: Int, yPercent: Int) {
        InstrumentationRegistry.getInstrumentation().uiAutomation
            .injectTap(Offset(width * xPercent / 100, height * yPercent / 100))
    }

    private fun screenPinch(fromShare: Float, toShare: Float) {
        val center = Offset(width / 2, height / 2)
        val from = Offset(min(width, height) * fromShare, 0f)
        val to = Offset(min(width, height) * toShare, 0f)
        val root = compose.focusedRoot()
        val origin = root.fetchSemanticsNode().positionOnScreen
        root.performTouchInput {
            pinch(center - from - origin, center - to - origin, center + from - origin, center + to - origin, PINCH_MS)
        }
    }

    private fun screenSwipe(start: Offset, end: Offset, durationMs: Long) {
        compose.focusedRoot().swipeOnScreen(start, end, durationMs)
    }

    /** Compose touch injection on this node's window, with points given in screen coordinates. */
    private fun SemanticsNodeInteraction.swipeOnScreen(start: Offset, end: Offset, durationMs: Long) {
        val origin = fetchSemanticsNode().positionOnScreen
        performTouchInput { swipe(start - origin, end - origin, durationMs) }
    }
}
