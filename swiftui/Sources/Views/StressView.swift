import SwiftUI

private let stressRows = 500
private let stressDeepLevels = 24
private let stressGridRows = 6
private let stressGridColumns = 4
private let stressCarouselEvery = 10
private let stressChips = 12
private let stressLateDelayNs: UInt64 = 2_000_000_000

/// A deliberately heavy screen for measuring how long a hierarchy walk takes: a 500-row lazy list
/// with nested rows and carousels, a deeply nested section, a static grid, and a row that only
/// appears two seconds after the screen opens. English only; mirrors the Compose sample's
/// `StressScreen` id for id.
struct StressView: View {
    @State private var status = "Tapped: none"
    @State private var lateReady = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(status).fontWeight(.semibold).accessibilityIdentifier(TestTags.stressStatus)
            Text(lateReady ? "Late row: ready" : "Late row: pending")
                .accessibilityIdentifier(TestTags.stressLateStatus)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Text("Stress test").font(.headline).accessibilityIdentifier(TestTags.stressHeader)
                    if lateReady { StressLateRow(onTap: tap) }
                    StressDeepLevel(level: 1)
                    StressGrid(onTap: tap)
                    ForEach(1...stressRows, id: \.self) { StressRow(index: $0, onTap: tap) }
                    Text("End of stress list").accessibilityIdentifier(TestTags.stressEnd)
                }
            }
            .accessibilityIdentifier(TestTags.stressList)
        }
        .padding(12)
        .task {
            // Restarts each time the screen appears, like the Compose LaunchedEffect.
            lateReady = false
            try? await Task.sleep(nanoseconds: stressLateDelayNs)
            lateReady = true
        }
    }

    private func tap(_ what: String) { status = "Tapped: \(what)" }
}

private struct StressLateRow: View {
    let onTap: (String) -> Void

    var body: some View {
        HStack {
            Text("Late row ready").fontWeight(.semibold)
            Spacer()
            Button("Late action") { onTap("Late action") }
                .buttonStyle(.bordered)
                .accessibilityIdentifier(TestTags.stressLateButton)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(TestTags.stressLate)
    }
}

/// One of [stressDeepLevels] nested containers, each its own accessibility container.
private struct StressDeepLevel: View {
    let level: Int

    var body: some View {
        VStack(alignment: .leading) {
            if level < stressDeepLevels {
                StressDeepLevel(level: level + 1)
            } else {
                Text("Deep leaf").accessibilityIdentifier(TestTags.stressDeepLeaf)
            }
        }
        .padding(.leading, 2)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("\(TestTags.stressDeepPrefix)\(level)")
    }
}

private struct StressGrid: View {
    let onTap: (String) -> Void

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<stressGridRows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<stressGridColumns, id: \.self) { column in
                        cell(row * stressGridColumns + column + 1)
                    }
                }
            }
        }
    }

    private func cell(_ number: Int) -> some View {
        Button { onTap("Cell \(number)") } label: {
            Text("Cell \(number)")
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("\(TestTags.stressGridPrefix)\(number)")
    }
}

private struct StressRow: View {
    let index: Int
    let onTap: (String) -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "star.fill")
                        .frame(width: 20, height: 20)
                        .accessibilityLabel("Row icon \(index)")
                    VStack(alignment: .leading) {
                        Text("Row \(index)").fontWeight(.semibold)
                        Text("Detail \(index) · group \(index % 10)").font(.caption)
                    }
                    .padding(.leading, 8)
                }
                if index % stressCarouselEvery == 0 { StressCarousel(row: index, onTap: onTap) }
            }
            Spacer()
            Button("Open \(index)") { onTap("Row \(index)") }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("\(TestTags.stressRowPrefix)\(index).button")
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("\(TestTags.stressRowPrefix)\(index)")
    }
}

private struct StressCarousel: View {
    let row: Int
    let onTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 6) {
                ForEach(1...stressChips, id: \.self) { chip in
                    Button("Chip \(row)-\(chip)") { onTap("Chip \(row)-\(chip)") }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("\(TestTags.stressChipPrefix)\(row).\(chip)")
                }
            }
        }
        .padding(.top, 8)
        .accessibilityIdentifier("\(TestTags.stressRowPrefix)\(row).carousel")
    }
}
