package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch

/**
 * Network demo screen — the visible counterpart to the Dev Scenario
 * interceptor wiring.
 *
 * On first entry the screen automatically fires one request so the desktop
 * Network tab has something to show without any user action. The four
 * buttons below cover the common shapes consumers care about: a plain GET,
 * a POST with a JSON body, a JSON GET against a different host, and an
 * intentional 4xx so the panel's non-2xx rendering gets exercised.
 *
 * Every result is appended to a running log at the bottom so the user can
 * eyeball what the interceptor saw without alt-tabbing to the desktop app.
 * The whole screen scrolls, so the stream logs and the results fit a small phone.
 * [NetworkStreamsSection] adds WebSocket and SSE demos against a local test server.
 */
private data class NetworkCallEntry(
    val id: Int,
    val label: String,
    val method: String,
    val url: String,
    val state: NetworkCallState,
)

private sealed interface NetworkCallState {
    data object InFlight : NetworkCallState
    data class Done(val response: DemoHttpResponse) : NetworkCallState
}

@Composable
internal fun NetworkScreen() {
    val strings = LocalSampleStrings.current
    val scope = rememberCoroutineScope()
    val entries = remember { mutableStateListOf<NetworkCallEntry>() }
    var nextId by remember { mutableStateOf(0) }
    var autoStatus by remember { mutableStateOf(strings.networkAutoFiring) }

    fun fireCall(label: String, method: String, url: String, body: String? = null) {
        val id = nextId++
        entries += NetworkCallEntry(id, label, method, url, NetworkCallState.InFlight)
        scope.launch {
            val resp = demoHttpCall(method, url, body)
            val idx = entries.indexOfFirst { it.id == id }
            if (idx >= 0) entries[idx] = entries[idx].copy(state = NetworkCallState.Done(resp))
        }
    }

    // Auto-fire: the very point of this screen is to demonstrate that the
    // Dev Scenario interceptor needs zero per-call wiring. The user shouldn't have
    // to tap anything to see *one* request in the desktop's Network tab.
    LaunchedEffect(Unit) {
        val firstUrl = "https://jsonplaceholder.typicode.com/posts/1"
        val id = nextId++
        entries += NetworkCallEntry(id, strings.networkAutoLabel, "GET", firstUrl, NetworkCallState.InFlight)
        val resp = demoHttpCall("GET", firstUrl)
        val idx = entries.indexOfFirst { it.id == id }
        if (idx >= 0) entries[idx] = entries[idx].copy(state = NetworkCallState.Done(resp))
        autoStatus = if (resp.isError) {
            strings.networkAutoFailed(resp.errorMessage.orEmpty())
        } else {
            strings.networkAutoDone(resp.code, resp.durationMs)
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        // Header — explains *why* this screen exists. Without a one-liner here
        // the demo just looks like "a screen with four buttons."
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.3f),
            ),
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text(
                    strings.networkDemoTitle,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                )
                Text(
                    strings.networkDemoBody,
                    style = MaterialTheme.typography.bodySmall,
                )
                Text(
                    autoStatus,
                    style = MaterialTheme.typography.labelSmall,
                    modifier = Modifier.padding(top = 6.dp).testTag(TestTags.NETWORK_AUTO_STATUS),
                )
            }
        }

        // Action grid — keep buttons full-width so tap targets stay
        // touch-friendly on small screens; vertical stack is also easier
        // for cross-platform E2E flows to target by test tag.
        Button(
            onClick = {
                fireCall(
                    "GET /posts/1",
                    "GET",
                    "https://jsonplaceholder.typicode.com/posts/1",
                )
            },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.NETWORK_BTN_GET_POST),
        ) { Text(strings.networkBtnGetPost) }

        Button(
            onClick = {
                fireCall(
                    "POST /posts",
                    "POST",
                    "https://jsonplaceholder.typicode.com/posts",
                    """{"title":"devtool","body":"hello","userId":1}""",
                )
            },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.NETWORK_BTN_POST_BODY),
        ) { Text(strings.networkBtnPostBody) }

        OutlinedButton(
            onClick = {
                fireCall(
                    "GET httpbin",
                    "GET",
                    "https://httpbin.org/get?source=devtool-sample",
                )
            },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.NETWORK_BTN_HTTPBIN),
        ) { Text(strings.networkBtnHttpbin) }

        OutlinedButton(
            onClick = {
                fireCall(
                    "GET → 404",
                    "GET",
                    "https://httpbin.org/status/404",
                )
            },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.NETWORK_BTN_404),
        ) { Text(strings.networkBtn404) }

        NetworkStreamsSection()

        // Results log — newest at the top, so the most recent call is the
        // first one below the demos.
        Surface(
            modifier = Modifier.fillMaxWidth().testTag(TestTags.NETWORK_RESULTS),
            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
            shape = RoundedCornerShape(8.dp),
        ) {
            Column(
                modifier = Modifier.padding(8.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                entries.reversed().forEach { entry ->
                    key(entry.id) { NetworkCallRow(entry) }
                }
            }
        }
    }
}

@Composable
private fun NetworkCallRow(entry: NetworkCallEntry) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(10.dp)) {
            Text(
                "${entry.method}  ${entry.label}",
                style = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.SemiBold,
            )
            Text(
                entry.url,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontFamily = FontFamily.Monospace,
            )
            when (val state = entry.state) {
                NetworkCallState.InFlight -> Box(
                    modifier = Modifier.fillMaxWidth().padding(top = 6.dp),
                    contentAlignment = Alignment.CenterStart,
                ) {
                    CircularProgressIndicator(modifier = Modifier.size(16.dp), strokeWidth = 2.dp)
                }
                is NetworkCallState.Done -> {
                    val color = when {
                        state.response.isError -> SampleAccents.error
                        state.response.code in 200..299 -> SampleAccents.success
                        else -> SampleAccents.warning
                    }
                    Text(
                        if (state.response.isError) {
                            "ERROR  ${state.response.errorMessage}"
                        } else {
                            "${state.response.code}  •  ${state.response.durationMs} ms"
                        },
                        modifier = Modifier
                            .clip(RoundedCornerShape(4.dp))
                            .padding(vertical = 4.dp),
                        color = color,
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.Bold,
                    )
                    if (state.response.bodyPreview.isNotBlank()) {
                        Text(
                            state.response.bodyPreview,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurface,
                            fontFamily = FontFamily.Monospace,
                            maxLines = 3,
                        )
                    }
                }
            }
        }
    }
}
