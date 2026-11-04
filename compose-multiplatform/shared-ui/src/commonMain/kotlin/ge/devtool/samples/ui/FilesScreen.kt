package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
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

/**
 * Opens the platform file chooser — a separate process on both platforms
 * (Android DocumentsUI, iOS UIDocumentPickerViewController) — and shows the
 * chosen file's name. Exercises drivers across an app boundary: the in-app
 * SDK can't see the chooser, so flows rely on the cross-app fallback / WDA.
 */
@Composable
internal fun FilesScreen() {
    val strings = LocalSampleStrings.current
    var status by remember { mutableStateOf(strings.filesNone) }
    val pickFile = rememberFilePicker(onUnavailable = { status = strings.filesNoPicker }) { name ->
        status = name?.let(strings::filesSelected) ?: strings.filesCancelled
    }
    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Button(onClick = pickFile, modifier = Modifier.testTag(TestTags.FILES_PICK)) { Text(strings.filesPick) }
        Text(status, style = MaterialTheme.typography.bodyLarge, modifier = Modifier.testTag(TestTags.FILES_SELECTED))
    }
}
