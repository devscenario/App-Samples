import Foundation

/// In-app language toggle for the native sample app. Drives the displayed
/// strings only (via `LanguageStore`); it does NOT change the OS / per-app
/// locale or `AppleLanguages`. Default is `.english` so existing E2E flows
/// and the XCUITest parity tests (which assert on English copy) keep passing.
///
/// Mirrors `SampleLanguage` in the Compose shared-ui sample
/// (`compose-multiplatform/shared-ui/.../SampleStrings.kt`). Reuse the same Georgian
/// (ქართული) translations so both platforms stay consistent.
enum SampleLanguage: String, CaseIterable {
    case english
    case georgian
}

/// Type-safe string table. Every user-visible string in the native sample is
/// a named member here, grouped by screen. The protocol forces `KaStrings` to
/// supply a translation for every key — a missing key is a compile error.
///
/// Functions (e.g. `loginSuccess`) cover strings that interpolate runtime
/// values. Accessibility identifiers / test tags (see `TestTags`), data ids
/// (order/product names, chip names), and network paths are intentionally NOT
/// in this table — they must never be translated.
protocol SampleStrings {
    // Navigation
    var back: String { get }
    var home: String { get }
    var languageChooser: String { get }
    var languageEnglish: String { get }
    var languageGeorgian: String { get }

    // Home grid / screen titles
    var titleHome: String { get }
    var titleLogin: String { get }
    var titleRegistration: String { get }
    var titleList: String { get }
    var titleGrid: String { get }
    var titleShowcase: String { get }
    var titleSearch: String { get }
    var titleCheckout: String { get }
    var titleProfile: String { get }
    var titlePinch: String { get }
    var titleModals: String { get }
    var titleDragDrop: String { get }
    var titleNetwork: String { get }
    var titleFiles: String { get }
    var titleAppFiles: String { get }
    var titleWebView: String { get }
    var titleStress: String { get }
    var titleBackend: String { get }

    // Backend screen (its own table, BackendStrings.swift)
    var backend: BackendStrings { get }
    // Network screen stream demos (their own table, StreamStrings.swift)
    var streams: StreamStrings { get }

    // Files
    var filesPick: String { get }
    var filesNone: String { get }
    var filesCancelled: String { get }
    func filesSelected(_ name: String) -> String

    // App files
    var appFilesAdd: String { get }
    var appFilesRead: String { get }
    var appFilesDelete: String { get }
    var appFilesMissing: String { get }
    var appFilesEmpty: String { get }
    func appFilesLine(_ number: Int) -> String

    // WebView
    var webNoEvent: String { get }
    func webLastEvent(_ event: String) -> String

    // Login
    var loginWelcome: String { get }
    var loginEmail: String { get }
    var loginPassword: String { get }
    var loginRememberMe: String { get }
    var loginSignIn: String { get }
    func loginEmailTyped(_ value: String) -> String
    func loginPasswordTyped(_ value: String) -> String
    func loginSuccess(_ email: String) -> String
    var loginFailure: String { get }

    // Registration
    var regCreateAccount: String { get }
    var regFullName: String { get }
    var regEmail: String { get }
    var regPassword: String { get }
    var regAcceptTerms: String { get }
    var regTermsAccepted: String { get }
    var regRegister: String { get }
    func regNameTyped(_ value: String) -> String
    func regEmailTyped(_ value: String) -> String
    func regPasswordTyped(_ value: String) -> String
    func regSuccess(_ email: String) -> String
    var regFailureName: String { get }
    var regFailureEmail: String { get }
    var regFailurePassword: String { get }

    // Checkout
    var checkoutTitle: String { get }
    var checkoutOrderSummary: String { get }
    var checkoutProduct: String { get }
    func checkoutSubtotal(_ amount: String) -> String
    func checkoutShipping(_ amount: String) -> String
    func checkoutTotal(_ amount: String) -> String
    var checkoutShippingAddress: String { get }
    var checkoutExpressDelivery: String { get }
    func checkoutPayment(_ method: String) -> String
    var checkoutPlaceOrder: String { get }
    func checkoutAddressTyped(_ value: String) -> String
    func checkoutOrderPlaced(_ address: String) -> String
    var checkoutFailure: String { get }

    // Profile
    var profileTitle: String { get }
    var profileDisplayName: String { get }
    var profilePhone: String { get }
    var profileMarketingEmails: String { get }
    var profileSave: String { get }
    func profileNameTyped(_ value: String) -> String
    func profilePhoneTyped(_ value: String) -> String
    func profileSaved(_ name: String) -> String
    var profileFailureName: String { get }
    var profileFailurePhone: String { get }

    // List
    var listOrderDetails: String { get }
    func listSelected(_ id: String) -> String
    func listCustomer(_ name: String) -> String
    func listTotal(_ total: String) -> String
    func listStatus(_ status: String) -> String
    var listStatusReady: String { get }
    var listStatusProcessing: String { get }

    // Grid
    var gridProductDetails: String { get }
    func gridSelected(_ name: String) -> String
    func gridPrice(_ price: String) -> String
    func gridInventory(_ inventory: String) -> String
    var gridInStock: String { get }
    var gridLowStock: String { get }

    // Search
    var searchTitle: String { get }
    var searchField: String { get }
    var searchRun: String { get }
    func searchQueryTyped(_ value: String) -> String
    func searchFeatured(_ count: Int) -> String
    func searchResults(_ query: String, _ count: Int) -> String
    func searchCategory(_ category: String) -> String
    func searchPrice(_ price: String) -> String

    // Showcase
    var showcaseTitle: String { get }
    var showcaseIntro: String { get }
    var showcaseEnableNotifications: String { get }
    var showcaseProgress: String { get }
    func showcaseListElement(_ index: Int) -> String
    var showcasePrimary: String { get }
    var showcaseSecondary: String { get }
    var showcaseEnd: String { get }

    // Pinch
    var pinchTitle: String { get }
    var pinchIntro: String { get }
    var pinchMe: String { get }
    func pinchStatus(_ scale: String, _ direction: String, _ events: Int) -> String
    var pinchDirIn: String { get }
    var pinchDirOut: String { get }
    var pinchDirNone: String { get }

    // Modals
    var modalsTitle: String { get }
    var modalsIntro: String { get }
    var modalsPartialSheet: String { get }
    var modalsFullSheet: String { get }
    var modalsAlertDialog: String { get }
    var modalsFullscreenDialog: String { get }
    func modalsStatus(_ value: String) -> String
    var modalsStatusNone: String { get }
    var modalsStatusPartialVisible: String { get }
    var modalsStatusFullVisible: String { get }
    var modalsStatusSheetDismissed: String { get }
    var modalsStatusAlertDismissed: String { get }
    var modalsStatusFullscreenDismissed: String { get }
    var modalsStatusAlertVisible: String { get }
    var modalsStatusFullscreenVisible: String { get }
    var modalsStatusAlertHidden: String { get }
    var modalsStatusAlertConfirmed: String { get }
    var modalsStatusSheetHidden: String { get }
    var modalsStatusFullscreenHidden: String { get }
    var modalsBottomSheet: String { get }
    var modalsSheetIntro: String { get }
    var modalsHideSheet: String { get }
    var modalsAlertTitle: String { get }
    var modalsAlertBody: String { get }
    var modalsConfirm: String { get }
    var modalsDismiss: String { get }
    var modalsFullscreenTitle: String { get }
    var modalsFullscreenBody: String { get }
    var modalsClose: String { get }
    var modalsDragHandle: String { get }
    var modalsCodeSheet: String { get }
    var modalsVerifyByCode: String { get }
    var modalsSmsCode: String { get }
    var modalsVerify: String { get }
    func modalsStatusCodeVerified(_ code: String) -> String
    var modalsPromoSoon: String { get }
    var modalsPromoTarget: String { get }
    var modalsPromoTitle: String { get }
    var modalsPromoBody: String { get }
    var modalsStatusTargetTapped: String { get }

    // Drag & drop
    var dragTitle: String { get }
    var dragIntro: String { get }
    func dragStatus(_ value: String) -> String
    var dragStatusNone: String { get }
    var dragDropZone: String { get }
    var dragDropHint: String { get }
    func dragDropHere(_ name: String) -> String
    var dragSources: String { get }
    var dragReorderable: String { get }
    var dragReorderHint: String { get }
    var dragHandleLabel: String { get }
    func dragDragging(_ name: String) -> String
    func dragDroppedInZone(_ name: String) -> String
    func dragCancelled(_ name: String) -> String
    func dragPickedUp(_ item: String) -> String
    func dragMovedUp(_ item: String) -> String
    func dragMovedDown(_ item: String) -> String
    var dragRowOne: String { get }
    var dragRowTwo: String { get }
    var dragRowThree: String { get }

    // Network
    var networkDemoTitle: String { get }
    var networkDemoBody: String { get }
    var networkAutoFiring: String { get }
    func networkAutoFailed(_ message: String) -> String
    func networkAutoDone(_ code: Int, _ durationMs: Int) -> String
    var networkAutoLabel: String { get }
    var networkBtnGetPost: String { get }
    var networkBtnPostBody: String { get }
    var networkBtnHttpbin: String { get }
    var networkBtn404: String { get }
}

/// English string table. Values must stay exactly as the prior hardcoded copy
/// so the XCUITest parity tests and English-asserting E2E flows keep passing.
struct EnStrings: SampleStrings {
    // Navigation
    let back = "Back"
    let home = "Home"
    let languageChooser = "Language"
    let languageEnglish = "English"
    let languageGeorgian = "Georgian"

    // Home grid / screen titles
    let titleHome = "Sample Screens"
    let titleLogin = "Login"
    let titleRegistration = "Registration"
    let titleList = "List"
    let titleGrid = "Grid"
    let titleShowcase = "Showcase"
    let titleSearch = "Search"
    let titleCheckout = "Checkout"
    let titleProfile = "Profile"
    let titlePinch = "Pinch"
    let titleModals = "Modals"
    let titleDragDrop = "Drag & Drop"
    let titleNetwork = "Network"
    let titleFiles = "Files"
    let titleAppFiles = "App files"
    let titleWebView = "WebView"
    let titleStress = "Stress"
    let titleBackend = EnBackendStrings().title
    let backend: BackendStrings = EnBackendStrings()
    let streams: StreamStrings = EnStreamStrings()

    // Files
    let filesPick = "Pick file"
    let filesNone = "No file selected"
    let filesCancelled = "No file chosen"
    func filesSelected(_ name: String) -> String { "Selected file: \(name)" }

    // App files
    let appFilesAdd = "Add line"
    let appFilesRead = "Read file"
    let appFilesDelete = "Delete file"
    let appFilesMissing = "No file"
    let appFilesEmpty = "Empty file"
    func appFilesLine(_ number: Int) -> String { "Line \(number)" }

    // WebView
    let webNoEvent = "none"
    func webLastEvent(_ event: String) -> String { "Last web event: \(event)" }

    // Login
    let loginWelcome = "Welcome back"
    let loginEmail = "Email"
    let loginPassword = "Password"
    let loginRememberMe = "Remember me"
    let loginSignIn = "Sign in"
    func loginEmailTyped(_ value: String) -> String { "Login email typed: \(value)" }
    func loginPasswordTyped(_ value: String) -> String { "Login password typed: \(value)" }
    func loginSuccess(_ email: String) -> String { "Login success for \(email)" }
    let loginFailure = "Login failed: enter a valid email and 6+ character password"

    // Registration
    let regCreateAccount = "Create account"
    let regFullName = "Full name"
    let regEmail = "Email"
    let regPassword = "Password"
    let regAcceptTerms = "Accept terms"
    let regTermsAccepted = "Terms accepted"
    let regRegister = "Register"
    func regNameTyped(_ value: String) -> String { "Registration name typed: \(value)" }
    func regEmailTyped(_ value: String) -> String { "Registration email typed: \(value)" }
    func regPasswordTyped(_ value: String) -> String { "Registration password typed: \(value)" }
    func regSuccess(_ email: String) -> String { "Registration success for \(email)" }
    let regFailureName = "Registration failed: enter full name"
    let regFailureEmail = "Registration failed: enter a valid email"
    let regFailurePassword = "Registration failed: password must be 8+ characters"

    // Checkout
    let checkoutTitle = "Checkout"
    let checkoutOrderSummary = "Order summary"
    let checkoutProduct = "Wireless Headphones"
    func checkoutSubtotal(_ amount: String) -> String { "Subtotal: \(amount)" }
    func checkoutShipping(_ amount: String) -> String { "Shipping: \(amount)" }
    func checkoutTotal(_ amount: String) -> String { "Total: \(amount)" }
    let checkoutShippingAddress = "Shipping address"
    let checkoutExpressDelivery = "Express delivery"
    func checkoutPayment(_ method: String) -> String { "Payment: \(method)" }
    let checkoutPlaceOrder = "Place order"
    func checkoutAddressTyped(_ value: String) -> String { "Checkout address typed: \(value)" }
    func checkoutOrderPlaced(_ address: String) -> String { "Order placed for \(address)" }
    let checkoutFailure = "Checkout failed: enter a valid shipping address"

    // Profile
    let profileTitle = "Profile settings"
    let profileDisplayName = "Display name"
    let profilePhone = "Phone number"
    let profileMarketingEmails = "Marketing emails"
    let profileSave = "Save profile"
    func profileNameTyped(_ value: String) -> String { "Profile name typed: \(value)" }
    func profilePhoneTyped(_ value: String) -> String { "Profile phone typed: \(value)" }
    func profileSaved(_ name: String) -> String { "Profile saved for \(name)" }
    let profileFailureName = "Profile failed: enter display name"
    let profileFailurePhone = "Profile failed: enter phone number"

    // List
    let listOrderDetails = "Order details"
    func listSelected(_ id: String) -> String { "Selected \(id)" }
    func listCustomer(_ name: String) -> String { "Customer: \(name)" }
    func listTotal(_ total: String) -> String { "Total: \(total)" }
    func listStatus(_ status: String) -> String { "Status: \(status)" }
    let listStatusReady = "Ready to ship"
    let listStatusProcessing = "Processing"

    // Grid
    let gridProductDetails = "Product details"
    func gridSelected(_ name: String) -> String { "Selected \(name)" }
    func gridPrice(_ price: String) -> String { "Price: \(price)" }
    func gridInventory(_ inventory: String) -> String { "Inventory: \(inventory)" }
    let gridInStock = "In stock"
    let gridLowStock = "Low stock"

    // Search
    let searchTitle = "Search catalog"
    let searchField = "Search products"
    let searchRun = "Run search"
    func searchQueryTyped(_ value: String) -> String { "Search query typed: \(value)" }
    func searchFeatured(_ count: Int) -> String { "Showing \(count) featured products" }
    func searchResults(_ query: String, _ count: Int) -> String { "Search results for \(query): \(count) items" }
    func searchCategory(_ category: String) -> String { "Category: \(category)" }
    func searchPrice(_ price: String) -> String { "Price: \(price)" }

    // Showcase
    let showcaseTitle = "Component Showcase"
    let showcaseIntro = "This tab helps validate gestures, scrolling, toggles, and assertions."
    let showcaseEnableNotifications = "Enable notifications"
    let showcaseProgress = "Progress"
    func showcaseListElement(_ index: Int) -> String { "List element \(index)" }
    let showcasePrimary = "Primary"
    let showcaseSecondary = "Secondary"
    let showcaseEnd = "End of screen"

    // Pinch
    let pinchTitle = "Pinch Playground"
    let pinchIntro = "Use two fingers to zoom the target in/out."
    let pinchMe = "Pinch me"
    func pinchStatus(_ scale: String, _ direction: String, _ events: Int) -> String {
        "Pinch scale: \(scale) | last: \(direction) | events: \(events)"
    }
    let pinchDirIn = "zoom in"
    let pinchDirOut = "zoom out"
    let pinchDirNone = "none"

    // Modals
    let modalsTitle = "Modals"
    let modalsIntro = "Open dialogs and sheets, then swipe down or dismiss to validate hide commands."
    let modalsPartialSheet = "Partial sheet"
    let modalsFullSheet = "Full sheet"
    let modalsAlertDialog = "Alert dialog"
    let modalsFullscreenDialog = "Fullscreen dialog"
    func modalsStatus(_ value: String) -> String { "Status: \(value)" }
    let modalsStatusNone = "No modal opened yet"
    let modalsStatusPartialVisible = "Partial bottom sheet visible"
    let modalsStatusFullVisible = "Full bottom sheet visible"
    let modalsStatusSheetDismissed = "Bottom sheet dismissed"
    let modalsStatusAlertDismissed = "Alert dialog dismissed"
    let modalsStatusFullscreenDismissed = "Fullscreen dialog dismissed"
    let modalsStatusAlertVisible = "Alert dialog visible"
    let modalsStatusFullscreenVisible = "Fullscreen dialog visible"
    let modalsStatusAlertHidden = "Alert dialog hidden with dismiss"
    let modalsStatusAlertConfirmed = "Alert dialog confirmed"
    let modalsStatusSheetHidden = "Bottom sheet hidden with close action"
    let modalsStatusFullscreenHidden = "Fullscreen dialog hidden"
    let modalsBottomSheet = "Bottom sheet"
    let modalsSheetIntro = "Swipe down to hide, or use the close action below."
    let modalsHideSheet = "Hide sheet"
    let modalsAlertTitle = "Session expired"
    let modalsAlertBody = "Test dismiss and confirm commands on this dialog."
    let modalsConfirm = "Confirm"
    let modalsDismiss = "Dismiss"
    let modalsFullscreenTitle = "Fullscreen-like dialog"
    let modalsFullscreenBody = "Use swipe/tap commands then close it."
    let modalsClose = "Close"
    let modalsDragHandle = "Drag handle"
    let modalsCodeSheet = "Code sheet"
    let modalsVerifyByCode = "Verify by code"
    let modalsSmsCode = "SMS code"
    let modalsVerify = "Verify"
    func modalsStatusCodeVerified(_ code: String) -> String { "Code verified: \(code)" }
    let modalsPromoSoon = "Promo soon"
    let modalsPromoTarget = "Promo target"
    let modalsPromoTitle = "Promo"
    let modalsPromoBody = "A limited offer, shown on its own."
    let modalsStatusTargetTapped = "Target tapped"

    // Drag & drop
    let dragTitle = "Drag & Drop"
    let dragIntro = "Drag a source chip into the drop zone, or drag rows to reorder them."
    func dragStatus(_ value: String) -> String { "Status: \(value)" }
    let dragStatusNone = "No drag performed yet"
    let dragDropZone = "Drop Zone"
    let dragDropHint = "(drag a chip here)"
    func dragDropHere(_ name: String) -> String { "Drop \"\(name)\" here" }
    let dragSources = "Drag sources:"
    let dragReorderable = "Reorderable rows:"
    let dragReorderHint = "Drag a row up or down to change its position."
    let dragHandleLabel = "drag"
    func dragDragging(_ name: String) -> String { "Dragging \(name)" }
    func dragDroppedInZone(_ name: String) -> String { "\(name) dropped in zone" }
    func dragCancelled(_ name: String) -> String { "\(name) drag cancelled" }
    func dragPickedUp(_ item: String) -> String { "Picked up: \(item)" }
    func dragMovedUp(_ item: String) -> String { "\(item) moved up" }
    func dragMovedDown(_ item: String) -> String { "\(item) moved down" }
    let dragRowOne = "Row One"
    let dragRowTwo = "Row Two"
    let dragRowThree = "Row Three"

    // Network
    let networkDemoTitle = "Dev Scenario interceptor demo"
    let networkDemoBody = "These requests are captured by Dev Scenario with NO `URLProtocol.registerClass(…)` "
        + "line anywhere in this app's source — the auto SwiftPM's `+load` bootstrap "
        + "registers globally and swizzles `URLSession(configuration:…)` on launch."
    let networkAutoFiring = "Firing initial request…"
    func networkAutoFailed(_ message: String) -> String { "Auto request failed: \(message)" }
    func networkAutoDone(_ code: Int, _ durationMs: Int) -> String {
        "Auto request done — \(code) in \(durationMs) ms. Check the Dev Scenario Network tab."
    }
    let networkAutoLabel = "Auto-fired on screen entry"
    let networkBtnGetPost = "GET jsonplaceholder /posts/1"
    let networkBtnPostBody = "POST jsonplaceholder /posts"
    let networkBtnHttpbin = "GET httpbin.org/get"
    let networkBtn404 = "GET → 404 (force error)"
}
