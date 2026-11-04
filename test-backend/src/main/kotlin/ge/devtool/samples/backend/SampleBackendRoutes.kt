package ge.devtool.samples.backend

import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.server.application.ApplicationCall
import io.ktor.server.request.receiveParameters
import io.ktor.server.request.receiveText
import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import io.ktor.server.routing.post
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import java.util.Base64

private const val ACCOUNT_ID_HEADER = "X-Account-Id"
private const val SESSION_HEADER = "X-Session"
private const val NO_ORDER = "No order"

/** Test-side endpoints: token, user search, order status. */
fun Route.testSideRoutes(state: SampleBackendState) {
    post("/auth/token") {
        val grantType = call.receiveParameters()["grant_type"]
        val (clientId, secret) = basicCredentials(call) ?: (null to null)
        when {
            !state.isValidClient(clientId, secret) -> call.respondError(HttpStatusCode.Unauthorized, "invalid_client")
            grantType != "client_credentials" -> call.respondError(HttpStatusCode.BadRequest, "unsupported_grant_type")
            else -> call.respond(buildJsonObject {
                put("access_token", state.issueToken(clientId, secret).orEmpty())
                put("token_type", "Bearer")
                put("expires_in", SampleBackendState.TOKEN_TTL_SECONDS)
            })
        }
    }
    get("/users/search") {
        if (!call.hasValidBearer(state)) return@get call.respondError(HttpStatusCode.Unauthorized, "invalid_token")
        val user = call.request.queryParameters["accountId"]?.trim()?.toLongOrNull()?.let(state::findUser)
        call.respond(buildJsonObject {
            put("users", buildJsonArray { if (user != null) add(user.toJson()) })
            put("count", if (user == null) 0 else 1)
        })
    }
    get("/orders/current") {
        if (!call.hasValidBearer(state)) return@get call.respondError(HttpStatusCode.Unauthorized, "invalid_token")
        val accountId = call.request.headers[ACCOUNT_ID_HEADER]?.trim()?.toLongOrNull()
        val order = state.currentOrder()
        if (accountId != SampleBackendState.ACCOUNT_ID || order == null) {
            return@get call.respondError(HttpStatusCode.NotFound, NO_ORDER)
        }
        call.respond(order.toJson())
    }
}

/** Endpoints the sample app calls. */
fun Route.appRoutes(state: SampleBackendState) {
    post("/app/login") {
        val body = call.jsonBody()
        val result = state.login(body["username"].asStringOrNull(), body["password"].asStringOrNull())
            ?: return@post call.respondError(HttpStatusCode.Unauthorized, "Wrong username or password")
        call.respond(buildJsonObject {
            put("session", result.session)
            put("username", result.username)
        })
    }
    post("/app/orders") {
        if (!state.isValidSession(call.request.headers[SESSION_HEADER])) {
            return@post call.respondError(HttpStatusCode.Unauthorized, "invalid_session")
        }
        call.respond(state.placeOrder().toJson())
    }
    get("/app/orders/current") {
        if (!state.isValidSession(call.request.headers[SESSION_HEADER])) {
            return@get call.respondError(HttpStatusCode.Unauthorized, "invalid_session")
        }
        val order = state.currentOrder() ?: return@get call.respondError(HttpStatusCode.NotFound, NO_ORDER)
        call.respond(order.toJson())
    }
}

/** Housekeeping: reset and health. */
fun Route.adminRoutes(state: SampleBackendState) {
    post("/test/reset") {
        state.reset()
        call.respond(buildJsonObject { put("ok", true) })
    }
    get("/health") { call.respond(buildJsonObject { put("ok", true) }) }
}

private fun basicCredentials(call: ApplicationCall): Pair<String, String>? {
    val header = call.request.headers[HttpHeaders.Authorization] ?: return null
    if (!header.startsWith("Basic ", ignoreCase = true)) return null
    val decoded = runCatching { String(Base64.getDecoder().decode(header.substring("Basic ".length).trim())) }
        .getOrNull() ?: return null
    val colon = decoded.indexOf(':')
    return if (colon < 0) null else decoded.substring(0, colon) to decoded.substring(colon + 1)
}

private fun ApplicationCall.hasValidBearer(state: SampleBackendState): Boolean {
    val header = request.headers[HttpHeaders.Authorization] ?: return false
    if (!header.startsWith("Bearer ", ignoreCase = true)) return false
    return state.isValidToken(header.substring("Bearer ".length).trim())
}

private suspend fun ApplicationCall.jsonBody(): JsonObject =
    runCatching { Json.parseToJsonElement(receiveText()) as? JsonObject }.getOrNull() ?: JsonObject(emptyMap())

private fun JsonElement?.asStringOrNull(): String? = (this as? JsonPrimitive)?.content

private suspend fun ApplicationCall.respondError(status: HttpStatusCode, message: String) =
    respond(status, buildJsonObject { put("error", message) })

private fun UserAccount.toJson() = buildJsonObject {
    put("accountId", accountId)
    put("username", username)
    put("status", status)
}

private fun OrderView.toJson() = buildJsonObject {
    put("orderId", orderId)
    put("status", status)
    put("updatedAt", updatedAt)
}
