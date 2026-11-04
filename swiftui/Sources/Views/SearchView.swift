import SwiftUI

private let catalog: [CatalogItem] = [
    CatalogItem(name: "Wireless Headphones", category: "Audio", price: "$89.99"),
    CatalogItem(name: "Noise Canceling Headphones", category: "Audio", price: "$129.99"),
    CatalogItem(name: "USB-C Travel Charger", category: "Accessories", price: "$24.99"),
    CatalogItem(name: "Fitness Watch", category: "Wearables", price: "$149.99"),
    CatalogItem(name: "Laptop Backpack", category: "Travel", price: "$59.99"),
]

struct SearchView: View {
    @ObservedObject private var store = LanguageStore.shared
    @State private var query = ""
    @State private var submittedQuery = ""
    @FocusState private var focused: Bool

    private var strings: SampleStrings { store.strings }

    private var results: [CatalogItem] {
        let trimmed = submittedQuery.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return catalog }
        return catalog.filter { item in
            item.name.localizedCaseInsensitiveContains(trimmed)
                || item.category.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(strings.searchTitle).font(.title2).fontWeight(.bold)

            TextField(strings.searchField, text: $query)
                .textFieldStyle(.roundedBorder)
                .focused($focused)
                .submitLabel(.search)
                .onSubmit { submit() }
                .accessibilityIdentifier(TestTags.searchQuery)
            if !query.isEmpty {
                Text(strings.searchQueryTyped(query))
                    .accessibilityIdentifier(TestTags.searchQueryPreview)
            }
            Button(action: submit) {
                Text(strings.searchRun).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(TestTags.searchSubmit)

            Text(statusText)
                .accessibilityIdentifier(TestTags.searchStatus)

            List(results) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name).fontWeight(.semibold)
                    Text(strings.searchCategory(item.category))
                    Text(strings.searchPrice(item.price))
                }
            }
            .listStyle(.plain)
            .accessibilityIdentifier(TestTags.searchResults)
        }
        .padding(16)
    }

    private var statusText: String {
        let trimmed = submittedQuery.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return strings.searchFeatured(results.count)
        }
        return strings.searchResults(trimmed, results.count)
    }

    private func submit() {
        submittedQuery = query.trimmingCharacters(in: .whitespaces)
        focused = false
    }
}
