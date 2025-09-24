// Resolves a nearby place name and reports when a new session starts.

import Foundation
import CoreLocation
import MapKit

public final class CurrentPlaceProvider: NSObject {
    private let manager = CLLocationManager()
    // MapKit-based place resolution (avoids deprecated CLGeocoder warnings on iOS 26)
    private var anchor: CLLocation?
    private var isRunning = false

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .other
    }

    public func start(onUpdate: @escaping (_ name: String, _ categoryKey: String, _ start: Date) -> Void) {
        guard !isRunning else { return }
        isRunning = true
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation()
        // Initial update if we have a cached location
        if let loc = manager.location {
            handle(location: loc, onUpdate: onUpdate)
        }
        self.onUpdate = onUpdate
    }

    public func stop() {
        isRunning = false
        manager.stopUpdatingLocation()
        onUpdate = nil
    }

    private var onUpdate: ((_ name: String, _ categoryKey: String, _ start: Date) -> Void)?

    private func handle(location: CLLocation, onUpdate: @escaping (_ name: String, _ categoryKey: String, _ start: Date) -> Void) {
        let shouldResetSession: Bool
        if let anchor {
            shouldResetSession = location.distance(from: anchor) > 75
        } else {
            shouldResetSession = true
        }

        if shouldResetSession {
            anchor = location
            let start = Date()
            Task { [weak self] in
                guard self?.isRunning == true else { return }
                let (name, category) = await self?.resolvePlace(for: location) ?? ("Nearby", .everything)
                onUpdate(name, category.rawValue, start)
            }
        }
    }

    private func resolvePlace(for location: CLLocation) async -> (String, SpendingCategory) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = nil
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        let search = MKLocalSearch(request: request)
        if let response = try? await search.start() {
            // Choose nearest map item
            let nearest = response.mapItems.min(by: { ($0.placemark.location?.distance(from: location) ?? .greatestFiniteMagnitude) < ($1.placemark.location?.distance(from: location) ?? .greatestFiniteMagnitude) })
            if let item = nearest {
                let name: String = {
                    if #available(iOS 26.0, *) { return item.name ?? "Nearby" }
                    return item.name ?? (item.placemark.name ?? item.placemark.locality ?? "Nearby")
                }()
                let category = inferCategory(fromName: name)
                return (name, category)
            }
        }
        return ("Nearby", .everything)
    }

    private func inferCategory(fromName name: String) -> SpendingCategory {
        let lower = name.lowercased()
        // Groceries
        let groceriesKeywords = ["grocery", "groceries", "market", "supermarket", "heb", "whole foods", "trader joe", "trader joe's", "costco", "walmart", "albertsons", "kroger", "safeway", "publix", "aldi", "ralphs", "giant", "h-e-b", "heb "]
        if groceriesKeywords.contains(where: { lower.contains($0) }) { return .groceries }

        // Coffee
        let coffeeKeywords = ["coffee", "starbucks", "dunkin", "peet", "philz", "blue bottle", "intelligentsia", "tim hortons"]
        if coffeeKeywords.contains(where: { lower.contains($0) }) { return .coffee }

        // Gas
        let gasKeywords = ["gas", "fuel", "shell", "chevron", "exxon", "mobil", "valero", "bp", "sunoco", "marathon"]
        if gasKeywords.contains(where: { lower.contains($0) }) { return .gas }

        // Dining / Restaurants
        let diningKeywords = ["restaurant", "grill", "bistro", "taqueria", "pizza", "burger", "bbq", "bar & grill", "cantina", "kitchen"]
        if diningKeywords.contains(where: { lower.contains($0) }) { return .dining }

        return .everything
    }
}

extension CurrentPlaceProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last, let onUpdate else { return }
        handle(location: latest, onUpdate: onUpdate)
    }
}


