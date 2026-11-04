import Foundation

/// Georgian (ქართული) string table. Translations are kept identical to the
/// Compose shared-ui sample's `KaStrings` so both platforms read the same.
struct KaStrings: SampleStrings {
    // Navigation
    let back = "უკან"
    let home = "მთავარი"
    let languageChooser = "ენა"
    let languageEnglish = "ინგლისური"
    let languageGeorgian = "ქართული"

    // Home grid / screen titles
    let titleHome = "სანიმუშო ეკრანები"
    let titleLogin = "შესვლა"
    let titleRegistration = "რეგისტრაცია"
    let titleList = "სია"
    let titleGrid = "ბადე"
    let titleShowcase = "კომპონენტები"
    let titleSearch = "ძებნა"
    let titleCheckout = "გადახდა"
    let titleProfile = "პროფილი"
    let titlePinch = "მასშტაბირება"
    let titleModals = "ფანჯრები"
    let titleDragDrop = "გადათრევა"
    let titleNetwork = "ქსელი"
    let titleFiles = "ფაილები"
    let titleAppFiles = "აპის ფაილები"
    let titleWebView = "ვებ-ხედი"
    let titleStress = "სტრესი"
    let titleBackend = KaBackendStrings().title
    let backend: BackendStrings = KaBackendStrings()
    let streams: StreamStrings = KaStreamStrings()

    // Files
    let filesPick = "ფაილის არჩევა"
    let filesNone = "ფაილი არ არის არჩეული"
    let filesCancelled = "ფაილი არ აირჩიეს"
    func filesSelected(_ name: String) -> String { "არჩეული ფაილი: \(name)" }

    // App files
    let appFilesAdd = "ხაზის დამატება"
    let appFilesRead = "ფაილის წაკითხვა"
    let appFilesDelete = "ფაილის წაშლა"
    let appFilesMissing = "ფაილი არ არის"
    let appFilesEmpty = "ფაილი ცარიელია"
    func appFilesLine(_ number: Int) -> String { "ხაზი \(number)" }

    // WebView
    let webNoEvent = "არაფერი"
    func webLastEvent(_ event: String) -> String { "ბოლო ვებ-მოვლენა: \(event)" }

    // Login
    let loginWelcome = "კეთილი იყოს თქვენი დაბრუნება"
    let loginEmail = "ელფოსტა"
    let loginPassword = "პაროლი"
    let loginRememberMe = "დამიმახსოვრე"
    let loginSignIn = "შესვლა"
    func loginEmailTyped(_ value: String) -> String { "აკრეფილი ელფოსტა: \(value)" }
    func loginPasswordTyped(_ value: String) -> String { "აკრეფილი პაროლი: \(value)" }
    func loginSuccess(_ email: String) -> String { "წარმატებული შესვლა: \(email)" }
    let loginFailure = "შესვლა ვერ მოხერხდა: შეიყვანეთ სწორი ელფოსტა და 6+ სიმბოლოიანი პაროლი"

    // Registration
    let regCreateAccount = "ანგარიშის შექმნა"
    let regFullName = "სრული სახელი"
    let regEmail = "ელფოსტა"
    let regPassword = "პაროლი"
    let regAcceptTerms = "პირობების მიღება"
    let regTermsAccepted = "პირობები მიღებულია"
    let regRegister = "რეგისტრაცია"
    func regNameTyped(_ value: String) -> String { "აკრეფილი სახელი: \(value)" }
    func regEmailTyped(_ value: String) -> String { "აკრეფილი ელფოსტა: \(value)" }
    func regPasswordTyped(_ value: String) -> String { "აკრეფილი პაროლი: \(value)" }
    func regSuccess(_ email: String) -> String { "წარმატებული რეგისტრაცია: \(email)" }
    let regFailureName = "რეგისტრაცია ვერ მოხერხდა: შეიყვანეთ სრული სახელი"
    let regFailureEmail = "რეგისტრაცია ვერ მოხერხდა: შეიყვანეთ სწორი ელფოსტა"
    let regFailurePassword = "რეგისტრაცია ვერ მოხერხდა: პაროლი უნდა იყოს 8+ სიმბოლო"

    // Checkout
    let checkoutTitle = "გადახდა"
    let checkoutOrderSummary = "შეკვეთის მიმოხილვა"
    let checkoutProduct = "უსადენო ყურსასმენები"
    func checkoutSubtotal(_ amount: String) -> String { "ჯამი: \(amount)" }
    func checkoutShipping(_ amount: String) -> String { "მიწოდება: \(amount)" }
    func checkoutTotal(_ amount: String) -> String { "სულ: \(amount)" }
    let checkoutShippingAddress = "მიწოდების მისამართი"
    let checkoutExpressDelivery = "სწრაფი მიწოდება"
    func checkoutPayment(_ method: String) -> String { "გადახდა: \(method)" }
    let checkoutPlaceOrder = "შეკვეთის გაფორმება"
    func checkoutAddressTyped(_ value: String) -> String { "აკრეფილი მისამართი: \(value)" }
    func checkoutOrderPlaced(_ address: String) -> String { "შეკვეთა გაფორმდა მისამართზე: \(address)" }
    let checkoutFailure = "გადახდა ვერ მოხერხდა: შეიყვანეთ სწორი მიწოდების მისამართი"

    // Profile
    let profileTitle = "პროფილის პარამეტრები"
    let profileDisplayName = "სახელი"
    let profilePhone = "ტელეფონის ნომერი"
    let profileMarketingEmails = "სარეკლამო წერილები"
    let profileSave = "პროფილის შენახვა"
    func profileNameTyped(_ value: String) -> String { "აკრეფილი სახელი: \(value)" }
    func profilePhoneTyped(_ value: String) -> String { "აკრეფილი ტელეფონი: \(value)" }
    func profileSaved(_ name: String) -> String { "პროფილი შენახულია: \(name)" }
    let profileFailureName = "შენახვა ვერ მოხერხდა: შეიყვანეთ სახელი"
    let profileFailurePhone = "შენახვა ვერ მოხერხდა: შეიყვანეთ ტელეფონის ნომერი"

    // List
    let listOrderDetails = "შეკვეთის დეტალები"
    func listSelected(_ id: String) -> String { "არჩეული \(id)" }
    func listCustomer(_ name: String) -> String { "მომხმარებელი: \(name)" }
    func listTotal(_ total: String) -> String { "სულ: \(total)" }
    func listStatus(_ status: String) -> String { "სტატუსი: \(status)" }
    let listStatusReady = "გასაგზავნად მზად"
    let listStatusProcessing = "მუშავდება"

    // Grid
    let gridProductDetails = "პროდუქტის დეტალები"
    func gridSelected(_ name: String) -> String { "არჩეული \(name)" }
    func gridPrice(_ price: String) -> String { "ფასი: \(price)" }
    func gridInventory(_ inventory: String) -> String { "მარაგი: \(inventory)" }
    let gridInStock = "მარაგშია"
    let gridLowStock = "მცირე მარაგი"

    // Search
    let searchTitle = "კატალოგის ძებნა"
    let searchField = "პროდუქტების ძებნა"
    let searchRun = "ძებნა"
    func searchQueryTyped(_ value: String) -> String { "აკრეფილი მოთხოვნა: \(value)" }
    func searchFeatured(_ count: Int) -> String { "ნაჩვენებია \(count) რჩეული პროდუქტი" }
    func searchResults(_ query: String, _ count: Int) -> String { "ძებნის შედეგი „\(query)“-ზე: \(count) ერთეული" }
    func searchCategory(_ category: String) -> String { "კატეგორია: \(category)" }
    func searchPrice(_ price: String) -> String { "ფასი: \(price)" }

    // Showcase
    let showcaseTitle = "კომპონენტების გალერეა"
    let showcaseIntro = "ეს ჩანართი ეხმარება ჟესტების, გადახვევის, გადამრთველებისა და შემოწმებების ვალიდაციას."
    let showcaseEnableNotifications = "შეტყობინებების ჩართვა"
    let showcaseProgress = "პროგრესი"
    func showcaseListElement(_ index: Int) -> String { "სიის ელემენტი \(index)" }
    let showcasePrimary = "ძირითადი"
    let showcaseSecondary = "მეორეული"
    let showcaseEnd = "ეკრანის დასასრული"

    // Pinch
    let pinchTitle = "მასშტაბირების სავარჯიშო"
    let pinchIntro = "გამოიყენეთ ორი თითი სამიზნის გასადიდებლად/დასაპატარავებლად."
    let pinchMe = "დამაპატარავე"
    func pinchStatus(_ scale: String, _ direction: String, _ events: Int) -> String {
        "მასშტაბი: \(scale) | ბოლო: \(direction) | მოვლენები: \(events)"
    }
    let pinchDirIn = "გადიდება"
    let pinchDirOut = "დაპატარავება"
    let pinchDirNone = "არცერთი"

    // Modals
    let modalsTitle = "ფანჯრები"
    let modalsIntro = "გახსენით დიალოგები და ფურცლები, შემდეგ გადაასრიალეთ ქვევით ან დახურეთ დამალვის ბრძანებების შესამოწმებლად."
    let modalsPartialSheet = "ნაწილობრივი ფურცელი"
    let modalsFullSheet = "სრული ფურცელი"
    let modalsAlertDialog = "გამაფრთხილებელი დიალოგი"
    let modalsFullscreenDialog = "სრულეკრანიანი დიალოგი"
    func modalsStatus(_ value: String) -> String { "სტატუსი: \(value)" }
    let modalsStatusNone = "ჯერ არცერთი ფანჯარა არ გახსნილა"
    let modalsStatusPartialVisible = "ნაწილობრივი ქვედა ფურცელი ხილულია"
    let modalsStatusFullVisible = "სრული ქვედა ფურცელი ხილულია"
    let modalsStatusSheetDismissed = "ქვედა ფურცელი დაიხურა"
    let modalsStatusAlertDismissed = "გამაფრთხილებელი დიალოგი დაიხურა"
    let modalsStatusFullscreenDismissed = "სრულეკრანიანი დიალოგი დაიხურა"
    let modalsStatusAlertVisible = "გამაფრთხილებელი დიალოგი ხილულია"
    let modalsStatusFullscreenVisible = "სრულეკრანიანი დიალოგი ხილულია"
    let modalsStatusAlertHidden = "გამაფრთხილებელი დიალოგი დაიმალა გაუქმებით"
    let modalsStatusAlertConfirmed = "გამაფრთხილებელი დიალოგი დადასტურდა"
    let modalsStatusSheetHidden = "ქვედა ფურცელი დაიმალა დახურვის მოქმედებით"
    let modalsStatusFullscreenHidden = "სრულეკრანიანი დიალოგი დაიმალა"
    let modalsBottomSheet = "ქვედა ფურცელი"
    let modalsSheetIntro = "გადაასრიალეთ ქვევით დასამალად ან გამოიყენეთ ქვემოთ მოცემული დახურვის მოქმედება."
    let modalsHideSheet = "ფურცლის დამალვა"
    let modalsAlertTitle = "სესია ამოიწურა"
    let modalsAlertBody = "შეამოწმეთ გაუქმებისა და დადასტურების ბრძანებები ამ დიალოგზე."
    let modalsConfirm = "დადასტურება"
    let modalsDismiss = "გაუქმება"
    let modalsFullscreenTitle = "სრულეკრანის მსგავსი დიალოგი"
    let modalsFullscreenBody = "გამოიყენეთ სრიალის/შეხების ბრძანებები, შემდეგ დახურეთ იგი."
    let modalsClose = "დახურვა"
    let modalsDragHandle = "გადასათრევი სახელური"
    let modalsCodeSheet = "კოდის ფურცელი"
    let modalsVerifyByCode = "კოდით დადასტურება"
    let modalsSmsCode = "SMS კოდი"
    let modalsVerify = "დადასტურება"
    func modalsStatusCodeVerified(_ code: String) -> String { "კოდი დადასტურდა: \(code)" }
    let modalsPromoSoon = "აქცია მალე"
    let modalsPromoTarget = "აქციის სამიზნე"
    let modalsPromoTitle = "აქცია"
    let modalsPromoBody = "შეზღუდული შეთავაზება, თავისით ნაჩვენები."
    let modalsStatusTargetTapped = "სამიზნეს შეეხნენ"

    // Drag & drop
    let dragTitle = "გადათრევა"
    let dragIntro = "გადაიტანეთ წყაროს ჩიპი ჩასაგდებ ზონაში, ან გადაათრიეთ მწკრივები მათი თანმიმდევრობის შესაცვლელად."
    func dragStatus(_ value: String) -> String { "სტატუსი: \(value)" }
    let dragStatusNone = "ჯერ გადათრევა არ შესრულებულა"
    let dragDropZone = "ჩასაგდები ზონა"
    let dragDropHint = "(გადმოათრიეთ ჩიპი აქ)"
    func dragDropHere(_ name: String) -> String { "ჩააგდეთ „\(name)“ აქ" }
    let dragSources = "გადასათრევი წყაროები:"
    let dragReorderable = "გადასალაგებელი მწკრივები:"
    let dragReorderHint = "გადაათრიეთ მწკრივი ზევით ან ქვევით პოზიციის შესაცვლელად."
    let dragHandleLabel = "გადათრევა"
    func dragDragging(_ name: String) -> String { "გადათრევა: \(name)" }
    func dragDroppedInZone(_ name: String) -> String { "\(name) ჩაგდებულია ზონაში" }
    func dragCancelled(_ name: String) -> String { "\(name) გადათრევა გაუქმდა" }
    func dragPickedUp(_ item: String) -> String { "აღებულია: \(item)" }
    func dragMovedUp(_ item: String) -> String { "\(item) გადაინაცვლა ზევით" }
    func dragMovedDown(_ item: String) -> String { "\(item) გადაინაცვლა ქვევით" }
    let dragRowOne = "მწკრივი ერთი"
    let dragRowTwo = "მწკრივი ორი"
    let dragRowThree = "მწკრივი სამი"

    // Network
    let networkDemoTitle = "Dev Scenario ინტერცეპტორის დემო"
    let networkDemoBody = "ამ მოთხოვნებს Dev Scenario იჭერს ამ აპლიკაციის კოდში ერთი `URLProtocol.registerClass(…)` "
        + "ხაზის გარეშეც — ავტომატური SwiftPM-ის `+load` ჩამტვირთავი გლობალურად რეგისტრირდება "
        + "და გაშვებისას ცვლის `URLSession(configuration:…)`-ს."
    let networkAutoFiring = "მიმდინარეობს საწყისი მოთხოვნის გაგზავნა…"
    func networkAutoFailed(_ message: String) -> String { "ავტომოთხოვნა ვერ შესრულდა: \(message)" }
    func networkAutoDone(_ code: Int, _ durationMs: Int) -> String {
        "ავტომოთხოვნა შესრულდა — \(code), \(durationMs) მწმ-ში. იხილეთ Dev Scenario-ის ქსელის ჩანართი."
    }
    let networkAutoLabel = "ავტომატურად გაიგზავნა ეკრანზე შესვლისას"
    let networkBtnGetPost = "GET jsonplaceholder /posts/1"
    let networkBtnPostBody = "POST jsonplaceholder /posts"
    let networkBtnHttpbin = "GET httpbin.org/get"
    let networkBtn404 = "GET → 404 (შეცდომის გამოწვევა)"
}
