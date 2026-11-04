import SwiftUI
import UIKit
import WebKit

/// Hosts a SwiftUI sample screen. Its scroll views decelerate like the Compose sample's
/// (Android-style fling) rather than with UIKit's longer default glide, so one scroll gesture
/// moves a list about as far in both iOS samples.
final class SampleHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyComposeLikeDeceleration()
    }
}

extension UIView {
    /// Sets `.fast` deceleration on every scroll view in this subtree. Web content keeps the
    /// system behaviour: the Compose sample shows the same native web view.
    func applyComposeLikeDeceleration() {
        if self is WKWebView { return }
        if let scrollView = self as? UIScrollView, scrollView.decelerationRate != .fast {
            scrollView.decelerationRate = .fast
        }
        subviews.forEach { $0.applyComposeLikeDeceleration() }
    }
}
