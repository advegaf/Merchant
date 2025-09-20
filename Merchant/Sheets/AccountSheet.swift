// Rules: Minimal account sheet placeholder for now.

import SwiftUI

struct AccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UIState.self) private var uiState
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Text("Signed in")
                }
                Section("Connectors") {
                    Button("Connect Bank (Plaid)") { uiState.showPlaidLinkSheet = true }
                }
            }
            .navigationTitle("Account")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}


