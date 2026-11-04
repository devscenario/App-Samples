package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp

/**
 * A modal bottom sheet holding a text field. The sheet is its own window on Android, so typing into
 * it checks that text input reaches fields outside the screen's window.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun VerifyCodeSheet(onVerify: (code: String) -> Unit, onDismiss: () -> Unit) {
    val strings = LocalSampleStrings.current.modals
    var code by remember { mutableStateOf("") }
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        modifier = Modifier.testTag(TestTags.MODALS_VERIFY_SHEET),
    ) {
        Column(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Text(strings.verifyByCode, style = MaterialTheme.typography.titleLarge)
            OutlinedTextField(
                value = code,
                onValueChange = { code = it },
                label = { Text(strings.smsCode) },
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth().testTag(TestTags.MODALS_VERIFY_CODE),
            )
            Button(
                onClick = { onVerify(code) },
                modifier = Modifier.fillMaxWidth().testTag(TestTags.MODALS_VERIFY_SUBMIT),
            ) {
                Text(strings.verify)
            }
        }
    }
}
