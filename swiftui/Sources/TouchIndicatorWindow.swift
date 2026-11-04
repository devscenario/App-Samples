import UIKit

/// `UIWindow` subclass that draws a green circle at every `.began`
/// touch point and fades it out over 450 ms — visual parity with the
/// Compose Multiplatform sample's `.drawWithContent` touch overlay.
///
/// Implementation: `sendEvent(_:)` runs before the touch is routed to
/// any view, so we see every real finger-down. Indicators are drawn
/// into a transparent overlay view that sits on top of the window's
/// content but has `isUserInteractionEnabled = false`, so it never
/// captures touches itself.
///
/// Synthetic taps from the in-app SDK (`/touch`) bypass
/// `UIApplication.sendEvent` — they dispatch directly to UIControl /
/// UIGestureRecognizer targets — so the indicator only marks real
/// user touches, matching the Compose sample's behavior (its
/// `pointerInput` also only fires on real `PointerEvent`s).
final class TouchIndicatorWindow: UIWindow {

    private static let radius: CGFloat = 24
    private static let durationSeconds: TimeInterval = 0.45
    // Compose sample uses Color(0xFF00C853).copy(alpha = 0.72f).
    private static let color = UIColor(red: 0, green: 200/255.0, blue: 83/255.0, alpha: 0.72)

    private lazy var overlay: UIView = {
        let v = UIView(frame: bounds)
        v.isUserInteractionEnabled = false
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .clear
        addSubview(v)
        return v
    }()

    override func sendEvent(_ event: UIEvent) {
        // Late subviews (modal presentations, keyboards, alerts) can be
        // added above ours, so re-elevate the overlay on every event
        // — cheap (single z-index check) and keeps indicators visible
        // when, say, the keyboard rises during typing.
        bringSubviewToFront(overlay)
        if let touches = event.allTouches {
            for touch in touches where touch.phase == .began {
                showIndicator(at: touch.location(in: overlay))
            }
        }
        super.sendEvent(event)
    }

    private func showIndicator(at point: CGPoint) {
        let circle = CAShapeLayer()
        let r = Self.radius
        circle.path = UIBezierPath(
            arcCenter: point,
            radius: r,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        ).cgPath
        circle.fillColor = Self.color.cgColor
        overlay.layer.addSublayer(circle)

        // Fade alongside Compose's auto-remove. Set isRemovedOnCompletion
        // = false + fillMode = .forwards so the layer reads as faded
        // throughout the delayed-remove window (no flash at the end).
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.0
        fade.duration = Self.durationSeconds
        fade.fillMode = .forwards
        fade.isRemovedOnCompletion = false
        circle.add(fade, forKey: "fade")

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.durationSeconds) { [weak circle] in
            circle?.removeFromSuperlayer()
        }
    }
}
