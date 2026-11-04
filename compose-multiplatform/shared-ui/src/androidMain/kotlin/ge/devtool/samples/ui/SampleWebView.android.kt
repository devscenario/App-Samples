package ge.devtool.samples.ui

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

/** `android.webkit.WebView`; page events arrive on the `DevtoolSample` JavaScript interface. */
@SuppressLint("SetJavaScriptEnabled")
@Composable
internal actual fun SampleWebView(html: String, baseUrl: String, onEvent: (String) -> Unit, modifier: Modifier) {
    val callback by rememberUpdatedState(onEvent)
    AndroidView(
        modifier = modifier,
        factory = { context ->
            WebView(context).apply {
                settings.javaScriptEnabled = true
                settings.domStorageEnabled = true
                webViewClient = WebViewClient()
                val main = Handler(Looper.getMainLooper())
                addJavascriptInterface(
                    object {
                        // Called on a WebView background thread.
                        @JavascriptInterface
                        fun postMessage(event: String) = main.post { callback(event) }.let { }
                    },
                    "DevtoolSample",
                )
                loadDataWithBaseURL(baseUrl, html, "text/html", "utf-8", null)
            }
        },
    )
}
