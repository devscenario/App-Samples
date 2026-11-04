package ge.devtool.samples.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import platform.Foundation.NSURL
import platform.UIKit.UIApplication
import platform.UIKit.UIDocumentPickerDelegateProtocol
import platform.UIKit.UIDocumentPickerViewController
import platform.UIKit.UIViewController
import platform.UniformTypeIdentifiers.UTTypeItem
import platform.darwin.NSObject

/** `UIDocumentPickerViewController` — a remote (out-of-process) view controller; name = URL's last path part. */
@Composable
// Every iOS device has the document picker, so [onUnavailable] never runs.
internal actual fun rememberFilePicker(onUnavailable: () -> Unit, onResult: (String?) -> Unit): () -> Unit {
    val callback by rememberUpdatedState(onResult)
    // Held for the composable's lifetime: the picker only keeps a weak reference to its delegate.
    val delegate = remember { PickerDelegate { callback(it) } }
    return {
        val picker = UIDocumentPickerViewController(forOpeningContentTypes = listOf(UTTypeItem), asCopy = true)
        picker.delegate = delegate
        topViewController()?.presentViewController(picker, animated = true, completion = null)
    }
}

private class PickerDelegate(private val onResult: (String?) -> Unit) : NSObject(), UIDocumentPickerDelegateProtocol {
    override fun documentPicker(controller: UIDocumentPickerViewController, didPickDocumentsAtURLs: List<*>) {
        onResult((didPickDocumentsAtURLs.firstOrNull() as? NSURL)?.lastPathComponent)
    }

    override fun documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
        onResult(null)
    }
}

private fun topViewController(): UIViewController? {
    var top = UIApplication.sharedApplication.keyWindow?.rootViewController
    while (top?.presentedViewController != null) top = top.presentedViewController
    return top
}
