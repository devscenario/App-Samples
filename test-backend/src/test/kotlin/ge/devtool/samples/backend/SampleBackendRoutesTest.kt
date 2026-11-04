package ge.devtool.samples.backend

import io.ktor.client.request.forms.submitForm
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.http.parameters
import io.ktor.server.testing.ApplicationTestBuilder
import io.ktor.server.testing.testApplication
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import java.util.Base64
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class SampleBackendRoutesTest {
    private var now = 5_000_000L
    private val state = SampleBackendState(clock = { now })

    private fun withBackend(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application { sampleBackend(state) }
        block()
    }

    private suspend fun ApplicationTestBuilder.token(secret: String = "sample-secret") =
        client.submitForm("/auth/token", parameters { append("grant_type", "client_credentials") }) {
            val basic = Base64.getEncoder().encodeToString("sample-client:$secret".toByteArray())
            header(HttpHeaders.Authorization, "Basic $basic")
        }

    @Test
    fun `token, user search and order status over HTTP`() = withBackend {
        assertEquals(HttpStatusCode.Unauthorized, token("bad").status)
        val tokenResponse = token()
        assertEquals(HttpStatusCode.OK, tokenResponse.status)
        val accessToken = Json.parseToJsonElement(tokenResponse.bodyAsText())
            .jsonObject["access_token"]!!.jsonPrimitive.content

        suspend fun search(id: String) = client.get("/users/search?accountId=$id") {
            header(HttpHeaders.Authorization, "Bearer $accessToken")
        }.bodyAsText()

        assertEquals("""{"users":[],"count":0}""", search("1001"))
        now += SampleBackendState.PROVISIONING_MS
        assertEquals(
            """{"users":[{"accountId":1001,"username":"${state.currentUsername()}","status":"active"}],"count":1}""",
            search("1001"),
        )
        assertTrue(search("1002").contains("\"count\":0"))

        val login = client.post("/app/login") {
            contentType(ContentType.Application.Json)
            setBody("""{"username":"${state.currentUsername()}","password":"sample-pass"}""")
        }
        assertEquals(HttpStatusCode.OK, login.status)
        val session = Json.parseToJsonElement(login.bodyAsText()).jsonObject["session"]!!.jsonPrimitive.content
        val placed = client.post("/app/orders") { header("X-Session", session) }.bodyAsText()
        assertTrue(placed.contains("\"status\":\"Placed\""))
        now += SampleBackendState.PACKED_AFTER_MS

        val current = client.get("/orders/current") {
            header(HttpHeaders.Authorization, "Bearer $accessToken")
            header("X-Account-Id", "1001")
        }
        assertTrue(current.bodyAsText().contains("\"status\":\"Packed\""))
        assertEquals(HttpStatusCode.Unauthorized, client.get("/orders/current").status)
        val appView = client.get("/app/orders/current") { header("X-Session", session) }.bodyAsText()
        assertTrue(appView.contains("\"status\":\"Packed\""))
    }

    @Test
    fun `wrong sign-in is rejected`() = withBackend {
        val response = client.post("/app/login") {
            contentType(ContentType.Application.Json)
            setBody("""{"username":"nobody","password":"sample-pass"}""")
        }
        assertEquals(HttpStatusCode.Unauthorized, response.status)
        assertTrue(response.bodyAsText().contains("Wrong username or password"))
    }
}
