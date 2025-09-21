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

    private func reason(for category: VenueCategory, cards: [CardUI]) -> String {
        let (_, why) = SimpleRulesEngine.recommend(for: String(describing: category), from: cards)
        return why
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
        let (category, placeName) = await detector.detect(visit: visit)
        let prefs = NotificationPreferencesStore.shared
        guard prefs.enabled else { return }
        // Gate: only notify for key venue categories
        switch category {
        case .restaurant:
            guard prefs.restaurants else { return }
        case .coffee:
            guard prefs.coffee else { return }
        case .groceries:
            guard prefs.groceries else { return }
        case .gas:
            guard prefs.gas else { return }
        case .other:
            return
        }
        let venue = venueKey(for: visit)
        let title = "Hey \(UserProfileStore.shared.displayName) — you're at \(placeName ?? title(for: category))"
        let all = await MockCardArtProvider().fetchCardsForReview()
        let selected = SelectedCardsStore.shared.selectedKeys
        let cards = selected.isEmpty ? all : all.filter { selected.contains($0.selectionKey) }
        let (card, why) = SimpleRulesEngine.recommend(for: String(describing: category), from: cards)
        let body: String
        if let card {
            body = "Best card to use is \(card.productName) — \(why). Tap to open Wallet."
        } else {
            body = self.body(for: category)
        }
        let reasonText = reason(for: category, cards: cards)
        await notifier.scheduleSuggestion(title: title, body: body, venueKey: venue, reason: reasonText)
    }
}

