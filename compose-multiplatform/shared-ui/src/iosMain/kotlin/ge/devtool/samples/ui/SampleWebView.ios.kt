package ge.devtool.samples.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.UIKitInteropProperties
import androidx.compose.ui.viewinterop.UIKitView
import kotlinx.cinterop.ExperimentalForeignApi
import platform.CoreGraphics.CGRectMake
import platform.Foundation.NSURL
import platform.WebKit.WKScriptMessage
import platform.WebKit.WKScriptMessageHandlerProtocol
import platform.WebKit.WKUserContentController
import platform.WebKit.WKWebView
import platform.WebKit.WKWebViewConfiguration
import platform.darwin.NSObject

/** `WKWebView`; page events arrive through the `DevtoolSample` script message handler. */
@OptIn(ExperimentalForeignApi::class, androidx.compose.ui.ExperimentalComposeUiApi::class)
@Composable
internal actual fun SampleWebView(html: String, baseUrl: String, onEvent: (String) -> Unit, modifier: Modifier) {
    val callback by rememberUpdatedState(onEvent)
    // Held for the composable's lifetime; the content controller retains it too.
    val handler = remember { MessageHandler { callback(it) } }
    UIKitView(
        modifier = modifier,
        // Without native accessibility the WKWebView's content is hidden from accessibility clients,
        // so XCUITest (WDA) can't see or tap anything inside the page.
        properties = UIKitInteropProperties(isInteractive = true, isNativeAccessibilityEnabled = true),
        factory = {
            val config = WKWebViewConfiguration().apply {
                userContentController = WKUserContentController().apply { addScriptMessageHandler(handler, "DevtoolSample") }
            }
            WKWebView(frame = CGRectMake(0.0, 0.0, 0.0, 0.0), configuration = config).apply {
                loadHTMLString(html, baseURL = NSURL.URLWithString(baseUrl))
            }
        },
    )
}

private class MessageHandler(private val onEvent: (String) -> Unit) : NSObject(), WKScriptMessageHandlerProtocol {
    override fun userContentController(userContentController: WKUserContentController, didReceiveScriptMessage: WKScriptMessage) {
        (didReceiveScriptMessage.body as? String)?.let(onEvent)
    }
}
