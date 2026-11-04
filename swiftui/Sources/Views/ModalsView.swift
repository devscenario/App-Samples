import SwiftUI

private enum SheetMode: Identifiable {
    case partial, full
    var id: String { self == .partial ? "partial" : "full" }
}

/// `presentationDetents` is iOS 16+. On iOS 15 the sheet just renders at
/// the system default (large). Both detents are visually distinct in the
/// E2E flow's status text either way (the partial vs full label updates
/// via the open-button callback, independent of the actual detent).
private struct SheetDetentsCompat: ViewModifier {
    let isFull: Bool
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents(isFull ? [.large] : [.medium, .large])
                // The sheet draws its own handle, labelled for accessibility (see SheetDragHandle).
                .presentationDragIndicator(.hidden)
        } else {
            content
        }
    }
}

struct ModalsView: View {
    /// Status as a discrete state so the displayed text re-localizes when the
    /// in-app language toggle flips. Mirrors the Compose `ModalsScreen`.
    private enum ModalStatus {
        case none, partialVisible, fullVisible, sheetDismissed, alertVisible, alertDismissed
        case fullscreenVisible, fullscreenDismissed, alertHidden, alertConfirmed, sheetHidden, fullscreenHidden
        case codeVerified(String)
        case targetTapped
    }

    @ObservedObject private var store = LanguageStore.shared
    @State private var status: ModalStatus = .none
    @State private var sheetMode: SheetMode?
    @State private var showAlertDialog = false
    @State private var showFullscreenDialog = false
    @State private var showVerifySheet = false
    @State private var showPromo = false
    /// Set by "Hide sheet" so its own status wins over the generic dismiss status.
    @State private var hidingWithAction = false

    private var strings: SampleStrings { store.strings }

    private var statusText: String {
        switch status {
        case .none: return strings.modalsStatusNone
        case .partialVisible: return strings.modalsStatusPartialVisible
        case .fullVisible: return strings.modalsStatusFullVisible
        case .sheetDismissed: return strings.modalsStatusSheetDismissed
        case .alertVisible: return strings.modalsStatusAlertVisible
        case .alertDismissed: return strings.modalsStatusAlertDismissed
        case .fullscreenDismissed: return strings.modalsStatusFullscreenDismissed
        case .fullscreenVisible: return strings.modalsStatusFullscreenVisible
        case .alertHidden: return strings.modalsStatusAlertHidden
        case .alertConfirmed: return strings.modalsStatusAlertConfirmed
        case .sheetHidden: return strings.modalsStatusSheetHidden
        case .fullscreenHidden: return strings.modalsStatusFullscreenHidden
        case .codeVerified(let code): return strings.modalsStatusCodeVerified(code)
        case .targetTapped: return strings.modalsStatusTargetTapped
        }
    }

    var body: some View {
        content
            .sheet(item: $sheetMode, onDismiss: {
                status = hidingWithAction ? .sheetHidden : .sheetDismissed
                hidingWithAction = false
            }) { mode in
                sheetBody(for: mode)
            }
            .scrimDialog(isPresented: showAlertDialog, onScrimTap: {
                showAlertDialog = false
                status = .alertDismissed
            }) { alertDialog }
            .scrimDialog(isPresented: showFullscreenDialog, onScrimTap: {
                showFullscreenDialog = false
                status = .fullscreenDismissed
            }) { fullscreenDialog }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(strings.modalsTitle).font(.title2).fontWeight(.bold)
            Text(strings.modalsIntro)
            sheetButtons
            dialogButtons
            codeSheetButton
            promoButtons
            Text(strings.modalsStatus(statusText))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(TestTags.modalsStatus)
            Spacer()
        }
        .padding(16)
    }

    private var sheetButtons: some View {
        HStack(spacing: 10) {
            Button(action: {
                hidingWithAction = false
                sheetMode = .partial
                status = .partialVisible
            }) {
                Text(strings.modalsPartialSheet).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(TestTags.modalsOpenPartialSheet)

            Button(action: {
                hidingWithAction = false
                sheetMode = .full
                status = .fullVisible
            }) {
                Text(strings.modalsFullSheet).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(TestTags.modalsOpenFullSheet)
        }
    }

    private var dialogButtons: some View {
        HStack(spacing: 10) {
            Button(action: {
                showAlertDialog = true
                status = .alertVisible
            }) {
                Text(strings.modalsAlertDialog).frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier(TestTags.modalsOpenAlertDialog)

            Button(action: {
                showFullscreenDialog = true
                status = .fullscreenVisible
            }) {
                Text(strings.modalsFullscreenDialog).frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier(TestTags.modalsOpenFullscreenDialog)
        }
    }

    /// Opens the "Verify by code" sheet; the sheet hangs off this button so it doesn't share a
    /// presenter with the partial/full sheet.
    private var codeSheetButton: some View {
        Button(action: { showVerifySheet = true }) {
            Text(strings.modalsCodeSheet).frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier(TestTags.modalsOpenVerifySheet)
        .sheet(isPresented: $showVerifySheet) {
            VerifyCodeSheet(strings: strings) { code in
                showVerifySheet = false
                status = .codeVerified(code)
            }
        }
    }

    /// "Promo soon" brings up a promo sheet on its own a moment later, like a server-driven one;
    /// "Promo target" is a plain button a flow taps while the promo may come up over it.
    private var promoButtons: some View {
        HStack(spacing: 10) {
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { showPromo = true }
            }) {
                Text(strings.modalsPromoSoon).frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier(TestTags.modalsPromoSoon)

            Button(action: { status = .targetTapped }) {
                Text(strings.modalsPromoTarget).frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier(TestTags.modalsPromoTarget)
        }
        .sheet(isPresented: $showPromo) {
            VStack(alignment: .leading, spacing: 10) {
                Text(strings.modalsPromoTitle).font(.title2)
                Text(strings.modalsPromoBody)
                Button(action: { showPromo = false }) {
                    Text(strings.modalsClose).frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(TestTags.modalsPromoClose)
                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(TestTags.modalsPromoSheet)
            .modifier(SheetDetentsCompat(isFull: false))
        }
    }

    private var alertDialog: some View {
        SampleAlertDialog(
            title: strings.modalsAlertTitle,
            message: strings.modalsAlertBody,
            dismissTitle: strings.modalsDismiss,
            confirmTitle: strings.modalsConfirm,
            onDismiss: {
                showAlertDialog = false
                status = .alertHidden
            },
            onConfirm: {
                showAlertDialog = false
                status = .alertConfirmed
            }
        )
    }

    private var fullscreenDialog: some View {
        SampleFullscreenDialog(
            title: strings.modalsFullscreenTitle,
            message: strings.modalsFullscreenBody,
            closeTitle: strings.modalsClose,
            onClose: {
                showFullscreenDialog = false
                status = .fullscreenHidden
            }
        )
    }

    /// Partial sheet: a fixed column. Full sheet: the whole column scrolls, with "Hide sheet" at
    /// its end. Both start with a drag handle the sheet can be dragged by.
    @ViewBuilder
    private func sheetBody(for mode: SheetMode) -> some View {
        VStack(spacing: 0) {
            SheetDragHandle(label: strings.modalsDragHandle)
            if mode == .full {
                ScrollView { sheetColumn(full: true) }
            } else {
                sheetColumn(full: false)
                Spacer(minLength: 0)
            }
        }
        .accessibilityIdentifier(TestTags.modalsSheet)
        .modifier(SheetDetentsCompat(isFull: mode == .full))
    }

    private func sheetColumn(full: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(strings.modalsBottomSheet).font(.title2)
            Text(strings.modalsSheetIntro)
            if full { ModalsFullSheetContent() }
            Button(strings.modalsHideSheet) {
                hidingWithAction = true
                sheetMode = nil
            }
            .padding(.vertical, 8)
            .accessibilityIdentifier(TestTags.modalsSheetHide)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A sheet holding a text field, as in the Compose sample: typing reaches a field in a presented sheet.
private struct VerifyCodeSheet: View {
    let strings: SampleStrings
    let onVerify: (String) -> Void
    @State private var code = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(strings.modalsVerifyByCode).font(.title2)
            TextField(strings.modalsSmsCode, text: $code)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .accessibilityIdentifier(TestTags.modalsVerifyCode)
            Button(action: { onVerify(code) }) {
                Text(strings.modalsVerify).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(TestTags.modalsVerifySubmit)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Keeps the children as their own elements: a container identifier would otherwise replace theirs.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(TestTags.modalsVerifySheet)
        .modifier(SheetDetentsCompat(isFull: false))
    }
}

/// The sheet's grab bar, exposed to accessibility as "Drag handle" like the Material sheet's.
private struct SheetDragHandle: View {
    let label: String

    var body: some View {
        Capsule()
            .fill(Color(.systemGray3))
            .frame(width: 32, height: 4)
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())
            .accessibilityElement()
            .accessibilityLabel(label)
    }
}

/// The long body of the full sheet (fixed English test copy, as in the Compose sample).
private struct ModalsFullSheetContent: View {
    var body: some View {
        Divider()
        Text("Section 1 — Details").font(.headline)
        Text("This is a fully expanded bottom sheet. It contains enough content to fill the entire screen height.")
        Text("Item A: Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
        Text("Item B: Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
        Text("Item C: Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.")
        Divider()
        Text("Section 2 — More Content").font(.headline)
        Text("Item D: Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.")
        Text("Item E: Excepteur sint occaecat cupidatat non proident.")
        Text("Item F: Sunt in culpa qui officia deserunt mollit anim id est laborum.")
        Divider()
        Text("Section 3 — Actions").font(.headline)
        Text("Item G: Curabitur pretium tincidunt lacus. Nulla gravida orci a odio.")
        Text("Item H: Nullam varius, turpis molestie dictum semper, ipsum libero faucibus nulla.")
        Text("Item I: Pellentesque ut neque. Pellentesque habitant morbi tristique senectus.")
        Divider()
        Text("Section 4 — Summary").font(.headline)
        Text("Item J: Fusce fermentum. Nullam varius nulla gravida orci a odio.")
        Text("Item K: Maecenas porttitor congue massa. Fusce posuere, magna sed pulvinar.")
        Spacer().frame(height: 8)
    }
}
