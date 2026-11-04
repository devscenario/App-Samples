package ge.devtool.samples.ui

import kotlin.test.Test
import kotlin.test.assertEquals

class DemoSseParserTest {

    @Test
    fun readsTheLocalServersEventsAndSkipsTheComment() {
        val parser = DemoSseParser()
        val events = listOf(
            "id: 1\nevent: greeting\ndata: hello\n\n",
            ": keepalive\n\n",
            "id: 2\nevent: tick\ndata: {\"n\":2}\n\n",
            "id: 3\nevent: done\ndata: bye\n\n",
        ).flatMap { parser.feed(it.encodeToByteArray()) }
        assertEquals(
            listOf(
                DemoSseEvent.Event("1", "greeting", "hello"),
                DemoSseEvent.Event("2", "tick", "{\"n\":2}"),
                DemoSseEvent.Event("3", "done", "bye"),
            ),
            events,
        )
    }

    @Test
    fun anEventSplitAcrossChunksIsReportedOnceItEnds() {
        val parser = DemoSseParser()
        assertEquals(emptyList(), parser.feed("id: 7\nevent: ti"))
        assertEquals(emptyList(), parser.feed("ck\ndata: a\r"))
        assertEquals(emptyList(), parser.feed("\ndata: b\r\n"))
        assertEquals(listOf(DemoSseEvent.Event("7", "tick", "a\nb")), parser.feed("\r\n"))
    }

    @Test
    fun aCharacterSplitAcrossChunksStaysWhole() {
        val parser = DemoSseParser()
        val bytes = "data: გამარჯობა €\n\n".encodeToByteArray()
        // Splits inside the first multi-byte character, then byte by byte.
        val events = parser.feed(bytes.copyOfRange(0, 7)) +
            bytes.copyOfRange(7, bytes.size).flatMap { parser.feed(byteArrayOf(it)) }
        assertEquals(listOf(DemoSseEvent.Event(null, null, "გამარჯობა €")), events)
    }

    @Test
    fun aLongLineIsReadWhole() {
        val value = "x".repeat(1_000)
        assertEquals(listOf(DemoSseEvent.Event(null, null, value)), DemoSseParser().feed("data: $value\n\n"))
    }

    @Test
    fun theIdCarriesOverAndTheTypeDoesNot() {
        val parser = DemoSseParser()
        val events = parser.feed("id: 4\nevent: tick\ndata: x\n\ndata: y\n\nevent: empty\n\n")
        assertEquals(listOf(DemoSseEvent.Event("4", "tick", "x"), DemoSseEvent.Event("4", null, "y")), events)
    }
}

private fun DemoSseParser.feed(text: String) = feed(text.encodeToByteArray())
