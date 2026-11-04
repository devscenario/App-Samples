package ge.devtool.samples.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInRoot
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex

@Composable
internal fun DragDropScreen() {
    val strings = LocalSampleStrings.current
    var statusText by remember { mutableStateOf(strings.dragStatusNone) }
    var draggingItem by remember { mutableStateOf<String?>(null) }

    var dropZoneTopLeft by remember { mutableStateOf(Offset.Zero) }
    var dropZoneSize by remember { mutableStateOf(IntSize.Zero) }
    // Row labels stay stable English keys (they double as `key(item)` identity
    // and are asserted literally by drag-drop.ds); mapped to the active
    // language only at render time.
    var listItems by remember { mutableStateOf(listOf(EnStrings.dragRowOne, EnStrings.dragRowTwo, EnStrings.dragRowThree)) }
    fun localizedRow(item: String): String = when (item) {
        EnStrings.dragRowOne -> strings.dragRowOne
        EnStrings.dragRowTwo -> strings.dragRowTwo
        EnStrings.dragRowThree -> strings.dragRowThree
        else -> item
    }

    // No verticalScroll: a scrollable container races detectDragGestures for vertical
    // motion and steals the gesture during touch slop, cancelling chip drags before they
    // can complete. So everything must fit on the smallest target, iPhone 16e (~750dp usable
    // height): with 14dp gaps and a 110dp drop zone, Row Three ended below the fold there.
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Text(
            strings.dragTitle,
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold
        )
        Text(strings.dragIntro, color = subtleText)

        StatusPill(
            text = strings.dragStatus(statusText),
            tone = PillTone.INFO,
            modifier = Modifier.testTag(TestTags.DRAG_STATUS),
        )

        // Drop zone
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(80.dp)
                .onGloballyPositioned { coords ->
                    dropZoneTopLeft = coords.positionInRoot()
                    dropZoneSize = coords.size
                }
                .clip(shape = RoundedCornerShape(18.dp))
                .background(if (draggingItem != null) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.35f))
                .border(
                    2.dp,
                    if (draggingItem != null) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.primary.copy(alpha = 0.35f),
                    RoundedCornerShape(18.dp)
                )
                .semantics { contentDescription = DROP_ZONE_DESC }
                .testTag(TestTags.DRAG_DROP_TARGET),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = draggingItem?.let { strings.dragDropHere(it) } ?: strings.dragDropZone,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.SemiBold
                )
                if (draggingItem == null) {
                    Text(strings.dragDropHint, style = MaterialTheme.typography.bodySmall, color = subtleText)
                }
            }
        }

        Text(strings.dragSources, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            // Chip names are language-neutral test-data identifiers: they are
            // matched literally by drag-drop.ds and drive `chipDescription`
            // (a content-description test hook), so they are NOT translated.
            listOf(
                "Alpha" to TestTags.DRAG_ITEM_ALPHA,
                "Beta"  to TestTags.DRAG_ITEM_BETA,
                "Gamma" to TestTags.DRAG_ITEM_GAMMA
            ).forEachIndexed { index, (name, tag) ->
                DraggableChip(
                    name = name,
                    color = SampleAccents.tileTints[index].first,
                    description = chipDescription(name),
                    isDragging = draggingItem == name,
                    modifier = Modifier.testTag(tag),
                    onDragStarted = {
                        draggingItem = name
                        statusText = strings.dragDragging(name)
                    },
                    onDragEnded = { finalCenter ->
                        draggingItem = null
                        val inZone = finalCenter.isInDropZone(dropZoneTopLeft, dropZoneSize)
                        statusText = if (inZone) strings.dragDroppedInZone(name) else strings.dragCancelled(name)
                    }
                )
            }
        }

        Text(strings.dragReorderable, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
        Text(strings.dragReorderHint, color = subtleText)

        listItems.forEachIndexed { index, item ->
            key(item) {
                ReorderableRow(
                    text = localizedRow(item),
                    handleLabel = strings.dragHandleLabel,
                    modifier = Modifier.testTag("${TestTags.DRAG_REORDER_ITEM_PREFIX}${index + 1}"),
                    onDragStarted = { statusText = strings.dragPickedUp(localizedRow(item)) },
                    onMoveUp = {
                        if (index > 0) {
                            val mutable = listItems.toMutableList()
                            mutable.removeAt(index)
                            mutable.add(index - 1, item)
                            listItems = mutable
                            statusText = strings.dragMovedUp(localizedRow(item))
                        }
                    },
                    onMoveDown = {
                        if (index < listItems.lastIndex) {
                            val mutable = listItems.toMutableList()
                            mutable.removeAt(index)
                            mutable.add(index + 1, item)
                            listItems = mutable
                            statusText = strings.dragMovedDown(localizedRow(item))
                        }
                    }
                )
            }
        }

        Spacer(modifier = Modifier.height(32.dp))
    }
}

@Composable
private fun DraggableChip(
    name: String,
    color: Color,
    description: String,
    isDragging: Boolean,
    modifier: Modifier = Modifier,
    onDragStarted: () -> Unit,
    onDragEnded: (Offset) -> Unit
) {
    // Always call the latest lambda even though pointerInput(Unit) never restarts.
    val currentOnDragStarted by rememberUpdatedState(onDragStarted)
    val currentOnDragEnded by rememberUpdatedState(onDragEnded)

    var offset by remember { mutableStateOf(Offset.Zero) }
    var basePosition by remember { mutableStateOf(Offset.Zero) }
    var chipSize by remember { mutableStateOf(IntSize.Zero) }

    fun currentCenter(): Offset = basePosition + offset + Offset(chipSize.width / 2f, chipSize.height / 2f)

    Box(
        modifier = modifier
            // Float dragged chip above siblings in the Row.
            .zIndex(if (isDragging) 10f else 0f)
            .onGloballyPositioned { coords ->
                if (!isDragging) basePosition = coords.positionInRoot()
                chipSize = coords.size
            }
            .graphicsLayer {
                translationX = offset.x
                translationY = offset.y
                scaleX = if (isDragging) 1.08f else 1f
                scaleY = if (isDragging) 1.08f else 1f
                alpha = if (isDragging) 0.9f else 1f
            }
            .pointerInput(Unit) {
                // `detectDragGestures` is Compose's higher-level drag detector.
                // Compared to the hand-rolled `awaitEachGesture` loop we had
                // here previously, it survives the touch-cancel events that
                // Compose Multiplatform iOS emits routinely during a single
                // continuous drag — the source of the "blink" symptom where
                // the chip flickered through Dragging → cancel → Dragging
                // multiple times per finger movement. `detectDragGestures`
                // treats those as part of the same drag and only fires
                // onDragEnd / onDragCancel when the *user* actually lifts.
                //
                // Tradeoff: there is ~24dp of touch slop before onDragStart
                // fires. For both manual users and the WDA-driven E2E flows
                // the drag distance is >>24dp (chip → drop zone is hundreds
                // of dp), so slop is crossed within the first few events.
                detectDragGestures(
                    onDragStart = { currentOnDragStarted() },
                    onDrag = { _, dragAmount -> offset += dragAmount },
                    onDragEnd = {
                        currentOnDragEnded(currentCenter())
                        offset = Offset.Zero
                    },
                    onDragCancel = {
                        currentOnDragEnded(currentCenter())
                        offset = Offset.Zero
                    }
                )
            }
            .background(
                color = if (isDragging) color.copy(alpha = 0.85f) else color,
                shape = RoundedCornerShape(50)
            )
            .semantics { contentDescription = description }
            .padding(horizontal = 18.dp, vertical = 10.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(name, color = Color.White, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun ReorderableRow(
    text: String,
    handleLabel: String,
    modifier: Modifier = Modifier,
    onDragStarted: () -> Unit,
    onMoveUp: () -> Unit,
    onMoveDown: () -> Unit
) {
    // rememberUpdatedState ensures the pointerInput(Unit) coroutine always
    // invokes the CURRENT lambda even after list reorder recompositions.
    val currentOnDragStarted by rememberUpdatedState(onDragStarted)
    val currentOnMoveUp by rememberUpdatedState(onMoveUp)
    val currentOnMoveDown by rememberUpdatedState(onMoveDown)

    var offsetY by remember { mutableStateOf(0f) }
    var isDragging by remember { mutableStateOf(false) }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .graphicsLayer {
                // Subtle lift feedback without large overlap/jump artifacts.
                translationY = if (isDragging) offsetY.coerceIn(-ROW_DRAG_VISUAL_OFFSET, ROW_DRAG_VISUAL_OFFSET) else 0f
            }
            .background(
                color = if (isDragging) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceContainerHigh,
                shape = RoundedCornerShape(14.dp)
            )
            .border(1.dp, if (isDragging) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outlineVariant, RoundedCornerShape(14.dp))
            .padding(horizontal = 16.dp, vertical = 14.dp)
            .pointerInput(Unit) {
                detectDragGestures(
                    onDragStart = {
                        isDragging = true
                        offsetY = 0f
                        currentOnDragStarted()
                    },
                    onDrag = { _, dragAmount ->
                        offsetY += dragAmount.y
                        if (offsetY < -REORDER_THRESHOLD) {
                            offsetY = 0f
                            currentOnMoveUp()
                        } else if (offsetY > REORDER_THRESHOLD) {
                            offsetY = 0f
                            currentOnMoveDown()
                        }
                    },
                    onDragEnd = {
                        isDragging = false
                        offsetY = 0f
                    },
                    onDragCancel = {
                        isDragging = false
                        offsetY = 0f
                    }
                )
            },
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text("⠿", color = subtleText, modifier = Modifier.padding(end = 12.dp))
        Text(text, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Medium)
        Spacer(modifier = Modifier.weight(1f))
        Box(
            modifier = Modifier
                .size(10.dp)
                .background(MaterialTheme.colorScheme.primary, RoundedCornerShape(50))
        )
        Spacer(modifier = Modifier.width(4.dp))
        Text(handleLabel, style = MaterialTheme.typography.bodySmall, color = subtleText)
    }
}

private fun Offset.isInDropZone(zoneTopLeft: Offset, zoneSize: IntSize): Boolean =
    x in zoneTopLeft.x..(zoneTopLeft.x + zoneSize.width) &&
    y in zoneTopLeft.y..(zoneTopLeft.y + zoneSize.height)

// ~one full row height in px at typical emulator density (≈2.75× → 48dp row ≈ 132px).
private const val REORDER_THRESHOLD = 110f
private const val ROW_DRAG_VISUAL_OFFSET = 24f

private const val DROP_ZONE_DESC = "drag-drop.target"

private fun chipDescription(name: String): String = "drag-drop.chip.${name.lowercase()}"


