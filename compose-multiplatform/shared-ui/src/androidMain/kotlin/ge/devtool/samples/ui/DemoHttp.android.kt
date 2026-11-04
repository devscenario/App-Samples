package ge.devtool.samples.ui

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.concurrent.TimeUnit

// THIS is the `OkHttpClient.Builder().build()` call the Dev Scenario auto-wire
// ASM transform rewrites at compile time. Inspect the dex output and you'll
// see a synthetic `addInterceptor(new NetworkLogInterceptor())` immediately
// before the `.build()` invocation, even though no such line appears here.
private val client = OkHttpClient.Builder().callTimeout(DEMO_HTTP_TIMEOUT_SECONDS, TimeUnit.SECONDS).build()

private const val JSON_MEDIA_TYPE = "application/json"
private const val MAX_PREVIEW_BYTES = 240
private const val NS_PER_MS = 1_000_000L

actual suspend fun demoHttpCall(
    method: String,
    url: String,
    body: String?,
    headers: Map<String, String>,
): DemoHttpResponse = withContext(Dispatchers.IO) {
    val startNs = System.nanoTime()
    runCatching {
        val builder = Request.Builder().url(url)
        headers.forEach { (name, value) -> builder.header(name, value) }
        when (method.uppercase()) {
            "POST" -> builder.post((body ?: "").toRequestBody(JSON_MEDIA_TYPE.toMediaType()))
            "DELETE" -> builder.delete((body ?: "").toRequestBody(JSON_MEDIA_TYPE.toMediaType()))
            else -> builder.get()
        }
        client.newCall(builder.build()).execute().use { resp ->
            val preview = resp.body?.string().orEmpty().take(MAX_PREVIEW_BYTES)
            val durationMs = (System.nanoTime() - startNs) / NS_PER_MS
            DemoHttpResponse(resp.code, durationMs, preview)
        }
    }.getOrElse { e ->
        val durationMs = (System.nanoTime() - startNs) / NS_PER_MS
        DemoHttpResponse(0, durationMs, "", e.message ?: e::class.simpleName ?: "unknown")
    }
}
