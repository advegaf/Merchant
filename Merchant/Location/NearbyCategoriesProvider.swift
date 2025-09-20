// Rules: Provide nearby POI category buckets via one-shot MapKit searches.
// Inputs: Current coordinate
// Outputs: Sorted category buckets with counts
// Constraints: Low power; graceful failure when location off

import Foundation
import MapKit
import CoreLocation

public struct NearbyCategoryBucket: Identifiable {
    public let id = UUID()
    public let name: String
    public let count: Int
}

public final class NearbyCategoriesProvider {
    public init() {}

    public func fetchCategories(near coordinate: CLLocationCoordinate2D) async -> [NearbyCategoryBucket] {
        let queries = ["Groceries", "Restaurants", "Coffee", "Gas", "Gyms", "Pharmacies"]
        var results: [NearbyCategoryBucket] = []
        await withTaskGroup(of: NearbyCategoryBucket?.self) { group in
            for q in queries {
                group.addTask { [q] in
                    let request = MKLocalSearch.Request()
                    request.naturalLanguageQuery = q
                    request.resultTypes = .pointOfInterest
                    request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
                    let search = MKLocalSearch(request: request)
                    do {
                        let resp = try await search.start()
                        let count = min(resp.mapItems.count, 50)
                        return count > 0 ? NearbyCategoryBucket(name: q, count: count) : nil
                    } catch { return nil }
                }
            }
            for await item in group {
                if let item { results.append(item) }
            }
        }
        return results.sorted { $0.count > $1.count }
    }
}


