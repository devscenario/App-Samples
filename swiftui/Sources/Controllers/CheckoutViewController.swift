import UIKit

final class CheckoutViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var orderSummaryLabel: UILabel!
    @IBOutlet private var productLabel: UILabel!
    @IBOutlet private var subtotalLabel: UILabel!
    @IBOutlet private var shippingLabel: UILabel!
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var addressField: UITextField!
    @IBOutlet private var addressPreviewLabel: UILabel!
    @IBOutlet private var deliveryLabel: UILabel!
    @IBOutlet private var deliverySwitch: UISwitch!
    @IBOutlet private var paymentLabel: UILabel!
    @IBOutlet private var placeOrderButton: UIButton!
    @IBOutlet private var statusLabel: UILabel!

    // Card detail is a data value, not translated copy. Only the "Payment:"
    // prefix localizes via `checkoutPayment(_:)`.
    private let paymentMethod = "Visa •••• 4242"

    private enum SubmitOutcome { case placed(address: String), failure }
    private var lastOutcome: SubmitOutcome?

    private var strings: SampleStrings { LanguageStore.shared.strings }

    override func viewDidLoad() {
        super.viewDidLoad()

        addressPreviewLabel.isHidden = true
        statusLabel.isHidden = true
        addressPreviewLabel.accessibilityIdentifier = TestTags.checkoutAddressPreview
        statusLabel.accessibilityIdentifier = TestTags.checkoutStatus

        deliverySwitch.addTarget(self, action: #selector(deliveryChanged), for: .valueChanged)
        addressField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)

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
        title = strings.titleCheckout
        titleLabel.text = strings.checkoutTitle
        orderSummaryLabel.text = strings.checkoutOrderSummary
        productLabel.text = strings.checkoutProduct
        subtotalLabel.text = strings.checkoutSubtotal("$89.99")
        addressField.placeholder = strings.checkoutShippingAddress
        deliveryLabel.text = strings.checkoutExpressDelivery
        paymentLabel.text = strings.checkoutPayment(paymentMethod)
        placeOrderButton.setTitle(strings.checkoutPlaceOrder, for: .normal)
        refreshTotals()

        if !addressPreviewLabel.isHidden {
            addressPreviewLabel.text = strings.checkoutAddressTyped(addressField.text ?? "")
        }
        if let outcome = lastOutcome {
            statusLabel.text = statusText(for: outcome)
        }
    }

    @objc private func deliveryChanged() {
        refreshTotals()
    }

    private func refreshTotals() {
        let express = deliverySwitch.isOn
        shippingLabel.text = strings.checkoutShipping(express ? "$12.00" : "$0.00")
        totalLabel.text = strings.checkoutTotal(express ? "$101.99" : "$89.99")
    }

    @objc private func addressChanged() {
        let text = addressField.text ?? ""
        addressPreviewLabel.isHidden = text.isEmpty
        addressPreviewLabel.text = strings.checkoutAddressTyped(text)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction private func placeOrderTapped(_ sender: UIButton) {
        let address = addressField.text ?? ""
        let outcome: SubmitOutcome = address.count >= 8 ? .placed(address: address) : .failure
        lastOutcome = outcome
        statusLabel.isHidden = false
        statusLabel.text = statusText(for: outcome)
    }

    private func statusText(for outcome: SubmitOutcome) -> String {
        switch outcome {
        case let .placed(address): return strings.checkoutOrderPlaced(address)
        case .failure: return strings.checkoutFailure
        }
    }
}
