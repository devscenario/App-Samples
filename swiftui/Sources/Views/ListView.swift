import SwiftUI

struct SampleOrder: Identifiable, Hashable {
    let id: String
    let customer: String
    let total: String
    let status: String
}

// `status` stays a stable English key in the data model; it is mapped to the
// active language at render time (see `localizedStatus`) so flows asserting on
// the default English copy keep working. Mirrors the Compose `ListScreen`.
private let sampleOrders: [SampleOrder] = (0..<24).map { index in
    let customers = ["Guja", "Giorgi", "Anzori", "Luka"]
    return SampleOrder(
        id: "Order #\(1001 + index)",
        customer: customers[index % customers.count],
        total: "$\(42 + index * 7).00",
        status: index % 3 == 0 ? EnStrings().listStatusReady : EnStrings().listStatusProcessing
    )
}

struct ListView: View {
    @ObservedObject private var store = LanguageStore.shared
    @State private var selected: SampleOrder?

    private var strings: SampleStrings { store.strings }

    private func localizedStatus(_ status: String) -> String {
        switch status {
        case EnStrings().listStatusReady: return strings.listStatusReady
        case EnStrings().listStatusProcessing: return strings.listStatusProcessing
        default: return status
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let order = selected {
                VStack(alignment: .leading, spacing: 4) {
                    Text(strings.listOrderDetails).font(.headline)
                    Text(strings.listSelected(order.id))
                    Text(strings.listCustomer(order.customer))
                    Text(strings.listTotal(order.total))
                    Text(strings.listStatus(localizedStatus(order.status)))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .accessibilityIdentifier(TestTags.listDetail)
            }

            List(sampleOrders) { order in
                Button {
                    selected = order
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.id).fontWeight(.semibold)
                        Text(strings.listCustomer(order.customer))
                        Text(strings.listStatus(localizedStatus(order.status)))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .accessibilityIdentifier(TestTags.listContainer)
        }
        .padding(12)
    }
}

#if DEBUG
#Preview {
    ListView()
}
#endif
