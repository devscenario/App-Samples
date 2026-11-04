import SwiftUI

struct PinchView: View {
    @ObservedObject private var store = LanguageStore.shared
    @State private var scale: CGFloat = 1.0
    @State private var lastDelta: CGFloat = 0
    @State private var gestureEvents: Int = 0

    private let minScale: CGFloat = 0.6
    private let maxScale: CGFloat = 2.2
    private let deltaEpsilon: CGFloat = 0.005
    /// The scale when the current pinch began: the pinch multiplies it, as in a photo viewer.
    @State private var baseScale: CGFloat = 1.0

    private var strings: SampleStrings { store.strings }

    var body: some View {
        VStack(spacing: 12) {
            Text(strings.pinchTitle).font(.title2).fontWeight(.bold)
            Text(strings.pinchIntro)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 232/255.0, green: 240/255.0, blue: 254/255.0))
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 26/255.0, green: 115/255.0, blue: 232/255.0))
                    .frame(width: 160, height: 160)
                    .scaleEffect(scale)
                    .overlay(
                        Text(strings.pinchMe).foregroundColor(.white).fontWeight(.bold)
                    )
                    .accessibilityIdentifier(TestTags.pinchTarget)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .contentShape(Rectangle())
            .accessibilityIdentifier(TestTags.pinchPlayground)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        applyScale((baseScale * value).clamped(to: minScale...maxScale))
                    }
                    .onEnded { _ in baseScale = scale }
            )

            Text(strings.pinchStatus(displayScale, direction, gestureEvents))
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(TestTags.pinchStatus)
        }
        .padding(16)
    }

    /// Two decimals, truncated, printed without trailing zeros ("1.0", "1.03"), as in Compose.
    private var displayScale: String {
        "\(Float(Int(scale * 100)) / 100)"
    }

    private var direction: String {
        if lastDelta > deltaEpsilon { return strings.pinchDirIn }
        if lastDelta < -deltaEpsilon { return strings.pinchDirOut }
        return strings.pinchDirNone
    }

    private func applyScale(_ newScale: CGFloat) {
        let delta = newScale - scale
        if abs(delta) > deltaEpsilon {
            lastDelta = delta
            gestureEvents += 1
            scale = newScale
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
