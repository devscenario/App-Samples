import Foundation

/// Incremental `text/event-stream` reader, the same rules as the Compose sample's `DemoSseParser.kt`:
/// fed the body's bytes as they arrive, each line decoded as UTF-8 once it ends (a character split
/// across chunks stays whole); LF, CR or CRLF line ends (also split across chunks), `:` comments
/// skipped, `data` lines joined with LF, the last `id` carried over, a block without data dispatches
/// nothing.
struct DemoSseParser {
    private static let cr = UInt8(ascii: "\r")
    private static let lf = UInt8(ascii: "\n")

    private var line: [UInt8] = []
    private var afterCr = false
    private var lastId: String?
    private var type: String?
    private var data: [String] = []

    mutating func feed(_ chunk: Data) -> [DemoEventStreamEvent] {
        var events: [DemoEventStreamEvent] = []
        for byte in chunk {
            if byte == Self.lf && afterCr {
                afterCr = false
                continue
            }
            afterCr = byte == Self.cr
            if byte == Self.cr || byte == Self.lf {
                if let event = endLine() { events.append(event) }
            } else {
                line.append(byte)
            }
        }
        return events
    }

    private mutating func endLine() -> DemoEventStreamEvent? {
        let text = String(decoding: line, as: UTF8.self)
        line.removeAll(keepingCapacity: true)
        if text.isEmpty { return dispatch() }
        if text.hasPrefix(":") { return nil }
        let parts = text.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        let name = String(parts[0])
        var value = parts.count > 1 ? String(parts[1]) : ""
        if value.hasPrefix(" ") { value.removeFirst() }
        switch name {
        case "id": lastId = value
        case "event": type = value
        case "data": data.append(value)
        default: break
        }
        return nil
    }

    private mutating func dispatch() -> DemoEventStreamEvent? {
        defer {
            type = nil
            data = []
        }
        return data.isEmpty ? nil : .event(id: lastId, type: type, data: data.joined(separator: "\n"))
    }
}
