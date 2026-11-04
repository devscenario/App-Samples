package ge.devtool.samples.ui

/**
 * Cross-platform HTTP outcome used by [NetworkScreen]. Kept deliberately
 * boring — the value of the demo is in the *side effect* (each call surfaces
 * in Dev Scenario's Network tab), so the screen only renders a one-line summary.
 */
data class DemoHttpResponse(
    val code: Int,
    val durationMs: Long,
    val bodyPreview: String,
    val errorMessage: String? = null,
) {
    val isError: Boolean get() = errorMessage != null
}

/**
 * Upper bound for one demo call. A device whose network hangs (an emulator with a stale DNS
 * route) otherwise leaves the screen on "Firing initial request…" for longer than
 * `network.ds` waits (20 s); with it the call always ends as "done" or "failed".
 */
internal const val DEMO_HTTP_TIMEOUT_SECONDS = 12L

/**
 * Fires a single HTTP call on the platform's native networking stack:
 *
 *  - Android `actual` uses `OkHttpClient` — the Dev Scenario auto-wire plugin
 *    (`io.github.devscenario.httpinterceptor.auto`) rewrites the `Builder.build()` call
 *    so traffic flows through `NetworkLogInterceptor` without any code here.
 *  - iOS `actual` uses `NSURLSession` — the SwiftPM `DevScenarioHttpInterceptorAuto`
 *    product's `+load` hook swizzles the URLSession factories so traffic
 *    flows through the iOS interceptor URLProtocol without any code here.
 *
 * Either way the screen calls one function and the desktop's Network tab
 * lights up. Failures (network down, malformed URL, etc.) round-trip
 * through [DemoHttpResponse.errorMessage] instead of throwing — the demo
 * must never crash a sample app. [headers] are added to the request as given.
 */
expect suspend fun demoHttpCall(
    method: String,
    url: String,
    body: String? = null,
    headers: Map<String, String> = emptyMap(),
): DemoHttpResponse
