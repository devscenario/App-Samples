package ge.devtool.samples.ui

/** Modals screen strings. [SampleStrings.modals] picks the table for the active language. */
internal interface ModalStrings {
    val title: String
    val intro: String
    val partialSheet: String
    val fullSheet: String
    val alertDialog: String
    val fullscreenDialog: String
    fun status(value: String): String
    val statusNone: String
    val statusPartialVisible: String
    val statusFullVisible: String
    val statusSheetDismissed: String
    val statusAlertVisible: String
    val statusFullscreenVisible: String
    val statusAlertDismissed: String
    val statusAlertConfirmed: String
    val statusAlertHidden: String
    val statusSheetHidden: String
    val statusFullscreenDismissed: String
    val statusFullscreenHidden: String
    val bottomSheet: String
    val sheetIntro: String
    val hideSheet: String
    val alertTitle: String
    val alertBody: String
    val confirm: String
    val dismiss: String
    val fullscreenTitle: String
    val fullscreenBody: String
    val close: String
    val codeSheet: String
    val verifyByCode: String
    val smsCode: String
    val verify: String
    fun statusCodeVerified(code: String): String
    val promoSoon: String
    val promoTarget: String
    val promoTitle: String
    val promoBody: String
    val statusTargetTapped: String
}

/** English modals screen strings. */
internal object EnModalStrings : ModalStrings {
    override val title = "Modals"
    override val intro = "Open dialogs and sheets, then swipe down or dismiss to validate hide commands."
    override val partialSheet = "Partial sheet"
    override val fullSheet = "Full sheet"
    override val alertDialog = "Alert dialog"
    override val fullscreenDialog = "Fullscreen dialog"
    override fun status(value: String) = "Status: $value"
    override val statusNone = "No modal opened yet"
    override val statusPartialVisible = "Partial bottom sheet visible"
    override val statusFullVisible = "Full bottom sheet visible"
    override val statusSheetDismissed = "Bottom sheet dismissed"
    override val statusAlertVisible = "Alert dialog visible"
    override val statusFullscreenVisible = "Fullscreen dialog visible"
    override val statusAlertDismissed = "Alert dialog dismissed"
    override val statusAlertConfirmed = "Alert dialog confirmed"
    override val statusAlertHidden = "Alert dialog hidden with dismiss"
    override val statusSheetHidden = "Bottom sheet hidden with close action"
    override val statusFullscreenDismissed = "Fullscreen dialog dismissed"
    override val statusFullscreenHidden = "Fullscreen dialog hidden"
    override val bottomSheet = "Bottom sheet"
    override val sheetIntro = "Swipe down to hide, or use the close action below."
    override val hideSheet = "Hide sheet"
    override val alertTitle = "Session expired"
    override val alertBody = "Test dismiss and confirm commands on this dialog."
    override val confirm = "Confirm"
    override val dismiss = "Dismiss"
    override val fullscreenTitle = "Fullscreen-like dialog"
    override val fullscreenBody = "Use swipe/tap commands then close it."
    override val close = "Close"
    override val codeSheet = "Code sheet"
    override val verifyByCode = "Verify by code"
    override val smsCode = "SMS code"
    override val verify = "Verify"
    override fun statusCodeVerified(code: String) = "Code verified: $code"
    override val promoSoon = "Promo soon"
    override val promoTarget = "Promo target"
    override val promoTitle = "Promo"
    override val promoBody = "A limited offer, shown on its own."
    override val statusTargetTapped = "Target tapped"
}

/** Georgian modals screen strings. */
internal object KaModalStrings : ModalStrings {
    override val title = "ფანჯრები"
    override val intro = "გახსენით დიალოგები და ფურცლები, შემდეგ გადაასრიალეთ ქვევით ან დახურეთ დამალვის ბრძანებების შესამოწმებლად."
    override val partialSheet = "ნაწილობრივი ფურცელი"
    override val fullSheet = "სრული ფურცელი"
    override val alertDialog = "გამაფრთხილებელი დიალოგი"
    override val fullscreenDialog = "სრულეკრანიანი დიალოგი"
    override fun status(value: String) = "სტატუსი: $value"
    override val statusNone = "ჯერ არცერთი ფანჯარა არ გახსნილა"
    override val statusPartialVisible = "ნაწილობრივი ქვედა ფურცელი ხილულია"
    override val statusFullVisible = "სრული ქვედა ფურცელი ხილულია"
    override val statusSheetDismissed = "ქვედა ფურცელი დაიხურა"
    override val statusAlertVisible = "გამაფრთხილებელი დიალოგი ხილულია"
    override val statusFullscreenVisible = "სრულეკრანიანი დიალოგი ხილულია"
    override val statusAlertDismissed = "გამაფრთხილებელი დიალოგი დაიხურა"
    override val statusAlertConfirmed = "გამაფრთხილებელი დიალოგი დადასტურდა"
    override val statusAlertHidden = "გამაფრთხილებელი დიალოგი დაიმალა გაუქმებით"
    override val statusSheetHidden = "ქვედა ფურცელი დაიმალა დახურვის მოქმედებით"
    override val statusFullscreenDismissed = "სრულეკრანიანი დიალოგი დაიხურა"
    override val statusFullscreenHidden = "სრულეკრანიანი დიალოგი დაიმალა"
    override val bottomSheet = "ქვედა ფურცელი"
    override val sheetIntro = "გადაასრიალეთ ქვევით დასამალად ან გამოიყენეთ ქვემოთ მოცემული დახურვის მოქმედება."
    override val hideSheet = "ფურცლის დამალვა"
    override val alertTitle = "სესია ამოიწურა"
    override val alertBody = "შეამოწმეთ გაუქმებისა და დადასტურების ბრძანებები ამ დიალოგზე."
    override val confirm = "დადასტურება"
    override val dismiss = "გაუქმება"
    override val fullscreenTitle = "სრულეკრანის მსგავსი დიალოგი"
    override val fullscreenBody = "გამოიყენეთ სრიალის/შეხების ბრძანებები, შემდეგ დახურეთ იგი."
    override val close = "დახურვა"
    override val codeSheet = "კოდის ფურცელი"
    override val verifyByCode = "კოდით დადასტურება"
    override val smsCode = "SMS კოდი"
    override val verify = "დადასტურება"
    override fun statusCodeVerified(code: String) = "კოდი დადასტურდა: $code"
    override val promoSoon = "აქცია მალე"
    override val promoTarget = "აქციის სამიზნე"
    override val promoTitle = "აქცია"
    override val promoBody = "შეზღუდული შეთავაზება, თავისით ნაჩვენები."
    override val statusTargetTapped = "სამიზნეს შეეხნენ"
}
