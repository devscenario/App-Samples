#if DEBUG
import Foundation
import Network

/// Debug builds: the local WebSocket echo and server-sent events test server the Network screen's
/// stream demos talk to, on the loopback only. Same ports, paths and behaviour as the Android
/// sample's debug server, so flows and network rules name the same URLs on both platforms.
/// Started on first use and kept for the life of the process, or until iOS stops its listeners.
enum LocalStreamTestServer {
    static let loopbackHost = "127.0.0.1"
    static let webSocketPort: UInt16 = 8770
    static let eventStreamPort: UInt16 = 8771
    static let webSocketPath = "/echo"
    static let eventStreamPath = "/events"

    /// Where the servers listen.
    struct Endpoints {
        let webSocketUrl: String
        let eventStreamUrl: String
    }

    private static let lock = NSLock()
    private static var endpoints: Endpoints?
    private static var echoServer: EchoWebSocketServer?
    private static var eventServer: EventStreamServer?

    /// Starts both servers and returns their addresses; later calls return the same ones while both
    /// still listen, and bind again once either stopped (iOS can reclaim a suspended app's listeners).
    /// Blocks until they listen (call it off the main thread); throws when a port can't be bound, for
    /// example when another app or simulator on this Mac already listens on it.
    static func start() throws -> Endpoints {
        lock.lock()
        defer { lock.unlock() }
        if let endpoints, echoServer?.isListening == true, eventServer?.isListening == true {
            return endpoints
        }
        stopServers()
        let echo = EchoWebSocketServer(port: webSocketPort)
        try echo.start()
        let events = EventStreamServer(port: eventStreamPort)
        do {
            try events.start()
        } catch {
            // Frees the WebSocket port so the next attempt can start both servers again.
            echo.stop()
            throw error
        }
        echoServer = echo
        eventServer = events
        let started = Endpoints(
            webSocketUrl: "ws://\(loopbackHost):\(webSocketPort)\(webSocketPath)",
            eventStreamUrl: "http://\(loopbackHost):\(eventStreamPort)\(eventStreamPath)"
        )
        endpoints = started
        return started
    }

    /// Frees both ports and forgets the addresses; callers hold [lock].
    private static func stopServers() {
        echoServer?.stop()
        eventServer?.stop()
        echoServer = nil
        eventServer = nil
        endpoints = nil
    }
}

/// Why a test server did not start.
struct LocalStreamServerError: Error, CustomStringConvertible {
    let description: String
}

/// Listens on [LocalStreamTestServer.loopbackHost]:[port] with [parameters] and hands each
/// connection to [onConnection]. Returns once the listener is ready; throws when it fails or
/// doesn't get ready within 5 s.
func startLoopbackListener(
    name: String,
    parameters: NWParameters,
    port: UInt16,
    queue: DispatchQueue,
    onConnection: @escaping (NWConnection) -> Void
) throws -> NWListener {
    guard let nwPort = NWEndpoint.Port(rawValue: port) else {
        throw LocalStreamServerError(description: "\(name): invalid port \(port)")
    }
    parameters.requiredLocalEndpoint = .hostPort(host: NWEndpoint.Host(LocalStreamTestServer.loopbackHost), port: nwPort)
    parameters.allowLocalEndpointReuse = true
    let listener = try NWListener(using: parameters)
    let settled = DispatchSemaphore(value: 0)
    var failure: Error?
    var signalled = false
    listener.stateUpdateHandler = { state in
        switch state {
        case .ready:
            break
        case let .failed(error), let .waiting(error):
            failure = error
        default:
            return
        }
        if !signalled {
            signalled = true
            settled.signal()
        }
    }
    listener.newConnectionHandler = onConnection
    listener.start(queue: queue)
    let timedOut = settled.wait(timeout: .now() + 5) == .timedOut
    // The state handler runs on [queue]: read what it wrote there.
    let error: Error? = queue.sync { timedOut ? LocalStreamServerError(description: "did not start") : failure }
    if let error {
        listener.cancel()
        throw LocalStreamServerError(description: "\(name): \(readable(error))")
    }
    return listener
}

/// "Address already in use" rather than the POSIX code's debug form.
private func readable(_ error: Error) -> String {
    if case let .posix(code)? = error as? NWError {
        return String(cString: strerror(code.rawValue))
    }
    return "\(error)"
}
#endif
