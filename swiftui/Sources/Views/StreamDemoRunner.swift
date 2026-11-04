import Foundation

/// Runs the Network screen's WebSocket and SSE demos against the local stream test server, with the
/// same steps and lines as the Compose sample's `StreamDemos.kt`. Each step is one log line, so
/// flows can wait for any step by its text. Everything runs on the main queue.
final class StreamDemoRunner: ObservableObject {
    /// Messages the WebSocket demo sends, one after the other's echo arrives.
    static let webSocketMessages = ["hello", "world"]

    @Published private(set) var wsLines: [String] = []
    @Published private(set) var sseLines: [String] = []
    @Published private(set) var wsRunning = false
    @Published private(set) var sseRunning = false

    private var socket: DemoWebSocketClient?
    private var eventStream: DemoEventStreamClient?
    private var outgoing: [String] = []
    private var pending: String?
    /// Bumped by [stop], so a server start still in flight when the screen leaves opens no demo.
    private var generation = 0

    /// Connects to the echo endpoint, sends [webSocketMessages] one at a time (the next after the
    /// previous one's echo), then closes. Messages that aren't the pending echo (the greeting) are
    /// logged as plain messages.
    func runWebSocket(_ strings: StreamStrings) {
        guard !wsRunning else { return }
        wsRunning = true
        wsLines = []
        withLocalServer(strings, log: { self.wsLines.append($0) }, done: { self.wsRunning = false }) { endpoints in
            self.wsLines.append(strings.wsConnecting)
            self.outgoing = Self.webSocketMessages
            self.pending = nil
            let client = DemoWebSocketClient { [weak self] client, event in self?.handle(event, from: client, strings) }
            self.socket = client
            client.open(endpoints.webSocket)
        }
    }

    /// Reads the event stream to its end and logs each event.
    func runSse(_ strings: StreamStrings) {
        guard !sseRunning else { return }
        sseRunning = true
        sseLines = []
        withLocalServer(strings, log: { self.sseLines.append($0) }, done: { self.sseRunning = false }) { endpoints in
            self.sseLines.append(strings.sseConnecting)
            let client = DemoEventStreamClient { [weak self] client, event in self?.handle(event, from: client, strings) }
            self.eventStream = client
            client.open(endpoints.eventStream)
        }
    }

    /// Closes whatever is still open (the screen went away).
    func stop() {
        generation += 1
        socket?.close()
        eventStream?.cancel()
    }

    /// Events from a client that isn't the current one (a demo that already ended) are ignored.
    private func handle(_ event: DemoWebSocketEvent, from client: DemoWebSocketClient, _ strings: StreamStrings) {
        guard client === socket else { return }
        switch event {
        case .opened:
            wsLines.append(strings.wsConnected)
            sendNext()
        case let .message(text):
            if text == pending {
                wsLines.append(strings.wsEcho(text))
                sendNext()
            } else {
                wsLines.append(strings.wsMessage(text))
            }
        case let .closed(code):
            wsLines.append(strings.wsClosed(code))
            endWebSocket()
        case let .failed(message):
            wsLines.append(strings.wsFailed(message))
            endWebSocket()
        }
    }

    private func handle(_ event: DemoEventStreamEvent, from client: DemoEventStreamClient, _ strings: StreamStrings) {
        guard client === eventStream else { return }
        switch event {
        case .opened:
            sseLines.append(strings.sseOpen)
        case let .event(id, type, data):
            sseLines.append(strings.sseEvent(id ?? "", type ?? "message", data))
        case .closed:
            sseLines.append(strings.sseClosed)
            endEventStream()
        case let .failed(message):
            sseLines.append(strings.sseFailed(message))
            endEventStream()
        case .ended:
            endEventStream()
        }
    }

    private func sendNext() {
        pending = outgoing.isEmpty ? nil : outgoing.removeFirst()
        if let pending {
            socket?.send(pending)
        } else {
            socket?.close()
        }
    }

    private func endWebSocket() {
        socket = nil
        wsRunning = false
    }

    private func endEventStream() {
        eventStream = nil
        sseRunning = false
    }

    /// Starts the debug build's local stream test server off the main queue, then runs [demo] with
    /// its addresses; without a server it logs why and calls [done]. When [stop] ran meanwhile, only
    /// [done] is called.
    private func withLocalServer(
        _ strings: StreamStrings,
        log: @escaping (String) -> Void,
        done: @escaping () -> Void,
        demo: @escaping (StreamEndpoints) -> Void
    ) {
        #if DEBUG
        let run = generation
        DispatchQueue.global(qos: .userInitiated).async {
            let result = Result { try LocalStreamTestServer.start() }
            DispatchQueue.main.async {
                guard run == self.generation else { return done() }
                switch result {
                case let .success(started):
                    guard let endpoints = StreamEndpoints(started) else {
                        log(strings.serverFailed("invalid URL"))
                        return done()
                    }
                    demo(endpoints)
                case let .failure(error):
                    log(strings.serverFailed("\(error)"))
                    done()
                }
            }
        }
        #else
        log(strings.noServer)
        done()
        #endif
    }
}

/// The local stream test server's addresses.
private struct StreamEndpoints {
    let webSocket: URL
    let eventStream: URL

    #if DEBUG
    init?(_ endpoints: LocalStreamTestServer.Endpoints) {
        guard let webSocket = URL(string: endpoints.webSocketUrl),
              let eventStream = URL(string: endpoints.eventStreamUrl) else { return nil }
        self.webSocket = webSocket
        self.eventStream = eventStream
    }
    #endif
}
