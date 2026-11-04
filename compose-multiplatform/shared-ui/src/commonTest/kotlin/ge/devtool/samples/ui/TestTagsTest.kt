package ge.devtool.samples.ui

import kotlin.test.Test
import kotlin.test.assertTrue

class TestTagsTest {
    @Test
    fun allTagPrefixesAreStable() {
        val tags = listOf(
            TestTags.APP_ROOT,
            TestTags.TAB_LOGIN,
            TestTags.TAB_REGISTRATION,
            TestTags.TAB_LIST,
            TestTags.TAB_GRID,
            TestTags.TAB_SHOWCASE,
            TestTags.TAB_SEARCH,
            TestTags.TAB_CHECKOUT,
            TestTags.TAB_PROFILE,
            TestTags.TAB_PINCH,
            TestTags.TAB_MODALS,
            TestTags.LOGIN_EMAIL,
            TestTags.REG_SUBMIT,
            TestTags.SHOWCASE_PROGRESS,
            TestTags.SEARCH_STATUS,
            TestTags.CHECKOUT_STATUS,
            TestTags.PROFILE_STATUS,
            TestTags.PINCH_PLAYGROUND,
            TestTags.PINCH_TARGET,
            TestTags.PINCH_STATUS,
            TestTags.MODALS_STATUS,
            TestTags.MODALS_OPEN_PARTIAL_SHEET,
            TestTags.MODALS_OPEN_FULL_SHEET,
            TestTags.MODALS_SHEET,
            TestTags.MODALS_SHEET_HIDE,
            TestTags.MODALS_OPEN_ALERT_DIALOG,
            TestTags.MODALS_ALERT_CONFIRM,
            TestTags.MODALS_ALERT_DISMISS,
            TestTags.MODALS_OPEN_FULLSCREEN_DIALOG,
            TestTags.MODALS_FULLSCREEN_DIALOG,
            TestTags.MODALS_FULLSCREEN_CLOSE,
            TestTags.MODALS_OPEN_VERIFY_SHEET,
            TestTags.MODALS_VERIFY_SHEET,
            TestTags.MODALS_VERIFY_CODE,
            TestTags.MODALS_VERIFY_SUBMIT,
            TestTags.MODALS_PROMO_SOON,
            TestTags.MODALS_PROMO_TARGET,
            TestTags.MODALS_PROMO_SHEET,
            TestTags.MODALS_PROMO_CLOSE,
            TestTags.TAB_DRAG_DROP,
            TestTags.DRAG_STATUS,
            TestTags.DRAG_DROP_TARGET,
            TestTags.DRAG_ITEM_ALPHA,
            TestTags.DRAG_ITEM_BETA,
            TestTags.DRAG_ITEM_GAMMA,
            TestTags.DRAG_REORDER_ITEM_PREFIX,
            TestTags.TAB_BACKEND,
            TestTags.BACKEND_URL,
            TestTags.BACKEND_USERNAME,
            TestTags.BACKEND_PASSWORD,
            TestTags.BACKEND_SIGN_IN,
            TestTags.BACKEND_STATUS,
            TestTags.BACKEND_SUBMIT,
            TestTags.BACKEND_REFRESH,
            TestTags.BACKEND_ORDER,
        )

        assertTrue(tags.all { it.startsWith("sample.") })
    }
}
