import UIKit

final class LoginViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var emailField: UITextField!
    @IBOutlet private var emailPreviewLabel: UILabel!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var passwordPreviewLabel: UILabel!
    @IBOutlet private var rememberSwitch: UISwitch!
    @IBOutlet private var rememberLabel: UILabel!
    @IBOutlet private var signInButton: UIButton!
    @IBOutlet private var statusLabel: UILabel!

    /// Last submit outcome, kept so the status string can be re-localized
    /// when the in-app language toggle flips while a result is on screen.
    private enum SubmitOutcome { case success(email: String), failure }
    private var lastOutcome: SubmitOutcome?

    private var strings: SampleStrings { LanguageStore.shared.strings }

    override func viewDidLoad() {
        super.viewDidLoad()

        emailPreviewLabel.isHidden = true
        passwordPreviewLabel.isHidden = true
        statusLabel.isHidden = true

        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)

        // Storyboard identifiers cover most controls; reapply here so the
        // labels (which start hidden) stay queryable when revealed.
        emailPreviewLabel.accessibilityIdentifier = TestTags.loginEmailPreview
        passwordPreviewLabel.accessibilityIdentifier = TestTags.loginPasswordPreview
        statusLabel.accessibilityIdentifier = TestTags.loginStatus

        applyStrings()
        NotificationCenter.default.addObserver(
            self, selector: #selector(applyStrings),
            name: LanguageStore.languageDidChange, object: nil
        )

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // The storyboard lays out the Remember-me row as a `UIStackView`
        // containing the switch + a non-interactive label. `UIStackView` is
        // a pure layout container and doesn't synthesize taps for its
        // subviews, so the label area was dead — tapping the text did
        // nothing. Adding a recognizer on the row toggles the switch the
        // way a typical iOS settings row behaves. Direct taps on the
        // toggle still work as before (a parent recognizer doesn't steal
        // taps that land on a `UIControl` child).
        if let row = rememberSwitch.superview {
            let rememberTap = UITapGestureRecognizer(target: self, action: #selector(toggleRemember))
            row.addGestureRecognizer(rememberTap)
        }
    }

    /// Applies the active language to all static + dynamic copy. Safe to call
    /// repeatedly (initial setup and on every language change).
    @objc private func applyStrings() {
        title = strings.titleLogin
        titleLabel.text = strings.loginWelcome
        emailField.placeholder = strings.loginEmail
        passwordField.placeholder = strings.loginPassword
        rememberLabel.text = strings.loginRememberMe
        signInButton.setTitle(strings.loginSignIn, for: .normal)

        // Re-localize live previews / status if currently displayed.
        if !emailPreviewLabel.isHidden {
            emailPreviewLabel.text = strings.loginEmailTyped(emailField.text ?? "")
        }
        if !passwordPreviewLabel.isHidden {
            passwordPreviewLabel.text = strings.loginPasswordTyped(passwordField.text ?? "")
        }
        if let outcome = lastOutcome {
            statusLabel.text = statusText(for: outcome)
        }
    }

    @objc private func toggleRemember() {
        rememberSwitch.setOn(!rememberSwitch.isOn, animated: true)
        rememberSwitch.sendActions(for: .valueChanged)
    }

    @objc private func emailChanged() {
        let text = emailField.text ?? ""
        emailPreviewLabel.isHidden = text.isEmpty
        emailPreviewLabel.text = strings.loginEmailTyped(text)
    }

    @objc private func passwordChanged() {
        let text = passwordField.text ?? ""
        passwordPreviewLabel.isHidden = text.isEmpty
        passwordPreviewLabel.text = strings.loginPasswordTyped(text)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction private func signInTapped(_ sender: UIButton) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let outcome: SubmitOutcome = (isValidEmail(email) && password.count >= 6)
            ? .success(email: email)
            : .failure
        lastOutcome = outcome
        statusLabel.isHidden = false
        statusLabel.text = statusText(for: outcome)
    }

    private func statusText(for outcome: SubmitOutcome) -> String {
        switch outcome {
        case let .success(email): return strings.loginSuccess(email)
        case .failure: return strings.loginFailure
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        guard let at = value.firstIndex(of: "@"), at != value.startIndex else { return false }
        let domain = value[value.index(after: at)...]
        return domain.contains(".") && !domain.hasSuffix(".")
    }
}
