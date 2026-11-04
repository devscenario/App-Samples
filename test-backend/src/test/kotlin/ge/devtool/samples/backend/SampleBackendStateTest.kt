package ge.devtool.samples.backend

import ge.devtool.samples.backend.SampleBackendState.Companion.CLIENT_ID
import ge.devtool.samples.backend.SampleBackendState.Companion.CLIENT_SECRET
import ge.devtool.samples.backend.SampleBackendState.Companion.USER_PASSWORD
import ge.devtool.samples.backend.SampleBackendState.Companion.ACCOUNT_ID
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class SampleBackendStateTest {
    private var now = 1_000_000L
    private val state = SampleBackendState(clock = { now }, random = Random(7))

    @Test
    fun `token needs the sample client credentials and expires`() {
        assertNull(state.issueToken(CLIENT_ID, "wrong"))
        assertNull(state.issueToken(null, null))
        val token = assertNotNull(state.issueToken(CLIENT_ID, CLIENT_SECRET))
        assertTrue(state.isValidToken(token))
        assertFalse(state.isValidToken("other"))
        now += SampleBackendState.TOKEN_TTL_SECONDS * 1_000L
        assertFalse(state.isValidToken(token))
    }

    @Test
    fun `search is empty while provisioning, then finds the user`() {
        assertNull(state.findUser(ACCOUNT_ID))
        now += SampleBackendState.PROVISIONING_MS - 1
        assertNull(state.findUser(ACCOUNT_ID))
        now += 1
        val user = assertNotNull(state.findUser(ACCOUNT_ID))
        assertEquals(state.currentUsername(), user.username)
        assertTrue(user.username.matches(Regex("sample_user_[a-z0-9]{4}")))
        assertNull(state.findUser(1002L))
    }

    @Test
    fun `sign-in rotates the username and starts provisioning again`() {
        now += SampleBackendState.PROVISIONING_MS
        val first = state.currentUsername()
        assertNull(state.login(first, "nope"))
        val result = assertNotNull(state.login(first, USER_PASSWORD))
        assertEquals(first, result.username)
        assertTrue(state.isValidSession(result.session))
        assertNotEquals(first, state.currentUsername())
        assertNull(state.login(first, USER_PASSWORD))
        assertNull(state.findUser(ACCOUNT_ID))
        now += SampleBackendState.PROVISIONING_MS
        assertEquals(state.currentUsername(), state.findUser(ACCOUNT_ID)?.username)
    }

    @Test
    fun `order status follows its timeline`() {
        assertNull(state.currentOrder())
        val created = state.placeOrder()
        assertEquals(SampleBackendState.STATUS_PLACED, created.status)
        now += SampleBackendState.PACKED_AFTER_MS - 1
        assertEquals(SampleBackendState.STATUS_PLACED, state.currentOrder()?.status)
        now += 1
        assertEquals(SampleBackendState.STATUS_PACKED, state.currentOrder()?.status)
        now += SampleBackendState.SHIPPED_AFTER_MS - SampleBackendState.PACKED_AFTER_MS
        val shipped = assertNotNull(state.currentOrder())
        assertEquals(SampleBackendState.STATUS_SHIPPED, shipped.status)
        assertEquals(created.orderId, shipped.orderId)
    }

    @Test
    fun `a new order replaces the earlier one`() {
        val first = state.placeOrder()
        now += SampleBackendState.SHIPPED_AFTER_MS
        val second = state.placeOrder()
        assertNotEquals(first.orderId, second.orderId)
        assertEquals(SampleBackendState.STATUS_PLACED, state.currentOrder()?.status)
    }

    @Test
    fun `reset clears sessions and the order and rotates the username`() {
        now += SampleBackendState.PROVISIONING_MS
        val session = assertNotNull(state.login(state.currentUsername(), USER_PASSWORD)).session
        state.placeOrder()
        val before = state.currentUsername()
        state.reset()
        assertFalse(state.isValidSession(session))
        assertNull(state.currentOrder())
        assertNotEquals(before, state.currentUsername())
        assertNull(state.findUser(ACCOUNT_ID))
    }
}
