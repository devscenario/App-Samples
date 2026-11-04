import UIKit

final class ProfileViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var nameField: UITextField!
    @IBOutlet private var namePreviewLabel: UILabel!
    @IBOutlet private var phoneField: UITextField!
    @IBOutlet private var phonePreviewLabel: UILabel!
    @IBOutlet private var marketingLabel: UILabel!
    @IBOutlet private var marketingSwitch: UISwitch!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var statusLabel: UILabel!

    private enum SubmitOutcome { case saved(name: String), failureName, failurePhone }
    private var lastOutcome: SubmitOutcome?

    private var strings: SampleStrings { LanguageStore.shared.strings }

    override func viewDidLoad() {
        super.viewDidLoad()

        // "QA Tester" is a default data value, not translated copy.
        nameField.text = "QA Tester"
        marketingSwitch.isOn = true

        phonePreviewLabel.isHidden = true
        statusLabel.isHidden = true

        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        phoneField.addTarget(self, action: #selector(phoneChanged), for: .editingChanged)

        namePreviewLabel.accessibilityIdentifier = TestTags.profileNamePreview
        phonePreviewLabel.accessibilityIdentifier = TestTags.profilePhonePreview
        statusLabel.accessibilityIdentifier = TestTags.profileStatus

        applyStrings()
        NotificationCenter.default.addObserver(
            self, selector: #selector(applyStrings),
            name: LanguageStore.languageDidChange, object: nil
        )

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func applyStrings() {
        title = strings.titleProfile
        titleLabel.text = strings.profileTitle
        nameField.placeholder = strings.profileDisplayName
        phoneField.placeholder = strings.profilePhone
        marketingLabel.text = strings.profileMarketingEmails
        saveButton.setTitle(strings.profileSave, for: .normal)

        refreshNamePreview()
        if !phonePreviewLabel.isHidden {
            phonePreviewLabel.text = strings.profilePhoneTyped(phoneField.text ?? "")
        }
        if let outcome = lastOutcome {
            statusLabel.text = statusText(for: outcome)
        }
    }

    @objc private func nameChanged() {
        refreshNamePreview()
    }

    private func refreshNamePreview() {
        namePreviewLabel.text = strings.profileNameTyped(nameField.text ?? "")
    }

    @objc private func phoneChanged() {
        let text = phoneField.text ?? ""
        phonePreviewLabel.isHidden = text.isEmpty
        phonePreviewLabel.text = strings.profilePhoneTyped(text)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction private func saveTapped(_ sender: UIButton) {
        let name = nameField.text ?? ""
        let phone = phoneField.text ?? ""
        let outcome: SubmitOutcome
        if name.count < 2 {
            outcome = .failureName
        } else if phone.count < 7 {
            outcome = .failurePhone
        } else {
            outcome = .saved(name: name)
        }
        lastOutcome = outcome
        statusLabel.isHidden = false
        statusLabel.text = statusText(for: outcome)
    }

    private func statusText(for outcome: SubmitOutcome) -> String {
        switch outcome {
        case let .saved(name): return strings.profileSaved(name)
        case .failureName: return strings.profileFailureName
        case .failurePhone: return strings.profileFailurePhone
        }
    }
}
