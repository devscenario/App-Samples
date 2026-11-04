package ge.devtool.samples.ui

import kotlin.test.Test
import kotlin.test.assertEquals

class AppFilesScreenTest {
    private fun next(current: String?) = withNextLine(current) { "Line $it" }

    @Test
    fun linesAreNumberedFromTheFirst() {
        assertEquals("Line 1\n", next(null))
        assertEquals("Line 1\n", next(""))
        assertEquals("Line 1\nLine 2\n", next("Line 1\n"))
    }

    @Test
    fun aFileWithoutANewLineGetsOne() {
        assertEquals("From a flow\nLine 2\n", next("From a flow"))
    }
}
