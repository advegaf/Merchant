
import Foundation

struct SimpleRulesEngine {
    static func recommend(for category: String, from cards: [CardUI]) -> (card: CardUI?, why: String) {
        // Use CardBenefitsCatalog to compute best multiplier for the given category
        let key = canonicalize(category: category)
        var best: (CardUI, Double, String)? = nil

        for card in cards {
            let selectionKey = card.selectionKey
            let details = CardBenefitsCatalog.details(for: selectionKey)
            let multiplier = details.multiplier(for: key)
            if best == nil || multiplier > (best?.1 ?? 0) {
                // Build a concise why line from catalog
                let why = CardBenefitsCatalog.benefits(for: selectionKey)
                best = (card, multiplier, why)
            }
        }

        if let best = best {
            // Prefer a direct category mention if available
            let whyDetail: String
            if best.1 > 1.0 {
                whyDetail = String(format: "%.0f× %@", best.1, humanLabel(for: key))
            } else {
                whyDetail = best.2
            }
            return (best.0, whyDetail)
        }

        return (nil, "General rewards")
    }

    private static func canonicalize(category: String) -> String {
        let c = category.lowercased()
        if c.contains("restaurant") || c.contains("dining") { return "dining" }
        if c.contains("coffee") { return "coffee" }
        if c.contains("grocery") || c.contains("grocer") { return "groceries" }
        if c.contains("gas") || c.contains("fuel") { return "gas" }
        if c.contains("flight") || c.contains("air") || c.contains("hotel") { return "travel" }
        if c.contains("drugstore") || c.contains("pharmacy") { return "drugstores" }
        if c.contains("transit") || c.contains("transport") || c.contains("uber") || c.contains("lyft") { return "transit" }
        if c.contains("entertainment") || c.contains("movie") { return "entertainment" }
        if c.contains("stream") { return "streaming" }
        if c.contains("online") || c.contains("ecommerce") { return "online" }
        return "everything"
    }

    private static func humanLabel(for key: String) -> String {
        switch key {
        case "dining": return "Dining"
        case "coffee": return "Coffee"
        case "groceries": return "Groceries"
        case "gas": return "Gas"
        case "travel": return "Travel"
        case "drugstores": return "Drugstores"
        case "transit": return "Transit"
        case "entertainment": return "Entertainment"
        case "streaming": return "Streaming"
        case "online": return "Online"
        default: return "Everywhere"
        }
    }
}


