package ge.devtool.samples.ui

/** Registration screen strings. [SampleStrings.registration] picks the table for the active language. */
internal interface RegistrationStrings {
    val createAccount: String
    val fullName: String
    val email: String
    val password: String
    val acceptTerms: String
    val termsAccepted: String
    val register: String
    fun nameTyped(value: String): String
    fun emailTyped(value: String): String
    fun passwordTyped(value: String): String
    fun success(email: String): String
    val failureName: String
    val failureEmail: String
    val failurePassword: String
}

/** English registration screen strings. */
internal object EnRegistrationStrings : RegistrationStrings {
    override val createAccount = "Create account"
    override val fullName = "Full name"
    override val email = "Email"
    override val password = "Password"
    override val acceptTerms = "Accept terms"
    override val termsAccepted = "Terms accepted"
    override val register = "Register"
    override fun nameTyped(value: String) = "Registration name typed: $value"
    override fun emailTyped(value: String) = "Registration email typed: $value"
    override fun passwordTyped(value: String) = "Registration password typed: $value"
    override fun success(email: String) = "Registration success for $email"
    override val failureName = "Registration failed: enter full name"
    override val failureEmail = "Registration failed: enter a valid email"
    override val failurePassword = "Registration failed: password must be 8+ characters"
}

/** Georgian registration screen strings. */
internal object KaRegistrationStrings : RegistrationStrings {
    override val createAccount = "ანგარიშის შექმნა"
    override val fullName = "სრული სახელი"
    override val email = "ელფოსტა"
    override val password = "პაროლი"
    override val acceptTerms = "პირობების მიღება"
    override val termsAccepted = "პირობები მიღებულია"
    override val register = "რეგისტრაცია"
    override fun nameTyped(value: String) = "აკრეფილი სახელი: $value"
    override fun emailTyped(value: String) = "აკრეფილი ელფოსტა: $value"
    override fun passwordTyped(value: String) = "აკრეფილი პაროლი: $value"
    override fun success(email: String) = "წარმატებული რეგისტრაცია: $email"
    override val failureName = "რეგისტრაცია ვერ მოხერხდა: შეიყვანეთ სრული სახელი"
    override val failureEmail = "რეგისტრაცია ვერ მოხერხდა: შეიყვანეთ სწორი ელფოსტა"
    override val failurePassword = "რეგისტრაცია ვერ მოხერხდა: პაროლი უნდა იყოს 8+ სიმბოლო"
}
