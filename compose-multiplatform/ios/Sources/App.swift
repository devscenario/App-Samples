import SwiftUI
import SampleSharedUi

#if canImport(DevScenarioAppInstrumentation)
// F2: Dev Scenario in-app instrumentation SDK linked into the sample.
//
// To enable in Xcode:
//   1. Open DevToolSampleIos.xcodeproj
//   2. File → Add Package Dependencies… → Add Local…
//   3. Navigate to `<repo>/app-instrumentation-ios` and select that folder
//   4. Add the `DevScenarioAppInstrumentation` library product to the
//      DevToolSampleIos target
// When the import succeeds we auto-start the in-app WS server on launch;
// pair the sample app with the "In-app SDK" iOS driver mode in Dev Scenario.
import DevScenarioAppInstrumentation
#endif

@main
struct DevToolSampleIosApp: App {

    init() {
        #if canImport(DevScenarioAppInstrumentation)
        DevScenarioAppInstrumentation.start()
        #endif
        #if DEBUG
        installStreamServer()
        #endif
    }

    #if DEBUG
    /// The Network screen's stream demos start the shared local stream test server on first use.
    private func installStreamServer() {
        LocalStreamServer_iosKt.installLocalStreamServer {
            do {
                let endpoints = try LocalStreamTestServer.start()
                return LocalStreamServerStart.companion.started(
                    webSocketUrl: endpoints.webSocketUrl,
                    eventStreamUrl: endpoints.eventStreamUrl
                )
            } catch {
                return LocalStreamServerStart.companion.failed(message: "\(error)")
            }
        }
    }
    #endif

    var body: some Scene {
        WindowGroup {
            ComposeRootView()
                .ignoresSafeArea()
        }
    }
}
