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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Page Title
                    HStack {
                        Text("Nearby Categories")
                            .font(CopilotDesign.Typography.displayMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Categories List
                    LazyVStack(spacing: 12) {
                        ForEach(categories) { bucket in
                            CategoryRow(bucket: bucket) {
                                Task { await choose(bucket) }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 50)
                }
            }
            .background(.ultraThinMaterial)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        let h = UIImpactFeedbackGenerator(style: .light)
                        h.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.2)) { dismiss() }
                    }
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

struct CategoryRow: View {
    let bucket: NearbyCategoryBucket
    let action: () -> Void

    var body: some View {
        CleanCard(style: .flat) {
            Button(action: action) {
                HStack(spacing: 16) {
                    // Category Icon
                    Circle()
                        .fill(CopilotDesign.Colors.accent.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(CopilotDesign.Colors.accent)
                        }

                    // Category Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bucket.name)
                            .font(CopilotDesign.Typography.bodyMedium)
                            .fontWeight(.medium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                        Text("Nearby locations")
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }

                    Spacer()

                    // Count Badge
                    Text("\(bucket.count)")
                        .font(CopilotDesign.Typography.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .fill(CopilotDesign.Colors.accent.opacity(0.1))
                        }

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
        }
    }
}


