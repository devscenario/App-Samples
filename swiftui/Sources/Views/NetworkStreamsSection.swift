import SwiftUI

/// WebSocket and SSE demos against the sample's local stream test server, the counterpart of the
/// Compose sample's `NetworkStreamsSection.kt`. Each button runs one demo; its steps show as one
/// line each, so flows can wait for any step by its text.
struct NetworkStreamsSection: View {
    @ObservedObject private var store = LanguageStore.shared
    @StateObject private var runner = StreamDemoRunner()

    private var strings: StreamStrings { store.strings.streams }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(strings.title)
                .font(.subheadline.weight(.semibold))
            HStack(spacing: 12) {
                demoButton(strings.webSocketButton, id: TestTags.networkBtnWebSocket, running: runner.wsRunning) {
                    runner.runWebSocket(strings)
                }
                demoButton(strings.sseButton, id: TestTags.networkBtnSse, running: runner.sseRunning) {
                    runner.runSse(strings)
                }
            }
            if !runner.wsLines.isEmpty || !runner.sseLines.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    logLines(runner.wsLines, id: TestTags.networkWsLog)
                    logLines(runner.sseLines, id: TestTags.networkSseLog)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .onDisappear { runner.stop() }
    }

    private func demoButton(_ title: String, id: String, running: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(running)
        .accessibilityIdentifier(id)
    }

    @ViewBuilder
    private func logLines(_ lines: [String], id: String) -> some View {
        if !lines.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.system(.caption2, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(id)
        }
    }
}
