// Rules: Simple transactions list; shows merchant, amount, category, date.
// Inputs: TransactionStore
// Outputs: Read-only list for now

import SwiftUI

struct TransactionsListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var records: [TransactionRecord] = []

    var body: some View {
        NavigationStack {
            List(records) { r in
                HStack {
                    VStack(alignment: .leading) {
                        Text(r.merchant)
                            .font(.body)
                        Text(r.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "$%.2f", r.amount))
                }
            }
            .navigationTitle("Transactions")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } } }
        }
        .onAppear { records = TransactionStore.shared.all() }
        .onReceive(NotificationCenter.default.publisher(for: .transactionsChanged)) { _ in records = TransactionStore.shared.all() }
    }
}


