package ge.devtool.samples.ui

object TestTags {
    const val APP_ROOT = "sample.app.root"
    const val TAB_LOGIN = "sample.tab.login"
    const val TAB_REGISTRATION = "sample.tab.registration"
    const val TAB_LIST = "sample.tab.list"
    const val TAB_GRID = "sample.tab.grid"
    const val TAB_SHOWCASE = "sample.tab.showcase"
    const val TAB_SEARCH = "sample.tab.search"
    const val TAB_CHECKOUT = "sample.tab.checkout"
    const val TAB_PROFILE = "sample.tab.profile"
    const val TAB_PINCH = "sample.tab.pinch"
    const val TAB_MODALS = "sample.tab.modals"

    // Home-grid navigation. The grid replaced the tab bar — each
    // "tab" is now a cell that pushes a detail screen. `NAV_BACK`
    // is the TopAppBar back-arrow IconButton on detail screens;
    // `NAV_TITLE` is the current screen's title text in the bar.
    const val HOME_GRID = "sample.home.grid"
    // "Launch env: <value>" at the top of the grid, only when the app was launched with an `env` argument.
    const val HOME_LAUNCH_ENV = "sample.home.launchEnv"
    // Cross-platform shorthand "BackButton" mirrors the UIKit default
    // identifier for the system back chevron in `UINavigationBar` (what
    // iOS WDA resolves `id: "BackButton"` against). Keeping the same
    // string here means the same .ds step — `tap(id("BackButton"))` —
    // works against the Compose back arrow on Android without
    // per-platform selector overrides. If you rename this, update
    // `navBack` in `swiftui/Sources/TestTags.swift`.
    const val NAV_BACK = "BackButton"
    const val NAV_TITLE = "sample.nav.title"

    // Language chooser in the TopAppBar `actions` slot. `ACTION_LANGUAGE` is
    // the IconButton that opens the dropdown; `LANG_ENGLISH` / `LANG_GEORGIAN`
    // are the two DropdownMenuItems. The toggle drives the in-app displayed
    // strings only (via `LocalSampleStrings`) — it does NOT change the OS /
    // per-app locale, so flow auto-detection won't observe it.
    const val ACTION_LANGUAGE = "sample.action.language"
    const val LANG_ENGLISH = "sample.lang.english"
    const val LANG_GEORGIAN = "sample.lang.georgian"

    const val LOGIN_EMAIL = "sample.login.email"
    const val LOGIN_PASSWORD = "sample.login.password"
    const val LOGIN_REMEMBER = "sample.login.remember"
    const val LOGIN_BUTTON = "sample.login.submit"
    const val LOGIN_EMAIL_PREVIEW = "sample.login.email.preview"
    const val LOGIN_PASSWORD_PREVIEW = "sample.login.password.preview"
    const val LOGIN_STATUS = "sample.login.status"

    const val REG_NAME = "sample.registration.name"
    const val REG_EMAIL = "sample.registration.email"
    const val REG_PASSWORD = "sample.registration.password"
    const val REG_TERMS = "sample.registration.terms"
    const val REG_SUBMIT = "sample.registration.submit"
    const val REG_NAME_PREVIEW = "sample.registration.name.preview"
    const val REG_EMAIL_PREVIEW = "sample.registration.email.preview"
    const val REG_PASSWORD_PREVIEW = "sample.registration.password.preview"
    const val REG_STATUS = "sample.registration.status"

    const val LIST_CONTAINER = "sample.list.container"
    const val LIST_DETAIL = "sample.list.detail"
    const val GRID_CONTAINER = "sample.grid.container"
    const val GRID_DETAIL = "sample.grid.detail"
    const val SHOWCASE_SCROLL = "sample.showcase.scroll"
    const val SHOWCASE_SLIDER = "sample.showcase.slider"
    const val SHOWCASE_SWITCH = "sample.showcase.switch"
    const val SHOWCASE_PROGRESS = "sample.showcase.progress"

    const val SEARCH_QUERY = "sample.search.query"
    const val SEARCH_QUERY_PREVIEW = "sample.search.query.preview"
    const val SEARCH_SUBMIT = "sample.search.submit"
    const val SEARCH_STATUS = "sample.search.status"
    const val SEARCH_RESULTS = "sample.search.results"

    const val CHECKOUT_ADDRESS = "sample.checkout.address"
    const val CHECKOUT_ADDRESS_PREVIEW = "sample.checkout.address.preview"
    const val CHECKOUT_DELIVERY = "sample.checkout.delivery"
    const val CHECKOUT_PAYMENT = "sample.checkout.payment"
    const val CHECKOUT_PLACE_ORDER = "sample.checkout.place.order"
    const val CHECKOUT_STATUS = "sample.checkout.status"

    const val PROFILE_NAME = "sample.profile.name"
    const val PROFILE_NAME_PREVIEW = "sample.profile.name.preview"
    const val PROFILE_PHONE = "sample.profile.phone"
    const val PROFILE_PHONE_PREVIEW = "sample.profile.phone.preview"
    const val PROFILE_MARKETING = "sample.profile.marketing"
    const val PROFILE_SAVE = "sample.profile.save"
    const val PROFILE_STATUS = "sample.profile.status"

    const val PINCH_PLAYGROUND = "sample.pinch.playground"
    const val PINCH_TARGET = "sample.pinch.target"
    const val PINCH_STATUS = "sample.pinch.status"

    const val MODALS_STATUS = "sample.modals.status"
    const val MODALS_OPEN_PARTIAL_SHEET = "sample.modals.sheet.partial"
    const val MODALS_OPEN_FULL_SHEET = "sample.modals.sheet.full"
    const val MODALS_SHEET = "sample.modals.sheet"
    const val MODALS_SHEET_HIDE = "sample.modals.sheet.hide"
    const val MODALS_OPEN_ALERT_DIALOG = "sample.modals.dialog.alert"
    const val MODALS_ALERT_CONFIRM = "sample.modals.dialog.alert.confirm"
    const val MODALS_ALERT_DISMISS = "sample.modals.dialog.alert.dismiss"
    const val MODALS_OPEN_FULLSCREEN_DIALOG = "sample.modals.dialog.fullscreen"
    const val MODALS_FULLSCREEN_DIALOG = "sample.modals.dialog.fullscreen.content"
    const val MODALS_FULLSCREEN_CLOSE = "sample.modals.dialog.fullscreen.close"
    const val MODALS_OPEN_VERIFY_SHEET = "sample.modals.verify.open"
    const val MODALS_VERIFY_SHEET = "sample.modals.verify.sheet"
    const val MODALS_VERIFY_CODE = "sample.modals.verify.code"
    const val MODALS_VERIFY_SUBMIT = "sample.modals.verify.submit"
    const val MODALS_PROMO_SOON = "sample.modals.promo.soon"
    const val MODALS_PROMO_TARGET = "sample.modals.promo.target"
    const val MODALS_PROMO_SHEET = "sample.modals.promo.sheet"
    const val MODALS_PROMO_CLOSE = "sample.modals.promo.close"

    const val TAB_DRAG_DROP = "sample.tab.dragdrop"

    // Network demo screen — exercises the Dev Scenario network interceptor by firing
    // requests against free public APIs. Tagged so flows can navigate to the
    // tile from the home grid and trigger each button.
    const val TAB_NETWORK = "sample.tab.network"
    const val NETWORK_AUTO_STATUS = "sample.network.auto.status"
    const val NETWORK_RESULTS = "sample.network.results"
    const val NETWORK_BTN_GET_POST = "sample.network.button.getPost"
    const val NETWORK_BTN_POST_BODY = "sample.network.button.postBody"
    const val NETWORK_BTN_HTTPBIN = "sample.network.button.httpbin"
    const val NETWORK_BTN_404 = "sample.network.button.404"
    // Stream demos against the sample's local WebSocket echo / SSE test server.
    const val NETWORK_BTN_WEBSOCKET = "sample.network.button.websocket"
    const val NETWORK_BTN_SSE = "sample.network.button.sse"
    const val NETWORK_WS_LOG = "sample.network.ws.log"
    const val NETWORK_SSE_LOG = "sample.network.sse.log"
    // Files screen — opens the platform file chooser (another process) and
    // shows the chosen file's name, for cross-app driver flows.
    const val TAB_FILES = "sample.tab.files"
    const val FILES_PICK = "sample.files.pick"
    const val FILES_SELECTED = "sample.files.selected"
    // App files screen: a file in the app's own storage, for flows that use read and file(…).
    const val TAB_APP_FILES = "sample.tab.appfiles"
    const val APP_FILES_NAME = "sample.appfiles.name"
    const val APP_FILES_ADD = "sample.appfiles.add"
    const val APP_FILES_READ = "sample.appfiles.read"
    const val APP_FILES_DELETE = "sample.appfiles.delete"
    const val APP_FILES_CONTENT = "sample.appfiles.content"
    const val TAB_WEBVIEW = "sample.tab.webview"
    const val WEBVIEW = "sample.webview.page"
    const val WEBVIEW_EVENT = "sample.webview.event"
    const val DRAG_STATUS = "sample.dragdrop.status"
    const val DRAG_DROP_TARGET = "sample.dragdrop.target"
    const val DRAG_ITEM_ALPHA = "sample.dragdrop.item.alpha"
    const val DRAG_ITEM_BETA = "sample.dragdrop.item.beta"
    const val DRAG_ITEM_GAMMA = "sample.dragdrop.item.gamma"
    const val DRAG_REORDER_ITEM_PREFIX = "sample.dragdrop.reorder."

    // Stress screen: a deliberately heavy tree for hierarchy-walk measurements. Kept out of the
    // benchmark regression. Row, grid, deep-level and chip ids append their numbers to the prefixes.
    const val TAB_STRESS = "sample.tab.stress"
    const val STRESS_STATUS = "sample.stress.status"
    const val STRESS_LATE_STATUS = "sample.stress.late.status"
    const val STRESS_LIST = "sample.stress.list"
    const val STRESS_HEADER = "sample.stress.header"
    const val STRESS_LATE = "sample.stress.late"
    const val STRESS_LATE_BUTTON = "sample.stress.late.button"
    const val STRESS_DEEP_PREFIX = "sample.stress.deep."
    const val STRESS_DEEP_LEAF = "sample.stress.deep.leaf"
    const val STRESS_GRID_PREFIX = "sample.stress.grid."
    const val STRESS_ROW_PREFIX = "sample.stress.row."
    const val STRESS_CHIP_PREFIX = "sample.stress.chip."
    const val STRESS_END = "sample.stress.end"

    // Backend screen: signs in against test-backend and follows an order.
    const val TAB_BACKEND = "sample.tab.backend"
    const val BACKEND_URL = "sample.backend.url"
    const val BACKEND_USERNAME = "sample.backend.username"
    const val BACKEND_PASSWORD = "sample.backend.password"
    const val BACKEND_SIGN_IN = "sample.backend.signin"
    const val BACKEND_STATUS = "sample.backend.status"
    const val BACKEND_SUBMIT = "sample.backend.submit"
    const val BACKEND_REFRESH = "sample.backend.refresh"
    const val BACKEND_ORDER = "sample.backend.order"
}
