package ge.devtool.samples.ui

/** Login screen strings. [SampleStrings.login] picks the table for the active language. */
internal interface LoginStrings {
    val welcome: String
    val email: String
    val password: String
    val rememberMe: String
    val signIn: String
    fun emailTyped(value: String): String
    fun passwordTyped(value: String): String
    fun success(email: String): String
    val failure: String
}

/** English login screen strings. */
internal object EnLoginStrings : LoginStrings {
    override val welcome = "Welcome back"
    override val email = "Email"
    override val password = "Password"
    override val rememberMe = "Remember me"
    override val signIn = "Sign in"
    override fun emailTyped(value: String) = "Login email typed: $value"
    override fun passwordTyped(value: String) = "Login password typed: $value"
    override fun success(email: String) = "Login success for $email"
    override val failure = "Login failed: enter a valid email and 6+ character password"
}

/** Georgian login screen strings. */
internal object KaLoginStrings : LoginStrings {
    override val welcome = "კეთილი იყოს თქვენი დაბრუნება"
    override val email = "ელფოსტა"
    override val password = "პაროლი"
    override val rememberMe = "დამიმახსოვრე"
    override val signIn = "შესვლა"
    override fun emailTyped(value: String) = "აკრეფილი ელფოსტა: $value"
    override fun passwordTyped(value: String) = "აკრეფილი პაროლი: $value"
    override fun success(email: String) = "წარმატებული შესვლა: $email"
    override val failure = "შესვლა ვერ მოხერხდა: შეიყვანეთ სწორი ელფოსტა და 6+ სიმბოლოიანი პაროლი"
}
