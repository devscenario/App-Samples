package ge.devtool.samples.ui

/** Backend screen strings. [SampleStrings.backend] picks the table for the active language. */
internal interface BackendStrings {
    val title: String
    val username: String
    val password: String
    val signIn: String
    fun signedIn(username: String): String
    val wrongCredentials: String
    val unreachable: String
    val placeOrder: String
    val orderPlaced: String
    val refresh: String
    fun status(status: String): String
    val noOrder: String
}

/** English backend screen strings. */
internal object EnBackendStrings : BackendStrings {
    override val title = "Backend"
    override val username = "Username"
    override val password = "Password"
    override val signIn = "Sign in"
    override fun signedIn(username: String) = "Signed in as $username"
    override val wrongCredentials = "Wrong username or password"
    override val unreachable = "Backend unreachable"
    override val placeOrder = "Place order"
    override val orderPlaced = "Order placed"
    override val refresh = "Refresh status"
    override fun status(status: String) = "Status: $status"
    override val noOrder = "No order"
}

/** Georgian backend screen strings. */
internal object KaBackendStrings : BackendStrings {
    override val title = "ბექენდი"
    override val username = "მომხმარებელი"
    override val password = "პაროლი"
    override val signIn = "შესვლა"
    override fun signedIn(username: String) = "შესულია: $username"
    override val wrongCredentials = "არასწორი მომხმარებელი ან პაროლი"
    override val unreachable = "ბექენდი მიუწვდომელია"
    override val placeOrder = "შეკვეთის განთავსება"
    override val orderPlaced = "შეკვეთა განთავსებულია"
    override val refresh = "სტატუსის განახლება"
    override fun status(status: String) = "სტატუსი: $status"
    override val noOrder = "შეკვეთა არ არის"
}
