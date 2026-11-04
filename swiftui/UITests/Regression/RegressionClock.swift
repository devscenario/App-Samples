import XCTest

/// Wall-clock timing of the regression: the whole run (first step after `app.launch()` to the last
/// step) and each unit. `report` prints one line starting with `marker` followed by the JSON, and
/// attaches the same JSON to the test result, so a benchmark run can read it from the
/// `xcodebuild test` output or the `.xcresult`.
final class RegressionClock {
    static let marker = "DEVSCENARIO_NATIVE_TIMING_JSON:"

    private struct UnitTiming: Encodable {
        let unit: String
        let ms: Int
    }

    private struct Report: Encodable {
        let suite = "native-xcuitest"
        let bundleId: String
        let device: String
        let os: String
        let launchMs: Int
        let totalMs: Int
        let units: [UnitTiming]
    }

    private var runStart: UInt64 = 0
    private var units: [UnitTiming] = []
    /// Unit names to run (comma-separated, e.g. "launch.ds,pinch.ds"); nil runs every unit. Each
    /// unit starts and ends on the home grid, so any subset runs on its own.
    private let only: Set<String>?

    init(only: String? = nil) {
        self.only = only.map { Set($0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }) }
    }

    func start() {
        runStart = Self.now()
    }

    /// Runs one unit and records its duration.
    func unit(_ name: String, _ body: () -> Void) {
        if let only, !only.contains(name) { return }
        let start = Self.now()
        body()
        units.append(UnitTiming(unit: name, ms: Self.millis(since: start)))
    }

    /// Ends the run and emits the timing JSON.
    func report(bundleId: String, launchMs: Int, testCase: XCTestCase) {
        let totalMs = Self.millis(since: runStart)
        let device = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? UIDevice.current.model
        let report = Report(
            bundleId: bundleId,
            device: device,
            os: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            launchMs: launchMs,
            totalMs: totalMs,
            units: units
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(report), let json = String(data: data, encoding: .utf8) else {
            XCTFail("Could not encode the timing report")
            return
        }
        print("\(Self.marker) \(json)")
        let attachment = XCTAttachment(string: json)
        attachment.name = "native-regression-timing.json"
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
    }

    static func now() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }

    static func millis(since start: UInt64) -> Int {
        Int((now() - start) / 1_000_000)
    }
}
