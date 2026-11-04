package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

/** A promo-style bottom sheet the Modals screen shows on its own; Close, Back or a tap outside closes it. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun PromoSheet(onClose: () -> Unit) {
    val strings = LocalSampleStrings.current.modals
    ModalBottomSheet(onDismissRequest = onClose, modifier = Modifier.testTag(TestTags.MODALS_PROMO_SHEET)) {
        Column(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(strings.promoTitle, style = MaterialTheme.typography.titleLarge)
            Text(strings.promoBody)
            Button(onClick = onClose, modifier = Modifier.testTag(TestTags.MODALS_PROMO_CLOSE)) {
                Text(strings.close)
            }
        }
    }
}
