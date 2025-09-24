// Nearby places with simple best-card recommendations and quick map links.

import SwiftUI
import MapKit
import UIKit

struct NearbySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var nearbyVenues: [NearbyVenue] = []
    @State private var cards: [CardUI] = []
    @State private var isLoading = true
    @State private var locationDenied = false
    @State private var selectedCategory: VenueCategory? = nil
    private let locator = CLLocationManager()
    private let finder = NearbyVenueFinder()
    private let selectedStore = SelectedCardsStore.shared

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header matching Alerts style
                    VStack(spacing: 8) {
                        Text("Nearby")
                            .font(CopilotDesign.Typography.displaySmall)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                        Text("Best cards at places around you")
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                    // Category chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryChip(label: "All", icon: "globe", color: CopilotDesign.Colors.textTertiary, selected: selectedCategory == nil) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { selectedCategory = nil }
                            }
                            CategoryChip(label: "Restaurants", icon: VenueCategory.restaurant.icon, color: VenueCategory.restaurant.color, selected: selectedCategory == .restaurant) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { selectedCategory = .restaurant }
                            }
                            CategoryChip(label: "Coffee", icon: VenueCategory.coffee.icon, color: VenueCategory.coffee.color, selected: selectedCategory == .coffee) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { selectedCategory = .coffee }
                            }
                            CategoryChip(label: "Groceries", icon: VenueCategory.groceries.icon, color: VenueCategory.groceries.color, selected: selectedCategory == .groceries) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { selectedCategory = .groceries }
                            }
                            CategoryChip(label: "Gas", icon: VenueCategory.gas.icon, color: VenueCategory.gas.color, selected: selectedCategory == .gas) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { selectedCategory = .gas }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, -4)

                    if isLoading {
                        VStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { _ in
                                CleanCard(style: .flat) {
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(CopilotDesign.Colors.textTertiary.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        VStack(alignment: .leading, spacing: 8) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(CopilotDesign.Colors.textTertiary.opacity(0.15))
                                                .frame(height: 14)
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(CopilotDesign.Colors.textTertiary.opacity(0.12))
                                                .frame(height: 12)
                                                .padding(.trailing, 40)
                                        }
                                        Spacer()
                                    }
                                    .padding(16)
                                }
                                .redacted(reason: .placeholder)
                            }
                        }
                        .padding(.horizontal, 20)
                    } else if locationDenied {
                        CleanCard(style: .transparent) {
                            VStack(spacing: 12) {
                                Text("Location is Off")
                                    .font(CopilotDesign.Typography.headlineSmall)
                                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
                                Text("Enable Location Services to see nearby recommendations.")
                                    .font(CopilotDesign.Typography.bodySmall)
                                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                CleanButton("Enable in Settings", style: .primary, size: .small) {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        DispatchQueue.main.async { UIApplication.shared.open(url) }
                                    }
                                }
                            }
                            .padding(20)
                        }
                        .padding(.horizontal, 20)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredVenues, id: \.id) { venue in
                                NearbyVenueRow(venue: venue, cards: cards)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: filteredVenues.map { $0.id })
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 20)
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
        .task { await loadNearbyData() }
        .onReceive(NotificationCenter.default.publisher(for: .selectedCardsChanged)) { _ in
            Task { await refreshCardsOnly() }
        }
    }

    private func loadNearbyData() async {
        locator.requestWhenInUseAuthorization()
        let status = locator.authorizationStatus
        if status == .denied || status == .restricted {
            locationDenied = true
            isLoading = false
            return
        }
        guard let coord = locator.location?.coordinate else { isLoading = false; return }
        let raw = await finder.fetch(around: coord)

        // Use user's selected cards to ensure compatibility
        let provider = MockCardArtProvider()
        let all = await provider.fetchCardsForReview()
        let selected = selectedStore.selectedKeys
        cards = selected.isEmpty ? all : all.filter { selected.contains($0.selectionKey) }

        nearbyVenues = raw.prefix(20).map { item in
            NearbyVenue(
                id: item.id,
                name: item.name,
                category: item.category,
                distance: Self.formatDistance(item.distanceMeters),
                estimatedEarnings: Self.estimateEarnings(for: item.category)
            )
        }

        isLoading = false
    }

    private func refreshCardsOnly() async {
        let provider = MockCardArtProvider()
        let all = await provider.fetchCardsForReview()
        let selected = selectedStore.selectedKeys
        cards = selected.isEmpty ? all : all.filter { selected.contains($0.selectionKey) }
    }

    private var filteredVenues: [NearbyVenue] {
        guard let selected = selectedCategory else { return nearbyVenues }
        return nearbyVenues.filter { $0.category == selected }
    }

    private static func formatDistance(_ meters: CLLocationDistance) -> String {
        let miles = meters / 1609.34
        if miles < 0.1 { return "<0.1 mi" }
        return String(format: "%.1f mi", miles)
    }

    private static func estimateEarnings(for category: VenueCategory) -> String {
        // Keep conservative defaults; row-level uses SimpleRulesEngine
        switch category {
        case .coffee, .restaurant: return "Dining rewards"
        case .groceries: return "Groceries rewards"
        case .gas: return "Gas rewards"
        case .other: return "General rewards"
        }
    }
}

struct NearbyVenue {
    let id: String
    let name: String
    let category: VenueCategory
    let distance: String
    let estimatedEarnings: String
}

extension VenueCategory {
    var color: Color {
        switch self {
        case .restaurant: return CopilotDesign.Colors.brandOrange
        case .coffee: return Color.brown
        case .groceries: return CopilotDesign.Colors.brandGreen
        case .gas: return CopilotDesign.Colors.brandBlue
        case .other: return CopilotDesign.Colors.textTertiary
        }
    }

    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .coffee: return "cup.and.saucer"
        case .groceries: return "cart.fill"
        case .gas: return "fuelpump.fill"
        case .other: return "building.2"
        }
    }
}

struct NearbyVenueRow: View {
    let venue: NearbyVenue
    let cards: [CardUI]
    @State private var bestCard: CardUI?
    @State private var recommendation: String = ""
    @State private var earningsText: String = ""
    @Environment(\.openURL) private var openURL

    var body: some View {
        CleanCard(style: .flat) {
            HStack(spacing: 14) {
                Circle()
                    .fill(venue.category.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: venue.category.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(venue.category.color)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(venue.name)
                        .font(CopilotDesign.Typography.bodyMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    // Distance line
                    HStack(spacing: 8) {
                        Text(venue.distance)
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }

                    // Best card chips on their own line with horizontal scroll to avoid clipping
                    if let bestCard = bestCard {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                Text(bestCard.productName)
                                    .font(CopilotDesign.Typography.labelSmall)
                                    .foregroundStyle(CopilotDesign.Colors.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule().fill(CopilotDesign.Colors.accent.opacity(0.12))
                                    )

                                if !earningsText.isEmpty {
                                    Text(earningsText)
                                        .font(CopilotDesign.Typography.labelSmall)
                                        .foregroundStyle(CopilotDesign.Colors.success)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule().fill(CopilotDesign.Colors.success.opacity(0.12))
                                        )
                                }
                            }
                        }
                    } else {
                        Text("No clear best")
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }
                }

                Spacer()

                Button {
                    let query = venue.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? venue.name
                    if let url = URL(string: "http://maps.apple.com/?q=\(query)") { openURL(url) }
                } label: {
                    Image(systemName: "map")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.accent)
                        .padding(8)
                        .background { Circle().fill(CopilotDesign.Colors.accent.opacity(0.12)) }
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
        .task { calculateBestCard() }
    }

    private func calculateBestCard() {
        // Use benefits-driven rules for clarity and consistency
        let (card, why) = SimpleRulesEngine.recommend(
            for: String(describing: venue.category),
            from: cards
        )
        bestCard = card
        recommendation = why
        earningsText = why
    }
}

// MARK: - Components

private struct CategoryChip: View {
    let label: String
    let icon: String
    let color: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(CopilotDesign.Typography.labelSmall)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selected ? color.opacity(0.18) : CopilotDesign.Colors.textTertiary.opacity(0.12))
            )
            .foregroundStyle(selected ? color : CopilotDesign.Colors.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NearbySheet()
}