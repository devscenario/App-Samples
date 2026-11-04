package ge.devtool.samples.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

/** How a status pill is coloured: done / in progress / plain. */
internal enum class PillTone { SUCCESS, INFO, NEUTRAL }

/** A small rounded label, e.g. "Status: Ready". The text is shown as given, so flows can assert it. */
@Composable
internal fun StatusPill(text: String, tone: PillTone, modifier: Modifier = Modifier) {
    val colors = MaterialTheme.colorScheme
    val (bg, fg) = when (tone) {
        PillTone.SUCCESS -> SampleAccents.successSoft to SampleAccents.success
        PillTone.INFO -> colors.primaryContainer to colors.onPrimaryContainer
        PillTone.NEUTRAL -> colors.surfaceContainerHighest to colors.onSurfaceVariant
    }
    Text(
        text,
        color = fg,
        style = MaterialTheme.typography.labelMedium,
        fontWeight = FontWeight.SemiBold,
        modifier = modifier.background(bg, CircleShape).padding(horizontal = 10.dp, vertical = 4.dp),
    )
}

/** A round badge with a name's first letter, tinted by [index]. */
@Composable
internal fun InitialAvatar(name: String, index: Int, size: Int = 44) {
    val (tint, badge) = SampleAccents.tileTints[index % SampleAccents.tileTints.size]
    Box(Modifier.size(size.dp).background(badge, CircleShape), contentAlignment = Alignment.Center) {
        Text(name.take(1).uppercase(), color = tint, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
    }
}

/** A white rounded card with a hairline border: the base surface for rows and groups. */
@Composable
internal fun SurfaceCard(
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit,
) {
    val colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerHigh)
    val border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant)
    if (onClick != null) {
        Card(onClick = onClick, modifier = modifier, shape = MaterialTheme.shapes.medium, colors = colors, border = border, content = content)
    } else {
        Card(modifier = modifier, shape = MaterialTheme.shapes.medium, colors = colors, border = border, content = content)
    }
}

/** The "selected item" panel above a list or grid: a tinted card with a bold heading. */
@Composable
internal fun DetailPanel(title: String, modifier: Modifier = Modifier, content: @Composable ColumnScope.() -> Unit) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.medium,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer,
            contentColor = MaterialTheme.colorScheme.onPrimaryContainer,
        ),
    ) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(title, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
            content()
        }
    }
}

/** Secondary text colour, for subtitles in rows. */
internal val subtleText: Color
    @Composable get() = MaterialTheme.colorScheme.onSurfaceVariant
