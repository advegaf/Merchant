// Rules: Trigger card picker onboarding after sign-in, without UI refactor.
// Inputs: UIState sign-in change
// Outputs: Presents CardPickerSheet if onboarding incomplete

import SwiftUI

extension HomeView {
    func triggerOnboardingIfNeeded(_ uiState: UIState) {
        uiState.presentCardPickerIfNeeded()
    }
}


