package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusDirection
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp

@Composable
internal fun RegistrationScreen() {
    val strings = LocalSampleStrings.current
    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var acceptedTerms by remember { mutableStateOf(false) }
    var statusMessage by remember { mutableStateOf("") }
    var registered by remember { mutableStateOf(false) }
    val focusManager = LocalFocusManager.current
    val liveSuccessMessage = if (name.length >= 2 && email.isValidEmail() && password.length >= 8) {
        strings.registration.success(email)
    } else {
        ""
    }

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(strings.registration.createAccount, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text(strings.registration.fullName) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
            keyboardActions = KeyboardActions(onNext = { focusManager.moveFocus(FocusDirection.Down) }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.REG_NAME)
        )
        if (name.isNotBlank()) {
            Text(strings.registration.nameTyped(name), modifier = Modifier.testTag(TestTags.REG_NAME_PREVIEW))
        }
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text(strings.registration.email) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
            keyboardActions = KeyboardActions(onNext = { focusManager.moveFocus(FocusDirection.Down) }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.REG_EMAIL)
        )
        if (email.isNotBlank()) {
            Text(strings.registration.emailTyped(email), modifier = Modifier.testTag(TestTags.REG_EMAIL_PREVIEW))
        }
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text(strings.registration.password) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.REG_PASSWORD)
        )
        if (password.isNotBlank()) {
            Text(strings.registration.passwordTyped(password), modifier = Modifier.testTag(TestTags.REG_PASSWORD_PREVIEW))
        }
        Button(
            onClick = { acceptedTerms = !acceptedTerms },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.REG_TERMS)
        ) {
            Text(if (acceptedTerms) strings.registration.termsAccepted else strings.registration.acceptTerms)
        }
        if (liveSuccessMessage.isNotBlank()) {
            Text(liveSuccessMessage, modifier = Modifier.testTag(TestTags.REG_STATUS))
        }
        if (statusMessage.isNotBlank()) {
            Text(statusMessage, modifier = Modifier.testTag(TestTags.REG_STATUS))
        }
        Button(
            onClick = {
                registered = false
                statusMessage = when {
                    name.length < 2 -> strings.registration.failureName
                    !email.isValidEmail() -> strings.registration.failureEmail
                    password.length < 8 -> strings.registration.failurePassword
                    else -> {
                        registered = true
                        strings.registration.success(email)
                    }
                }
            },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.REG_SUBMIT)
        ) {
            Text(if (registered) statusMessage else strings.registration.register)
        }
    }
}

