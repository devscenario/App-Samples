package ge.devtool.samples.android.regression

import android.app.UiAutomation
import android.os.SystemClock
import android.view.InputDevice
import android.view.MotionEvent
import androidx.compose.ui.geometry.Offset

/**
 * A tap in screen coordinates, injected through [UiAutomation] into whatever window is under it
 * (also outside the app's Compose windows, e.g. the area around a dialog): DOWN and UP at the same
 * point and time, the zero-length click UiAutomator's own gestures send.
 */
internal fun UiAutomation.injectTap(at: Offset) {
    val downTime = SystemClock.uptimeMillis()
    inject(MotionEvent.ACTION_DOWN, downTime, at)
    inject(MotionEvent.ACTION_UP, downTime, at)
}

private fun UiAutomation.inject(action: Int, downTime: Long, at: Offset) {
    val properties = MotionEvent.PointerProperties().apply { id = 0; toolType = MotionEvent.TOOL_TYPE_FINGER }
    val coords = MotionEvent.PointerCoords().apply { x = at.x; y = at.y; pressure = 1f; size = 1f }
    val event = MotionEvent.obtain(
        downTime, downTime, action, 1, arrayOf(properties), arrayOf(coords),
        0, 0, 1f, 1f, 0, 0, InputDevice.SOURCE_TOUCHSCREEN, 0,
    )
    try {
        check(injectInputEvent(event, true)) { "Could not inject $event" }
    } finally {
        event.recycle()
    }
}
