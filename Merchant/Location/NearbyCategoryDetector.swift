// Rules: Simple detector to identify venue category (e.g., restaurant) using MKLocalSearch.
// Inputs: CLVisit with coordinates
// Outputs: PurchaseCategory classification
// Constraints: Rate-limit searches; low-power; degrade when offline

import Foundation
import CoreLocation
import MapKit

public enum VenueCategory {
    case restaurant
    case coffee
    case groceries
    case gas
    case other
}

public protocol NearbyCategoryDetecting {
    func classify(visit: CLVisit) async -> VenueCategory
}

public final class NearbyCategoryDetector: NearbyCategoryDetecting {
    public init() {}

    public func classify(visit: CLVisit) async -> VenueCategory {
        let coord = CLLocationCoordinate2D(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        let region = MKCoordinateRegion(center: coord, latitudinalMeters: 400, longitudinalMeters: 400)

        if await hasPOI(query: "coffee", region: region) { return .coffee }
        if await hasPOI(query: "restaurant", region: region) { return .restaurant }

        let hasGrocery = await hasPOI(query: "grocery", region: region)
        if hasGrocery { return .groceries }
        let hasSupermarket = await hasPOI(query: "supermarket", region: region)
        if hasSupermarket { return .groceries }

        let hasGas = await hasPOI(query: "gas", region: region)
        if hasGas { return .gas }
        let hasFuel = await hasPOI(query: "fuel", region: region)
        if hasFuel { return .gas }

        return .other
    }

    private func hasPOI(query: String, region: MKCoordinateRegion) async -> Bool {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = region
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            return !response.mapItems.isEmpty
        } catch { return false }
    }
}


