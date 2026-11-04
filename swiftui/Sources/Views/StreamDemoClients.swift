import Foundation

/// What a demo WebSocket reports.
enum DemoWebSocketEvent {
    case opened
    case message(String)
    case closed(Int)
    case failed(String)
}

/// A URLSession WebSocket on a delegate session (the interceptor's auto variant sees it like any app
/// socket). Every event is reported on the main queue, with the client it came from; the socket ends
/// after one close or failure.
final class DemoWebSocketClient: NSObject, URLSessionWebSocketDelegate {
    private let onEvent: (DemoWebSocketClient, DemoWebSocketEvent) -> Void
    private var task: URLSessionWebSocketTask?
    private var finished = false

    init(onEvent: @escaping (DemoWebSocketClient, DemoWebSocketEvent) -> Void) {
        self.onEvent = onEvent
    }

    func open(_ url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let task = session.webSocketTask(with: url)
        self.task = task
        task.resume()
        receiveNext()
    }

    func send(_ text: String) {
        task?.send(.string(text)) { _ in }
    }

    func close() {
        task?.cancel(with: .normalClosure, reason: nil)
    }

    /// Reads messages until a read fails; the close or failure itself comes from the delegate calls.
    private func receiveNext() {
        task?.receive { [weak self] result in
            guard case let .success(message) = result else { return }
            DispatchQueue.main.async {
                guard let self else { return }
                switch message {
                case let .string(text): self.onEvent(self, .message(text))
                case let .data(data): self.onEvent(self, .message(String(decoding: data, as: UTF8.self)))
                @unknown default: break
                }
                self.receiveNext()
            }
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        onEvent(self, .opened)
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        finish(.closed(closeCode.rawValue))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        session.finishTasksAndInvalidate()
        // A socket the app closed may complete without a close callback; it still has its code.
        let code = (task as? URLSessionWebSocketTask)?.closeCode ?? .invalid
        finish(code != .invalid ? .closed(code.rawValue) : .failed(error?.localizedDescription ?? "closed"))
    }

    private func finish(_ event: DemoWebSocketEvent) {
        guard !finished else { return }
        finished = true
        onEvent(self, event)
    }
}

/// What a demo event stream reports.
enum DemoEventStreamEvent {
    case opened
    case event(id: String?, type: String?, data: String)
    case closed
    case failed(String)
    /// The stream ended with nothing to log: the app cancelled it, or its failure was already reported.
    case ended
}

/// Reads a `text/event-stream` with a data-delegate URLSession, chunk by chunk as it arrives. Every
/// event is reported on the main queue, with the client it came from.
final class DemoEventStreamClient: NSObject, URLSessionDataDelegate {
    private let onEvent: (DemoEventStreamClient, DemoEventStreamEvent) -> Void
    private var task: URLSessionDataTask?
    private var parser = DemoSseParser()
    private var failed = false

    init(onEvent: @escaping (DemoEventStreamClient, DemoEventStreamEvent) -> Void) {
        self.onEvent = onEvent
    }

    func open(_ url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request)
        self.task = task
        task.resume()
    }

    func cancel() {
        task?.cancel()
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status == 200 {
            onEvent(self, .opened)
        } else {
            failed = true
            onEvent(self, .failed("HTTP \(status)"))
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard !failed else { return }
        parser.feed(data).forEach { onEvent(self, $0) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        session.finishTasksAndInvalidate()
        if failed {
            onEvent(self, .ended)
        } else if let error {
            let cancelled = (error as? URLError)?.code == .cancelled
            onEvent(self, cancelled ? .ended : .failed(error.localizedDescription))
        } else {
            onEvent(self, .closed)
        }
    }
}
