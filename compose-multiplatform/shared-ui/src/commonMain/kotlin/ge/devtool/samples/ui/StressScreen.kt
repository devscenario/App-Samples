package ge.devtool.samples.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay

private const val STRESS_ROWS = 500
private const val STRESS_DEEP_LEVELS = 24
private const val STRESS_GRID_ROWS = 6
private const val STRESS_GRID_COLUMNS = 4
private const val STRESS_CAROUSEL_EVERY = 10
private const val STRESS_CHIPS = 12
private const val STRESS_LATE_DELAY_MS = 2_000L

/**
 * A deliberately heavy screen for measuring how long a hierarchy walk takes: a 500-row lazy list
 * with nested rows and carousels, a deeply nested section, a static grid, and a row that only
 * appears two seconds after the screen opens. Content is English only and mirrors the native iOS
 * sample's Stress screen id for id.
 */
@Composable
internal fun StressScreen() {
    var status by remember { mutableStateOf("Tapped: none") }
    var lateReady by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        delay(STRESS_LATE_DELAY_MS)
        lateReady = true
    }
    val onTap: (String) -> Unit = { status = "Tapped: $it" }

    Column(modifier = Modifier.fillMaxSize().padding(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(status, fontWeight = FontWeight.SemiBold, modifier = Modifier.testTag(TestTags.STRESS_STATUS))
        Text(
            if (lateReady) "Late row: ready" else "Late row: pending",
            modifier = Modifier.testTag(TestTags.STRESS_LATE_STATUS),
        )
        LazyColumn(
            modifier = Modifier.weight(1f).fillMaxWidth().testTag(TestTags.STRESS_LIST),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            item(key = "header") {
                Text(
                    "Stress test",
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.testTag(TestTags.STRESS_HEADER),
                )
            }
            if (lateReady) item(key = "late") { StressLateRow(onTap) }
            item(key = "deep") { StressDeepSection() }
            item(key = "grid") { StressGrid(onTap) }
            items(count = STRESS_ROWS, key = { "row-${it + 1}" }) { StressRow(it + 1, onTap) }
            item(key = "end") {
                Text("End of stress list", modifier = Modifier.testTag(TestTags.STRESS_END))
            }
        }
    }
}

@Composable
private fun StressLateRow(onTap: (String) -> Unit) {
    Card(modifier = Modifier.fillMaxWidth().testTag(TestTags.STRESS_LATE)) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text("Late row ready", fontWeight = FontWeight.SemiBold)
            FilledTonalButton(
                onClick = { onTap("Late action") },
                modifier = Modifier.testTag(TestTags.STRESS_LATE_BUTTON),
            ) { Text("Late action") }
        }
    }
}

/** [STRESS_DEEP_LEVELS] nested boxes, each its own semantics node, around one leaf text. */
@Composable
private fun StressDeepSection() {
    StressDeepLevel(level = 1)
}

@Composable
private fun StressDeepLevel(level: Int) {
    Box(modifier = Modifier.fillMaxWidth().padding(start = 2.dp).testTag("${TestTags.STRESS_DEEP_PREFIX}$level")) {
        if (level < STRESS_DEEP_LEVELS) {
            StressDeepLevel(level + 1)
        } else {
            Text("Deep leaf", modifier = Modifier.testTag(TestTags.STRESS_DEEP_LEAF))
        }
    }
}

@Composable
private fun StressGrid(onTap: (String) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        repeat(STRESS_GRID_ROWS) { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp), modifier = Modifier.fillMaxWidth()) {
                repeat(STRESS_GRID_COLUMNS) { column ->
                    val cell = row * STRESS_GRID_COLUMNS + column + 1
                    Card(
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.surfaceContainerHigh,
                        ),
                        modifier = Modifier.weight(1f).clickable { onTap("Cell $cell") },
                    ) {
                        Text(
                            "Cell $cell",
                            modifier = Modifier.padding(8.dp).testTag("${TestTags.STRESS_GRID_PREFIX}$cell"),
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun StressRow(index: Int, onTap: (String) -> Unit) {
    Card(modifier = Modifier.fillMaxWidth().testTag("${TestTags.STRESS_ROW_PREFIX}$index")) {
        Row(modifier = Modifier.fillMaxWidth().padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Filled.Star,
                        contentDescription = "Row icon $index",
                        modifier = Modifier.size(20.dp),
                    )
                    Column(modifier = Modifier.padding(start = 8.dp)) {
                        Text("Row $index", fontWeight = FontWeight.SemiBold)
                        Text("Detail $index · group ${index % 10}", style = MaterialTheme.typography.bodySmall)
                    }
                }
                if (index % STRESS_CAROUSEL_EVERY == 0) StressCarousel(index, onTap)
            }
            FilledTonalButton(
                onClick = { onTap("Row $index") },
                modifier = Modifier.testTag("${TestTags.STRESS_ROW_PREFIX}$index.button"),
            ) { Text("Open $index") }
        }
    }
}

@Composable
private fun StressCarousel(row: Int, onTap: (String) -> Unit) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        modifier = Modifier.fillMaxWidth().padding(top = 8.dp)
            .testTag("${TestTags.STRESS_ROW_PREFIX}$row.carousel"),
    ) {
        items(count = STRESS_CHIPS, key = { it }) { j ->
            val chip = "Chip $row-${j + 1}"
            AssistChip(
                onClick = { onTap(chip) },
                label = { Text(chip) },
                modifier = Modifier.testTag("${TestTags.STRESS_CHIP_PREFIX}$row.${j + 1}"),
            )
        }
    }
}
