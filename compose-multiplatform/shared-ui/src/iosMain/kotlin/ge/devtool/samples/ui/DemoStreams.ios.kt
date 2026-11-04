package ge.devtool.samples.ui

import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.readBytes
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.receiveAsFlow
import platform.Foundation.NSData
import platform.Foundation.NSError
import platform.Foundation.NSHTTPURLResponse
import platform.Foundation.NSMutableURLRequest
import platform.Foundation.NSString
import platform.Foundation.NSURL
import platform.Foundation.NSURLErrorCancelled
import platform.Foundation.NSURLErrorDomain
import platform.Foundation.NSURLResponse
import platform.Foundation.NSURLSession
import platform.Foundation.NSURLSessionConfiguration
import platform.Foundation.NSURLSessionDataDelegateProtocol
import platform.Foundation.NSURLSessionDataTask
import platform.Foundation.NSURLSessionTask
import platform.Foundation.NSURLSessionWebSocketCloseCode
import platform.Foundation.NSURLSessionWebSocketDelegateProtocol
import platform.Foundation.NSURLSessionWebSocketMessage
import platform.Foundation.NSURLSessionWebSocketTask
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.create
import platform.Foundation.setValue
import platform.darwin.NSObject

private const val NORMAL_CLOSURE: NSURLSessionWebSocketCloseCode = 1000

/** URLSession's "no close code" value (`NSURLSessionWebSocketCloseCodeInvalid`). */
private const val NO_CLOSE_CODE: NSURLSessionWebSocketCloseCode = 0

/** NSURLSessionResponseAllow; the binding types the disposition as `Long`. */
private const val RESPONSE_ALLOW = 1L

@OptIn(BetaInteropApi::class)
private fun NSData.utf8(): String = NSString.create(data = this, encoding = NSUTF8StringEncoding)?.toString().orEmpty()

@OptIn(ExperimentalForeignApi::class)
private fun NSData.toByteArray(): ByteArray = bytes?.readBytes(length.toInt()) ?: ByteArray(0)

private fun NSError.isCancel(): Boolean = domain == NSURLErrorDomain && code == NSURLErrorCancelled

/**
 * Reports a WebSocket's open, close and completion to [events]. Messages come from the receive
 * loop in [openDemoWebSocket]. [events] closes after the first close or failure.
 */
private class DemoWebSocketDelegate(
    private val events: Channel<DemoWsEvent>,
) : NSObject(), NSURLSessionWebSocketDelegateProtocol {
    private var finished = false

    override fun URLSession(session: NSURLSession, webSocketTask: NSURLSessionWebSocketTask, didOpenWithProtocol: String?) {
        events.trySend(DemoWsEvent.Opened)
    }

    override fun URLSession(
        session: NSURLSession,
        webSocketTask: NSURLSessionWebSocketTask,
        didCloseWithCode: NSURLSessionWebSocketCloseCode,
        reason: NSData?,
    ) {
        finish(DemoWsEvent.Closed(didCloseWithCode.toInt(), reason?.utf8().orEmpty()))
    }

    override fun URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError: NSError?) {
        session.finishTasksAndInvalidate()
        val socket = task as? NSURLSessionWebSocketTask
        val code = socket?.closeCode ?: NO_CLOSE_CODE
        // A socket the app closed may complete without a close callback; it still has its code.
        val event = if (code != NO_CLOSE_CODE) {
            DemoWsEvent.Closed(code.toInt(), socket?.closeReason?.utf8().orEmpty())
        } else {
            DemoWsEvent.Failed(didCompleteWithError?.localizedDescription ?: "closed")
        }
        finish(event)
    }

    private fun finish(event: DemoWsEvent) {
        if (finished) return
        finished = true
        events.trySend(event)
        events.close()
    }
}

/** URLSession WebSocket on a delegate session, so the network interceptor sees it like the app's own. */
actual fun openDemoWebSocket(url: String): DemoWebSocket? {
    val nsUrl = NSURL.URLWithString(url) ?: return null
    val events = Channel<DemoWsEvent>(Channel.UNLIMITED)
    val delegate = DemoWebSocketDelegate(events)
    val session = NSURLSession.sessionWithConfiguration(
        configuration = NSURLSessionConfiguration.defaultSessionConfiguration,
        delegate = delegate,
        delegateQueue = null,
    )
    val task = session.webSocketTaskWithURL(nsUrl)
    fun receiveNext() {
        task.receiveMessageWithCompletionHandler { message: NSURLSessionWebSocketMessage?, _: NSError? ->
            // A failed read ends the loop; the close or failure is reported by the delegate.
            if (message == null) return@receiveMessageWithCompletionHandler
            events.trySend(DemoWsEvent.Message(message.string ?: message.data?.utf8().orEmpty()))
            receiveNext()
        }
    }
    task.resume()
    receiveNext()
    return object : DemoWebSocket {
        override val events: Flow<DemoWsEvent> = events.receiveAsFlow()

        override fun send(text: String) {
            task.sendMessage(NSURLSessionWebSocketMessage(text)) { _: NSError? -> }
        }

        override fun close() {
            task.cancelWithCloseCode(NORMAL_CLOSURE, reason = null)
        }
    }
}

/** Feeds a `text/event-stream` body to [DemoSseParser] and reports the stream's steps. */
private class DemoEventStreamDelegate(
    private val report: (DemoSseEvent) -> Unit,
    private val done: () -> Unit,
) : NSObject(), NSURLSessionDataDelegateProtocol {
    private val parser = DemoSseParser()
    private var failed = false

    override fun URLSession(
        session: NSURLSession,
        dataTask: NSURLSessionDataTask,
        didReceiveResponse: NSURLResponse,
        completionHandler: (Long) -> Unit,
    ) {
        val status = (didReceiveResponse as? NSHTTPURLResponse)?.statusCode?.toInt() ?: 0
        if (status == 200) {
            report(DemoSseEvent.Opened)
        } else {
            failed = true
            report(DemoSseEvent.Failed("HTTP $status"))
        }
        completionHandler(RESPONSE_ALLOW)
    }

    override fun URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData: NSData) {
        if (!failed) parser.feed(didReceiveData.toByteArray()).forEach(report)
    }

    override fun URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError: NSError?) {
        session.finishTasksAndInvalidate()
        when {
            failed -> Unit
            didCompleteWithError == null -> report(DemoSseEvent.Closed)
            !didCompleteWithError.isCancel() -> report(DemoSseEvent.Failed(didCompleteWithError.localizedDescription))
        }
        done()
    }
}

/** Reads the event stream with a data-delegate URLSession, chunk by chunk as it arrives. */
actual fun demoEventStream(url: String): Flow<DemoSseEvent>? {
    val nsUrl = NSURL.URLWithString(url) ?: return null
    return callbackFlow {
        val delegate = DemoEventStreamDelegate(report = { trySend(it) }, done = { channel.close() })
        val session = NSURLSession.sessionWithConfiguration(
            configuration = NSURLSessionConfiguration.defaultSessionConfiguration,
            delegate = delegate,
            delegateQueue = null,
        )
        val request = NSMutableURLRequest.requestWithURL(nsUrl)
        request.setValue("text/event-stream", forHTTPHeaderField = "Accept")
        val task = session.dataTaskWithRequest(request)
        task.resume()
        awaitClose { task.cancel() }
    }
}
