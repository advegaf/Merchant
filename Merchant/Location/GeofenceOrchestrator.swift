// Rules: Build geofences around top nearby POIs and notify on entry.
// Inputs: current coord; NearbyCategoryDetector/Provider; GeofenceManager; NotificationService
// Outputs: Instant entry suggestions
// Constraints: ≤10 regions; 150m radius; refresh periodically

import Foundation
import CoreLocation
import MapKit

public final class GeofenceOrchestrator {
    private let geofencer: Geofencing
    private let notifier: NotificationServicing
    private let locator = CLLocationManager()

    public init(geofencer: Geofencing, notifier: NotificationServicing) {
        self.geofencer = geofencer
        self.notifier = notifier
        self.geofencer.onEnter = { [weak self] region in
            guard let id = region.identifier.removingPercentEncoding else { return }
            Task { await self?.notifyEnter(id: id) }
        }
    }

    public func start() async {
        await geofencer.requestAuthorization()
        let _ = await notifier.requestAuthorization()
        await refreshRegions()
    }

    public func refreshRegions() async {
        guard let coord = locator.location?.coordinate else { return }
        let queries = ["groceries", "restaurants", "coffee", "gas"]
        var regions: [CLCircularRegion] = []
        for q in queries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = q
            request.resultTypes = .pointOfInterest
            request.region = MKCoordinateRegion(center: coord, latitudinalMeters: 3000, longitudinalMeters: 3000)
            let search = MKLocalSearch(request: request)
            if let resp = try? await search.start() {
                for item in resp.mapItems.prefix(3) { // up to ~12 total across queries
                    let c = item.placemark.coordinate
                    let region = CLCircularRegion(center: c, radius: 150, identifier: (item.name ?? q).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? q)
                    regions.append(region)
                    if regions.count >= 10 { break }
                }
            }
            if regions.count >= 10 { break }
        }
        geofencer.setRegions(regions)
    }

    private func notifyEnter(id: String) async {
        let title = "You're at \(id)"
        // Recommend generically based on id keywords
        let (card, why) = SimpleRulesEngine.recommend(for: id, from: await MockCardArtProvider().fetchCardsForReview())
        let body = card?.productName != nil ? "Best: \(card!.productName) — \(why)" : why
        await notifier.scheduleSuggestion(title: title, body: body, venueKey: id, reason: why)
    }
}


