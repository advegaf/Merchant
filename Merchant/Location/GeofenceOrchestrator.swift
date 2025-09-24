// Creates geofences for nearby places and schedules entry notifications.

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
        let prefs = NotificationPreferencesStore.shared
        guard prefs.enabled else { return }
        var queries: [String] = []
        if prefs.groceries { queries.append("groceries") }
        if prefs.restaurants { queries.append("restaurants") }
        if prefs.coffee { queries.append("coffee") }
        if prefs.gas { queries.append("gas") }
        var regions: [CLCircularRegion] = []
        for q in queries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = q
            request.resultTypes = .pointOfInterest
            request.region = MKCoordinateRegion(center: coord, latitudinalMeters: 3000, longitudinalMeters: 3000)
            let search = MKLocalSearch(request: request)
            if let resp = try? await search.start() {
                for item in resp.mapItems.prefix(3) { // up to ~12 total across queries
                    let c: CLLocationCoordinate2D
                    if #available(iOS 26.0, *) {
                        c = modernCoordinate(for: item)
                    } else {
                        c = legacyCoordinate(for: item)
                    }
                    let name: String = {
                        if let n = item.name, !n.isEmpty { return n }
                        return q
                    }()
                    let ident = "\(q)|\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
                    let region = CLCircularRegion(center: c, radius: 150, identifier: ident)
                    regions.append(region)
                    if regions.count >= 10 { break }
                }
            }
            if regions.count >= 10 { break }
        }
        geofencer.setRegions(regions)
    }

    // MARK: - Availability helpers (silence deprecation while keeping iOS 15+ support)

    private func legacyCoordinate(for item: MKMapItem) -> CLLocationCoordinate2D {
        item.placemark.coordinate
    }

    @available(iOS 26.0, *)
    private func modernCoordinate(for item: MKMapItem) -> CLLocationCoordinate2D {
        item.location.coordinate
    }

    private func notifyEnter(id: String) async {
        let parts = id.split(separator: "|")
        let category = parts.first.map(String.init) ?? "Nearby"
        let place = parts.dropFirst().joined(separator: "|")
        let prefs = NotificationPreferencesStore.shared
        guard prefs.enabled else { return }
        if category.contains("grocery") && !prefs.groceries { return }
        if category.contains("restaurant") && !prefs.restaurants { return }
        if category.contains("coffee") && !prefs.coffee { return }
        if category.contains("gas") && !prefs.gas { return }

        let title = "Hey \(UserProfileStore.shared.displayName) — you're at \(place)"
        let all = await MockCardArtProvider().fetchCardsForReview()
        let selected = SelectedCardsStore.shared.selectedKeys
        let cards = selected.isEmpty ? all : all.filter { selected.contains($0.selectionKey) }
        let (card, why) = SimpleRulesEngine.recommend(for: category, from: cards)
        let body: String
        if let card { body = "Best card to use is \(card.productName) — \(why). Tap to open Wallet." } else { body = "Best card to use: see app" }
        await notifier.scheduleSuggestion(title: title, body: body, venueKey: place, reason: why)
    }
}
