package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusDirection
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp

@Composable
internal fun LoginScreen() {
    val login = platformLoginStrings()
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var rememberMe by remember { mutableStateOf(false) }
    var statusMessage by remember { mutableStateOf("") }
    val focusManager = LocalFocusManager.current

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(login.welcome, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text(login.email) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
            keyboardActions = KeyboardActions(onNext = { focusManager.moveFocus(FocusDirection.Down) }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.LOGIN_EMAIL)
        )
        if (email.isNotBlank()) {
            Text(login.emailTyped(email), modifier = Modifier.testTag(TestTags.LOGIN_EMAIL_PREVIEW))
        }
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text(login.password) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.LOGIN_PASSWORD)
        )
        if (password.isNotBlank()) {
            Text(login.passwordTyped(password), modifier = Modifier.testTag(TestTags.LOGIN_PASSWORD_PREVIEW))
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .toggleable(
                    value = rememberMe,
                    role = Role.Switch,
                    onValueChange = { rememberMe = it }
                ),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Switch(
                checked = rememberMe,
                onCheckedChange = null,
                modifier = Modifier.testTag(TestTags.LOGIN_REMEMBER)
            )
            Text(login.rememberMe, modifier = Modifier.padding(start = 8.dp))
        }
        Button(
            onClick = {
                statusMessage = if (email.isValidEmail() && password.length >= 6) {
                    login.success(email)
                } else {
                    login.failure
                }
            },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.LOGIN_BUTTON)
        ) {
            Text(login.signIn)
        }
        if (statusMessage.isNotBlank()) {
            Text(statusMessage, modifier = Modifier.testTag(TestTags.LOGIN_STATUS))
        }
    }
}

