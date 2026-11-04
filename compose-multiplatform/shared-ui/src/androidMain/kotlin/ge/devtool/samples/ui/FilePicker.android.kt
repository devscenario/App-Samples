package ge.devtool.samples.ui

import android.content.ActivityNotFoundException
import android.net.Uri
import android.provider.OpenableColumns
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.platform.LocalContext

/** `ACTION_OPEN_DOCUMENT` (DocumentsUI, another process); the name comes from the provider. */
@Composable
internal actual fun rememberFilePicker(onUnavailable: () -> Unit, onResult: (String?) -> Unit): () -> Unit {
    val context = LocalContext.current
    val callback by rememberUpdatedState(onResult)
    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri: Uri? ->
        callback(uri?.let { displayName(context.contentResolver, it) })
    }
    val unavailable by rememberUpdatedState(onUnavailable)
    return {
        try {
            launcher.launch(arrayOf("*/*"))
        } catch (_: ActivityNotFoundException) {
            unavailable()
        }
    }
}

private fun displayName(resolver: android.content.ContentResolver, uri: Uri): String =
    resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
        if (cursor.moveToFirst()) cursor.getString(0) else null
    } ?: uri.lastPathSegment.orEmpty()
