import Foundation

// Mirrors TestTags.kt in shared-ui so the same E2E flows can drive
// either app — Compose-MP iOS sample or this from-scratch native one.
// Keep keys in sync with `compose-multiplatform/shared-ui/.../TestTags.kt`.
enum TestTags {
    static let appRoot = "sample.app.root"
    // "BackButton" matches the UIKit default identifier for the system
    // back chevron AND the Compose `Modifier.testTag` value (see
    // `compose-multiplatform/shared-ui/.../TestTags.kt`). Same .ds step — `tap(id("BackButton"))` —
    // drives both platforms.
    static let navBack = "BackButton"
    // "Home" bar button on every pushed screen (this app only; the Compose sample has none).
    static let navHome = "sample.nav.home"
    // "Launch env: <value>" on the home screen, only when the app was launched with `-env <value>`.
    // Mirrors `HOME_LAUNCH_ENV` in shared-ui TestTags.kt.
    static let homeLaunchEnv = "sample.home.launchEnv"
    // The launch flag and environment variable the home screen shows when the app was launched with them.
    static let homeLaunchFlag = "sample.home.launchFlag"
    static let homeLaunchEnvironment = "sample.home.launchEnvironment"

    // Language chooser in the home nav bar's right `UIBarButtonItem`.
    // `actionLanguage` is the bar button that opens the `UIMenu`;
    // `langEnglish` / `langGeorgian` are the two menu actions. Keys mirror
    // the Compose sample's `TestTags.kt` (`ACTION_LANGUAGE` / `LANG_*`) so
    // the same E2E flow drives both platforms.
    static let actionLanguage = "sample.action.language"
    static let langEnglish = "sample.lang.english"
    static let langGeorgian = "sample.lang.georgian"

    static let tabLogin = "sample.tab.login"
    static let tabRegistration = "sample.tab.registration"
    static let tabList = "sample.tab.list"
    static let tabGrid = "sample.tab.grid"
    static let tabShowcase = "sample.tab.showcase"
    static let tabSearch = "sample.tab.search"
    static let tabCheckout = "sample.tab.checkout"
    static let tabProfile = "sample.tab.profile"
    static let tabPinch = "sample.tab.pinch"
    static let tabModals = "sample.tab.modals"
    static let tabDragDrop = "sample.tab.dragdrop"
    static let tabNetwork = "sample.tab.network"
    static let tabFiles = "sample.tab.files"
    static let filesPick = "sample.files.pick"
    static let filesSelected = "sample.files.selected"
    static let tabAppFiles = "sample.tab.appfiles"
    static let appFilesName = "sample.appfiles.name"
    static let appFilesAdd = "sample.appfiles.add"
    static let appFilesRead = "sample.appfiles.read"
    static let appFilesDelete = "sample.appfiles.delete"
    static let appFilesContent = "sample.appfiles.content"
    static let tabWebView = "sample.tab.webview"
    static let webViewPage = "sample.webview.page"
    static let webViewEvent = "sample.webview.event"

    // Stress screen (walk-performance measurements, not in the sample regression).
    static let tabStress = "sample.tab.stress"
    static let stressStatus = "sample.stress.status"
    static let stressLateStatus = "sample.stress.late.status"
    static let stressList = "sample.stress.list"
    static let stressHeader = "sample.stress.header"
    static let stressLate = "sample.stress.late"
    static let stressLateButton = "sample.stress.late.button"
    static let stressDeepPrefix = "sample.stress.deep."
    static let stressDeepLeaf = "sample.stress.deep.leaf"
    static let stressGridPrefix = "sample.stress.grid."
    static let stressRowPrefix = "sample.stress.row."
    static let stressChipPrefix = "sample.stress.chip."
    static let stressEnd = "sample.stress.end"

    // Backend screen (parity with TestTags.kt)
    static let tabBackend = "sample.tab.backend"
    static let backendUrl = "sample.backend.url"
    static let backendUsername = "sample.backend.username"
    static let backendPassword = "sample.backend.password"
    static let backendSignIn = "sample.backend.signin"
    static let backendStatus = "sample.backend.status"
    static let backendSubmit = "sample.backend.submit"
    static let backendRefresh = "sample.backend.refresh"
    static let backendOrder = "sample.backend.order"

    static let networkAutoStatus = "sample.network.auto.status"
    static let networkResults = "sample.network.results"
    static let networkBtnGetPost = "sample.network.button.getPost"
    static let networkBtnPostBody = "sample.network.button.postBody"
    static let networkBtnHttpbin = "sample.network.button.httpbin"
    static let networkBtn404 = "sample.network.button.404"
    static let networkBtnWebSocket = "sample.network.button.websocket"
    static let networkBtnSse = "sample.network.button.sse"
    static let networkWsLog = "sample.network.ws.log"
    static let networkSseLog = "sample.network.sse.log"

    static let loginEmail = "sample.login.email"
    static let loginPassword = "sample.login.password"
    static let loginRemember = "sample.login.remember"
    static let loginButton = "sample.login.submit"
    static let loginEmailPreview = "sample.login.email.preview"
    static let loginPasswordPreview = "sample.login.password.preview"
    static let loginStatus = "sample.login.status"

    static let regName = "sample.registration.name"
    static let regEmail = "sample.registration.email"
    static let regPassword = "sample.registration.password"
    static let regTerms = "sample.registration.terms"
    static let regSubmit = "sample.registration.submit"
    static let regNamePreview = "sample.registration.name.preview"
    static let regEmailPreview = "sample.registration.email.preview"
    static let regPasswordPreview = "sample.registration.password.preview"
    static let regStatus = "sample.registration.status"

    static let listContainer = "sample.list.container"
    static let listDetail = "sample.list.detail"
    static let gridContainer = "sample.grid.container"
    static let gridDetail = "sample.grid.detail"

    static let showcaseScroll = "sample.showcase.scroll"
    static let showcaseSlider = "sample.showcase.slider"
    static let showcaseSwitch = "sample.showcase.switch"
    static let showcaseProgress = "sample.showcase.progress"

    static let searchQuery = "sample.search.query"
    static let searchQueryPreview = "sample.search.query.preview"
    static let searchSubmit = "sample.search.submit"
    static let searchStatus = "sample.search.status"
    static let searchResults = "sample.search.results"

    static let checkoutAddress = "sample.checkout.address"
    static let checkoutAddressPreview = "sample.checkout.address.preview"
    static let checkoutDelivery = "sample.checkout.delivery"
    static let checkoutPayment = "sample.checkout.payment"
    static let checkoutPlaceOrder = "sample.checkout.place.order"
    static let checkoutStatus = "sample.checkout.status"

    static let profileName = "sample.profile.name"
    static let profileNamePreview = "sample.profile.name.preview"
    static let profilePhone = "sample.profile.phone"
    static let profilePhonePreview = "sample.profile.phone.preview"
    static let profileMarketing = "sample.profile.marketing"
    static let profileSave = "sample.profile.save"
    static let profileStatus = "sample.profile.status"

    static let pinchPlayground = "sample.pinch.playground"
    static let pinchTarget = "sample.pinch.target"
    static let pinchStatus = "sample.pinch.status"

    static let modalsStatus = "sample.modals.status"
    static let modalsOpenPartialSheet = "sample.modals.sheet.partial"
    static let modalsOpenFullSheet = "sample.modals.sheet.full"
    static let modalsSheet = "sample.modals.sheet"
    static let modalsSheetHide = "sample.modals.sheet.hide"
    static let modalsOpenAlertDialog = "sample.modals.dialog.alert"
    static let modalsAlertConfirm = "sample.modals.dialog.alert.confirm"
    static let modalsAlertDismiss = "sample.modals.dialog.alert.dismiss"
    static let modalsOpenFullscreenDialog = "sample.modals.dialog.fullscreen"
    static let modalsFullscreenDialog = "sample.modals.dialog.fullscreen.content"
    static let modalsFullscreenClose = "sample.modals.dialog.fullscreen.close"
    static let modalsOpenVerifySheet = "sample.modals.verify.open"
    static let modalsVerifySheet = "sample.modals.verify.sheet"
    static let modalsVerifyCode = "sample.modals.verify.code"
    static let modalsVerifySubmit = "sample.modals.verify.submit"
    static let modalsPromoSoon = "sample.modals.promo.soon"
    static let modalsPromoTarget = "sample.modals.promo.target"
    static let modalsPromoSheet = "sample.modals.promo.sheet"
    static let modalsPromoClose = "sample.modals.promo.close"

    static let dragStatus = "sample.dragdrop.status"
    static let dragDropTarget = "sample.dragdrop.target"
    static let dragItemAlpha = "sample.dragdrop.item.alpha"
    static let dragItemBeta = "sample.dragdrop.item.beta"
    static let dragItemGamma = "sample.dragdrop.item.gamma"
    static let dragReorderItemPrefix = "sample.dragdrop.reorder."
}

// Lightweight value types for the SwiftUI list/grid/search screens.
// Mirror the data fixtures in shared-ui so flows asserting against
// e.g. "Order #1001" / "Wireless Headphones" find them on iOS too.
struct SampleProductItem: Identifiable, Hashable {
    let name: String
    let price: String
    let inventory: String
    var id: String { name }
}

struct CatalogItem: Identifiable, Hashable {
    let name: String
    let category: String
    let price: String
    var id: String { name }
}
