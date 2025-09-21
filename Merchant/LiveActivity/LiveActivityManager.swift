// Rules: Manage Live Activity lifecycle based on location and venue detection
// Inputs: Location visits, venue detection, card recommendations
// Outputs: Live Activity start/stop/update based on context
// Constraints: Respect user preferences, battery efficiency, privacy

// Build-gated manager to avoid compile errors on platforms without ActivityKit
#if canImport(ActivityKit)
import ActivityKit
import Combine
import CoreLocation
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published var isLiveActivityActive = false
    private var currentActivity: Activity<CardRecommendationAttributes>?

    func startLiveActivity(
        venueName: String,
        venueCategory: String,
        bestCard: String,
        recommendation: String,
        estimatedSavings: String
    ) {
        // Check if Live Activities are supported and enabled
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }

        // End any existing activity first
        endLiveActivity()

        let attributes = CardRecommendationAttributes(userId: "current_user")
        let contentState = CardRecommendationAttributes.ContentState(
            venueName: venueName,
            venueCategory: venueCategory,
            bestCard: bestCard,
            recommendation: recommendation,
            estimatedSavings: estimatedSavings,
            lastUpdated: Date()
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )

            currentActivity = activity
            isLiveActivityActive = true

            print("✅ Live Activity started for \(venueName)")
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
        }
    }

    func updateLiveActivity(
        venueName: String,
        venueCategory: String,
        bestCard: String,
        recommendation: String,
        estimatedSavings: String
    ) {
        guard let activity = currentActivity else { return }

        let updatedContentState = CardRecommendationAttributes.ContentState(
            venueName: venueName,
            venueCategory: venueCategory,
            bestCard: bestCard,
            recommendation: recommendation,
            estimatedSavings: estimatedSavings,
            lastUpdated: Date()
        )

        Task {
            await activity.update(.init(state: updatedContentState, staleDate: nil))
            print("🔄 Live Activity updated for \(venueName)")
        }
    }

    func endLiveActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            isLiveActivityActive = false
            print("🛑 Live Activity ended")
        }
    }

    func handleLocationUpdate(visit: CLVisit, detectedVenue: String?, category: VenueCategory) async {
        // Only start Live Activity if we have a meaningful venue detection
        guard let venueName = detectedVenue, !venueName.isEmpty else {
            endLiveActivity()
            return
        }

        // Get card recommendation
        let cardProvider = MockCardArtProvider()
        let cards = await cardProvider.fetchCardsForReview()
        let (bestCard, reason) = SimpleRulesEngine.recommend(
            for: String(describing: category),
            from: cards
        )

        guard let recommendedCard = bestCard else {
            endLiveActivity()
            return
        }

        let estimatedSavings = calculateEstimatedSavings(for: category)

        if isLiveActivityActive {
            // Update existing activity
            updateLiveActivity(
                venueName: venueName,
                venueCategory: String(describing: category),
                bestCard: recommendedCard.productName,
                recommendation: reason,
                estimatedSavings: estimatedSavings
            )
        } else {
            // Start new activity
            startLiveActivity(
                venueName: venueName,
                venueCategory: String(describing: category),
                bestCard: recommendedCard.productName,
                recommendation: reason,
                estimatedSavings: estimatedSavings
            )
        }
    }

    private func calculateEstimatedSavings(for category: VenueCategory) -> String {
        // Simple estimation based on category
        switch category {
        case .restaurant: return "$1.25"
        case .coffee: return "$0.85"
        case .groceries: return "$4.20"
        case .gas: return "$1.50"
        case .other: return "$0.75"
        }
    }
}

// Integration hooks will live inside the orchestrator file to respect access control.
#endif