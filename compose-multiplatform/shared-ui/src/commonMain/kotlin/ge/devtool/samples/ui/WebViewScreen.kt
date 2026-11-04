package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

/**
 * A native label above a WebView hosting [SAMPLE_WEB_PAGE]. Exercises drivers inside web content
 * (inputs, buttons, a checkbox, a link, scrolling) and hybrid checks: the page reports each action
 * through the JavaScript bridge, and the native label shows the last one.
 */
@Composable
internal fun WebViewScreen() {
    val strings = LocalSampleStrings.current
    var lastEvent by remember { mutableStateOf<String?>(null) }
    Column(
        modifier = Modifier.fillMaxSize().padding(horizontal = 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Text(
            strings.webLastEvent(lastEvent ?: strings.webNoEvent),
            style = MaterialTheme.typography.bodyMedium,
            modifier = Modifier.testTag(TestTags.WEBVIEW_EVENT),
        )
        SampleWebView(
            html = SAMPLE_WEB_PAGE,
            baseUrl = SAMPLE_WEB_BASE_URL,
            onEvent = { lastEvent = it },
            modifier = Modifier.fillMaxWidth().weight(1f).testTag(TestTags.WEBVIEW),
        )
    }
}

/** Platform WebView (Android `WebView`, iOS `WKWebView`) with JavaScript on and the `DevtoolSample` bridge. */
@Composable
internal expect fun SampleWebView(html: String, baseUrl: String, onEvent: (String) -> Unit, modifier: Modifier)
