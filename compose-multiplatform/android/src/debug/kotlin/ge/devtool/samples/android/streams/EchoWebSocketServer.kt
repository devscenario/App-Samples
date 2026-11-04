package ge.devtool.samples.android.streams

import org.java_websocket.WebSocket
import org.java_websocket.handshake.ClientHandshake
import org.java_websocket.server.WebSocketServer
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/** Sent to every client right after it connects, before any echo. */
internal const val WEBSOCKET_GREETING = "welcome"

private const val START_TIMEOUT_SECONDS = 5L
private const val POLICY_VIOLATION = 1008

/**
 * WebSocket echo server: greets each client on [WEBSOCKET_PATH] with [WEBSOCKET_GREETING], then
 * sends every text or binary message back unchanged. Other paths are closed right away.
 */
internal class EchoWebSocketServer(port: Int) : WebSocketServer(InetSocketAddress(LOOPBACK_HOST, port)) {
    private val started = CountDownLatch(1)

    @Volatile
    private var startError: Exception? = null

    init {
        isReuseAddr = true
        isDaemon = true
    }

    /** Starts the server and waits until it listens; stops it and throws when it cannot bind. */
    fun startAndAwait() {
        start()
        val failure = if (started.await(START_TIMEOUT_SECONDS, TimeUnit.SECONDS)) {
            startError?.let { IllegalStateException("WebSocket server: ${it.message}", it) }
        } else {
            IllegalStateException("WebSocket server did not start")
        } ?: return
        stop()
        throw failure
    }

    override fun onStart() {
        started.countDown()
    }

    override fun onOpen(conn: WebSocket, handshake: ClientHandshake) {
        if (handshake.resourceDescriptor.substringBefore('?') != WEBSOCKET_PATH) {
            conn.close(POLICY_VIOLATION, "unknown path")
            return
        }
        conn.send(WEBSOCKET_GREETING)
    }

    override fun onMessage(conn: WebSocket, message: String) {
        conn.send(message)
    }

    override fun onMessage(conn: WebSocket, message: ByteBuffer) {
        conn.send(message)
    }

    override fun onClose(conn: WebSocket, code: Int, reason: String, remote: Boolean) = Unit

    override fun onError(conn: WebSocket?, ex: Exception) {
        // No connection means the server itself failed (for example the port is taken).
        if (conn == null) {
            startError = ex
            started.countDown()
        }
    }
}
