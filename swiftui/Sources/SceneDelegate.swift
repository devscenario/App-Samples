import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        // `TouchIndicatorWindow` is a plain UIWindow with one extra
        // behavior: it draws a green circle at every real touch-down
        // point (matches the Compose sample's overlay).
        let window = TouchIndicatorWindow(windowScene: windowScene)
        // Single-page grid as the root, wrapped in a navigation
        // controller so each cell push gets the standard back button.
        let home = HomeViewController(entries: HomeEntry.all)
        window.rootViewController = UINavigationController(rootViewController: home)
        self.window = window
        window.makeKeyAndVisible()
    }
}
