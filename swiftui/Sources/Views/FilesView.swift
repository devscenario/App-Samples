import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Opens the system document picker — a remote, out-of-process view controller — and shows the
/// chosen file's name. Parity with the shared-ui `FilesScreen`: the same
/// `UIDocumentPickerViewController` (any item, opened as a copy). Like any document picker it
/// reopens where it was last left.
/// Exercises drivers across an app boundary (the in-app SDK can't see the picker, WDA can).
struct FilesView: View {
    @ObservedObject private var store = LanguageStore.shared
    @State private var status: String?
    @StateObject private var picker = DocumentPicker()

    private var strings: SampleStrings { store.strings }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(strings.filesPick) {
                picker.present { name in
                    status = name.map(strings.filesSelected) ?? strings.filesCancelled
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(TestTags.filesPick)
            Text(status ?? strings.filesNone)
                .accessibilityIdentifier(TestTags.filesSelected)
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Presents `UIDocumentPickerViewController` from the top view controller and reports the picked
/// file's name (nil when cancelled). Kept alive by the view: the picker holds its delegate weakly.
private final class DocumentPicker: NSObject, ObservableObject, UIDocumentPickerDelegate {
    private var onResult: ((String?) -> Void)?

    func present(onResult: @escaping (String?) -> Void) {
        self.onResult = onResult
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        controller.delegate = self
        Self.topViewController()?.present(controller, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        onResult?(urls.first?.lastPathComponent)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        onResult?(nil)
    }

    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        var top = scenes.flatMap(\.windows).first(where: \.isKeyWindow)?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}
