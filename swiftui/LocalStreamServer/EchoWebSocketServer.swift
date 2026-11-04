#if DEBUG
import Foundation
import Network

/// WebSocket echo server: greets each client with [EchoWebSocketServer.greeting], then sends every
/// text or binary message back unchanged, and answers a close with the same code.
///
/// Unlike the Android sample's server it accepts any path: Network.framework's WebSocket protocol
/// doesn't hand the server the request path, so it can't close other paths with 1008.
final class EchoWebSocketServer {
    /// Sent to every client right after it connects, before any echo.
    static let greeting = "welcome"

    private let port: UInt16
    private let queue = DispatchQueue(label: "sample.stream-server.websocket")
    private var listener: NWListener?

    init(port: UInt16) {
        self.port = port
    }

    /// Binds the port and accepts clients; throws when it can't listen.
    func start() throws {
        let parameters = NWParameters.tcp
        let webSocket = NWProtocolWebSocket.Options()
        webSocket.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.insert(webSocket, at: 0)
        listener = try startLoopbackListener(
            name: "WebSocket server",
            parameters: parameters,
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
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.send(Data(Self.greeting.utf8), opcode: .text, on: connection)
                self?.receive(on: connection)
            case .failed, .waiting:
                connection.cancel()
            default:
                break
            }
        }
        connection.start(queue: queue)
    }

    private func receive(on connection: NWConnection) {
        connection.receiveMessage { [weak self] content, context, _, error in
            guard let self, error == nil else {
                connection.cancel()
                return
            }
            let metadata = context?.protocolMetadata(definition: NWProtocolWebSocket.definition)
                as? NWProtocolWebSocket.Metadata
            switch metadata?.opcode {
            case .text?, .binary?:
                self.send(content ?? Data(), opcode: metadata?.opcode ?? .text, on: connection)
                self.receive(on: connection)
            case .close?:
                self.close(connection, code: metadata?.closeCode ?? .protocolCode(.normalClosure))
            default:
                self.receive(on: connection)
            }
        }
    }

    private func send(_ data: Data, opcode: NWProtocolWebSocket.Opcode, on connection: NWConnection) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: opcode)
        let context = NWConnection.ContentContext(identifier: "echo", metadata: [metadata])
        connection.send(content: data, contentContext: context, isComplete: true, completion: .idempotent)
    }

    /// Answers the client's close frame with the same code, then ends the connection.
    private func close(_ connection: NWConnection, code: NWProtocolWebSocket.CloseCode) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .close)
        metadata.closeCode = code
        let context = NWConnection.ContentContext(identifier: "close", metadata: [metadata])
        connection.send(content: nil, contentContext: context, isComplete: true, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}
#endif
