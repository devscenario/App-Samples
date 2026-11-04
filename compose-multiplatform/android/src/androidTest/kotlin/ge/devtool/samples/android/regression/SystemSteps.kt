package ge.devtool.samples.android.regression

import android.app.Instrumentation
import android.graphics.Rect
import android.os.Build
import android.os.ParcelFileDescriptor
import android.os.SystemClock
import androidx.annotation.RequiresApi
import androidx.compose.ui.test.junit4.ComposeTestRule
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import java.util.concurrent.TimeoutException
import java.util.regex.Pattern

/** Longest wait between two reads of the screen; any window content change ends it earlier. */
private const val POLL_MS = 50L

/**
 * Compose sends its accessibility updates from a coroutine paced by the composition's clock (every
 * 100 ms), and under a Compose test that clock only moves when the test advances it.
 */
private const val COMPOSE_ACCESSIBILITY_INTERVAL_MS = 100L

/** A tap in another app's window waits for this long without accessibility events (capped). */
private const val SETTLE_QUIET_MS = 100L
private const val SETTLE_TIMEOUT_MS = 2_000L

private const val DOWNLOADS_DIR = "/storage/emulated/0/Download"

/**
 * The .ds commands for what the app's Compose tree can't see: the system file picker (DocumentsUI,
 * another process), through UiAutomator, which reads the same
 * accessibility tree a Dev Scenario hierarchy dump reads, and matches text the same way
 * ([TextSelectors]). Steps poll the tree themselves, so UiAutomator's idle wait before every query
 * and action (500 ms without accessibility events) is turned off. Before each read the app's
 * Compose clock is moved on, so the app has published its current screen to the accessibility tree.
 */
internal class SystemSteps(
    private val rule: ComposeTestRule,
    private val device: UiDevice,
    private val instrumentation: Instrumentation,
) {

    private val appPackage = instrumentation.targetContext.packageName

    init {
        Configurator.getInstance().waitForIdleTimeout = 0
    }

    /** A target in another process (the file picker) is tapped once its window has settled. */
    fun tapOn(text: String) {
        val target = awaitVisible(text, DEFAULT_WAIT_MS)
        if (target.applicationPackage != appPackage) settle()
        target.click()
    }

    fun waitUntilVisible(text: String, timeoutMs: Long = DEFAULT_WAIT_MS) {
        awaitVisible(text, timeoutMs)
    }

    /**
     * `pushFile`: one shell (the shell user, what `adb push` writes as) writes the file into the
     * shared Downloads folder and asks MediaProvider to index it (`scan_file`, synchronous), so the
     * file picker lists it.
     */
    @RequiresApi(Build.VERSION_CODES.S)
    fun pushFile(name: String, content: String) {
        val path = "$DOWNLOADS_DIR/$name"
        val script = "printf %s '${content.replace("'", "'\\''")}' > $path\n" +
            "content call --uri content://media --method scan_file --arg $path\n"
        val streams = instrumentation.uiAutomation.executeShellCommandRw("sh")
        ParcelFileDescriptor.AutoCloseOutputStream(streams[1]).use { it.write(script.toByteArray()) }
        val output = ParcelFileDescriptor.AutoCloseInputStream(streams[0]).use { String(it.readBytes()) }
        // The scan's result bundle holds the indexed file's uri, or null when it wasn't indexed.
        if (!output.contains("STREAM=") || output.contains("STREAM=null")) {
            throw AssertionError("pushFile: MediaProvider didn't index $name: $output")
        }
    }

    private fun settle() {
        try {
            instrumentation.uiAutomation.waitForIdle(SETTLE_QUIET_MS, SETTLE_TIMEOUT_MS)
        } catch (_: TimeoutException) {
            // Still changing after the cap: tap where the target is now.
        }
    }

    private fun awaitVisible(text: String, timeoutMs: Long): UiObject2 {
        val deadline = SystemClock.uptimeMillis() + timeoutMs
        while (true) {
            publishAppTree()
            find(text)?.let { return it }
            val left = deadline - SystemClock.uptimeMillis()
            if (left <= 0) throw AssertionError("Timed out after $timeoutMs ms waiting for text~$text")
            device.waitForWindowUpdate(null, minOf(left, POLL_MS))
        }
    }

    private fun publishAppTree() {
        rule.mainClock.advanceTimeBy(COMPOSE_ACCESSIBILITY_INTERVAL_MS)
    }

    /** The node a text selector picks: text or content description contains it; exact first. */
    private fun find(text: String): UiObject2? {
        val pattern = Pattern.compile("(?isu).*" + Pattern.quote(TextSelectors.normalize(text)) + ".*")
        return (findAll(By.text(pattern)) + findAll(By.desc(pattern)))
            .mapNotNull { candidate -> runCatching { Candidate(candidate, text) }.getOrNull() }
            .filter { !it.bounds.isEmpty }
            .minWithOrNull(compareBy<Candidate> { it.rank })
            ?.node
    }

    private fun findAll(selector: BySelector): List<UiObject2> =
        runCatching { device.findObjects(selector) }.getOrDefault(emptyList())

    /** One read of a matching node's properties, ranked like the Dev Scenario matcher's pick. */
    private class Candidate(val node: UiObject2, target: String) {
        val bounds: Rect = node.visibleBounds
        val rank: Int = run {
            val needle = TextSelectors.normalize(target)
            val exact = listOfNotNull(node.text, node.contentDescription)
                .any { TextSelectors.normalize(it).equals(needle, ignoreCase = true) }
            listOf(exact, node.isClickable, node.isFocusable, node.isEnabled)
                .fold(0) { acc, met -> acc * 2 + if (met) 0 else 1 }
        }
    }
}
