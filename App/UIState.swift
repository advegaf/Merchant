// Rules: UI-only session state management for authentication, sheet presentation
// Inputs: User interactions (sign in, sheet triggers)
// Outputs: Boolean flags controlling UI visibility and blurring
// Constraints: No business logic, purely presentation state

import SwiftUI
import Observation

@Observable
final class UIState {
    var isSignedIn = false
    var showPlaidLinkSheet = false
    var showReviewCardsSheet = false
    var showAuthSheet = false
    var cardsToReview: [CardUI] = []

    func signIn() {
        isSignedIn = true
        showAuthSheet = false
    }

    func showPlaidLink() {
        showPlaidLinkSheet = true
    }

    func completeCardReview(selectedCards: [CardUI]) {
        showReviewCardsSheet = false
        cardsToReview = []
    }
}
