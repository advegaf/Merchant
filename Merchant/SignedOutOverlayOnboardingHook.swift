
import SwiftUI

extension HomeView {
    func triggerOnboardingIfNeeded(_ uiState: UIState) {
        uiState.presentCardPickerIfNeeded()
    }
}


