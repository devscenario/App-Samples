package ge.devtool.samples.ui

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.withContext

/** Messages the WebSocket demo sends, one after the other's echo arrives. */
internal val WS_DEMO_MESSAGES = listOf("hello", "world")

/**
 * Starts the local stream test server if the build has one. Returns its addresses, or null after
 * reporting why there is none through [log].
 */
private suspend fun localEndpoints(
    strings: StreamStrings,
    starter: (() -> LocalStreamEndpoints)?,
    log: (String) -> Unit,
): LocalStreamEndpoints? {
    if (starter == null) {
        log(strings.noServer)
        return null
    }
    return withContext(Dispatchers.IO) { runCatching { starter() } }.getOrElse { e ->
        log(strings.serverFailed(e.message ?: e::class.simpleName ?: "unknown"))
        null
    }
}

/**
 * WebSocket demo: connects to the local echo endpoint, sends [WS_DEMO_MESSAGES] one at a time
 * (the next after the previous one's echo), then closes. Each step is reported through [log];
 * messages that are not an echo of the pending message (the server's greeting) are reported as
 * plain messages. [starter] and [open] default to the build's server hook and platform client.
 */
internal suspend fun runWebSocketDemo(
    strings: StreamStrings,
    log: (String) -> Unit,
    starter: (() -> LocalStreamEndpoints)? = LocalStreamServerHook.starter(),
    open: (String) -> DemoWebSocket? = ::openDemoWebSocket,
) {
    val endpoints = localEndpoints(strings, starter, log) ?: return
    log(strings.wsConnecting)
    val socket = open(endpoints.webSocketUrl) ?: run {
        log(strings.notOnPlatform)
        return
    }
    val outgoing = ArrayDeque(WS_DEMO_MESSAGES)
    var pending: String? = null
    fun sendNext() {
        pending = outgoing.removeFirstOrNull()
        pending?.let(socket::send) ?: socket.close()
    }
    try {
        socket.events.collect { event ->
            when (event) {
                DemoWsEvent.Opened -> {
                    log(strings.wsConnected)
                    sendNext()
                }
                is DemoWsEvent.Message -> if (event.text == pending) {
                    log(strings.wsEcho(event.text))
                    sendNext()
                } else {
                    log(strings.wsMessage(event.text))
                }
                is DemoWsEvent.Closed -> log(strings.wsClosed(event.code))
                is DemoWsEvent.Failed -> log(strings.wsFailed(event.message))
            }
        }
    } finally {
        socket.close()
    }
}

/** SSE demo: reads the local event stream to its end and reports each event through [log]. */
internal suspend fun runSseDemo(strings: StreamStrings, log: (String) -> Unit) {
    val endpoints = localEndpoints(strings, LocalStreamServerHook.starter(), log) ?: return
    log(strings.sseConnecting)
    val stream = demoEventStream(endpoints.eventStreamUrl) ?: run {
        log(strings.notOnPlatform)
        return
    }
    stream.collect { event ->
        when (event) {
            DemoSseEvent.Opened -> log(strings.sseOpen)
            is DemoSseEvent.Event -> log(strings.sseEvent(event.id.orEmpty(), event.type ?: "message", event.data))
            DemoSseEvent.Closed -> log(strings.sseClosed)
            is DemoSseEvent.Failed -> log(strings.sseFailed(event.message))
        }
    }
}
