import SwiftUI

struct RegistrationView: View {
    private enum SubmitOutcome { case success(email: String), failureName, failureEmail, failurePassword }

    @ObservedObject private var store = LanguageStore.shared
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var acceptedTerms = false
    @State private var submitted = false

    private var strings: SampleStrings { store.strings }

    private var isValid: Bool {
        name.count >= 2 && isValidEmail(email) && password.count >= 8
    }

    private var liveSuccessMessage: String {
        isValid ? strings.regSuccess(email) : ""
    }

    private var statusMessage: String {
        guard submitted else { return "" }
        return statusText(for: outcome)
    }

    private var outcome: SubmitOutcome {
        if name.count < 2 { return .failureName }
        if !isValidEmail(email) { return .failureEmail }
        if password.count < 8 { return .failurePassword }
        return .success(email: email)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(strings.regCreateAccount).font(.title2).fontWeight(.bold)

                TextField(strings.regFullName, text: $name)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier(TestTags.regName)
                if !name.isEmpty {
                    Text(strings.regNameTyped(name))
                        .accessibilityIdentifier(TestTags.regNamePreview)
                }

                TextField(strings.regEmail, text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .accessibilityIdentifier(TestTags.regEmail)
                if !email.isEmpty {
                    Text(strings.regEmailTyped(email))
                        .accessibilityIdentifier(TestTags.regEmailPreview)
                }

                // A plain text field, as in the Compose screen (its password isn't masked either). A
                // SwiftUI SecureField can also drop typed characters under automation.
                TextField(strings.regPassword, text: $password)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .accessibilityIdentifier(TestTags.regPassword)
                if !password.isEmpty {
                    Text(strings.regPasswordTyped(password))
                        .accessibilityIdentifier(TestTags.regPasswordPreview)
                }

                Button(action: { acceptedTerms.toggle() }) {
                    Text(acceptedTerms ? strings.regTermsAccepted : strings.regAcceptTerms)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(TestTags.regTerms)

                if !liveSuccessMessage.isEmpty {
                    Text(liveSuccessMessage)
                        .accessibilityIdentifier(TestTags.regStatus)
                }
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .accessibilityIdentifier(TestTags.regStatus)
                }

                Button(action: { submitted = true }) {
                    Text((submitted && isValid) ? strings.regSuccess(email) : strings.regRegister)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(TestTags.regSubmit)
            }
            .padding(16)
        }
    }

    private func statusText(for outcome: SubmitOutcome) -> String {
        switch outcome {
        case let .success(email): return strings.regSuccess(email)
        case .failureName: return strings.regFailureName
        case .failureEmail: return strings.regFailureEmail
        case .failurePassword: return strings.regFailurePassword
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        guard let at = value.firstIndex(of: "@"), at != value.startIndex else { return false }
        let after = value[value.index(after: at)...]
        guard let dot = after.lastIndex(of: ".") else { return false }
        return dot != after.startIndex && dot != after.index(before: after.endIndex)
            && !value.contains(where: { $0.isWhitespace })
    }
}
