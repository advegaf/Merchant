// Rules: One-shot nearby categories list using MapKit; no persistent location.
// Inputs: User location, NearbyCategoriesProvider
// Outputs: List with counts; tap to filter (future hook)
// Constraints: Simple UI; no refactor

import SwiftUI
import CoreLocation

struct NearbyCategoriesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categories: [NearbyCategoryBucket] = []
    @State private var provider = NearbyCategoriesProvider()
    private let locator = CLLocationManager()

    var body: some View {
        NavigationStack {
            List(categories) { bucket in
                HStack {
                    Text(bucket.name)
                    Spacer()
                    Text("\(bucket.count)")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Nearby Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task { await loadOnce() }
    }

    private func loadOnce() async {
        locator.requestWhenInUseAuthorization()
        if let coord = locator.location?.coordinate {
            categories = await provider.fetchCategories(near: coord)
        }
    }
}


