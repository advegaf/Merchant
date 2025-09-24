
import SwiftUI
import CoreLocation

@main
struct MerchantApp: App {
    @State private var uiState = UIState()
    @State private var orchestrator: VisitNotificationOrchestrator? = nil
    @State private var geoOrch: GeofenceOrchestrator? = nil

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(uiState)
                .environment(NotificationPreferencesStore.shared)
                .environment(SelectedCardsStore.shared)
                .environment(UserProfileStore.shared)
                .preferredColorScheme(.dark)
                .task {
                    // Wire location → detector → notifications
                    let location = LocationService()
                    let detector = NearbyCategoryDetector()
                    let notifier = NotificationService()
                    let orch = VisitNotificationOrchestrator(locationService: location, detector: detector, notifier: notifier)
                    orchestrator = orch
                    if PrivacyKeys.hasLocationWhenInUse {
                        await location.requestAuthorization()
                        await orch.start()
                    }

                    // Start geofencing for near-instant entry alerts
                    if PrivacyKeys.hasLocationAlways {
                        let geofencer = GeofenceManager()
                        let geo = GeofenceOrchestrator(geofencer: geofencer, notifier: notifier)
                        geoOrch = geo
                        await geo.start()
                    }
                }
        }
    }
}
