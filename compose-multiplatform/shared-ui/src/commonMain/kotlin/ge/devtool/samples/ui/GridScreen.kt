package ge.devtool.samples.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
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
internal fun GridScreen() {
    val strings = LocalSampleStrings.current
    // `inventory` stays a stable English key in the data model; mapped to the
    // active language only at render time.
    val cards = remember {
        List(18) { index ->
            SampleProductItem(
                name = "Product ${index + 1}",
                price = "$${19 + index * 3}.99",
                inventory = if (index % 4 == 0) EnStrings.gridLowStock else EnStrings.gridInStock
            )
        }
    }
    fun localizedInventory(inventory: String): String = when (inventory) {
        EnStrings.gridLowStock -> strings.gridLowStock
        EnStrings.gridInStock -> strings.gridInStock
        else -> inventory
    }
    var selectedProduct by remember { mutableStateOf<SampleProductItem?>(null) }

    Column(modifier = Modifier.fillMaxSize().padding(horizontal = 16.dp, vertical = 8.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        selectedProduct?.let { product ->
            DetailPanel(strings.gridProductDetails, modifier = Modifier.testTag(TestTags.GRID_DETAIL)) {
                Text(strings.gridSelected(product.name))
                Text(strings.gridPrice(product.price))
                Text(strings.gridInventory(localizedInventory(product.inventory)))
            }
        }

        LazyVerticalGrid(
            columns = GridCells.Fixed(2),
            modifier = Modifier.weight(1f).fillMaxWidth().testTag(TestTags.GRID_CONTAINER),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            itemsIndexed(cards) { index, card ->
                val (tint, badge) = SampleAccents.tileTints[index % SampleAccents.tileTints.size]
                SurfaceCard(onClick = { selectedProduct = card }, modifier = Modifier.fillMaxWidth().height(120.dp)) {
                    Column(
                        modifier = Modifier.fillMaxSize().padding(12.dp),
                        verticalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Box(Modifier.size(26.dp).background(badge, MaterialTheme.shapes.small)) {
                                Box(Modifier.size(10.dp).align(Alignment.Center).background(tint, CircleShape))
                            }
                            Text(card.name, fontWeight = FontWeight.SemiBold)
                        }
                        Text(card.price, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                        StatusPill(
                            localizedInventory(card.inventory),
                            if (card.inventory == EnStrings.gridLowStock) PillTone.NEUTRAL else PillTone.SUCCESS,
                        )
                    }
                }
            }
        }
    }
}

