import SwiftUI

/// A file the app keeps in its `Documents` folder. Parity with the shared-ui `AppFilesScreen`: the buttons add to it,
/// show it and delete it, so a flow can check what the app wrote with `read` and see what `file(…)` changed by
/// tapping Read file.
struct AppFilesView: View {
    private static let fileName = "sample-log.txt"

    @ObservedObject private var store = LanguageStore.shared
    @State private var content: String?

    private var strings: SampleStrings { store.strings }

    private var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(Self.fileName)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(Self.fileName)
                    .font(.caption)
                    .accessibilityIdentifier(TestTags.appFilesName)
                Button(strings.appFilesAdd) {
                    addLine()
                    content = read()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(TestTags.appFilesAdd)
                Button(strings.appFilesRead) { content = read() }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier(TestTags.appFilesRead)
                Button(strings.appFilesDelete) {
                    try? FileManager.default.removeItem(at: url)
                    content = read()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(TestTags.appFilesDelete)
                Text(shown)
                    .accessibilityIdentifier(TestTags.appFilesContent)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear { content = read() }
    }

    private var shown: String {
        guard let content else { return strings.appFilesMissing }
        if content.isEmpty { return strings.appFilesEmpty }
        var text = content
        while text.hasSuffix("\n") { text.removeLast() }
        return text
    }

    private func read() -> String? { try? String(contentsOf: url, encoding: .utf8) }

    private func addLine() {
        let text = read() ?? ""
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true).count
        let separator = text.isEmpty || text.hasSuffix("\n") ? "" : "\n"
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? "\(text)\(separator)\(strings.appFilesLine(lines + 1))\n".write(to: url, atomically: true, encoding: .utf8)
    }
}
