package ge.devtool.samples.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSDocumentDirectory
import platform.Foundation.NSFileManager
import platform.Foundation.NSSearchPathForDirectoriesInDomains
import platform.Foundation.NSString
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.NSUserDomainMask
import platform.Foundation.create
import platform.Foundation.stringWithContentsOfFile
import platform.Foundation.writeToFile

/** The file in the app's `Documents` folder. */
@OptIn(ExperimentalForeignApi::class, BetaInteropApi::class)
@Composable
internal actual fun rememberSampleAppFile(): SampleAppFile = remember {
    val folder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).first() as String
    val path = "$folder/$APP_FILE_NAME"
    object : SampleAppFile {
        override fun read(): String? = NSString.stringWithContentsOfFile(path, NSUTF8StringEncoding, null)

        override fun write(text: String) {
            NSFileManager.defaultManager.createDirectoryAtPath(
                folder,
                withIntermediateDirectories = true,
                attributes = null,
                error = null,
            )
            NSString.create(string = text).writeToFile(path, atomically = true, encoding = NSUTF8StringEncoding, error = null)
        }

        override fun delete() {
            NSFileManager.defaultManager.removeItemAtPath(path, null)
        }
    }
}
