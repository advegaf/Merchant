// Rules: App entry point with dark mode preference and UIState environment
// Inputs: System launch
// Outputs: Root UI hierarchy with theme and state injection
// Constraints: iOS 26+ only, dark mode default

import SwiftUI

@main
struct MerchantApp: App {
    @State private var uiState = UIState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(uiState)
                .preferredColorScheme(.dark)
        }
    }
}
