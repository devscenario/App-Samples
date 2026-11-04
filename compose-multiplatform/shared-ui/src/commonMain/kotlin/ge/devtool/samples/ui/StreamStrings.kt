package ge.devtool.samples.ui

/** Network screen stream demo strings. [SampleStrings.streams] picks the table for the active language. */
internal interface StreamStrings {
    val title: String
    val webSocketButton: String
    val sseButton: String
    val noServer: String
    val notOnPlatform: String
    fun serverFailed(message: String): String
    val wsConnecting: String
    val wsConnected: String
    fun wsMessage(text: String): String
    fun wsEcho(text: String): String
    fun wsClosed(code: Int): String
    fun wsFailed(message: String): String
    val sseConnecting: String
    val sseOpen: String
    fun sseEvent(id: String, type: String, data: String): String
    val sseClosed: String
    fun sseFailed(message: String): String
}

/** English stream demo strings. */
internal object EnStreamStrings : StreamStrings {
    override val title = "Streams"
    override val webSocketButton = "WebSocket"
    override val sseButton = "SSE"
    override val noServer = "No local server"
    override val notOnPlatform = "Not on this platform yet"
    override fun serverFailed(message: String) = "Server failed: $message"
    override val wsConnecting = "WS connecting"
    override val wsConnected = "WS connected"
    override fun wsMessage(text: String) = "WS message: $text"
    override fun wsEcho(text: String) = "WS echo: $text"
    override fun wsClosed(code: Int) = "WS closed: $code"
    override fun wsFailed(message: String) = "WS failed: $message"
    override val sseConnecting = "SSE connecting"
    override val sseOpen = "SSE open"
    override fun sseEvent(id: String, type: String, data: String) = "SSE event $id ($type): $data"
    override val sseClosed = "SSE closed"
    override fun sseFailed(message: String) = "SSE failed: $message"
}

/** Georgian stream demo strings. */
internal object KaStreamStrings : StreamStrings {
    override val title = "სტრიმები"
    override val webSocketButton = "WebSocket"
    override val sseButton = "SSE"
    override val noServer = "ლოკალური სერვერი არ არის"
    override val notOnPlatform = "ამ პლატფორმაზე ჯერ არ არის"
    override fun serverFailed(message: String) = "სერვერის შეცდომა: $message"
    override val wsConnecting = "WS უკავშირდება"
    override val wsConnected = "WS დაკავშირდა"
    override fun wsMessage(text: String) = "WS შეტყობინება: $text"
    override fun wsEcho(text: String) = "WS ექო: $text"
    override fun wsClosed(code: Int) = "WS დაიხურა: $code"
    override fun wsFailed(message: String) = "WS შეცდომა: $message"
    override val sseConnecting = "SSE უკავშირდება"
    override val sseOpen = "SSE გაიხსნა"
    override fun sseEvent(id: String, type: String, data: String) = "SSE მოვლენა $id ($type): $data"
    override val sseClosed = "SSE დაიხურა"
    override fun sseFailed(message: String) = "SSE შეცდომა: $message"
}
