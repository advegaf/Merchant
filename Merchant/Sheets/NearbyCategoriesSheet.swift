// Rules: One-shot nearby categories list using MapKit; no persistent location.
// Inputs: User location, NearbyCategoriesProvider
// Outputs: List with counts; tap to filter (future hook)
// Constraints: Simple UI; no refactor

import SwiftUI
import CoreLocation

struct NearbyCategoriesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categories: [NearbyCategoryBucket] = []
    @State private var recommendation: (title: String, body: String)? = nil
    @State private var provider = NearbyCategoriesProvider()
    private let locator = CLLocationManager()

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { bucket in
                    Button {
                        Task { await choose(bucket) }
                    } label: {
                        HStack {
                            Text(bucket.name)
                            Spacer()
                            Text("\(bucket.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
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
        .alert(recommendation?.title ?? "", isPresented: Binding(
            get: { recommendation != nil },
            set: { if !$0 { recommendation = nil } }
        )) {
            Button("Open in Maps") { openInMaps() }
            Button("OK", role: .cancel) { recommendation = nil }
        } message: {
            Text(recommendation?.body ?? "")
        }
    }

    private func loadOnce() async {
        locator.requestWhenInUseAuthorization()
        if let coord = locator.location?.coordinate {
            categories = await provider.fetchCategories(near: coord)
        }
    }

    private func choose(_ bucket: NearbyCategoryBucket) async {
        // Recommend from selected cards
        let all = await MockCardArtProvider().fetchCardsForReview()
        let selected = SelectedCardsStore.shared.selectedKeys
        let cards = selected.isEmpty ? all : all.filter { selected.contains($0.selectionKey) }
        let (card, why) = SimpleRulesEngine.recommend(for: bucket.name, from: cards)
        if let card {
            recommendation = (title: "Best: \(card.productName)", body: why)
        } else {
            recommendation = (title: "Best Card", body: "General rewards")
        }
    }

    private func openInMaps() {
        guard let title = recommendation?.title else { return }
        let q = title.replacingOccurrences(of: "Best: ", with: "")
        let query = (q + " near me").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "http://maps.apple.com/?q=\(query)") else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
}


