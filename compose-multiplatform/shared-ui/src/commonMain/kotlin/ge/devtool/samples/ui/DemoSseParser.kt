package ge.devtool.samples.ui

/**
 * Incremental `text/event-stream` reader for the stream demo clients that get raw chunks (iOS).
 * Feed it the body's bytes as they arrive; it returns the events each chunk completes. Each line is
 * decoded as UTF-8 once it ends, so a character split across chunks stays whole. Lines end with LF,
 * CR or CRLF (also split across chunks); comments (`:`) are skipped; an event's `data` lines are
 * joined with LF; the last `id` carries over to later events, as the SSE spec has it; a block
 * without data dispatches nothing.
 */
internal class DemoSseParser {
    private var line = ByteArray(INITIAL_LINE_BYTES)
    private var lineLength = 0
    private var afterCr = false
    private var lastId: String? = null
    private var type: String? = null
    private val data = mutableListOf<String>()

    fun feed(chunk: ByteArray): List<DemoSseEvent.Event> {
        val events = mutableListOf<DemoSseEvent.Event>()
        chunk.forEach { b ->
            if (b == LF && afterCr) {
                afterCr = false
                return@forEach
            }
            afterCr = b == CR
            if (b == CR || b == LF) {
                endLine()?.let(events::add)
            } else {
                append(b)
            }
        }
        return events
    }

    private fun append(b: Byte) {
        if (lineLength == line.size) line = line.copyOf(line.size * 2)
        line[lineLength++] = b
    }

    private fun endLine(): DemoSseEvent.Event? {
        val text = line.decodeToString(0, lineLength)
        lineLength = 0
        if (text.isEmpty()) return dispatch()
        if (text.startsWith(':')) return null
        val name = text.substringBefore(':')
        val value = if (':' in text) text.substringAfter(':').removePrefix(" ") else ""
        when (name) {
            "id" -> lastId = value
            "event" -> type = value
            "data" -> data += value
        }
        return null
    }

    private fun dispatch(): DemoSseEvent.Event? {
        val event = if (data.isEmpty()) null else DemoSseEvent.Event(lastId, type, data.joinToString("\n"))
        type = null
        data.clear()
        return event
    }
}

private const val INITIAL_LINE_BYTES = 256
private const val CR = '\r'.code.toByte()
private const val LF = '\n'.code.toByte()
