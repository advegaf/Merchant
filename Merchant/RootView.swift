// Rules: Root navigation container managing auth flow and main content
// Inputs: UIState for authentication and sheet presentation
// Outputs: HomeView or auth gating based on sign-in status
// Constraints: No navigation complexity, simple conditional rendering

import SwiftUI

struct RootView: View {
    @Environment(UIState.self) private var uiState

    var body: some View {
        NavigationStack {
            HomeView()
                .sheet(isPresented: .constant(uiState.showAuthSheet)) {
                    AuthSheet()
                }
                .sheet(
                    isPresented: Binding(
                        get: { uiState.showPlaidLinkSheet },
                        set: { uiState.showPlaidLinkSheet = $0 }
                    )
                ) {
                    PlaidLinkSheet()
                }
                .sheet(
                    isPresented: Binding(
                        get: { uiState.showCardPicker },
                        set: { uiState.showCardPicker = $0 }
                    )
                ) {
                    CardPickerSheet()
                        .environment(SelectedCardsStore.shared)
                }
        }
    }
}

#Preview {
    RootView()
        .environment(UIState())
}