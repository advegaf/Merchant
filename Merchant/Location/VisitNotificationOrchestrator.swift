// Rules: Orchestrate location visits → category detection → local notification suggestion.
// Inputs: LocationServicing visits
// Outputs: Local notifications with clear reasons
// Constraints: Respect privacy toggles; feature flag gate; degrade gracefully when disabled

import Foundation
import CoreLocation

public final class VisitNotificationOrchestrator {
    private let locationService: LocationServicing
    private let detector: NearbyCategoryDetecting
    private let notifier: NotificationServicing

    public init(locationService: LocationServicing,
                detector: NearbyCategoryDetecting,
                notifier: NotificationServicing) {
        self.locationService = locationService
        self.detector = detector
        self.notifier = notifier
        self.locationService.onVisit = { [weak self] visit in
            Task { await self?.handle(visit: visit) }
        }
    }

    public func start() async {
        guard FeatureFlags.PlaidSync else { return }
        _ = await notifier.requestAuthorization()
        await locationService.start()
    }

    private func venueKey(for visit: CLVisit) -> String {
        "\(visit.coordinate.latitude.rounded())_\(visit.coordinate.longitude.rounded())"
    }

    private func bestCardName(for category: VenueCategory) -> String {
        switch category {
        case .restaurant: return "Sapphire Preferred"
        case .coffee: return "Sapphire Preferred"
        case .groceries: return "Amex Blue Cash"
        case .gas: return "Citi Custom Cash"
        case .other: return "Freedom Unlimited"
        }
    }

    private func reason(for category: VenueCategory) -> String {
        switch category {
        case .restaurant: return "3× on dining"
        case .coffee: return "3× on dining"
        case .groceries: return "6% on groceries"
        case .gas: return "5% on gas"
        case .other: return "1.5× everywhere"
        }
    }

    private func title(for category: VenueCategory) -> String {
        switch category {
        case .restaurant: return "Looks like you're at a restaurant"
        case .coffee: return "Looks like you're grabbing coffee"
        case .groceries: return "Looks like you're at a grocery store"
        case .gas: return "Looks like you're at a gas station"
        case .other: return "You're nearby"
        }
    }

    private func body(for category: VenueCategory) -> String {
        let card = bestCardName(for: category)
        switch category {
        case .restaurant: return "Use \(card) for extra points."
        case .coffee: return "Use \(card) for extra points."
        case .groceries: return "Use \(card) for top grocery rewards."
        case .gas: return "Use \(card) for top gas rewards."
        case .other: return "Use \(card) for solid rewards."
        }
    }

    private func handle(visit: CLVisit) async {
        let category = await detector.classify(visit: visit)
        // Gate: only notify for key venue categories
        switch category {
        case .restaurant, .coffee, .groceries, .gas:
            break
        case .other:
            return
        }
        let venue = venueKey(for: visit)
        let title = title(for: category)
        let body = body(for: category)
        let reason = reason(for: category)
        await notifier.scheduleSuggestion(title: title, body: body, venueKey: venue, reason: reason)
    }
}


