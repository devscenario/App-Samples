package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

/** One stream demo's log lines and whether it is running. */
private class StreamDemoLog {
    val lines: SnapshotStateList<String> = mutableStateListOf()
    var running by mutableStateOf(false)

    /** Clears the log and runs [demo] unless a run is already going. */
    fun start(scope: CoroutineScope, demo: suspend ((String) -> Unit) -> Unit) {
        if (running) return
        running = true
        lines.clear()
        scope.launch {
            try {
                demo { line -> lines += line }
            } finally {
                running = false
            }
        }
    }
}

/**
 * WebSocket and SSE demos against the sample's local stream test server. Each button runs one
 * demo; its steps show as one line each, so flows can wait for any step by its text.
 */
@Composable
internal fun NetworkStreamsSection() {
    val strings = LocalSampleStrings.current.streams
    val scope = rememberCoroutineScope()
    val wsLog = remember { StreamDemoLog() }
    val sseLog = remember { StreamDemoLog() }
    Text(strings.title, style = MaterialTheme.typography.titleSmall)
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
        OutlinedButton(
            onClick = { wsLog.start(scope) { log -> runWebSocketDemo(strings, log) } },
            enabled = !wsLog.running,
            modifier = Modifier.weight(1f).testTag(TestTags.NETWORK_BTN_WEBSOCKET),
        ) { Text(strings.webSocketButton, maxLines = 1, overflow = TextOverflow.Ellipsis) }
        OutlinedButton(
            onClick = { sseLog.start(scope) { log -> runSseDemo(strings, log) } },
            enabled = !sseLog.running,
            modifier = Modifier.weight(1f).testTag(TestTags.NETWORK_BTN_SSE),
        ) { Text(strings.sseButton, maxLines = 1, overflow = TextOverflow.Ellipsis) }
    }
    if (wsLog.lines.isNotEmpty() || sseLog.lines.isNotEmpty()) {
        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(10.dp), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                StreamLogLines(wsLog.lines, TestTags.NETWORK_WS_LOG)
                StreamLogLines(sseLog.lines, TestTags.NETWORK_SSE_LOG)
            }
        }
    }
}

@Composable
private fun StreamLogLines(lines: List<String>, tag: String) {
    if (lines.isEmpty()) return
    Column(modifier = Modifier.fillMaxWidth().testTag(tag)) {
        lines.forEach { line ->
            Text(
                line,
                style = MaterialTheme.typography.labelSmall,
                fontFamily = FontFamily.Monospace,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}
