import SwiftUI
import UIKit

extension View {
    /// Presents `content` as a dialog over a dimmed scrim that covers the whole window (navigation
    /// bar included), like a Material dialog: a tap on the scrim calls `onScrimTap`. Shown while
    /// `isPresented` is true.
    func scrimDialog<DialogContent: View>(
        isPresented: Bool,
        onScrimTap: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> DialogContent
    ) -> some View {
        background(ScrimDialogHost(isPresented: isPresented, onScrimTap: onScrimTap, content: content))
    }
}

/// Invisible controller that presents / dismisses the dialog controller as `isPresented` changes.
private struct ScrimDialogHost<DialogContent: View>: UIViewControllerRepresentable {
    let isPresented: Bool
    let onScrimTap: () -> Void
    let content: () -> DialogContent

    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        let screen = ScrimDialogScreen(onScrimTap: onScrimTap, content: content())
        let presented = host.presentedViewController as? UIHostingController<ScrimDialogScreen<DialogContent>>
        if isPresented {
            if let presented {
                presented.rootView = screen
                return
            }
            let controller = UIHostingController(rootView: screen)
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            controller.view.backgroundColor = .clear
            // Presenting during a SwiftUI update pass is not allowed: defer to the next run loop.
            DispatchQueue.main.async { host.present(controller, animated: true) }
        } else if presented != nil {
            host.dismiss(animated: true)
        }
    }
}

private struct ScrimDialogScreen<DialogContent: View>: View {
    let onScrimTap: () -> Void
    let content: DialogContent

    var body: some View {
        ZStack {
            Color.black.opacity(0.32)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: onScrimTap)
            content
        }
    }
}

/// Alert-style dialog body: title, message and a trailing row of text buttons.
struct SampleAlertDialog: View {
    let title: String
    let message: String
    let dismissTitle: String
    let confirmTitle: String
    let onDismiss: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.title2)
            Text(message).foregroundColor(.secondary)
            HStack(spacing: 8) {
                Spacer()
                Button(dismissTitle, action: onDismiss)
                    .accessibilityIdentifier(TestTags.modalsAlertDismiss)
                Button(confirmTitle, action: onConfirm)
                    .accessibilityIdentifier(TestTags.modalsAlertConfirm)
            }
        }
        .padding(24)
        .frame(maxWidth: 320, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 28).fill(Color(.secondarySystemBackground)))
        .padding(.horizontal, 32)
    }
}

/// Fullscreen-like dialog body: title, message and a Close button across the width.
struct SampleFullscreenDialog: View {
    let title: String
    let message: String
    let closeTitle: String
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.title3).fontWeight(.bold)
            Text(message)
            Button(action: onClose) {
                Text(closeTitle).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(TestTags.modalsFullscreenClose)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .accessibilityIdentifier(TestTags.modalsFullscreenDialog)
        .padding(16)
    }
}
