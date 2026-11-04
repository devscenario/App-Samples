package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
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

/** The screen's file, in the app's own storage (Android `filesDir`, iOS `Documents`). */
internal const val APP_FILE_NAME = "sample-log.txt"

/** The screen's text file; [read] is null when there is none. */
internal interface SampleAppFile {
    fun read(): String?
    fun write(text: String)
    fun delete()
}

@Composable
internal expect fun rememberSampleAppFile(): SampleAppFile

/** [current] with a numbered line added at the bottom. */
internal fun withNextLine(current: String?, line: (Int) -> String): String {
    val text = current.orEmpty()
    val lines = text.lineSequence().count { it.isNotEmpty() }
    val separator = if (text.isEmpty() || text.endsWith("\n")) "" else "\n"
    return "$text$separator${line(lines + 1)}\n"
}

/**
 * A file the app keeps in its own storage. The buttons add to it, show it and delete it, so a flow can check what the
 * app wrote with `read` and see what `file(…)` changed by tapping Read file.
 */
@Composable
internal fun AppFilesScreen() {
    val strings = LocalSampleStrings.current.appFiles
    val file = rememberSampleAppFile()
    var content by remember { mutableStateOf(file.read()) }
    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text(
            APP_FILE_NAME,
            style = MaterialTheme.typography.bodySmall,
            modifier = Modifier.testTag(TestTags.APP_FILES_NAME),
        )
        Button(
            onClick = {
                file.write(withNextLine(file.read(), strings::line))
                content = file.read()
            },
            modifier = Modifier.testTag(TestTags.APP_FILES_ADD),
        ) { Text(strings.add) }
        Button(onClick = { content = file.read() }, modifier = Modifier.testTag(TestTags.APP_FILES_READ)) {
            Text(strings.read)
        }
        Button(
            onClick = {
                file.delete()
                content = file.read()
            },
            modifier = Modifier.testTag(TestTags.APP_FILES_DELETE),
        ) { Text(strings.delete) }
        Text(
            when {
                content == null -> strings.missing
                content.isNullOrEmpty() -> strings.empty
                else -> content.orEmpty().trimEnd('\n')
            },
            style = MaterialTheme.typography.bodyLarge,
            modifier = Modifier.testTag(TestTags.APP_FILES_CONTENT),
        )
    }
}
