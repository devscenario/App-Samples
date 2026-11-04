package ge.devtool.samples.ui

import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.usePinned
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import platform.Foundation.NSData
import platform.Foundation.NSDate
import platform.Foundation.NSError
import platform.Foundation.NSHTTPURLResponse
import platform.Foundation.NSMutableData
import platform.Foundation.NSMutableURLRequest
import platform.Foundation.NSString
import platform.Foundation.NSURL
import platform.Foundation.NSURLRequest
import platform.Foundation.NSURLResponse
import platform.Foundation.NSURLSession
import platform.Foundation.NSURLSessionConfiguration
import platform.Foundation.NSURLSessionDataDelegateProtocol
import platform.Foundation.NSURLSessionDataTask
import platform.Foundation.NSURLSessionTask
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.appendData
import platform.Foundation.create
import platform.Foundation.dataWithBytes
import platform.Foundation.setHTTPBody
import platform.Foundation.setHTTPMethod
import platform.Foundation.setValue
import platform.Foundation.timeIntervalSince1970
import platform.darwin.NSObject

private const val MAX_PREVIEW_BYTES = 240

/**
 * `NSURLSessionDataDelegate` that accumulates the response body and signals
 * completion. We use the delegate-based path instead of the completion-handler
 * overload of `dataTaskWithRequest:` because Kotlin/Native's Foundation
 * bindings do not expose the latter with stable lambda interop (the call site
 * resolves to the no-completion overload regardless of explicit lambda typing).
 *
 * The delegate is a one-shot — it owns one in-flight request and forwards
 * the final state to [onComplete] exactly once. Concurrent calls each create
 * their own delegate + session pair, so there is no shared mutable state.
 */
private class DemoSessionDelegate(
    private val onComplete: (NSData?, NSURLResponse?, NSError?) -> Unit,
) : NSObject(), NSURLSessionDataDelegateProtocol {

    private val buffer = NSMutableData()
    private var capturedResponse: NSURLResponse? = null
    private var finished = false

    override fun URLSession(
        session: NSURLSession,
        dataTask: NSURLSessionDataTask,
        didReceiveResponse: NSURLResponse,
        completionHandler: (platform.Foundation.NSURLSessionResponseDisposition) -> Unit,
    ) {
        capturedResponse = didReceiveResponse
        // 1 == NSURLSessionResponseAllow. The Kotlin binding types the
        // disposition as `Long` even though the ObjC type is `NSInteger`.
        completionHandler(1L)
    }

    override fun URLSession(
        session: NSURLSession,
        dataTask: NSURLSessionDataTask,
        didReceiveData: NSData,
    ) {
        buffer.appendData(didReceiveData)
    }

    override fun URLSession(
        session: NSURLSession,
        task: NSURLSessionTask,
        didCompleteWithError: NSError?,
    ) {
        if (finished) return
        finished = true
        onComplete(buffer, capturedResponse, didCompleteWithError)
    }
}

@OptIn(ExperimentalForeignApi::class, BetaInteropApi::class)
actual suspend fun demoHttpCall(
    method: String,
    url: String,
    body: String?,
    headers: Map<String, String>,
): DemoHttpResponse = suspendCancellableCoroutine { cont ->
    val nsUrl = NSURL.URLWithString(url) ?: run {
        cont.resume(DemoHttpResponse(0, 0, "", "Invalid URL: $url"))
        return@suspendCancellableCoroutine
    }
    val request = NSMutableURLRequest.requestWithURL(nsUrl)
    request.setHTTPMethod(method.uppercase())
    request.setTimeoutInterval(DEMO_HTTP_TIMEOUT_SECONDS.toDouble())
    if (body != null) {
        val bytes = body.encodeToByteArray()
        val nsData = bytes.usePinned { pinned ->
            NSData.dataWithBytes(pinned.addressOf(0), bytes.size.toULong())
        }
        request.setHTTPBody(nsData)
        request.setValue("application/json", forHTTPHeaderField = "Content-Type")
    }
    headers.forEach { (name, value) -> request.setValue(value, forHTTPHeaderField = name) }

    val startSeconds = NSDate().timeIntervalSince1970
    val delegate = DemoSessionDelegate { data, response, error ->
        val durationMs = ((NSDate().timeIntervalSince1970 - startSeconds) * 1000).toLong()
        if (error != null) {
            cont.resume(DemoHttpResponse(0, durationMs, "", error.localizedDescription))
        } else {
            val httpResponse = response as? NSHTTPURLResponse
            val code = httpResponse?.statusCode?.toInt() ?: 0
            val preview = data?.let { d ->
                (NSString.create(data = d, encoding = NSUTF8StringEncoding) as String?)
                    ?.take(MAX_PREVIEW_BYTES)
            }.orEmpty()
            cont.resume(DemoHttpResponse(code, durationMs, preview))
        }
    }
    val session = NSURLSession.sessionWithConfiguration(
        configuration = NSURLSessionConfiguration.defaultSessionConfiguration,
        delegate = delegate,
        delegateQueue = null,
    )
    val task: NSURLSessionDataTask = session.dataTaskWithRequest(request as NSURLRequest)
    task.resume()
    cont.invokeOnCancellation { task.cancel() }
}
