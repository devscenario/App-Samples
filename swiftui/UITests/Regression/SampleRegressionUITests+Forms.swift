import XCTest

/// The form units: login, registration, checkout, search, profile.
extension SampleRegressionUITests {
    // login.ds
    func unitLogin() {
        d.waitUntilVisible("Login", timeout: 10)
        d.tap("Login")
        d.tap("Email")
        d.inputText("qa@example.com")
        d.assertVisible("Login email typed: qa@example.com")
        d.tap("Password")
        d.inputText("Pass1234")
        d.assertVisible("Login password typed: Pass1234")
        d.tap("Remember me")
        d.tap("Sign in")
        d.assertVisible("Login success for qa@example.com")
        backToHome()
    }

    // registration.ds
    func unitRegistration() {
        d.waitUntilVisible("Registration", timeout: 10)
        d.tap("Registration")
        d.waitUntilVisible("Create account", timeout: 10)
        d.tap("Full name")
        d.inputText("Test User")
        d.assertVisible("Registration name typed: Test User")
        d.tap("Email")
        d.inputText("newuser@test.example.com")
        d.assertVisible("Registration email typed: newuser@test.example.com")
        d.tap("Password")
        d.inputText("Password123")
        d.assertVisible("Registration password typed: Password123")
        d.assertVisible("Registration success for newuser@test.example.com")
        d.scrollUntilVisible("Register", maxScrolls: 2)
        d.tap("Register")
        backToHome()
    }

    // checkout.ds
    func unitCheckout() {
        d.waitUntilVisible("Checkout", timeout: 10)
        d.tap("Checkout")
        d.waitUntilVisible("Checkout", timeout: 10)
        d.assertVisible("Order summary")
        d.tap("Shipping address")
        d.inputText("42 Test Street")
        d.assertVisible("Checkout address typed: 42 Test Street")
        d.tap("Express delivery")
        d.assertVisible("Payment: Visa •••• 4242")
        d.tap("Place order")
        d.assertVisible("Order placed for 42 Test Street")
        backToHome()
    }

    // search.ds
    func unitSearch() {
        d.waitUntilVisible("Search", timeout: 10)
        d.tap("Search")
        d.waitUntilVisible("Search catalog", timeout: 10)
        d.tap("Search products")
        d.inputText("headphones")
        d.assertVisible("Search query typed: headphones")
        d.tap("Run search")
        d.assertVisible("Search results for headphones: 2 items")
        d.assertVisible("Wireless Headphones")
        backToHome()
    }

    // profile.ds
    func unitProfile() {
        d.waitUntilVisible("Profile", timeout: 10)
        d.tap("Profile")
        d.waitUntilVisible("Profile settings", timeout: 10)
        d.assertVisible("Profile name typed: QA Tester")
        d.tap("Phone number")
        d.inputText("5551234567")
        d.assertVisible("Profile phone typed: 5551234567")
        d.tap("Marketing emails")
        d.tap("Save profile")
        d.assertVisible("Profile saved for QA Tester")
        backToHome()
    }
}
