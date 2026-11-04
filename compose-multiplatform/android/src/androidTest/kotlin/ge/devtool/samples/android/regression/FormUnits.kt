package ge.devtool.samples.android.regression

// Units with text input, each a step-for-step mirror of its .ds file in
// flows/samples/units/.

/**
 * launch.ds. Its `launchApp` (`clearState: true`) is the test rule's activity launch, before the
 * timer starts; this is the unit's wait for the home screen.
 */
internal fun RegressionSteps.launch() = with(ui) {
    waitUntilVisible("Sample Screens", timeoutMs = 15_000)
}

/** login.ds */
internal fun RegressionSteps.login() = with(ui) {
    waitUntilVisible("Login", timeoutMs = 10_000)
    tapOn("Login")
    tapOn("Email")
    inputText("qa@example.com")
    assertVisible("Login email typed: qa@example.com")
    tapOn("Password")
    inputText("Pass1234")
    assertVisible("Login password typed: Pass1234")
    tapOn("Remember me")
    tapOn("Sign in")
    assertVisible("Login success for qa@example.com")
    tapOn("Back")
    waitUntilVisible("Sample Screens")
}

/** registration.ds */
internal fun RegressionSteps.registration() = with(ui) {
    waitUntilVisible("Registration", timeoutMs = 10_000)
    tapOn("Registration")
    waitUntilVisible("Create account", timeoutMs = 10_000)
    tapOn("Full name")
    inputText("Test User")
    assertVisible("Registration name typed: Test User")
    tapOn("Email")
    inputText("newuser@test.example.com")
    assertVisible("Registration email typed: newuser@test.example.com")
    tapOn("Password")
    inputText("Password123")
    assertVisible("Registration password typed: Password123")
    assertVisible("Registration success for newuser@test.example.com")
    scrollUntilVisible("Register", maxScrolls = 2)
    tapOn("Register")
    tapOn("Back")
    waitUntilVisible("Sample Screens")
}

/** checkout.ds */
internal fun RegressionSteps.checkout() = with(ui) {
    waitUntilVisible("Checkout", timeoutMs = 10_000)
    tapOn("Checkout")
    waitUntilVisible("Checkout", timeoutMs = 10_000)
    assertVisible("Order summary")
    tapOn("Shipping address")
    inputText("42 Test Street")
    assertVisible("Checkout address typed: 42 Test Street")
    tapOn("Express delivery")
    assertVisible("Payment: Visa •••• 4242")
    tapOn("Place order")
    assertVisible("Order placed for 42 Test Street")
    tapOn("Back")
    waitUntilVisible("Sample Screens")
}

/** search.ds */
internal fun RegressionSteps.search() = with(ui) {
    waitUntilVisible("Search", timeoutMs = 10_000)
    tapOn("Search")
    waitUntilVisible("Search catalog", timeoutMs = 10_000)
    tapOn("Search products")
    inputText("headphones")
    assertVisible("Search query typed: headphones")
    tapOn("Run search")
    assertVisible("Search results for headphones: 2 items")
    assertVisible("Wireless Headphones")
    tapOn("Back")
    waitUntilVisible("Sample Screens")
}

/** profile.ds */
internal fun RegressionSteps.profile() = with(ui) {
    waitUntilVisible("Profile", timeoutMs = 10_000)
    tapOn("Profile")
    waitUntilVisible("Profile settings", timeoutMs = 10_000)
    assertVisible("Profile name typed: QA Tester")
    tapOn("Phone number")
    inputText("5551234567")
    assertVisible("Profile phone typed: 5551234567")
    tapOn("Marketing emails")
    tapOn("Save profile")
    assertVisible("Profile saved for QA Tester")
    tapOn("Back")
    waitUntilVisible("Sample Screens")
}
