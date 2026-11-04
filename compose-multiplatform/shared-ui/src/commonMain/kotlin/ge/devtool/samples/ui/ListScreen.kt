package ge.devtool.samples.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
internal fun ListScreen() {
    val strings = LocalSampleStrings.current
    // `status` stays a stable English key in the data model; it is mapped to
    // the active language at render time so flows targeting English keep
    // working under the default English table.
    val items = remember {
        List(24) { index ->
            SampleOrderItem(
                id = "Order #${index + 1001}",
                customer = listOf("Guja", "Giorgi", "Anzori", "Luka")[index % 4],
                total = "$${42 + index * 7}.00",
                status = if (index % 3 == 0) EnStrings.listStatusReady else EnStrings.listStatusProcessing
            )
        }
    }
    fun localizedStatus(status: String): String = when (status) {
        EnStrings.listStatusReady -> strings.listStatusReady
        EnStrings.listStatusProcessing -> strings.listStatusProcessing
        else -> status
    }
    var selectedOrder by remember { mutableStateOf<SampleOrderItem?>(null) }

    Column(modifier = Modifier.fillMaxSize().padding(horizontal = 16.dp, vertical = 8.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        selectedOrder?.let { order ->
            DetailPanel(strings.listOrderDetails, modifier = Modifier.testTag(TestTags.LIST_DETAIL)) {
                Text(strings.listSelected(order.id))
                Text(strings.listCustomer(order.customer))
                Text(strings.listTotal(order.total))
                Text(strings.listStatus(localizedStatus(order.status)))
            }
        }

        LazyColumn(
            modifier = Modifier.weight(1f).fillMaxWidth().testTag(TestTags.LIST_CONTAINER),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            itemsIndexed(items) { index, order ->
                SurfaceCard(onClick = { selectedOrder = order }, modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier.padding(horizontal = 14.dp, vertical = 12.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        InitialAvatar(order.customer, index)
                        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(
                                order.id,
                                fontWeight = FontWeight.SemiBold,
                                style = MaterialTheme.typography.titleMedium,
                                modifier = Modifier.clickable { selectedOrder = order }
                            )
                            Text(strings.listCustomer(order.customer), color = subtleText, style = MaterialTheme.typography.bodyMedium)
                        }
                        StatusPill(
                            strings.listStatus(localizedStatus(order.status)),
                            if (order.status == EnStrings.listStatusReady) PillTone.SUCCESS else PillTone.INFO,
                        )
                    }
                }
            }
        }
    }
}

