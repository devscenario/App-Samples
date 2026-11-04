package ge.devtool.samples.android

import android.util.Log

/**
 * Tiny stopwatch for E2E perf comparison. Each test wraps its body in
 * `measure("LoginTest") { ... }`, and the result is logged on a single line
 * so the CI can grep it out. The format mirrors what the Dev Scenario runner's
 * `command.completed` event emits (`durationMs`) so both numbers are directly
 * comparable.
 */
internal inline fun measure(name: String, block: () -> Unit) {
    val started = System.currentTimeMillis()
    var failure: Throwable? = null
    try {
        block()
    } catch (t: Throwable) {
        failure = t
        throw t
    } finally {
        val elapsed = System.currentTimeMillis() - started
        val status = if (failure == null) "PASSED" else "FAILED"
        Log.i("EspressoE2E", "$name $status durationMs=$elapsed")
        println("EspressoE2E $name $status durationMs=$elapsed")
    }
}
