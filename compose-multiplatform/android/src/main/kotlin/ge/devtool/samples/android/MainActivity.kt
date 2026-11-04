package ge.devtool.samples.android

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import ge.devtool.samples.android.streams.installLocalStreamServer
import ge.devtool.samples.ui.ANDROID_DEFAULT_BACKEND_URL
import ge.devtool.samples.ui.SAMPLE_BACKEND_URL_KEY
import ge.devtool.samples.ui.SAMPLE_LAUNCH_ENV_KEY
import ge.devtool.samples.ui.SampleApp

// AppCompatActivity (not the bare ComponentActivity) so the in-app language
// chooser's AppCompatDelegate.setApplicationLocales() applies on API 24+ — it
// requires an AppCompat host + theme to recreate the activity with the new
// per-app locale. The devtool reads that locale back via
// `cmd locale get-app-locales`.
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Debug builds hand the Network screen a local stream test server (started on first use);
        // release builds install nothing.
        installLocalStreamServer()
        val launchEnv = intent.getStringExtra(SAMPLE_LAUNCH_ENV_KEY)
        val backendUrl = intent.getStringExtra(SAMPLE_BACKEND_URL_KEY) ?: ANDROID_DEFAULT_BACKEND_URL
        setContent {
            // Test tags double as resource ids, so tools reading the accessibility tree from outside
            // the app (UIAutomator) can select by `id:` like the in-app SDK does.
            Box(Modifier.semantics { testTagsAsResourceId = true }) {
                SampleApp(launchEnv, backendUrl)
            }
        }
    }
}
