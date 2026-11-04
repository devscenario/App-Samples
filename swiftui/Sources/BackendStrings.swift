import Foundation

/// Backend screen strings, identical to the Compose sample's `BackendStrings.kt`.
protocol BackendStrings {
    var title: String { get }
    var username: String { get }
    var password: String { get }
    var signIn: String { get }
    func signedIn(_ username: String) -> String
    var wrongCredentials: String { get }
    var unreachable: String { get }
    var placeOrder: String { get }
    var orderPlaced: String { get }
    var refresh: String { get }
    func status(_ status: String) -> String
    var noOrder: String { get }
}

struct EnBackendStrings: BackendStrings {
    let title = "Backend"
    let username = "Username"
    let password = "Password"
    let signIn = "Sign in"
    func signedIn(_ username: String) -> String { "Signed in as \(username)" }
    let wrongCredentials = "Wrong username or password"
    let unreachable = "Backend unreachable"
    let placeOrder = "Place order"
    let orderPlaced = "Order placed"
    let refresh = "Refresh status"
    func status(_ status: String) -> String { "Status: \(status)" }
    let noOrder = "No order"
}

struct KaBackendStrings: BackendStrings {
    let title = "ბექენდი"
    let username = "მომხმარებელი"
    let password = "პაროლი"
    let signIn = "შესვლა"
    func signedIn(_ username: String) -> String { "შესულია: \(username)" }
    let wrongCredentials = "არასწორი მომხმარებელი ან პაროლი"
    let unreachable = "ბექენდი მიუწვდომელია"
    let placeOrder = "შეკვეთის განთავსება"
    let orderPlaced = "შეკვეთა განთავსებულია"
    let refresh = "სტატუსის განახლება"
    func status(_ status: String) -> String { "სტატუსი: \(status)" }
    let noOrder = "შეკვეთა არ არის"
}
