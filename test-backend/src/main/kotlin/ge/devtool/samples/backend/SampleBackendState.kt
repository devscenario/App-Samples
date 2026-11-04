package ge.devtool.samples.backend

import java.time.Instant
import kotlin.random.Random

/**
 * In-memory state of the sample backend: OAuth client-credential tokens, the one test user and
 * its current order. All time is read from [clock] (epoch millis) so tests can step it.
 *
 * The test user's username is random and changes after every successful app sign-in. For
 * [PROVISIONING_MS] after each change (and after start or reset) the user search finds nobody,
 * so a caller has to retry until the new username shows up.
 */
class SampleBackendState(
    private val clock: () -> Long = System::currentTimeMillis,
    private val random: Random = Random.Default,
) {
    private val lock = Any()
    private val tokens = mutableMapOf<String, Long>()
    private val sessions = mutableSetOf<String>()
    private var username = ""
    private var provisionedAt = 0L
    private var order: StoredOrder? = null
    private var nextOrderId = FIRST_ORDER_ID

    init {
        reset()
    }

    /** Issues a bearer token for the sample client, or null when the credentials are wrong. */
    fun issueToken(clientId: String?, clientSecret: String?): String? {
        if (!isValidClient(clientId, clientSecret)) return null
        val token = randomToken()
        synchronized(lock) { tokens[token] = clock() + TOKEN_TTL_SECONDS * MILLIS_PER_SECOND }
        return token
    }

    fun isValidClient(clientId: String?, clientSecret: String?): Boolean =
        clientId == CLIENT_ID && clientSecret == CLIENT_SECRET

    fun isValidToken(token: String?): Boolean = synchronized(lock) {
        val expiresAt = token?.let { tokens[it] } ?: return false
        clock() < expiresAt
    }

    /** The user with [accountId], or null when unknown or still provisioning. */
    fun findUser(accountId: Long): UserAccount? = synchronized(lock) {
        if (accountId != ACCOUNT_ID || isProvisioning()) return null
        UserAccount(ACCOUNT_ID, username, USER_STATUS)
    }

    /** Signs the app in; on success returns the session and rotates the username. */
    fun login(user: String?, password: String?): LoginResult? = synchronized(lock) {
        if (user != username || password != USER_PASSWORD) return null
        val session = randomToken()
        sessions += session
        val signedInAs = username
        rotateUsername()
        LoginResult(session, signedInAs)
    }

    fun isValidSession(session: String?): Boolean = synchronized(lock) { session != null && session in sessions }

    /** Places the user's order, replacing any earlier one. */
    fun placeOrder(): OrderView = synchronized(lock) {
        val stored = StoredOrder(nextOrderId++, clock())
        order = stored
        stored.view(clock())
    }

    fun currentOrder(): OrderView? = synchronized(lock) { order?.view(clock()) }

    /** New username (provisioning again), no sessions, no order. Tokens stay valid. */
    fun reset() = synchronized(lock) {
        sessions.clear()
        order = null
        rotateUsername()
    }

    /** The username the app has to sign in with right now (for tests). */
    fun currentUsername(): String = synchronized(lock) { username }

    private fun isProvisioning(): Boolean = clock() - provisionedAt < PROVISIONING_MS

    private fun rotateUsername() {
        var next: String
        do {
            next = USERNAME_PREFIX + (1..USERNAME_SUFFIX_LENGTH).map { ALPHABET[random.nextInt(ALPHABET.length)] }
                .joinToString("")
        } while (next == username)
        username = next
        provisionedAt = clock()
    }

    private fun randomToken(): String =
        (1..TOKEN_LENGTH).map { ALPHABET[random.nextInt(ALPHABET.length)] }.joinToString("")

    private class StoredOrder(val orderId: Int, val createdAt: Long) {
        fun view(now: Long): OrderView {
            val age = now - createdAt
            val (status, changedAt) = when {
                age >= SHIPPED_AFTER_MS -> STATUS_SHIPPED to createdAt + SHIPPED_AFTER_MS
                age >= PACKED_AFTER_MS -> STATUS_PACKED to createdAt + PACKED_AFTER_MS
                else -> STATUS_PLACED to createdAt
            }
            return OrderView(orderId, status, Instant.ofEpochMilli(changedAt).toString())
        }
    }

    companion object {
        const val CLIENT_ID = "sample-client"
        const val CLIENT_SECRET = "sample-secret"
        const val TOKEN_TTL_SECONDS = 600
        const val ACCOUNT_ID = 1001L
        const val USER_PASSWORD = "sample-pass"
        const val USER_STATUS = "active"
        const val PROVISIONING_MS = 2_000L
        const val PACKED_AFTER_MS = 3_000L
        const val SHIPPED_AFTER_MS = 6_000L
        const val STATUS_PLACED = "Placed"
        const val STATUS_PACKED = "Packed"
        const val STATUS_SHIPPED = "Shipped"
        const val USERNAME_PREFIX = "sample_user_"
        private const val USERNAME_SUFFIX_LENGTH = 4
        private const val TOKEN_LENGTH = 32
        private const val FIRST_ORDER_ID = 70_001
        private const val MILLIS_PER_SECOND = 1_000L
        private const val ALPHABET = "abcdefghijklmnopqrstuvwxyz0123456789"
    }
}

data class UserAccount(val accountId: Long, val username: String, val status: String)

data class LoginResult(val session: String, val username: String)

data class OrderView(val orderId: Int, val status: String, val updatedAt: String)
