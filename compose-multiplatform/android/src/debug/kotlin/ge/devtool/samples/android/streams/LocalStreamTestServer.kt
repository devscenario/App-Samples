package ge.devtool.samples.android.streams

import ge.devtool.samples.ui.LocalStreamEndpoints
import java.io.IOException
import ge.devtool.samples.ui.LocalStreamServerHook

/** Loopback only: the test server is reachable from this device, never from the network. */
internal const val LOOPBACK_HOST = "127.0.0.1"

/** Fixed ports, so flows and network rules can name the URLs. */
internal const val WEBSOCKET_PORT = 8770
internal const val EVENT_STREAM_PORT = 8771

internal const val WEBSOCKET_PATH = "/echo"
internal const val EVENT_STREAM_PATH = "/events"

/**
 * Debug builds: the local WebSocket echo and SSE test server the Network screen's stream demos talk
 * to. Started on first use and kept for the life of the process.
 */
internal object LocalStreamTestServer {
    private var endpoints: LocalStreamEndpoints? = null

    @Synchronized
    fun start(): LocalStreamEndpoints {
        endpoints?.let { return it }
        val echo = EchoWebSocketServer(WEBSOCKET_PORT)
        echo.startAndAwait()
        try {
            EventStreamServer(EVENT_STREAM_PORT).start()
        } catch (e: IOException) {
            // Frees the WebSocket port so the next attempt can start both servers again.
            echo.stop()
            throw e
        }
        return LocalStreamEndpoints(
            webSocketUrl = "ws://$LOOPBACK_HOST:$WEBSOCKET_PORT$WEBSOCKET_PATH",
            eventStreamUrl = "http://$LOOPBACK_HOST:$EVENT_STREAM_PORT$EVENT_STREAM_PATH",
        ).also { endpoints = it }
    }
}

/** Makes the stream demos start [LocalStreamTestServer] when they first need it. */
fun installLocalStreamServer() {
    LocalStreamServerHook.install(LocalStreamTestServer::start)
}
