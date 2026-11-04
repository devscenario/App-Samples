package ge.devtool.samples.android

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import com.devscenario.app.instrumentation.DevScenarioInstrumentation
import com.devscenario.app.instrumentation.DevScenarioTestSupport

/**
 * Debug only: registers the actions a flow runs with `appAction`. `resetToHome` opens the start
 * screen in a fresh task, the way a test's setup would before each test. `sampleUser` hands the
 * flow a user name as the variable `SAMPLE_USER` (with a `suffix` argument appended when given).
 */
class SampleAppActions : ContentProvider() {

    override fun onCreate(): Boolean {
        val app = requireNotNull(context).applicationContext
        DevScenarioInstrumentation.registerAction("resetToHome") {
            DevScenarioTestSupport.startActivityAndWait(app, MainActivity::class.java)
        }
        DevScenarioInstrumentation.registerValueAction("sampleUser") { args ->
            mapOf("SAMPLE_USER" to "ada" + args["suffix"].orEmpty())
        }
        return true
    }

    override fun query(uri: Uri, p: Array<String>?, s: String?, a: Array<String>?, o: String?): Cursor? = null
    override fun getType(uri: Uri): String? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, s: String?, a: Array<String>?): Int = 0
    override fun update(uri: Uri, v: ContentValues?, s: String?, a: Array<String>?): Int = 0
}
