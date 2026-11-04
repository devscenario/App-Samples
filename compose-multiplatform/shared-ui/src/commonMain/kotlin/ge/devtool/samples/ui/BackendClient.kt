package ge.devtool.samples.ui

/** Launch argument overriding the sample backend's base URL (Android string extra, iOS `-backendUrl <url>`). */
const val SAMPLE_BACKEND_URL_KEY = "backendUrl"

/** Default base URL on an Android emulator: the host's loopback. */
const val ANDROID_DEFAULT_BACKEND_URL = "http://10.0.2.2:8095"

/** Default base URL on an iOS simulator, which shares the host's network. */
const val IOS_DEFAULT_BACKEND_URL = "http://localhost:8095"

/** What a backend call ended with, independent of the display language. */
internal sealed interface BackendOutcome {
    data class SignedIn(val session: String, val username: String) : BackendOutcome
    data object WrongCredentials : BackendOutcome
    data object Unreachable : BackendOutcome
    data object OrderPlaced : BackendOutcome
    data class Status(val status: String) : BackendOutcome
    data object NoOrder : BackendOutcome
}

/** The sample app's side of `test-backend`: sign-in and the current order. */
internal class BackendClient(private val baseUrl: String) {

    suspend fun signIn(username: String, password: String): BackendOutcome {
        val body = """{"username":${jsonString(username)},"password":${jsonString(password)}}"""
        val response = demoHttpCall("POST", "$baseUrl/app/login", body)
        return when {
            response.isError -> BackendOutcome.Unreachable
            response.code == HTTP_OK -> {
                val session = jsonStringField(response.bodyPreview, "session")
                val name = jsonStringField(response.bodyPreview, "username")
                if (session == null || name == null) BackendOutcome.Unreachable else BackendOutcome.SignedIn(session, name)
            }
            else -> BackendOutcome.WrongCredentials
        }
    }

    suspend fun placeOrder(session: String): BackendOutcome {
        val response = demoHttpCall("POST", "$baseUrl/app/orders", "{}", mapOf(SESSION_HEADER to session))
        return when {
            response.isError -> BackendOutcome.Unreachable
            response.code == HTTP_OK -> BackendOutcome.OrderPlaced
            else -> BackendOutcome.NoOrder
        }
    }

    suspend fun refreshStatus(session: String): BackendOutcome {
        val response = demoHttpCall("GET", "$baseUrl/app/orders/current", headers = mapOf(SESSION_HEADER to session))
        val status = jsonStringField(response.bodyPreview, "status")
        return when {
            response.isError -> BackendOutcome.Unreachable
            response.code == HTTP_OK && status != null -> BackendOutcome.Status(status)
            else -> BackendOutcome.NoOrder
        }
    }

    private companion object {
        const val HTTP_OK = 200
        const val SESSION_HEADER = "X-Session"
    }
}

/** The text a [BackendOutcome] shows in [strings]. */
internal fun BackendOutcome.text(strings: BackendStrings): String = when (this) {
    is BackendOutcome.SignedIn -> strings.signedIn(username)
    BackendOutcome.WrongCredentials -> strings.wrongCredentials
    BackendOutcome.Unreachable -> strings.unreachable
    BackendOutcome.OrderPlaced -> strings.orderPlaced
    is BackendOutcome.Status -> strings.status(status)
    BackendOutcome.NoOrder -> strings.noOrder
}

/** The string value of a top-level `"name":"…"` field; enough for the backend's flat replies. */
internal fun jsonStringField(json: String, name: String): String? =
    Regex("\"" + name + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"").find(json)?.groupValues?.get(1)

private fun jsonString(value: String): String =
    "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
