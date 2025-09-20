// Rules: UI-only session state management for authentication, sheet presentation
// Inputs: User interactions (sign in, sheet triggers)
// Outputs: Boolean flags controlling UI visibility and blurring
// Constraints: No business logic, purely presentation state

import SwiftUI

@Observable
final class UIState {
    var isSignedIn = false
    var showAuthSheet = false
    var showPlaidLinkSheet = false
    var showCardPicker = false

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