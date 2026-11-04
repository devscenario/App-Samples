package ge.devtool.samples.android.streams

import android.util.Log
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.io.OutputStream
import java.net.InetSocketAddress
import java.net.ServerSocket
import java.net.Socket
import kotlin.concurrent.thread

private const val TAG = "SampleEventStream"

/** Pause before each chunk of [EVENT_STREAM_SCRIPT]. */
private const val EVENT_INTERVAL_MS = 250L

/**
 * What [EVENT_STREAM_PATH] sends, one chunk per [EVENT_INTERVAL_MS]: three events with ids and
 * names and a keepalive comment between them. The server then ends the response, so a client sees
 * the stream close after the third event.
 */
internal val EVENT_STREAM_SCRIPT = listOf(
    "id: 1\nevent: greeting\ndata: hello\n\n",
    ": keepalive\n\n",
    "id: 2\nevent: tick\ndata: {\"n\":2}\n\n",
    "id: 3\nevent: done\ndata: bye\n\n",
)

private const val STREAM_HEADERS = "HTTP/1.1 200 OK\r\n" +
    "Content-Type: text/event-stream\r\n" +
    "Cache-Control: no-cache\r\n" +
    "Connection: close\r\n\r\n"

private const val NOT_FOUND = "HTTP/1.1 404 Not Found\r\n" +
    "Content-Length: 0\r\n" +
    "Connection: close\r\n\r\n"

/**
 * Minimal HTTP server for server-sent events: `GET` [EVENT_STREAM_PATH] answers with
 * [EVENT_STREAM_SCRIPT] as `text/event-stream`, any other path with 404. One thread per client.
 */
internal class EventStreamServer(private val port: Int) {

    /** Binds the port (throws when it is taken) and accepts clients on a background thread. */
    fun start() {
        val serverSocket = ServerSocket()
        serverSocket.reuseAddress = true
        serverSocket.bind(InetSocketAddress(LOOPBACK_HOST, port))
        thread(isDaemon = true, name = "sample-sse-accept") {
            while (!serverSocket.isClosed) {
                val client = try {
                    serverSocket.accept()
                } catch (e: IOException) {
                    Log.w(TAG, "Event stream server stopped accepting", e)
                    break
                }
                thread(isDaemon = true, name = "sample-sse-client") { serve(client) }
            }
        }
    }

    private fun serve(client: Socket) = client.use { socket ->
        try {
            val path = readRequestPath(socket) ?: return
            val out = socket.getOutputStream()
            if (path != EVENT_STREAM_PATH) {
                out.writeAscii(NOT_FOUND)
                return
            }
            out.writeAscii(STREAM_HEADERS)
            EVENT_STREAM_SCRIPT.forEach { chunk ->
                Thread.sleep(EVENT_INTERVAL_MS)
                out.write(chunk.toByteArray(Charsets.UTF_8))
                out.flush()
            }
        } catch (_: IOException) {
            // The client went away mid-stream.
        }
    }

    /** Reads the request line and headers; returns the path without its query. */
    private fun readRequestPath(socket: Socket): String? {
        val reader = BufferedReader(InputStreamReader(socket.getInputStream(), Charsets.US_ASCII))
        val requestLine = reader.readLine() ?: return null
        while (true) {
            val header = reader.readLine()
            if (header.isNullOrEmpty()) break
        }
        return requestLine.split(' ').getOrNull(1)?.substringBefore('?')
    }

    private fun OutputStream.writeAscii(text: String) {
        write(text.toByteArray(Charsets.US_ASCII))
        flush()
    }
}
