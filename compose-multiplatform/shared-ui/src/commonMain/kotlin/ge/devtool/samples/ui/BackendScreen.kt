package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch

/**
 * Signs in against `test-backend` and places and follows the user's order, so flows can
 * check app state that comes from a real backend (a username that changes, a status that moves on).
 */
@Composable
internal fun BackendScreen(baseUrl: String) {
    val strings = LocalSampleStrings.current.backend
    val client = remember(baseUrl) { BackendClient(baseUrl) }
    val scope = rememberCoroutineScope()
    var username by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var signIn by remember { mutableStateOf<BackendOutcome?>(null) }
    var order by remember { mutableStateOf<BackendOutcome?>(null) }
    var busy by remember { mutableStateOf(false) }
    val session = (signIn as? BackendOutcome.SignedIn)?.session

    fun launchCall(call: suspend () -> Unit) {
        busy = true
        scope.launch {
            try { call() } finally { busy = false }
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text(
            baseUrl,
            style = MaterialTheme.typography.labelSmall,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.testTag(TestTags.BACKEND_URL),
        )
        BackendCredentials(username, password, onUsername = { username = it }, onPassword = { password = it })
        Button(
            onClick = { launchCall { signIn = client.signIn(username.trim(), password); order = null } },
            enabled = !busy,
            modifier = Modifier.fillMaxWidth().testTag(TestTags.BACKEND_SIGN_IN),
        ) { Text(strings.signIn, maxLines = 1) }
        signIn?.let { Text(it.text(strings), modifier = Modifier.testTag(TestTags.BACKEND_STATUS)) }
        if (session != null) {
            OutlinedButton(
                onClick = { launchCall { order = client.placeOrder(session) } },
                enabled = !busy,
                modifier = Modifier.fillMaxWidth().testTag(TestTags.BACKEND_SUBMIT),
            ) { Text(strings.placeOrder, maxLines = 1) }
            OutlinedButton(
                onClick = { launchCall { order = client.refreshStatus(session) } },
                enabled = !busy,
                modifier = Modifier.fillMaxWidth().testTag(TestTags.BACKEND_REFRESH),
            ) { Text(strings.refresh, maxLines = 1) }
            order?.let { Text(it.text(strings), modifier = Modifier.testTag(TestTags.BACKEND_ORDER)) }
        }
    }
}

@Composable
private fun BackendCredentials(
    username: String,
    password: String,
    onUsername: (String) -> Unit,
    onPassword: (String) -> Unit,
) {
    val strings = LocalSampleStrings.current.backend
    OutlinedTextField(
        value = username,
        onValueChange = onUsername,
        label = { Text(strings.username) },
        singleLine = true,
        // No autocorrect or capitalization: usernames are typed exactly, as on iOS.
        keyboardOptions = KeyboardOptions(
            capitalization = KeyboardCapitalization.None,
            autoCorrectEnabled = false,
            keyboardType = KeyboardType.Ascii,
            imeAction = ImeAction.Next,
        ),
        modifier = Modifier.fillMaxWidth().testTag(TestTags.BACKEND_USERNAME),
    )
    OutlinedTextField(
        value = password,
        onValueChange = onPassword,
        label = { Text(strings.password) },
        singleLine = true,
        visualTransformation = PasswordVisualTransformation(),
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Done),
        modifier = Modifier.fillMaxWidth().testTag(TestTags.BACKEND_PASSWORD),
    )
}
