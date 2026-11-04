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
import androidx.compose.material3.Card
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
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp

@Composable
internal fun CheckoutScreen() {
    val strings = LocalSampleStrings.current
    var address by remember { mutableStateOf("") }
    var expressDelivery by remember { mutableStateOf(false) }
    var statusMessage by remember { mutableStateOf("") }
    val paymentMethod = "Visa •••• 4242"
    val focusManager = LocalFocusManager.current

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(strings.checkoutTitle, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(strings.checkoutOrderSummary, fontWeight = FontWeight.SemiBold)
                Text(strings.checkoutProduct)
                Text(strings.checkoutSubtotal("\$89.99"))
                Text(strings.checkoutShipping(if (expressDelivery) "\$12.00" else "\$0.00"))
                Text(strings.checkoutTotal(if (expressDelivery) "\$101.99" else "\$89.99"), fontWeight = FontWeight.Bold)
            }
        }
        OutlinedTextField(
            value = address,
            onValueChange = { address = it },
            label = { Text(strings.checkoutShippingAddress) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.CHECKOUT_ADDRESS)
        )
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .toggleable(
                    value = expressDelivery,
                    role = Role.Switch,
                    onValueChange = { expressDelivery = it }
                ),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(strings.checkoutExpressDelivery)
            Switch(
                checked = expressDelivery,
                onCheckedChange = null,
                modifier = Modifier.testTag(TestTags.CHECKOUT_DELIVERY)
            )
        }
        Text(strings.checkoutPayment(paymentMethod), modifier = Modifier.testTag(TestTags.CHECKOUT_PAYMENT))
        Button(
            onClick = {
                statusMessage = if (address.length >= 8) {
                    strings.checkoutOrderPlaced(address)
                } else {
                    strings.checkoutFailure
                }
            },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.CHECKOUT_PLACE_ORDER)
        ) {
            Text(strings.checkoutPlaceOrder)
        }
        if (address.isNotBlank()) {
            Text(strings.checkoutAddressTyped(address), modifier = Modifier.testTag(TestTags.CHECKOUT_ADDRESS_PREVIEW))
        }
        if (statusMessage.isNotBlank()) {
            Text(statusMessage, modifier = Modifier.testTag(TestTags.CHECKOUT_STATUS))
        }
    }
}

