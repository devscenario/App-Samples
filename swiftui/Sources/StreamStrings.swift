import Foundation

/// Network screen stream demo strings, identical to the Compose sample's `StreamStrings.kt`.
protocol StreamStrings {
    var title: String { get }
    var webSocketButton: String { get }
    var sseButton: String { get }
    var noServer: String { get }
    func serverFailed(_ message: String) -> String
    var wsConnecting: String { get }
    var wsConnected: String { get }
    func wsMessage(_ text: String) -> String
    func wsEcho(_ text: String) -> String
    func wsClosed(_ code: Int) -> String
    func wsFailed(_ message: String) -> String
    var sseConnecting: String { get }
    var sseOpen: String { get }
    func sseEvent(_ id: String, _ type: String, _ data: String) -> String
    var sseClosed: String { get }
    func sseFailed(_ message: String) -> String
}

struct EnStreamStrings: StreamStrings {
    let title = "Streams"
    let webSocketButton = "WebSocket"
    let sseButton = "SSE"
    let noServer = "No local server"
    func serverFailed(_ message: String) -> String { "Server failed: \(message)" }
    let wsConnecting = "WS connecting"
    let wsConnected = "WS connected"
    func wsMessage(_ text: String) -> String { "WS message: \(text)" }
    func wsEcho(_ text: String) -> String { "WS echo: \(text)" }
    func wsClosed(_ code: Int) -> String { "WS closed: \(code)" }
    func wsFailed(_ message: String) -> String { "WS failed: \(message)" }
    let sseConnecting = "SSE connecting"
    let sseOpen = "SSE open"
    func sseEvent(_ id: String, _ type: String, _ data: String) -> String { "SSE event \(id) (\(type)): \(data)" }
    let sseClosed = "SSE closed"
    func sseFailed(_ message: String) -> String { "SSE failed: \(message)" }
}

struct KaStreamStrings: StreamStrings {
    let title = "სტრიმები"
    let webSocketButton = "WebSocket"
    let sseButton = "SSE"
    let noServer = "ლოკალური სერვერი არ არის"
    func serverFailed(_ message: String) -> String { "სერვერის შეცდომა: \(message)" }
    let wsConnecting = "WS უკავშირდება"
    let wsConnected = "WS დაკავშირდა"
    func wsMessage(_ text: String) -> String { "WS შეტყობინება: \(text)" }
    func wsEcho(_ text: String) -> String { "WS ექო: \(text)" }
    func wsClosed(_ code: Int) -> String { "WS დაიხურა: \(code)" }
    func wsFailed(_ message: String) -> String { "WS შეცდომა: \(message)" }
    let sseConnecting = "SSE უკავშირდება"
    let sseOpen = "SSE გაიხსნა"
    func sseEvent(_ id: String, _ type: String, _ data: String) -> String { "SSE მოვლენა \(id) (\(type)): \(data)" }
    let sseClosed = "SSE დაიხურა"
    func sseFailed(_ message: String) -> String { "SSE შეცდომა: \(message)" }
}
