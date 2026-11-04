package ge.devtool.samples.ui

import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.receiveAsFlow
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okhttp3.sse.EventSource
import okhttp3.sse.EventSourceListener
import okhttp3.sse.EventSources

// Built with `OkHttpClient.Builder().build()` so the network interceptor plugin's rewrite of
// `build()` applies to the stream demos as it does to the HTTP demos.
private val streamClient = OkHttpClient.Builder().build()

private const val NORMAL_CLOSURE = 1000

actual fun openDemoWebSocket(url: String): DemoWebSocket? {
    val events = Channel<DemoWsEvent>(Channel.UNLIMITED)
    val listener = object : WebSocketListener() {
        override fun onOpen(webSocket: WebSocket, response: Response) {
            events.trySend(DemoWsEvent.Opened)
        }

        override fun onMessage(webSocket: WebSocket, text: String) {
            events.trySend(DemoWsEvent.Message(text))
        }

        override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
            webSocket.close(code, null)
        }

        override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
            events.trySend(DemoWsEvent.Closed(code, reason))
            events.close()
        }

        override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            events.trySend(DemoWsEvent.Failed(t.message ?: t::class.simpleName ?: "unknown"))
            events.close()
        }
    }
    val socket = streamClient.newWebSocket(Request.Builder().url(url).build(), listener)
    return object : DemoWebSocket {
        override val events: Flow<DemoWsEvent> = events.receiveAsFlow()
        override fun send(text: String) {
            socket.send(text)
        }

        override fun close() {
            socket.close(NORMAL_CLOSURE, null)
        }
    }
}

actual fun demoEventStream(url: String): Flow<DemoSseEvent>? = callbackFlow {
    val listener = object : EventSourceListener() {
        override fun onOpen(eventSource: EventSource, response: Response) {
            trySend(DemoSseEvent.Opened)
        }

        override fun onEvent(eventSource: EventSource, id: String?, type: String?, data: String) {
            trySend(DemoSseEvent.Event(id, type, data))
        }

        override fun onClosed(eventSource: EventSource) {
            trySend(DemoSseEvent.Closed)
            channel.close()
        }

        override fun onFailure(eventSource: EventSource, t: Throwable?, response: Response?) {
            val message = t?.message ?: response?.let { "HTTP ${it.code}" } ?: "unknown"
            trySend(DemoSseEvent.Failed(message))
            channel.close()
        }
    }
    val source = EventSources.createFactory(streamClient)
        .newEventSource(Request.Builder().url(url).build(), listener)
    awaitClose { source.cancel() }
}
