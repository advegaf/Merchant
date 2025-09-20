// Rules: Manual spend input; simple form with validation.
// Inputs: merchant, amount, category
// Outputs: Adds TransactionRecord to store

import SwiftUI

struct AddSpendSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var merchant: String = ""
    @State private var amount: String = ""
    @State private var category: String = "Dining"
    private let categories = ["Dining", "Groceries", "Gas", "Travel", "Shopping", "Utilities", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Merchant", text: $merchant)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0) }
                }
            }
            .navigationTitle("Add Spend")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(!canSave)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var canSave: Bool {
        guard !merchant.isEmpty, Double(amount) != nil else { return false }
        return true
    }

    private func save() {
        guard let amt = Double(amount) else { return }
        let rec = TransactionRecord(merchant: merchant, amount: amt, category: category)
        TransactionStore.shared.add(rec)
        dismiss()
    }
}


