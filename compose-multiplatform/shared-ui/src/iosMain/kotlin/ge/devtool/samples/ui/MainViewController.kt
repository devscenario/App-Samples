package ge.devtool.samples.ui

import androidx.compose.ui.window.ComposeUIViewController
import platform.Foundation.NSUserDefaults
import platform.UIKit.UIViewController

fun MainViewController(): UIViewController {
    // Launch arguments (`-env staging`) land in the arguments domain of the standard user defaults.
    val launchEnv = NSUserDefaults.standardUserDefaults.stringForKey(SAMPLE_LAUNCH_ENV_KEY)
    val backendUrl = NSUserDefaults.standardUserDefaults.stringForKey(SAMPLE_BACKEND_URL_KEY) ?: IOS_DEFAULT_BACKEND_URL
    return ComposeUIViewController { SampleApp(launchEnv, backendUrl) }
}

