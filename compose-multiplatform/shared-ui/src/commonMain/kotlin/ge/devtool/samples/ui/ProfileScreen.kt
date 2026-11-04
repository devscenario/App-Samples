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
internal fun ProfileScreen() {
    val strings = LocalSampleStrings.current
    var displayName by remember { mutableStateOf("QA Tester") }
    var phone by remember { mutableStateOf("") }
    var marketingEnabled by remember { mutableStateOf(true) }
    var statusMessage by remember { mutableStateOf("") }
    val focusManager = LocalFocusManager.current

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(strings.profileTitle, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        OutlinedTextField(
            value = displayName,
            onValueChange = { displayName = it },
            label = { Text(strings.profileDisplayName) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
            keyboardActions = KeyboardActions(onNext = { focusManager.moveFocus(FocusDirection.Down) }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.PROFILE_NAME)
        )
        Text(strings.profileNameTyped(displayName), modifier = Modifier.testTag(TestTags.PROFILE_NAME_PREVIEW))
        OutlinedTextField(
            value = phone,
            onValueChange = { phone = it },
            label = { Text(strings.profilePhone) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.PROFILE_PHONE)
        )
        if (phone.isNotBlank()) {
            Text(strings.profilePhoneTyped(phone), modifier = Modifier.testTag(TestTags.PROFILE_PHONE_PREVIEW))
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .toggleable(
                    value = marketingEnabled,
                    role = Role.Switch,
                    onValueChange = { marketingEnabled = it }
                ),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(strings.profileMarketingEmails)
            Switch(
                checked = marketingEnabled,
                onCheckedChange = null,
                modifier = Modifier.testTag(TestTags.PROFILE_MARKETING)
            )
        }
        Button(
            onClick = {
                statusMessage = when {
                    displayName.length < 2 -> strings.profileFailureName
                    phone.length < 7 -> strings.profileFailurePhone
                    else -> strings.profileSaved(displayName)
                }
            },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.PROFILE_SAVE)
        ) {
            Text(strings.profileSave)
        }
        if (statusMessage.isNotBlank()) {
            Text(statusMessage, modifier = Modifier.testTag(TestTags.PROFILE_STATUS))
        }
    }
}

