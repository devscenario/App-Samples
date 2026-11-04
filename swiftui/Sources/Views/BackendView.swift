import SwiftUI

/// Native-iOS counterpart to `BackendScreen.kt`: signs in against `test-backend` and
/// follows the user's order. Same tags and texts as the Compose screen.
struct BackendView: View {
    @ObservedObject private var store = LanguageStore.shared
    @State private var username = ""
    @State private var password = ""
    @State private var signIn: BackendOutcome?
    @State private var order: BackendOutcome?
    @State private var busy = false

    private let client = BackendClient(baseUrl: BackendClient.launchBaseUrl())
    private var strings: BackendStrings { store.strings.backend }
    private var session: String? {
        if case let .signedIn(session, _) = signIn { return session }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(client.baseUrl).font(.caption2).lineLimit(1).truncationMode(.tail)
                    .accessibilityIdentifier(TestTags.backendUrl)
                TextField(strings.username, text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .accessibilityIdentifier(TestTags.backendUsername)
                SecureField(strings.password, text: $password)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier(TestTags.backendPassword)
                actionButton(strings.signIn, id: TestTags.backendSignIn, prominent: true) {
                    signIn = await client.signIn(username: username.trimmingCharacters(in: .whitespaces),
                                                 password: password)
                    order = nil
                }
                if let signIn {
                    Text(signIn.text(strings)).accessibilityIdentifier(TestTags.backendStatus)
                }
                if let session {
                    actionButton(strings.placeOrder, id: TestTags.backendSubmit, prominent: false) {
                        order = await client.placeOrder(session: session)
                    }
                    actionButton(strings.refresh, id: TestTags.backendRefresh, prominent: false) {
                        order = await client.refreshStatus(session: session)
                    }
                    if let order {
                        Text(order.text(strings)).accessibilityIdentifier(TestTags.backendOrder)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(strings.title)
    }

    @ViewBuilder
    private func actionButton(_ title: String, id: String, prominent: Bool,
                              action: @escaping () async -> Void) -> some View {
        let button = Button {
            busy = true
            Task {
                await action()
                busy = false
            }
        } label: {
            Text(title).lineLimit(1).frame(maxWidth: .infinity)
        }
        .disabled(busy)
        .accessibilityIdentifier(id)
        if prominent {
            button.buttonStyle(.borderedProminent)
        } else {
            button.buttonStyle(.bordered)
        }
    }
}

/// What a backend call ended with, independent of the display language.
enum BackendOutcome {
    case signedIn(session: String, username: String)
    case wrongCredentials
    case unreachable
    case orderPlaced
    case status(String)
    case noOrder

    func text(_ strings: BackendStrings) -> String {
        switch self {
        case let .signedIn(_, username): return strings.signedIn(username)
        case .wrongCredentials: return strings.wrongCredentials
        case .unreachable: return strings.unreachable
        case .orderPlaced: return strings.orderPlaced
        case let .status(code): return strings.status(code)
        case .noOrder: return strings.noOrder
        }
    }
}

/// The app's side of the sample backend over `URLSession.shared`.
struct BackendClient {
    static let defaultBaseUrl = "http://localhost:8095"

    let baseUrl: String

    /// `-backendUrl <url>` launch argument (lands in the standard user defaults), else the default.
    static func launchBaseUrl() -> String {
        UserDefaults.standard.string(forKey: "backendUrl") ?? defaultBaseUrl
    }

    func signIn(username: String, password: String) async -> BackendOutcome {
        guard let (code, json) = await call("POST", "/app/login",
                                            body: ["username": username, "password": password]) else {
            return .unreachable
        }
        guard code == 200 else { return .wrongCredentials }
        guard let session = json["session"] as? String, let name = json["username"] as? String else {
            return .unreachable
        }
        return .signedIn(session: session, username: name)
    }

    func placeOrder(session: String) async -> BackendOutcome {
        guard let (code, _) = await call("POST", "/app/orders", body: [:], session: session) else {
            return .unreachable
        }
        return code == 200 ? .orderPlaced : .noOrder
    }

    func refreshStatus(session: String) async -> BackendOutcome {
        guard let (code, json) = await call("GET", "/app/orders/current", session: session) else {
            return .unreachable
        }
        guard code == 200, let status = json["status"] as? String else { return .noOrder }
        return .status(status)
    }

    /// Status code and JSON object of one call, or nil when the backend can't be reached.
    private func call(_ method: String, _ path: String, body: [String: String]? = nil,
                      session: String? = nil) async -> (Int, [String: Any])? {
        guard let url = URL(string: baseUrl + path) else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 12)
        request.httpMethod = method
        if let body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let session { request.setValue(session, forHTTPHeaderField: "X-Session") }
        guard let (data, response) = try? await URLSession.shared.data(for: request) else { return nil }
        let code = (response as? HTTPURLResponse)?.statusCode ?? 0
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
        return (code, json)
    }
}
