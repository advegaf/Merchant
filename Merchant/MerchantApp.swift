// Rules: App entry point with dark mode preference and UIState environment
// Inputs: System launch
// Outputs: Root UI hierarchy with theme and state injection
// Constraints: iOS 26+ only, dark mode default

import SwiftUI
import CoreLocation

@main
struct MerchantApp: App {
    @State private var uiState = UIState()
    @State private var orchestrator: VisitNotificationOrchestrator? = nil

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(uiState)
                .preferredColorScheme(.dark)
                .task {
                    // Wire location → detector → notifications
                    let location = LocationService()
                    let detector = NearbyCategoryDetector()
                    let notifier = NotificationService()
                    let orch = VisitNotificationOrchestrator(locationService: location, detector: detector, notifier: notifier)
                    orchestrator = orch
                    await location.requestAuthorization()
                    await orch.start()
                }
        }
    }
}
