
import SwiftUI

struct RootView: View {
    @Environment(UIState.self) private var uiState

    var body: some View {
        NavigationStack {
            HomeView()
                .environment(SelectedCardsStore.shared)
                .environment(UserProfileStore.shared)
                .environment(NotificationPreferencesStore.shared)
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
                        .environment(NotificationPreferencesStore.shared)
                        .environment(UserProfileStore.shared)
                }
                .sheet(
                    isPresented: Binding(
                        get: { uiState.showNearbyCategories },
                        set: { uiState.showNearbyCategories = $0 }
                    )
                ) {
                    NearbyCategoriesSheet()
                }
                .sheet(
                    isPresented: Binding(
                        get: { uiState.showTransactionsSheet },
                        set: { uiState.showTransactionsSheet = $0 }
                    )
                ) { TransactionsListSheet() }
                .sheet(
                    isPresented: Binding(
                        get: { uiState.showAccountSheet },
                        set: { uiState.showAccountSheet = $0 }
                    )
                ) { AccountSheet() }
                .sheet(
                    isPresented: Binding(
                        get: { uiState.showAddSpendSheet },
                        set: { uiState.showAddSpendSheet = $0 }
                    )
                ) { AddSpendSheet() }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowTransactionsFromHeader"))) { _ in
            uiState.showTransactionsSheet = true
        }
    }
}

#Preview {
    RootView()
        .environment(UIState())
}