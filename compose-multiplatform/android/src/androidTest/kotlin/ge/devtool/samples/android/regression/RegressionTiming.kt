package ge.devtool.samples.android.regression

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/** Logcat tag of the one-line timing JSON. */
internal const val TIMING_LOG_TAG = "NativeRegressionTiming"

/** File (in the app's files dir) the timing JSON is also written to. */
internal const val TIMING_FILE_NAME = "native-regression-timing.json"

/** Instrumentation argument naming the units to run, e.g. `-e regressionUnits launch.ds,pinch.ds`. */
internal const val UNITS_ARGUMENT = "regressionUnits"

/**
 * Wall-clock timing of the run: the total from the first unit's first step to the last unit's last
 * step, and each unit's duration. Reported as one JSON line on logcat ([TIMING_LOG_TAG]) and in
 * [TIMING_FILE_NAME], also when a unit fails. With [selected] (unit file names) only those units run.
 */
internal class RegressionTiming(
    private val suite: String,
    private val context: Context,
    private val selected: Set<String>? = null,
) {

    private class UnitResult(val name: String, val file: String, val durationMs: Long, val passed: Boolean)

    private val results = mutableListOf<UnitResult>()
    private var startedAt = 0L

    fun start() {
        startedAt = SystemClock.elapsedRealtime()
    }

    fun unit(name: String, file: String, body: () -> Unit) {
        if (selected != null && file.substringAfterLast('/') !in selected) return
        val unitStart = SystemClock.elapsedRealtime()
        var passed = false
        try {
            body()
            passed = true
        } finally {
            results += UnitResult(name, file, SystemClock.elapsedRealtime() - unitStart, passed)
        }
    }

    fun finish(failure: Throwable?) {
        val totalMs = SystemClock.elapsedRealtime() - startedAt
        val json = JSONObject()
            .put("suite", suite)
            .put("status", if (failure == null) "PASSED" else "FAILED")
            .put("totalMs", totalMs)
            .put("device", "${Build.MANUFACTURER} ${Build.MODEL}")
            .put("sdkInt", Build.VERSION.SDK_INT)
            .put("units", JSONArray(results.map { it.toJson() }))
        selected?.let { json.put("selectedUnits", JSONArray(it.toList())) }
        failure?.let { json.put("failure", it.message ?: it.javaClass.name) }
        val line = json.toString()
        Log.i(TIMING_LOG_TAG, line)
        File(context.filesDir, TIMING_FILE_NAME).writeText(line)
    }

    companion object {
        /** The units named by [UNITS_ARGUMENT], or null (all units) when it is absent. */
        fun selectedUnits(arguments: Bundle): Set<String>? = arguments.getString(UNITS_ARGUMENT)
            ?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }?.toSet()
    }

    private fun UnitResult.toJson() = JSONObject()
        .put("unit", name)
        .put("file", file)
        .put("durationMs", durationMs)
        .put("status", if (passed) "PASSED" else "FAILED")
}
