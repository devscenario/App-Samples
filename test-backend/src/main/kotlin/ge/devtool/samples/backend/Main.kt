package ge.devtool.samples.backend

import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.application.Application
import io.ktor.server.application.createApplicationPlugin
import io.ktor.server.application.hooks.ResponseSent
import io.ktor.server.application.install
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation
import io.ktor.server.request.httpMethod
import io.ktor.server.request.uri
import io.ktor.server.routing.routing
import org.slf4j.LoggerFactory

private const val DEFAULT_PORT = 8095
private const val PORT_ENV = "SAMPLE_BACKEND_PORT"
private const val DEFAULT_HOST = "127.0.0.1"
private const val HOST_ENV = "SAMPLE_BACKEND_HOST"

private val log = LoggerFactory.getLogger("SampleBackend")

fun main() {
    val port = System.getenv(PORT_ENV)?.toIntOrNull() ?: DEFAULT_PORT
    val host = System.getenv(HOST_ENV)?.takeIf { it.isNotBlank() } ?: DEFAULT_HOST
    val state = SampleBackendState()
    log.info("Sample backend on http://$host:$port (account ${SampleBackendState.ACCOUNT_ID})")
    embeddedServer(Netty, port = port, host = host) { sampleBackend(state) }.start(wait = true)
}

/** Installs the JSON support, the request log and every route on [state]. */
fun Application.sampleBackend(state: SampleBackendState) {
    install(ContentNegotiation) { json() }
    install(RequestLog)
    routing {
        testSideRoutes(state)
        appRoutes(state)
        adminRoutes(state)
    }
}

/** One line per request: method, path, status. */
private val RequestLog = createApplicationPlugin("RequestLog") {
    on(ResponseSent) { call ->
        log.info("${call.request.httpMethod.value} ${call.request.uri} -> ${call.response.status()?.value}")
    }
}
