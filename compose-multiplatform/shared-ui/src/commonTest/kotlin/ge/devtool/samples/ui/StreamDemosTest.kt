package ge.devtool.samples.ui

import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals

/** An echo server stand-in: greets on open, echoes each message, confirms a close. */
private class FakeEchoSocket : DemoWebSocket {
    private val channel = Channel<DemoWsEvent>(Channel.UNLIMITED)
    val sent = mutableListOf<String>()

    init {
        channel.trySend(DemoWsEvent.Opened)
        channel.trySend(DemoWsEvent.Message("welcome"))
    }

    override val events: Flow<DemoWsEvent> = channel.receiveAsFlow()

    override fun send(text: String) {
        sent += text
        channel.trySend(DemoWsEvent.Message(text))
    }

    override fun close() {
        if (channel.trySend(DemoWsEvent.Closed(1000, "")).isSuccess) channel.close()
    }
}

class StreamDemosTest {
    private val endpoints = LocalStreamEndpoints("ws://local/echo", "http://local/events")

    @Test
    fun webSocketDemoSendsEachMessageAfterTheEchoOfThePreviousOneThenCloses() = runTest {
        val socket = FakeEchoSocket()
        val lines = mutableListOf<String>()
        runWebSocketDemo(EnStreamStrings, { lines += it }, starter = { endpoints }, open = { socket })
        assertEquals(WS_DEMO_MESSAGES, socket.sent)
        assertEquals(
            listOf(
                "WS connecting", "WS connected", "WS message: welcome",
                "WS echo: hello", "WS echo: world", "WS closed: 1000",
            ),
            lines,
        )
    }

    @Test
    fun webSocketDemoReportsAMissingServer() = runTest {
        val lines = mutableListOf<String>()
        runWebSocketDemo(EnStreamStrings, { lines += it }, starter = null, open = { error("not opened") })
        assertEquals(listOf("No local server"), lines)
    }

    @Test
    fun webSocketDemoReportsAServerThatFailsToStart() = runTest {
        val lines = mutableListOf<String>()
        runWebSocketDemo(EnStreamStrings, { lines += it }, starter = { error("port taken") }, open = { error("not opened") })
        assertEquals(listOf("Server failed: port taken"), lines)
    }
}
