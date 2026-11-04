package ge.devtool.samples.ui

import androidx.compose.runtime.Composable

/**
 * Returns a launcher for the platform's system file chooser. [onResult] gets
 * the chosen file's display name, or null when the user backed out.
 * [onUnavailable] runs instead when the device has no file chooser (Android
 * images without DocumentsUI).
 */
@Composable
internal expect fun rememberFilePicker(onUnavailable: () -> Unit, onResult: (String?) -> Unit): () -> Unit
