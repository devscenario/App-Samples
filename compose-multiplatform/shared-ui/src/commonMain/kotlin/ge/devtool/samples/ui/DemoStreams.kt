package ge.devtool.samples.ui

import kotlinx.coroutines.flow.Flow

/** Where the sample's local stream test server listens. */
data class LocalStreamEndpoints(val webSocketUrl: String, val eventStreamUrl: String)

/**
 * Hook for builds that carry the local stream test server (the Android and iOS samples' debug builds).
 * Without an [install]ed starter the stream demos report that no server is available.
 */
object LocalStreamServerHook {
    private var starter: (() -> LocalStreamEndpoints)? = null

    /** [starter] starts the server on first use (blocking) and returns its addresses. */
    fun install(starter: () -> LocalStreamEndpoints) {
        this.starter = starter
    }

    internal fun starter(): (() -> LocalStreamEndpoints)? = starter
}

/** What a demo WebSocket reports. */
sealed interface DemoWsEvent {
    data object Opened : DemoWsEvent
    data class Message(val text: String) : DemoWsEvent
    data class Closed(val code: Int, val reason: String) : DemoWsEvent
    data class Failed(val message: String) : DemoWsEvent
}

/** An open demo WebSocket. [events] completes after [DemoWsEvent.Closed] or [DemoWsEvent.Failed]. */
interface DemoWebSocket {
    val events: Flow<DemoWsEvent>
    fun send(text: String)
    fun close()
}

/** What a demo event stream reports. */
sealed interface DemoSseEvent {
    data object Opened : DemoSseEvent
    data class Event(val id: String?, val type: String?, val data: String) : DemoSseEvent
    data object Closed : DemoSseEvent
    data class Failed(val message: String) : DemoSseEvent
}

/**
 * Opens a WebSocket on the platform's networking stack (OkHttp on Android, URLSession on iOS, so
 * the network interceptor sees it). Null where the platform has no demo client or the URL is invalid.
 */
expect fun openDemoWebSocket(url: String): DemoWebSocket?

/**
 * Reads a `text/event-stream` on the platform's networking stack. Collecting the flow opens the
 * stream; it completes after [DemoSseEvent.Closed] or [DemoSseEvent.Failed], and cancelling the
 * collector closes the stream. Null where the platform has no demo client or the URL is invalid.
 */
expect fun demoEventStream(url: String): Flow<DemoSseEvent>?
