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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
internal fun ShowcaseScreen() {
    val strings = LocalSampleStrings.current
    var notificationsEnabled by remember { mutableStateOf(true) }
    var progress by remember { mutableFloatStateOf(0.5f) }
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier.fillMaxSize()
            .verticalScroll(scrollState)
            .padding(16.dp)
            .testTag(TestTags.SHOWCASE_SCROLL),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(strings.showcaseTitle, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        Text(strings.showcaseIntro)

        // The whole row is the switch (and carries its tag): tapping its text flips it too.
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .toggleable(
                    value = notificationsEnabled,
                    role = Role.Switch,
                    onValueChange = { notificationsEnabled = it }
                )
                .testTag(TestTags.SHOWCASE_SWITCH),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(strings.showcaseEnableNotifications)
            Switch(checked = notificationsEnabled, onCheckedChange = null)
        }

        Text(strings.showcaseProgress)
        LinearProgressIndicator(
            progress = { progress },
            modifier = Modifier.fillMaxWidth().height(8.dp).testTag(TestTags.SHOWCASE_PROGRESS)
        )
        // Quarter steps: a drag settles on an exact value.
        Slider(
            value = progress,
            onValueChange = { progress = it },
            steps = SLIDER_STEPS,
            modifier = Modifier.fillMaxWidth().testTag(TestTags.SHOWCASE_SLIDER)
        )

        repeat(12) { index ->
            Row(
                modifier = Modifier.fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(if (index % 2 == 0) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceContainerHigh)
                    .padding(12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(strings.showcaseListElement(index + 1))
                Box(
                    modifier = Modifier
                        .size(34.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(MaterialTheme.colorScheme.primary)
                )
            }
        }

        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Button(onClick = {}, modifier = Modifier.weight(1f)) { Text(strings.showcasePrimary) }
            Button(onClick = {}, modifier = Modifier.weight(1f)) { Text(strings.showcaseSecondary) }
        }

        Text(
            text = strings.showcaseEnd,
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            style = MaterialTheme.typography.bodySmall
        )
    }
}

/** Values between the ends of the slider: 3 gives quarter steps. */
private const val SLIDER_STEPS = 3
