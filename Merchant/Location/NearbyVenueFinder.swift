
import Foundation
import CoreLocation
import MapKit

struct RawNearbyVenue: Identifiable {
    let id = UUID().uuidString
    let name: String
    let category: VenueCategory
    let distanceMeters: CLLocationDistance
}

final class NearbyVenueFinder {
    func fetch(around coordinate: CLLocationCoordinate2D, limitPerCategory: Int = 5) async -> [RawNearbyVenue] {
        let queries: [(String, VenueCategory)] = [
            ("coffee", .coffee),
            ("restaurant", .restaurant),
            ("grocery", .groceries),
            ("supermarket", .groceries),
            ("gas", .gas)
        ]
        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var results: [RawNearbyVenue] = []

        await withTaskGroup(of: [RawNearbyVenue].self) { group in
            for (query, cat) in queries {
                group.addTask {
                    await self.search(query: query, category: cat, near: coordinate, origin: origin, limit: limitPerCategory)
                }
            }
            for await chunk in group {
                results.append(contentsOf: chunk)
            }
        }

        // Deduplicate by name and category, keep closest
        var bestByKey: [String: RawNearbyVenue] = [:]
        for v in results {
            let key = "\(v.category)|\(v.name.lowercased())"
            if let existing = bestByKey[key] {
                if v.distanceMeters < existing.distanceMeters { bestByKey[key] = v }
            } else {
                bestByKey[key] = v
            }
        }

        return bestByKey.values.sorted { $0.distanceMeters < $1.distanceMeters }
    }

    private func search(query: String, category: VenueCategory, near coordinate: CLLocationCoordinate2D, origin: CLLocation, limit: Int) async -> [RawNearbyVenue] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        let search = MKLocalSearch(request: request)
        do {
            let resp = try await search.start()
            return resp.mapItems.prefix(limit).compactMap { item in
                guard let name = item.name else { return nil }
                let loc = item.location ?? CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let dist = origin.distance(from: loc)
                return RawNearbyVenue(name: name, category: category, distanceMeters: dist)
            }
        } catch {
            return []
        }
    }
}


