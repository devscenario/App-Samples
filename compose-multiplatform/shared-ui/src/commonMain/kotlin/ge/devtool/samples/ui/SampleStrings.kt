package ge.devtool.samples.ui

import androidx.compose.runtime.staticCompositionLocalOf

/**
 * In-app language for the sample app. Drives the displayed strings via
 * [LocalSampleStrings] AND mirrors into the OS-level per-app locale through
 * [SampleLocaleController] (so the OS persists the choice and Dev Scenario's
 * flow-translation auto-detection observes it). Default is [ENGLISH] for any OS
 * locale other than Georgian, so existing E2E flows and the Espresso parity
 * tests (which assert on English copy) keep passing.
 */
internal enum class SampleLanguage(val label: String) {
    ENGLISH("English"),
    GEORGIAN("Georgian"),
}

/**
 * Type-safe string table. Every user-visible string in the shared-ui sample is
 * a named property here, grouped by screen. The interface forces [KaStrings] to
 * supply a translation for every key — a missing key is a compile error.
 *
 * Functions (e.g. [LoginStrings.success]) cover strings that interpolate runtime values.
 * Test-tag strings, content descriptions used as test hooks, and any route/key
 * are intentionally NOT in this table — they must never be translated.
 */
internal interface SampleStrings {
    // TopAppBar / navigation
    val back: String
    val languageChooser: String
    val languageEnglish: String
    val languageGeorgian: String

    // Per-screen tables kept in their own files
    val login: LoginStrings
    val registration: RegistrationStrings
    val modals: ModalStrings
    val stress: StressStrings
    val backend: BackendStrings
    val appFiles: AppFilesStrings
    val streams: StreamStrings

    // Home grid / screen titles
    val titleHome: String
    val titleLogin: String
    val titleRegistration: String
    val titleList: String
    val titleGrid: String
    val titleShowcase: String
    val titleSearch: String
    val titleCheckout: String
    val titleProfile: String
    val titlePinch: String
    val titleModals: String
    val titleDragDrop: String
    val titleNetwork: String
    val titleFiles: String
    val titleWebView: String

    // Checkout
    val checkoutTitle: String
    val checkoutOrderSummary: String
    val checkoutProduct: String
    fun checkoutSubtotal(amount: String): String
    fun checkoutShipping(amount: String): String
    fun checkoutTotal(amount: String): String
    val checkoutShippingAddress: String
    val checkoutExpressDelivery: String
    fun checkoutPayment(method: String): String
    val checkoutPlaceOrder: String
    fun checkoutAddressTyped(value: String): String
    fun checkoutOrderPlaced(address: String): String
    val checkoutFailure: String

    // Profile
    val profileTitle: String
    val profileDisplayName: String
    val profilePhone: String
    val profileMarketingEmails: String
    val profileSave: String
    fun profileNameTyped(value: String): String
    fun profilePhoneTyped(value: String): String
    fun profileSaved(name: String): String
    val profileFailureName: String
    val profileFailurePhone: String

    // List
    val listOrderDetails: String
    fun listSelected(id: String): String
    fun listCustomer(name: String): String
    fun listTotal(total: String): String
    fun listStatus(status: String): String
    val listStatusReady: String
    val listStatusProcessing: String

    // Grid
    val gridProductDetails: String
    fun gridSelected(name: String): String
    fun gridPrice(price: String): String
    fun gridInventory(inventory: String): String
    val gridInStock: String
    val gridLowStock: String

    // Search
    val searchTitle: String
    val searchField: String
    val searchRun: String
    fun searchQueryTyped(value: String): String
    fun searchFeatured(count: Int): String
    fun searchResults(query: String, count: Int): String
    fun searchCategory(category: String): String
    fun searchPrice(price: String): String

    // Showcase
    val showcaseTitle: String
    val showcaseIntro: String
    val showcaseEnableNotifications: String
    val showcaseProgress: String
    fun showcaseListElement(index: Int): String
    val showcasePrimary: String
    val showcaseSecondary: String
    val showcaseEnd: String

    // Pinch
    val pinchTitle: String
    val pinchIntro: String
    val pinchMe: String
    fun pinchStatus(scale: Float, direction: String, events: Int): String
    val pinchDirIn: String
    val pinchDirOut: String
    val pinchDirNone: String

    // Drag & drop
    val dragTitle: String
    val dragIntro: String
    fun dragStatus(value: String): String
    val dragStatusNone: String
    val dragDropZone: String
    val dragDropHint: String
    fun dragDropHere(name: String): String
    val dragSources: String
    val dragReorderable: String
    val dragReorderHint: String
    val dragHandleLabel: String
    fun dragDragging(name: String): String
    fun dragDroppedInZone(name: String): String
    fun dragCancelled(name: String): String
    fun dragPickedUp(item: String): String
    fun dragMovedUp(item: String): String
    fun dragMovedDown(item: String): String
    val dragRowOne: String
    val dragRowTwo: String
    val dragRowThree: String

    // Files
    val filesPick: String
    val filesNone: String
    val filesCancelled: String
    val filesNoPicker: String
    fun filesSelected(name: String): String

    // WebView
    val webNoEvent: String
    fun webLastEvent(event: String): String

    // Network
    val networkDemoTitle: String
    val networkDemoBody: String
    val networkAutoFiring: String
    fun networkAutoFailed(message: String): String
    fun networkAutoDone(code: Int, durationMs: Long): String
    val networkAutoLabel: String
    val networkBtnGetPost: String
    val networkBtnPostBody: String
    val networkBtnHttpbin: String
    val networkBtn404: String
}

/** English string table. Values must stay exactly as the prior hardcoded copy. */
internal object EnStrings : SampleStrings {
    // TopAppBar / navigation
    override val back = "Back"
    override val languageChooser = "Language"
    override val languageEnglish = "English"
    override val languageGeorgian = "Georgian"

    // Per-screen tables kept in their own files
    override val login: LoginStrings = EnLoginStrings
    override val registration: RegistrationStrings = EnRegistrationStrings
    override val modals: ModalStrings = EnModalStrings
    override val stress: StressStrings = EnStressStrings
    override val backend: BackendStrings = EnBackendStrings
    override val appFiles: AppFilesStrings = EnAppFilesStrings
    override val streams: StreamStrings = EnStreamStrings

    // Home grid / screen titles
    override val titleHome = "Sample Screens"
    override val titleLogin = "Login"
    override val titleRegistration = "Registration"
    override val titleList = "List"
    override val titleGrid = "Grid"
    override val titleShowcase = "Showcase"
    override val titleSearch = "Search"
    override val titleCheckout = "Checkout"
    override val titleProfile = "Profile"
    override val titlePinch = "Pinch"
    override val titleModals = "Modals"
    override val titleDragDrop = "Drag & Drop"
    override val titleNetwork = "Network"
    override val titleFiles = "Files"
    override val titleWebView = "WebView"

    // Checkout
    override val checkoutTitle = "Checkout"
    override val checkoutOrderSummary = "Order summary"
    override val checkoutProduct = "Wireless Headphones"
    override fun checkoutSubtotal(amount: String) = "Subtotal: $amount"
    override fun checkoutShipping(amount: String) = "Shipping: $amount"
    override fun checkoutTotal(amount: String) = "Total: $amount"
    override val checkoutShippingAddress = "Shipping address"
    override val checkoutExpressDelivery = "Express delivery"
    override fun checkoutPayment(method: String) = "Payment: $method"
    override val checkoutPlaceOrder = "Place order"
    override fun checkoutAddressTyped(value: String) = "Checkout address typed: $value"
    override fun checkoutOrderPlaced(address: String) = "Order placed for $address"
    override val checkoutFailure = "Checkout failed: enter a valid shipping address"

    // Profile
    override val profileTitle = "Profile settings"
    override val profileDisplayName = "Display name"
    override val profilePhone = "Phone number"
    override val profileMarketingEmails = "Marketing emails"
    override val profileSave = "Save profile"
    override fun profileNameTyped(value: String) = "Profile name typed: $value"
    override fun profilePhoneTyped(value: String) = "Profile phone typed: $value"
    override fun profileSaved(name: String) = "Profile saved for $name"
    override val profileFailureName = "Profile failed: enter display name"
    override val profileFailurePhone = "Profile failed: enter phone number"

    // List
    override val listOrderDetails = "Order details"
    override fun listSelected(id: String) = "Selected $id"
    override fun listCustomer(name: String) = "Customer: $name"
    override fun listTotal(total: String) = "Total: $total"
    override fun listStatus(status: String) = "Status: $status"
    override val listStatusReady = "Ready to ship"
    override val listStatusProcessing = "Processing"

    // Grid
    override val gridProductDetails = "Product details"
    override fun gridSelected(name: String) = "Selected $name"
    override fun gridPrice(price: String) = "Price: $price"
    override fun gridInventory(inventory: String) = "Inventory: $inventory"
    override val gridInStock = "In stock"
    override val gridLowStock = "Low stock"

    // Search
    override val searchTitle = "Search catalog"
    override val searchField = "Search products"
    override val searchRun = "Run search"
    override fun searchQueryTyped(value: String) = "Search query typed: $value"
    override fun searchFeatured(count: Int) = "Showing $count featured products"
    override fun searchResults(query: String, count: Int) = "Search results for $query: $count items"
    override fun searchCategory(category: String) = "Category: $category"
    override fun searchPrice(price: String) = "Price: $price"

    // Showcase
    override val showcaseTitle = "Component Showcase"
    override val showcaseIntro = "This tab helps validate gestures, scrolling, toggles, and assertions."
    override val showcaseEnableNotifications = "Enable notifications"
    override val showcaseProgress = "Progress"
    override fun showcaseListElement(index: Int) = "List element $index"
    override val showcasePrimary = "Primary"
    override val showcaseSecondary = "Secondary"
    override val showcaseEnd = "End of screen"

    // Pinch
    override val pinchTitle = "Pinch Playground"
    override val pinchIntro = "Use two fingers to zoom the target in/out."
    override val pinchMe = "Pinch me"
    override fun pinchStatus(scale: Float, direction: String, events: Int) =
        "Pinch scale: $scale | last: $direction | events: $events"
    override val pinchDirIn = "zoom in"
    override val pinchDirOut = "zoom out"
    override val pinchDirNone = "none"

    // Drag & drop
    override val dragTitle = "Drag & Drop"
    override val dragIntro = "Drag a source chip into the drop zone, or drag rows to reorder them."
    override fun dragStatus(value: String) = "Status: $value"
    override val dragStatusNone = "No drag performed yet"
    override val dragDropZone = "Drop Zone"
    override val dragDropHint = "(drag a chip here)"
    override fun dragDropHere(name: String) = "Drop \"$name\" here"
    override val dragSources = "Drag sources:"
    override val dragReorderable = "Reorderable rows:"
    override val dragReorderHint = "Drag a row up or down to change its position."
    override val dragHandleLabel = "drag"
    override fun dragDragging(name: String) = "Dragging $name"
    override fun dragDroppedInZone(name: String) = "$name dropped in zone"
    override fun dragCancelled(name: String) = "$name drag cancelled"
    override fun dragPickedUp(item: String) = "Picked up: $item"
    override fun dragMovedUp(item: String) = "$item moved up"
    override fun dragMovedDown(item: String) = "$item moved down"
    override val dragRowOne = "Row One"
    override val dragRowTwo = "Row Two"
    override val dragRowThree = "Row Three"

    // Network
    override val networkDemoTitle = "Dev Scenario interceptor demo"
    override val networkDemoBody =
        "These requests are captured by Dev Scenario with NO `.addInterceptor(…)` " +
            "lines anywhere in this app's source — the auto-wire plugin / SwiftPM " +
            "swizzle handles it for you."
    override val filesPick = "Pick file"
    override val filesNone = "No file selected"
    override val filesCancelled = "No file chosen"
    override val filesNoPicker = "No file picker on this device"
    override fun filesSelected(name: String) = "Selected file: $name"

    override val webNoEvent = "none"
    override fun webLastEvent(event: String) = "Last web event: $event"
    override val networkAutoFiring = "Firing initial request…"
    override fun networkAutoFailed(message: String) = "Auto request failed: $message"
    override fun networkAutoDone(code: Int, durationMs: Long) =
        "Auto request done — $code in $durationMs ms. Check the Dev Scenario Network tab."
    override val networkAutoLabel = "Auto-fired on screen entry"
    override val networkBtnGetPost = "GET jsonplaceholder /posts/1"
    override val networkBtnPostBody = "POST jsonplaceholder /posts"
    override val networkBtnHttpbin = "GET httpbin.org/get"
    override val networkBtn404 = "GET → 404 (force error)"
}

/** Georgian (ქართული) string table. */
internal object KaStrings : SampleStrings {
    // TopAppBar / navigation
    override val back = "უკან"
    override val languageChooser = "ენა"
    override val languageEnglish = "ინგლისური"
    override val languageGeorgian = "ქართული"

    // Per-screen tables kept in their own files
    override val login: LoginStrings = KaLoginStrings
    override val registration: RegistrationStrings = KaRegistrationStrings
    override val modals: ModalStrings = KaModalStrings
    override val stress: StressStrings = KaStressStrings
    override val backend: BackendStrings = KaBackendStrings
    override val appFiles: AppFilesStrings = KaAppFilesStrings
    override val streams: StreamStrings = KaStreamStrings

    // Home grid / screen titles
    override val titleHome = "სანიმუშო ეკრანები"
    override val titleLogin = "შესვლა"
    override val titleRegistration = "რეგისტრაცია"
    override val titleList = "სია"
    override val titleGrid = "ბადე"
    override val titleShowcase = "კომპონენტები"
    override val titleSearch = "ძებნა"
    override val titleCheckout = "გადახდა"
    override val titleProfile = "პროფილი"
    override val titlePinch = "მასშტაბირება"
    override val titleModals = "ფანჯრები"
    override val titleDragDrop = "გადათრევა"
    override val titleNetwork = "ქსელი"
    override val titleFiles = "ფაილები"
    override val titleWebView = "ვებ-ხედი"

    // Checkout
    override val checkoutTitle = "გადახდა"
    override val checkoutOrderSummary = "შეკვეთის მიმოხილვა"
    override val checkoutProduct = "უსადენო ყურსასმენები"
    override fun checkoutSubtotal(amount: String) = "ჯამი: $amount"
    override fun checkoutShipping(amount: String) = "მიწოდება: $amount"
    override fun checkoutTotal(amount: String) = "სულ: $amount"
    override val checkoutShippingAddress = "მიწოდების მისამართი"
    override val checkoutExpressDelivery = "სწრაფი მიწოდება"
    override fun checkoutPayment(method: String) = "გადახდა: $method"
    override val checkoutPlaceOrder = "შეკვეთის გაფორმება"
    override fun checkoutAddressTyped(value: String) = "აკრეფილი მისამართი: $value"
    override fun checkoutOrderPlaced(address: String) = "შეკვეთა გაფორმდა მისამართზე: $address"
    override val checkoutFailure = "გადახდა ვერ მოხერხდა: შეიყვანეთ სწორი მიწოდების მისამართი"

    // Profile
    override val profileTitle = "პროფილის პარამეტრები"
    override val profileDisplayName = "სახელი"
    override val profilePhone = "ტელეფონის ნომერი"
    override val profileMarketingEmails = "სარეკლამო წერილები"
    override val profileSave = "პროფილის შენახვა"
    override fun profileNameTyped(value: String) = "აკრეფილი სახელი: $value"
    override fun profilePhoneTyped(value: String) = "აკრეფილი ტელეფონი: $value"
    override fun profileSaved(name: String) = "პროფილი შენახულია: $name"
    override val profileFailureName = "შენახვა ვერ მოხერხდა: შეიყვანეთ სახელი"
    override val profileFailurePhone = "შენახვა ვერ მოხერხდა: შეიყვანეთ ტელეფონის ნომერი"

    // List
    override val listOrderDetails = "შეკვეთის დეტალები"
    override fun listSelected(id: String) = "არჩეული $id"
    override fun listCustomer(name: String) = "მომხმარებელი: $name"
    override fun listTotal(total: String) = "სულ: $total"
    override fun listStatus(status: String) = "სტატუსი: $status"
    override val listStatusReady = "გასაგზავნად მზად"
    override val listStatusProcessing = "მუშავდება"

    // Grid
    override val gridProductDetails = "პროდუქტის დეტალები"
    override fun gridSelected(name: String) = "არჩეული $name"
    override fun gridPrice(price: String) = "ფასი: $price"
    override fun gridInventory(inventory: String) = "მარაგი: $inventory"
    override val gridInStock = "მარაგშია"
    override val gridLowStock = "მცირე მარაგი"

    // Search
    override val searchTitle = "კატალოგის ძებნა"
    override val searchField = "პროდუქტების ძებნა"
    override val searchRun = "ძებნა"
    override fun searchQueryTyped(value: String) = "აკრეფილი მოთხოვნა: $value"
    override fun searchFeatured(count: Int) = "ნაჩვენებია $count რჩეული პროდუქტი"
    override fun searchResults(query: String, count: Int) = "ძებნის შედეგი „$query“-ზე: $count ერთეული"
    override fun searchCategory(category: String) = "კატეგორია: $category"
    override fun searchPrice(price: String) = "ფასი: $price"

    // Showcase
    override val showcaseTitle = "კომპონენტების გალერეა"
    override val showcaseIntro = "ეს ჩანართი ეხმარება ჟესტების, გადახვევის, გადამრთველებისა და შემოწმებების ვალიდაციას."
    override val showcaseEnableNotifications = "შეტყობინებების ჩართვა"
    override val showcaseProgress = "პროგრესი"
    override fun showcaseListElement(index: Int) = "სიის ელემენტი $index"
    override val showcasePrimary = "ძირითადი"
    override val showcaseSecondary = "მეორეული"
    override val showcaseEnd = "ეკრანის დასასრული"

    // Pinch
    override val pinchTitle = "მასშტაბირების სავარჯიშო"
    override val pinchIntro = "გამოიყენეთ ორი თითი სამიზნის გასადიდებლად/დასაპატარავებლად."
    override val pinchMe = "დამაპატარავე"
    override fun pinchStatus(scale: Float, direction: String, events: Int) =
        "მასშტაბი: $scale | ბოლო: $direction | მოვლენები: $events"
    override val pinchDirIn = "გადიდება"
    override val pinchDirOut = "დაპატარავება"
    override val pinchDirNone = "არცერთი"

    // Drag & drop
    override val dragTitle = "გადათრევა"
    override val dragIntro = "გადაიტანეთ წყაროს ჩიპი ჩასაგდებ ზონაში, ან გადაათრიეთ მწკრივები მათი თანმიმდევრობის შესაცვლელად."
    override fun dragStatus(value: String) = "სტატუსი: $value"
    override val dragStatusNone = "ჯერ გადათრევა არ შესრულებულა"
    override val dragDropZone = "ჩასაგდები ზონა"
    override val dragDropHint = "(გადმოათრიეთ ჩიპი აქ)"
    override fun dragDropHere(name: String) = "ჩააგდეთ „$name“ აქ"
    override val dragSources = "გადასათრევი წყაროები:"
    override val dragReorderable = "გადასალაგებელი მწკრივები:"
    override val dragReorderHint = "გადაათრიეთ მწკრივი ზევით ან ქვევით პოზიციის შესაცვლელად."
    override val dragHandleLabel = "გადათრევა"
    override fun dragDragging(name: String) = "გადათრევა: $name"
    override fun dragDroppedInZone(name: String) = "$name ჩაგდებულია ზონაში"
    override fun dragCancelled(name: String) = "$name გადათრევა გაუქმდა"
    override fun dragPickedUp(item: String) = "აღებულია: $item"
    override fun dragMovedUp(item: String) = "$item გადაინაცვლა ზევით"
    override fun dragMovedDown(item: String) = "$item გადაინაცვლა ქვევით"
    override val dragRowOne = "მწკრივი ერთი"
    override val dragRowTwo = "მწკრივი ორი"
    override val dragRowThree = "მწკრივი სამი"

    // Network
    override val networkDemoTitle = "Dev Scenario ინტერცეპტორის დემო"
    override val networkDemoBody =
        "ამ მოთხოვნებს Dev Scenario იჭერს ამ აპლიკაციის კოდში ერთი `.addInterceptor(…)` " +
            "ხაზის გარეშეც — ავტომატური დაკავშირების მოდული / SwiftPM swizzle ამას " +
            "თქვენ მაგივრად აკეთებს."
    override val filesPick = "ფაილის არჩევა"
    override val filesNone = "ფაილი არ არის არჩეული"
    override val filesCancelled = "ფაილი არ აირჩიეს"
    override val filesNoPicker = "ამ მოწყობილობაზე ფაილის ამრჩევი არ არის"
    override fun filesSelected(name: String) = "არჩეული ფაილი: $name"

    override val webNoEvent = "არაფერი"
    override fun webLastEvent(event: String) = "ბოლო ვებ-მოვლენა: $event"
    override val networkAutoFiring = "მიმდინარეობს საწყისი მოთხოვნის გაგზავნა…"
    override fun networkAutoFailed(message: String) = "ავტომოთხოვნა ვერ შესრულდა: $message"
    override fun networkAutoDone(code: Int, durationMs: Long) =
        "ავტომოთხოვნა შესრულდა — $code, $durationMs მწმ-ში. იხილეთ Dev Scenario-ის ქსელის ჩანართი."
    override val networkAutoLabel = "ავტომატურად გაიგზავნა ეკრანზე შესვლისას"
    override val networkBtnGetPost = "GET jsonplaceholder /posts/1"
    override val networkBtnPostBody = "POST jsonplaceholder /posts"
    override val networkBtnHttpbin = "GET httpbin.org/get"
    override val networkBtn404 = "GET → 404 (შეცდომის გამოწვევა)"
}

/** Default is English so existing English-asserting flows/tests keep passing. */
internal val LocalSampleStrings = staticCompositionLocalOf<SampleStrings> { EnStrings }
