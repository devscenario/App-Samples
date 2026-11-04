import XCTest

/// `pushFile` on a simulator: writes the file into the target app's `Documents/`, where Dev
/// Scenario's driver puts it (`simctl get_app_container … data` + a copy).
///
/// A UI test can't call `simctl`, but on a simulator every app's data container is a directory on
/// the Mac's disk next to the test runner's own, readable and writable by the runner. The target's
/// container is the sibling whose container-manager metadata names its bundle id. Simulator only:
/// on a device the runner can't reach another app's container.
enum RegressionFilePusher {
    private static let metadataFile = ".com.apple.mobile_container_manager.metadata.plist"

    static func push(name: String, content: String, bundleId: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let container = dataContainer(of: bundleId) else {
            XCTFail("pushFile: no data container for \(bundleId) next to \(NSHomeDirectory())", file: file, line: line)
            return
        }
        let documents = container.appendingPathComponent("Documents", isDirectory: true)
        // Only the last path component: a name can't point outside Documents/.
        let fileName = URL(fileURLWithPath: name).lastPathComponent
        do {
            try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
            try Data(content.utf8).write(to: documents.appendingPathComponent(fileName), options: .atomic)
        } catch {
            XCTFail("pushFile could not write \(name) into \(documents.path): \(error)", file: file, line: line)
        }
    }

    private static func dataContainer(of bundleId: String) -> URL? {
        let containers = URL(fileURLWithPath: NSHomeDirectory()).deletingLastPathComponent()
        let candidates = (try? FileManager.default.contentsOfDirectory(
            at: containers, includingPropertiesForKeys: nil
        )) ?? []
        return candidates.first { container in
            let metadata = container.appendingPathComponent(metadataFile)
            guard let plist = NSDictionary(contentsOf: metadata) else { return false }
            return plist["MCMMetadataIdentifier"] as? String == bundleId
        }
    }
}
