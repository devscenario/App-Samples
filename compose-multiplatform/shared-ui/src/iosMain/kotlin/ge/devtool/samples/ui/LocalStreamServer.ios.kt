package ge.devtool.samples.ui

/**
 * What the iOS app's server starter hands back to [installLocalStreamServer]: the server's addresses,
 * or why it did not start. A Swift closure can't throw into Kotlin, so a failure is a value here.
 */
class LocalStreamServerStart private constructor(
    internal val endpoints: LocalStreamEndpoints?,
    internal val failure: String?,
) {
    companion object {
        fun started(webSocketUrl: String, eventStreamUrl: String) =
            LocalStreamServerStart(LocalStreamEndpoints(webSocketUrl, eventStreamUrl), null)

        fun failed(message: String) = LocalStreamServerStart(null, message)
    }
}

/**
 * Called by the iOS app's debug build: the stream demos call [start] (off the main thread, blocking)
 * the first time they need the local stream test server.
 */
fun installLocalStreamServer(start: () -> LocalStreamServerStart) {
    LocalStreamServerHook.install {
        val result = start()
        result.endpoints ?: throw IllegalStateException(result.failure ?: "unknown")
    }
}
