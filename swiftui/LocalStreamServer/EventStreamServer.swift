#if DEBUG
import Foundation
import Network

/// Minimal HTTP server for server-sent events: `GET` [LocalStreamTestServer.eventStreamPath] answers
/// with [EventStreamServer.script] as `text/event-stream`, one chunk every 250 ms, then ends the
/// response; any other path answers 404.
final class EventStreamServer {
    /// Three events with ids and names and a keepalive comment between them, as the Android sample sends.
    static let script = [
        "id: 1\nevent: greeting\ndata: hello\n\n",
        ": keepalive\n\n",
        "id: 2\nevent: tick\ndata: {\"n\":2}\n\n",
        "id: 3\nevent: done\ndata: bye\n\n",
    ]

    private static let interval: DispatchTimeInterval = .milliseconds(250)
    private static let maxRequestHeadBytes = 16 * 1024

    private static let streamHeaders = "HTTP/1.1 200 OK\r\n" +
        "Content-Type: text/event-stream\r\n" +
        "Cache-Control: no-cache\r\n" +
        "Connection: close\r\n\r\n"

    private static let notFound = "HTTP/1.1 404 Not Found\r\n" +
        "Content-Length: 0\r\n" +
        "Connection: close\r\n\r\n"

    private let port: UInt16
    private let queue = DispatchQueue(label: "sample.stream-server.events")
    private var listener: NWListener?

    init(port: UInt16) {
        self.port = port
    }

    /// Binds the port and accepts clients; throws when it can't listen.
    func start() throws {
        listener = try startLoopbackListener(
            name: "Event stream server",
            parameters: .tcp,
            port: port,
            queue: queue
        ) { [weak self] connection in
            self?.accept(connection)
        }
    }

    /// Whether the listener is still accepting clients (iOS can reclaim a suspended app's listener).
    var isListening: Bool {
        if case .ready? = listener?.state { return true }
        return false
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func accept(_ connection: NWConnection) {
        connection.stateUpdateHandler = { state in
            if case .failed = state { connection.cancel() }
        }
        connection.start(queue: queue)
        readRequestHead(on: connection, buffer: Data())
    }

    /// Reads up to the end of the request headers, then answers.
    private func readRequestHead(on connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] content, _, isComplete, error in
            guard let self else { return }
            var head = buffer
            if let content { head.append(content) }
            if head.range(of: Data("\r\n\r\n".utf8)) != nil {
                self.answer(Self.requestPath(head), on: connection)
            } else if error != nil || isComplete || head.count > Self.maxRequestHeadBytes {
                connection.cancel()
            } else {
                self.readRequestHead(on: connection, buffer: head)
            }
        }
    }

    private func answer(_ path: String?, on connection: NWConnection) {
        guard path == LocalStreamTestServer.eventStreamPath else {
            send(Self.notFound, on: connection) { connection.cancel() }
            return
        }
        send(Self.streamHeaders, on: connection) {}
        sendChunk(0, on: connection)
    }

    private func sendChunk(_ index: Int, on connection: NWConnection) {
        guard index < Self.script.count else {
            connection.cancel()
            return
        }
        queue.asyncAfter(deadline: .now() + Self.interval) { [weak self] in
            self?.send(Self.script[index], on: connection) {
                self?.sendChunk(index + 1, on: connection)
            }
        }
    }

    private func send(_ text: String, on connection: NWConnection, then next: @escaping () -> Void) {
        connection.send(content: Data(text.utf8), completion: .contentProcessed { error in
            if error != nil {
                // The client went away mid-stream.
                connection.cancel()
            } else {
                next()
            }
        })
    }

    /// The request line's path without its query.
    private static func requestPath(_ head: Data) -> String? {
        guard let text = String(data: head, encoding: .ascii),
              let requestLine = text.components(separatedBy: "\r\n").first else { return nil }
        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2 else { return nil }
        return parts[1].split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init)
    }
}
#endif
