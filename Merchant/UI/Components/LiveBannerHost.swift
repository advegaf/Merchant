
import SwiftUI
import Foundation

struct LiveBannerHost: View {
    @State private var venueName: String = "Nearby"
    @State private var venueCategory: String = ""
    @State private var bestCard: String = ""
    @State private var recommendation: String = ""
    @State private var estimated: String = ""
    @State private var startedAt: Date = Date()
    private let placeProvider = CurrentPlaceProvider()

    var body: some View {
        LiveActivityBanner(
            venueName: venueName,
            venueCategory: venueCategory,
            bestCard: bestCard,
            recommendation: recommendation,
            estimatedSavings: estimated
        )
        .onAppear {
            placeProvider.start { name, categoryKey, start in
                venueName = name
                venueCategory = categoryKey
                startedAt = start
                Task { await recompute() }
            }
        }
        .onDisappear { placeProvider.stop() }
    }

    private func recompute() async {
        // Determine category from venue name
        let lower = venueName.lowercased()
        let spendingCategory: SpendingCategory = {
            if lower.contains("coffee") { return .coffee }
            if lower.contains("gas") || lower.contains("fuel") { return .gas }
            if lower.contains("grocery") || lower.contains("market") || lower.contains("super") { return .groceries }
            if lower.contains("restaurant") || lower.contains("grill") || lower.contains("bistro") { return .dining }
            return .everything
        }()

        venueCategory = spendingCategory.rawValue

        // Use user's selected product names with the enhanced rules engine
        let userCards = SelectedCardsStore.shared.selectedProductNames
        let spendAmount = 50.0 // representative quick-estimate
        let rec = EnhancedRulesEngine.shared.recommendCard(
            for: spendingCategory,
            amount: spendAmount,
            userCards: userCards
        )

        if let card = rec.card {
            bestCard = card.productName
        } else {
            bestCard = ""
        }
        recommendation = rec.reason
        estimated = String(format: "$%.2f", rec.earnings.cashValue)
    }

    // Detailed estimate now uses EnhancedRulesEngine; ad-hoc helper removed.
}


