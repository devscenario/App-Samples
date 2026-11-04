import SwiftUI

/// Native-iOS counterpart to `NetworkScreen.kt` in the Compose sample.
///
/// Fires one request automatically on `task { }` and exposes four buttons for
/// the additional shapes, then the WebSocket and SSE demos
/// (`NetworkStreamsSection`). Every request flows through `URLSession.shared`,
/// which the `DevScenarioHttpInterceptorAuto` SwiftPM product hooks via `+load`
/// (`[NSURLProtocol registerClass:]` + class-method swizzle on
/// `+[NSURLSession sessionWithConfiguration:…]`). No interceptor wiring
/// appears in this file — that's the entire point of the demo.
struct NetworkView: View {

    private struct CallRow: Identifiable {
        let id: Int
        let label: String
        let method: String
        let url: String
        var result: Result?

        struct Result {
            let code: Int
            let durationMs: Int
            let bodyPreview: String
            let errorMessage: String?
            var isError: Bool { errorMessage != nil }
        }
    }

    /// Auto-request status as discrete state so the displayed text re-localizes
    /// when the in-app language toggle flips.
    private enum AutoStatus {
        case firing
        case failed(message: String)
        case done(code: Int, durationMs: Int)
    }

    @ObservedObject private var store = LanguageStore.shared
    @State private var rows: [CallRow] = []
    @State private var autoStatus: AutoStatus = .firing
    @State private var nextId: Int = 0

    private var strings: SampleStrings { store.strings }

    private var autoStatusText: String {
        switch autoStatus {
        case .firing: return strings.networkAutoFiring
        case let .failed(message): return strings.networkAutoFailed(message)
        case let .done(code, durationMs): return strings.networkAutoDone(code, durationMs)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header

                VStack(spacing: 10) {
                    Button(strings.networkBtnGetPost) {
                        fire(label: "GET /posts/1", method: "GET",
                             url: "https://jsonplaceholder.typicode.com/posts/1")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier(TestTags.networkBtnGetPost)
                    .frame(maxWidth: .infinity)

                    Button(strings.networkBtnPostBody) {
                        fire(label: "POST /posts", method: "POST",
                             url: "https://jsonplaceholder.typicode.com/posts",
                             body: #"{"title":"devtool","body":"hello","userId":1}"#)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier(TestTags.networkBtnPostBody)
                    .frame(maxWidth: .infinity)

                    Button(strings.networkBtnHttpbin) {
                        fire(label: "GET httpbin", method: "GET",
                             url: "https://httpbin.org/get?source=devtool-sample")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier(TestTags.networkBtnHttpbin)
                    .frame(maxWidth: .infinity)

                    Button(strings.networkBtn404) {
                        fire(label: "GET → 404", method: "GET",
                             url: "https://httpbin.org/status/404")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier(TestTags.networkBtn404)
                    .frame(maxWidth: .infinity)
                }

                NetworkStreamsSection()

                resultsList
            }
            .padding(16)
        }
        .navigationTitle(strings.titleNetwork)
        .task {
            await autoFire()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(strings.networkDemoTitle)
                .font(.headline)
            Text(strings.networkDemoBody)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(autoStatusText)
                .font(.caption)
                .foregroundStyle(.tint)
                .accessibilityIdentifier(TestTags.networkAutoStatus)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var resultsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows.reversed()) { row in
                resultCard(row)
            }
        }
        .accessibilityIdentifier(TestTags.networkResults)
    }

    @ViewBuilder
    private func resultCard(_ row: CallRow) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(row.method)  \(row.label)").font(.subheadline).fontWeight(.semibold)
            Text(row.url).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            if let result = row.result {
                let color: Color = {
                    if result.isError { return .red }
                    if (200..<300).contains(result.code) { return .green }
                    return .orange
                }()
                if result.isError {
                    Text("ERROR  \(result.errorMessage ?? "")").foregroundStyle(color).font(.caption)
                } else {
                    Text("\(result.code)  •  \(result.durationMs) ms")
                        .foregroundStyle(color)
                        .font(.caption.weight(.bold))
                }
                if !result.bodyPreview.isEmpty {
                    Text(result.bodyPreview)
                        .font(.system(.caption2, design: .monospaced))
                        .lineLimit(3)
                }
            } else {
                ProgressView().controlSize(.mini)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Networking

    private func autoFire() async {
        let url = "https://jsonplaceholder.typicode.com/posts/1"
        let id = beginCall(label: strings.networkAutoLabel, method: "GET", url: url)
        let result = await perform(method: "GET", url: url, body: nil)
        complete(id: id, result: result)
        autoStatus = result.isError
            ? .failed(message: result.errorMessage ?? "")
            : .done(code: result.code, durationMs: result.durationMs)
    }

    private func fire(label: String, method: String, url: String, body: String? = nil) {
        let id = beginCall(label: label, method: method, url: url)
        Task {
            let result = await perform(method: method, url: url, body: body)
            complete(id: id, result: result)
        }
    }

    private func beginCall(label: String, method: String, url: String) -> Int {
        let id = nextId
        nextId += 1
        rows.append(CallRow(id: id, label: label, method: method, url: url, result: nil))
        return id
    }

    private func complete(id: Int, result: CallRow.Result) {
        guard let index = rows.firstIndex(where: { $0.id == id }) else { return }
        rows[index].result = result
    }

    private func perform(method: String, url: String, body: String?) async -> CallRow.Result {
        guard let target = URL(string: url) else {
            return CallRow.Result(code: 0, durationMs: 0, bodyPreview: "", errorMessage: "Invalid URL")
        }
        var request = URLRequest(url: target)
        request.httpMethod = method
        if let body {
            request.httpBody = body.data(using: .utf8)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let start = Date()
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let elapsedMs = Int(Date().timeIntervalSince(start) * 1000)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            let preview = String(data: data.prefix(240), encoding: .utf8) ?? ""
            return CallRow.Result(code: code, durationMs: elapsedMs, bodyPreview: preview, errorMessage: nil)
        } catch {
            let elapsedMs = Int(Date().timeIntervalSince(start) * 1000)
            return CallRow.Result(code: 0, durationMs: elapsedMs, bodyPreview: "",
                                  errorMessage: error.localizedDescription)
        }
    }
}
