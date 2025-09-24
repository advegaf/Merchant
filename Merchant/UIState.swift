
import SwiftUI
import Observation

@Observable
final class UIState {
    var isSignedIn = false
    var showAuthSheet = false
    var showPlaidLinkSheet = false
    var showCardPicker = false
    var showNearbyCategories = false
    var showTransactionsSheet = false
    var showAccountSheet = false
    var showAddSpendSheet = false
    var showNearbySheet = false
    var showNotificationSettings = false
    var showOptimizationBreakdown = false
    var showSettingsSheet = false

    func signIn() {
        isSignedIn = true
        showAuthSheet = false
    }

    func presentPlaidLink() {
        showPlaidLinkSheet = true
    }

    func dismissPlaidLink() {
        showPlaidLinkSheet = false
    }

    func presentCardPickerIfNeeded() {
        if !SelectedCardsStore.shared.hasCompletedOnboarding {
            showCardPicker = true
        }
    }
}
