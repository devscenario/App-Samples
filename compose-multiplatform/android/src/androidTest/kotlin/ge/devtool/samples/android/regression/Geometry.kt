package ge.devtool.samples.android.regression

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.semantics.SemanticsNode
import androidx.compose.ui.unit.toSize

/** Bounds on screen, unclipped (the bounds a driver's hierarchy dump reports). */
internal fun SemanticsNode.screenBounds(): Rect = Rect(positionOnScreen, size.toSize())

internal fun SemanticsNode.screenCenter(): Offset = screenBounds().center

/** Placed, with a part left after clipping by its ancestors and the window. */
internal fun SemanticsNode.isDisplayed(): Boolean =
    layoutInfo.isPlaced && boundsInWindow.width > 0f && boundsInWindow.height > 0f
