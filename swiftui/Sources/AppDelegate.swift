import UIKit

#if canImport(DevScenarioAppInstrumentation)
// F2: Dev Scenario in-app instrumentation SDK linked into the sample.
// Same opt-in pattern as the Compose-based sample so this
// from-scratch native app can also pair with the "In-app SDK" iOS
// driver mode in Dev Scenario.
import DevScenarioAppInstrumentation
#endif

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        #if canImport(DevScenarioAppInstrumentation)
        DevScenarioAppInstrumentation.start()
        #endif
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
