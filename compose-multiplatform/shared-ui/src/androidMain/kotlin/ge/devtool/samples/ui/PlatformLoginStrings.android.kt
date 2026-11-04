package ge.devtool.samples.ui

import android.content.res.Resources
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import ge.devtool.samples.sharedui.R

/**
 * Android `actual`: the login texts come from string resources, the way most Android apps load
 * theirs, so tools that work on resources (string swaps, the app's string record) reach them. The
 * per-app locale picks `values` or `values-ka`, matching the in-app language.
 */
@Composable
internal actual fun platformLoginStrings(): LoginStrings {
    val resources = LocalContext.current.resources
    return remember(resources) { ResourceLoginStrings(resources) }
}

/** Reads each text when it's shown, so a resource lookup happens on every composition. */
private class ResourceLoginStrings(private val res: Resources) : LoginStrings {
    override val welcome: String get() = res.getString(R.string.sample_login_welcome)
    override val email: String get() = res.getString(R.string.sample_login_email)
    override val password: String get() = res.getString(R.string.sample_login_password)
    override val rememberMe: String get() = res.getString(R.string.sample_login_remember_me)
    override val signIn: String get() = res.getString(R.string.sample_login_sign_in)
    override fun emailTyped(value: String): String = res.getString(R.string.sample_login_email_typed, value)
    override fun passwordTyped(value: String): String = res.getString(R.string.sample_login_password_typed, value)
    override fun success(email: String): String = res.getString(R.string.sample_login_success, email)
    override val failure: String get() = res.getString(R.string.sample_login_failure)
}
