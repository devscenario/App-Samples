import SwiftUI

struct DragDropView: View {
    /// Status as a discrete state so the displayed text re-localizes on a
    /// language toggle. The associated value is a stable English row key /
    /// chip name (a test-data id), localized only at render time. Mirrors the
    /// Compose `DragDropScreen`.
    private enum DragStatus {
        case none
        case dragging(String), droppedInZone(String), cancelled(String)
        case pickedUp(String), movedUp(String), movedDown(String)
    }

    @ObservedObject private var store = LanguageStore.shared
    @State private var status: DragStatus = .none
    @State private var draggingItem: String?
    @State private var dropZoneFrame: CGRect = .zero
    // Row labels stay stable English keys (they double as the `ForEach` id and
    // are asserted literally by drag-drop flows); mapped to the active language
    // only at render time via `localizedRow`.
    @State private var listItems: [String] = [EnStrings().dragRowOne, EnStrings().dragRowTwo, EnStrings().dragRowThree]

    private var strings: SampleStrings { store.strings }

    private func localizedRow(_ item: String) -> String {
        switch item {
        case EnStrings().dragRowOne: return strings.dragRowOne
        case EnStrings().dragRowTwo: return strings.dragRowTwo
        case EnStrings().dragRowThree: return strings.dragRowThree
        default: return item
        }
    }

    private var statusText: String {
        switch status {
        case .none: return strings.dragStatusNone
        case let .dragging(name): return strings.dragDragging(name)
        case let .droppedInZone(name): return strings.dragDroppedInZone(name)
        case let .cancelled(name): return strings.dragCancelled(name)
        case let .pickedUp(item): return strings.dragPickedUp(localizedRow(item))
        case let .movedUp(item): return strings.dragMovedUp(localizedRow(item))
        case let .movedDown(item): return strings.dragMovedDown(localizedRow(item))
        }
    }

    var body: some View {
        // No ScrollView (it would steal the drags), so everything must fit the smallest
        // target, iPhone 16e: same spacing and drop-zone height as the Compose screen.
        VStack(alignment: .leading, spacing: 10) {
            Text(strings.dragTitle).font(.title2).fontWeight(.bold)
            Text(strings.dragIntro)

            Text(strings.dragStatus(statusText))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(TestTags.dragStatus)

            Divider()

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(draggingItem != nil ? Color(red: 232/255.0, green: 245/255.0, blue: 233/255.0) : Color(white: 0.96))
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(draggingItem != nil ? Color(red: 67/255.0, green: 160/255.0, blue: 71/255.0) : Color(white: 0.74), lineWidth: 2)
                VStack {
                    Text(draggingItem.map { strings.dragDropHere($0) } ?? strings.dragDropZone).fontWeight(.semibold)
                    if draggingItem == nil {
                        Text(strings.dragDropHint).font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(GeometryReader { proxy in
                Color.clear.onAppear { dropZoneFrame = proxy.frame(in: .global) }
                    .onChange(of: proxy.frame(in: .global)) { dropZoneFrame = $0 }
            })
            .accessibilityIdentifier(TestTags.dragDropTarget)

            Divider()
            Text(strings.dragSources).font(.headline)
            HStack(spacing: 12) {
                // Chip names are language-neutral test-data ids: they back the
                // `dragItem*` identifiers and are asserted literally, so they
                // are NOT translated.
                draggableChip(name: "Alpha", tag: TestTags.dragItemAlpha)
                draggableChip(name: "Beta", tag: TestTags.dragItemBeta)
                draggableChip(name: "Gamma", tag: TestTags.dragItemGamma)
            }

            Divider()
            Text(strings.dragReorderable).font(.headline)
            Text(strings.dragReorderHint)

            ForEach(Array(listItems.enumerated()), id: \.element) { index, item in
                reorderableRow(item: item, index: index)
            }

            Spacer(minLength: 32)
        }
        .padding(16)
    }

    @ViewBuilder
    private func draggableChip(name: String, tag: String) -> some View {
        DraggableChip(
            name: name,
            isDragging: draggingItem == name,
            onDragStarted: {
                draggingItem = name
                status = .dragging(name)
            },
            onDragEnded: { finalCenter in
                let inZone = dropZoneFrame.contains(finalCenter)
                draggingItem = nil
                status = inZone ? .droppedInZone(name) : .cancelled(name)
            }
        )
        .accessibilityIdentifier(tag)
    }

    @ViewBuilder
    private func reorderableRow(item: String, index: Int) -> some View {
        ReorderableRow(
            text: localizedRow(item),
            handleLabel: strings.dragHandleLabel,
            onDragStarted: { status = .pickedUp(item) },
            onMoveUp: {
                guard index > 0 else { return }
                var copy = listItems
                copy.remove(at: index)
                copy.insert(item, at: index - 1)
                listItems = copy
                status = .movedUp(item)
            },
            onMoveDown: {
                guard index < listItems.count - 1 else { return }
                var copy = listItems
                copy.remove(at: index)
                copy.insert(item, at: index + 1)
                listItems = copy
                status = .movedDown(item)
            }
        )
        .accessibilityIdentifier("\(TestTags.dragReorderItemPrefix)\(index + 1)")
    }
}

private struct DraggableChip: View {
    let name: String
    let isDragging: Bool
    let onDragStarted: () -> Void
    let onDragEnded: (CGPoint) -> Void

    @State private var offset: CGSize = .zero
    @State private var basePoint: CGPoint = .zero

    var body: some View {
        Text(name)
            .foregroundColor(.white).fontWeight(.medium)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(isDragging ? Color(red: 21/255.0, green: 101/255.0, blue: 192/255.0) : Color(red: 26/255.0, green: 115/255.0, blue: 232/255.0)))
            .scaleEffect(isDragging ? 1.08 : 1)
            .offset(offset)
            .background(GeometryReader { proxy in
                Color.clear.onAppear {
                    let frame = proxy.frame(in: .global)
                    basePoint = CGPoint(x: frame.midX, y: frame.midY)
                }
            })
            .gesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .global)
                    .onChanged { value in
                        if !isDragging { onDragStarted() }
                        offset = CGSize(width: value.translation.width, height: value.translation.height)
                    }
                    .onEnded { value in
                        let endPoint = CGPoint(x: basePoint.x + value.translation.width, y: basePoint.y + value.translation.height)
                        offset = .zero
                        onDragEnded(endPoint)
                    }
            )
    }
}

private struct ReorderableRow: View {
    let text: String
    let handleLabel: String
    let onDragStarted: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    @State private var offsetY: CGFloat = 0
    /// Drag translation at the last move: each move restarts the count, as in Compose.
    @State private var moveBaseY: CGFloat = 0
    @State private var isDragging = false
    /// The Compose screen's 110 px threshold, in points.
    private let threshold: CGFloat = 110 / UIScreen.main.scale

    var body: some View {
        HStack {
            Text("⠿").foregroundColor(.gray)
            Text(text)
            Spacer()
            Circle().fill(Color(red: 26/255.0, green: 115/255.0, blue: 232/255.0)).frame(width: 10, height: 10)
            Text(handleLabel).font(.caption).foregroundColor(.gray)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 8).fill(isDragging ? Color(red: 227/255.0, green: 242/255.0, blue: 253/255.0) : Color(white: 0.98)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isDragging ? Color(red: 26/255.0, green: 115/255.0, blue: 232/255.0) : Color(white: 0.88)))
        .offset(y: min(max(offsetY, -24), 24))
        .gesture(
            DragGesture(minimumDistance: 4)
                .onChanged { value in
                    if !isDragging { isDragging = true; moveBaseY = 0; onDragStarted() }
                    offsetY = value.translation.height - moveBaseY
                    if offsetY < -threshold {
                        moveBaseY = value.translation.height
                        offsetY = 0
                        onMoveUp()
                    } else if offsetY > threshold {
                        moveBaseY = value.translation.height
                        offsetY = 0
                        onMoveDown()
                    }
                }
                .onEnded { _ in
                    offsetY = 0
                    moveBaseY = 0
                    isDragging = false
                }
        )
    }
}
