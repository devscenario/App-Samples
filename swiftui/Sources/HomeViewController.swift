import UIKit
import SwiftUI

/// Single-page home screen: a UIKit `UICollectionView` grid of cells,
/// each cell opening the corresponding sample screen pushed onto a
/// `UINavigationController` stack. Replaces the previous tab-bar
/// layout — the same 11 screens (3 Storyboard, 8 SwiftUI) are
/// reachable from one grid + back button.
///
/// UIKit (not SwiftUI) for the grid because the in-app SDK + WDA both
/// drive selectors against the live `UIView` tree, and `UIHostingView`
/// collapses SwiftUI accessibility content into UIAccessibility-only
/// elements that don't show up in the standard subview walk —
/// so SwiftUI cells with `.accessibilityIdentifier(...)` weren't
/// resolvable. UICollectionViewCells are first-class `UIView`s; setting
/// `cell.accessibilityIdentifier` flows through unchanged.
///
/// Cell identifiers stay `sample.tab.<name>` for parity with the
/// Compose sample's `TestTags.kt` so cross-platform E2E flows resolve
/// the same keys on either app.
final class HomeViewController: UICollectionViewController, UINavigationControllerDelegate {

    private let entries: [HomeEntry]
    private var strings: SampleStrings { LanguageStore.shared.strings }

    init(entries: [HomeEntry]) {
        self.entries = entries
        super.init(collectionViewLayout: Self.makeLayout())
        title = LanguageStore.shared.strings.titleHome
        // The pushed screens' back button reads "Back" (not the home title), like the Compose top bar.
        navigationItem.backButtonTitle = LanguageStore.shared.strings.back
    }

    required init?(coder: NSCoder) { fatalError("Use init(entries:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = TestTags.appRoot
        collectionView.backgroundColor = .systemBackground
        collectionView.decelerationRate = .fast   // Compose-like fling, see SampleHostingController
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseId)
        navigationController?.delegate = self
        installLanguageChooser()
        installLaunchLabels()
        // Refresh the grid titles + nav title whenever the in-app language
        // toggle changes. The store posts this after `language` is set.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: LanguageStore.languageDidChange,
            object: nil
        )
    }

    // MARK: - Launch values

    /// What the app was launched with, pinned to the bottom of the screen: "Launch env: <value>" for
    /// `-env <value>` (launch arguments land in the standard user defaults, mirrors the Compose sample's
    /// home line), "Launch flag: sample-flag" for that word among the process arguments, and
    /// "Launch environment: <value>" for the `SAMPLE_ENV` variable. Nothing is shown without them.
    private func installLaunchLabels() {
        var lines: [(text: String, tag: String)] = []
        if let env = UserDefaults.standard.string(forKey: "env") {
            lines.append(("Launch env: \(env)", TestTags.homeLaunchEnv))
        }
        if ProcessInfo.processInfo.arguments.contains("sample-flag") {
            lines.append(("Launch flag: sample-flag", TestTags.homeLaunchFlag))
        }
        if let value = ProcessInfo.processInfo.environment["SAMPLE_ENV"] {
            lines.append(("Launch environment: \(value)", TestTags.homeLaunchEnvironment))
        }
        guard !lines.isEmpty else { return }
        let stack = UIStackView(arrangedSubviews: lines.map { line in
            let label = UILabel()
            label.text = line.text
            label.accessibilityIdentifier = line.tag
            label.font = .preferredFont(forTextStyle: .footnote)
            label.textAlignment = .center
            return label
        })
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.backgroundColor = .systemBackground
        stack.layer.zPosition = 1 // above the cells, which the collection view adds later
        stack.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(stack)
        let frame = collectionView.frameLayoutGuide
        let height = CGFloat(lines.count) * 32
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: frame.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: frame.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: height),
        ])
        collectionView.contentInset.bottom += height
    }

    // MARK: - Language chooser

    /// Right-corner nav-bar button presenting a two-item `UIMenu`
    /// (English / Georgian). The active language is shown with a checkmark
    /// (`.state = .on`). Bar button + actions carry stable accessibility
    /// identifiers (mirrors the Compose sample's TopAppBar action).
    private func installLanguageChooser() {
        let item = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "globe"),
            primaryAction: nil,
            menu: makeLanguageMenu()
        )
        item.accessibilityIdentifier = TestTags.actionLanguage
        item.accessibilityLabel = strings.languageChooser
        navigationItem.rightBarButtonItem = item
    }

    private func makeLanguageMenu() -> UIMenu {
        let current = LanguageStore.shared.language
        let english = UIAction(
            title: strings.languageEnglish,
            state: current == .english ? .on : .off
        ) { _ in LanguageStore.shared.language = .english }
        english.accessibilityIdentifier = TestTags.langEnglish

        let georgian = UIAction(
            title: strings.languageGeorgian,
            state: current == .georgian ? .on : .off
        ) { _ in LanguageStore.shared.language = .georgian }
        georgian.accessibilityIdentifier = TestTags.langGeorgian

        return UIMenu(title: strings.languageChooser, children: [english, georgian])
    }

    @objc private func languageDidChange() {
        title = strings.titleHome
        navigationItem.backButtonTitle = strings.back
        // Rebuild the menu so the checkmark + localized action titles update.
        navigationItem.rightBarButtonItem?.menu = makeLanguageMenu()
        navigationItem.rightBarButtonItem?.accessibilityLabel = strings.languageChooser
        // Re-render visible cells with the new-language titles. Cells off-screen
        // re-configure on dequeue, so reloading the data source is enough.
        collectionView.reloadData()
    }

    // MARK: - Layout

    private static func makeLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        ))
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(140)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Data source

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        entries.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseId, for: indexPath) as! HomeCell
        let entry = entries[indexPath.item]
        cell.configure(with: entry) { [weak self] in
            self?.open(entry)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handles real-user finger taps (UIKit fires this through the
        // collection view's own gesture recognizer). Synthetic SDK taps
        // route through the per-cell UITapGestureRecognizer installed
        // in `HomeCell` — see TouchHandler.fireTapRecognizer.
        collectionView.deselectItem(at: indexPath, animated: true)
        open(entries[indexPath.item])
    }

    private func open(_ entry: HomeEntry) {
        let detail = entry.makeViewController()
        detail.title = entry.title
        detail.navigationItem.rightBarButtonItem = makeHomeItem()
        navigationController?.pushViewController(detail, animated: true)
    }

    /// "Home" on every pushed screen (this app only; the Compose sample has none): one idempotent step
    /// that takes a flow back to the start screen from wherever it is.
    private func makeHomeItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(
            title: LanguageStore.shared.strings.home,
            primaryAction: UIAction { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        )
        item.accessibilityIdentifier = TestTags.navHome
        return item
    }

    // MARK: - UINavigationControllerDelegate

    // We let the system render its native back button (iOS 26 keeps it
    // visible even when a custom `leftBarButtonItem` is installed, which
    // caused a duplicated chevron). Apple's private `_UIButtonBarButton`
    // wrapper doesn't inherit `accessibilityIdentifier` from the bar item,
    // so after each push we walk the nav bar and tag the rendered UIView
    // directly — selectors against `TestTags.navBack` then resolve to the
    // real back control.
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard viewController !== self else { return }
        DispatchQueue.main.async { [weak navigationController] in
            guard let bar = navigationController?.navigationBar else { return }
            Self.tagSystemBackButton(in: bar, label: LanguageStore.shared.strings.back)
        }
    }

    private static func tagSystemBackButton(in view: UIView, label: String) {
        for subview in view.subviews {
            if let control = subview as? UIControl,
               control.accessibilityLabel == label {
                control.accessibilityIdentifier = TestTags.navBack
                return
            }
            tagSystemBackButton(in: subview, label: label)
        }
    }
}

// MARK: - Cell

private final class HomeCell: UICollectionViewCell {
    static let reuseId = "HomeCell"

    /// The cell's actual tap target. A `UIButton` (not a gesture
    /// recognizer) so the in-app SDK's `/touch` handler — which
    /// dispatches `UIControl.sendActions(.touchUpInside)` after
    /// hit-testing — reliably triggers the cell action. The button
    /// also carries the `accessibilityIdentifier` so selectors
    /// resolve to it (cells are not on-screen UIViews the SDK can
    /// query directly the same way).
    private let button = HomeCellButton(type: .custom)
    private var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        // Hide the cell itself from accessibility — the inner button is
        // the discoverable element so `id`/`label` queries resolve there.
        isAccessibilityElement = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with entry: HomeEntry, onTap: @escaping () -> Void) {
        button.configure(title: entry.title, systemImage: entry.systemImage)
        button.accessibilityIdentifier = entry.id
        button.accessibilityLabel = entry.title
        self.onTap = onTap
    }

    @objc private func handleTap() {
        onTap?()
    }
}

/// A tile-shaped UIButton with a centered icon + title — used as the
/// HomeCell's tap target. Built around `configure(title:systemImage:)`
/// so the layout owns its own constraints regardless of how the cell
/// rehydrates it on reuse.
private final class HomeCellButton: UIButton {
    private let iconView = UIImageView()
    private let titleStackLabel = UILabel()
    private var configured = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 14
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, systemImage: String) {
        if !configured {
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = .label
            iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
            titleStackLabel.font = .preferredFont(forTextStyle: .callout)
            titleStackLabel.adjustsFontForContentSizeCategory = true
            titleStackLabel.textAlignment = .center
            titleStackLabel.numberOfLines = 0
            titleStackLabel.textColor = .label
            let stack = UIStackView(arrangedSubviews: [iconView, titleStackLabel])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.isUserInteractionEnabled = false   // taps fall through to the button
            addSubview(stack)
            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: centerYAnchor),
                stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
                stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
                iconView.heightAnchor.constraint(equalToConstant: 32),
            ])
            configured = true
        }
        iconView.image = UIImage(systemName: systemImage)
        titleStackLabel.text = title
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1.0 }
    }
}

// MARK: - Entry model

struct HomeEntry: Identifiable, Hashable {
    let id: String        // cell accessibility identifier (parity with TestTags.kt)
    /// Resolves the cell's user-visible title from the active language table.
    /// The id (a test hook) stays fixed; only the displayed title localizes.
    let titleKey: KeyPath<SampleStrings, String>
    let systemImage: String
    let factory: Factory

    /// Title in the currently selected language.
    var title: String { LanguageStore.shared.strings[keyPath: titleKey] }

    /// Two-shape factory so the entry list can hold both Storyboard-backed
    /// view controllers (Login, Profile, Checkout) and SwiftUI-backed
    /// views (everything else) in the same array.
    enum Factory: Hashable {
        case storyboard(name: String, identifier: String)
        case swiftui(SwiftUIBuilder)
    }

    /// Wraps a SwiftUI view in an `AnyView` so distinct concrete view
    /// types share a single enum case. Hashable by object identity.
    final class SwiftUIBuilder: Hashable {
        let make: () -> AnyView
        init<V: View>(_ make: @escaping () -> V) { self.make = { AnyView(make()) } }
        static func == (lhs: SwiftUIBuilder, rhs: SwiftUIBuilder) -> Bool { lhs === rhs }
        func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    }

    func makeViewController() -> UIViewController {
        switch factory {
        case let .storyboard(name, identifier):
            return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier)
        case let .swiftui(builder):
            return SampleHostingController(rootView: builder.make())
        }
    }
}

extension HomeEntry {
    /// All 11 sample screens, in the same order as the Compose sample's
    /// `SampleApp.kt` tab list. Cell ids match `TestTags.kt` so E2E flows
    /// written for either app resolve the same identifiers.
    static let all: [HomeEntry] = [
        HomeEntry(id: TestTags.tabLogin, titleKey: \.titleLogin, systemImage: "person.crop.circle",
                  factory: .storyboard(name: "Login", identifier: "LoginViewController")),
        HomeEntry(id: TestTags.tabRegistration, titleKey: \.titleRegistration, systemImage: "person.badge.plus",
                  factory: .swiftui(.init { RegistrationView() })),
        HomeEntry(id: TestTags.tabList, titleKey: \.titleList, systemImage: "list.bullet",
                  factory: .swiftui(.init { ListView() })),
        HomeEntry(id: TestTags.tabGrid, titleKey: \.titleGrid, systemImage: "square.grid.2x2",
                  factory: .swiftui(.init { GridView() })),
        HomeEntry(id: TestTags.tabShowcase, titleKey: \.titleShowcase, systemImage: "slider.horizontal.3",
                  factory: .swiftui(.init { ShowcaseView() })),
        HomeEntry(id: TestTags.tabSearch, titleKey: \.titleSearch, systemImage: "magnifyingglass",
                  factory: .swiftui(.init { SearchView() })),
        HomeEntry(id: TestTags.tabCheckout, titleKey: \.titleCheckout, systemImage: "bag",
                  factory: .storyboard(name: "Checkout", identifier: "CheckoutViewController")),
        HomeEntry(id: TestTags.tabProfile, titleKey: \.titleProfile, systemImage: "person.fill",
                  factory: .storyboard(name: "Profile", identifier: "ProfileViewController")),
        HomeEntry(id: TestTags.tabPinch, titleKey: \.titlePinch, systemImage: "hand.draw",
                  factory: .swiftui(.init { PinchView() })),
        HomeEntry(id: TestTags.tabModals, titleKey: \.titleModals, systemImage: "rectangle.bottomthird.inset.filled",
                  factory: .swiftui(.init { ModalsView() })),
        HomeEntry(id: TestTags.tabDragDrop, titleKey: \.titleDragDrop, systemImage: "arrow.up.and.down.and.arrow.left.and.right",
                  factory: .swiftui(.init { DragDropView() })),
        HomeEntry(id: TestTags.tabNetwork, titleKey: \.titleNetwork, systemImage: "cloud",
                  factory: .swiftui(.init { NetworkView() })),
        HomeEntry(id: TestTags.tabFiles, titleKey: \.titleFiles, systemImage: "paperclip",
                  factory: .swiftui(.init { FilesView() })),
        HomeEntry(id: TestTags.tabAppFiles, titleKey: \.titleAppFiles, systemImage: "doc.text",
                  factory: .swiftui(.init { AppFilesView() })),
        HomeEntry(id: TestTags.tabWebView, titleKey: \.titleWebView, systemImage: "globe",
                  factory: .swiftui(.init { WebViewScreen() })),
        HomeEntry(id: TestTags.tabStress, titleKey: \.titleStress, systemImage: "speedometer",
                  factory: .swiftui(.init { StressView() })),
        HomeEntry(id: TestTags.tabBackend, titleKey: \.titleBackend, systemImage: "server.rack",
                  factory: .swiftui(.init { BackendView() })),
    ]
}
