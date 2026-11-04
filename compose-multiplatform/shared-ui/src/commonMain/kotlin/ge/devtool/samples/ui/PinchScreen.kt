package ge.devtool.samples.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlin.math.abs

@Composable
internal fun PinchScreen() {
    val strings = LocalSampleStrings.current
    var scale by remember { mutableFloatStateOf(1f) }
    var lastDelta by remember { mutableFloatStateOf(0f) }
    var gestureEvents by remember { mutableFloatStateOf(0f) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(strings.pinchTitle, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        Text(strings.pinchIntro)

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(MaterialTheme.colorScheme.primaryContainer)
                // A standard pinch, as in a photo viewer: fingers apart zoom in, together zoom out.
                .pointerInput(Unit) {
                    detectTransformGestures { _, _, zoomChange, _ ->
                        val updatedScale = (scale * zoomChange).coerceIn(MIN_SCALE, MAX_SCALE)
                        val effectiveDelta = updatedScale - scale
                        if (abs(effectiveDelta) > DELTA_EPSILON) {
                            lastDelta = effectiveDelta
                            gestureEvents += 1f
                        }
                        scale = updatedScale
                    }
                }
                .testTag(TestTags.PINCH_PLAYGROUND),
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier
                    .size(160.dp)
                    .graphicsLayer {
                        scaleX = scale
                        scaleY = scale
                    }
                    .clip(RoundedCornerShape(18.dp))
                    .background(MaterialTheme.colorScheme.primary)
                    .testTag(TestTags.PINCH_TARGET),
                contentAlignment = Alignment.Center
            ) {
                Text(strings.pinchMe, color = Color.White, fontWeight = FontWeight.Bold)
            }
        }

        val direction = when {
            lastDelta > DELTA_EPSILON -> strings.pinchDirIn
            lastDelta < -DELTA_EPSILON -> strings.pinchDirOut
            else -> strings.pinchDirNone
        }
        val displayScale = (scale * 100f).toInt() / 100f
        Text(
            text = strings.pinchStatus(displayScale, direction, gestureEvents.toInt()),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.PINCH_STATUS)
        )
    }
}

private const val MIN_SCALE = 0.6f
private const val MAX_SCALE = 2.2f
private const val DELTA_EPSILON = 0.005f

