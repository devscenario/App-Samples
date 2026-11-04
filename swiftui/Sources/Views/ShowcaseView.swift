import SwiftUI

struct ShowcaseView: View {
    @ObservedObject private var store = LanguageStore.shared
    @State private var notificationsEnabled = true
    @State private var progress: Double = 0.5

    private var strings: SampleStrings { store.strings }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(strings.showcaseTitle).font(.title2).fontWeight(.bold)
                Text(strings.showcaseIntro)

                // The whole row is the switch: tapping its text flips it too.
                Toggle(strings.showcaseEnableNotifications, isOn: $notificationsEnabled)
                    .contentShape(Rectangle())
                    .onTapGesture { notificationsEnabled.toggle() }
                    .accessibilityIdentifier(TestTags.showcaseSwitch)

                Text(strings.showcaseProgress)
                ProgressView(value: progress)
                    .frame(height: 8)
                    .accessibilityIdentifier(TestTags.showcaseProgress)
                // Quarter steps: a drag settles on an exact value.
                Slider(value: $progress, in: 0...1, step: 0.25)
                    .accessibilityIdentifier(TestTags.showcaseSlider)

                ForEach(0..<12, id: \.self) { index in
                    HStack {
                        Text(strings.showcaseListElement(index + 1))
                        Spacer()
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 26/255.0, green: 115/255.0, blue: 232/255.0))
                            .frame(width: 34, height: 34)
                    }
                    .padding(12)
                    .background(index % 2 == 0 ? Color(red: 232/255.0, green: 240/255.0, blue: 254/255.0) : Color(red: 246/255.0, green: 248/255.0, blue: 252/255.0))
                    .cornerRadius(10)
                }

                HStack(spacing: 10) {
                    Button(strings.showcasePrimary) {}
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                    Button(strings.showcaseSecondary) {}
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                }

                Text(strings.showcaseEnd).font(.caption).padding(.vertical, 8).frame(maxWidth: .infinity)
            }
            .padding(16)
        }
        .accessibilityIdentifier(TestTags.showcaseScroll)
    }
}
