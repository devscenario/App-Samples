package ge.devtool.samples.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import java.io.File

/** The file in `Context.filesDir`. */
@Composable
internal actual fun rememberSampleAppFile(): SampleAppFile {
    val context = LocalContext.current
    return remember {
        val file = File(context.filesDir, APP_FILE_NAME)
        object : SampleAppFile {
            override fun read(): String? = if (file.isFile) file.readText() else null
            override fun write(text: String) = file.writeText(text)
            override fun delete() {
                file.delete()
            }
        }
    }
}
