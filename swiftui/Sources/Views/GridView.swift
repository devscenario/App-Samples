import SwiftUI

// `inventory` stays a stable English key in the data model and is mapped to the
// active language at render time (see `localizedInventory`). Mirrors the
// Compose `GridScreen`.
private let gridProducts: [SampleProductItem] = (0..<18).map { index in
    SampleProductItem(
        name: "Product \(index + 1)",
        price: "$\(19 + index * 3).99",
        inventory: index % 4 == 0 ? EnStrings().gridLowStock : EnStrings().gridInStock
    )
}

struct GridView: View {
    @ObservedObject private var store = LanguageStore.shared
    @State private var selected: SampleProductItem?
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    private var strings: SampleStrings { store.strings }

    private func localizedInventory(_ inventory: String) -> String {
        switch inventory {
        case EnStrings().gridInStock: return strings.gridInStock
        case EnStrings().gridLowStock: return strings.gridLowStock
        default: return inventory
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let product = selected {
                VStack(alignment: .leading, spacing: 4) {
                    Text(strings.gridProductDetails).fontWeight(.bold)
                    Text(strings.gridSelected(product.name))
                    Text(strings.gridPrice(product.price))
                    Text(strings.gridInventory(localizedInventory(product.inventory)))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .accessibilityIdentifier(TestTags.gridDetail)
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(gridProducts) { product in
                        Button(action: { selected = product }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name).fontWeight(.medium)
                                Spacer()
                                Text(product.price)
                                Text(localizedInventory(product.inventory)).font(.caption)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
            }
            .accessibilityIdentifier(TestTags.gridContainer)
        }
        .padding(12)
    }
}
