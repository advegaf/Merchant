// Rules: Minimal category→card recommendation with one-line rationale.
// Inputs: Category string, selected cards
// Outputs: Recommended CardUI and why-line
// Constraints: Heuristic only

import Foundation

struct SimpleRulesEngine {
    static func recommend(for category: String, from cards: [CardUI]) -> (card: CardUI?, why: String) {
        let normalized = category.lowercased()
        // Prefer by product names heuristics
        let pick: (String, String)? = {
            if normalized.contains("dining") || normalized.contains("restaurant") || normalized.contains("coffee") {
                return ("Sapphire", "3× on dining")
            } else if normalized.contains("grocery") || normalized.contains("grocer") {
                return ("Blue Cash Preferred", "6% groceries")
            } else if normalized.contains("gas") || normalized.contains("fuel") {
                return ("Custom Cash", "5% on gas")
            } else if normalized.contains("travel") || normalized.contains("air") || normalized.contains("hotel") {
                return ("Sapphire Reserve", "Premium travel perks")
            } else {
                return ("Freedom Unlimited", "1.5× everywhere")
            }
        }()
        if let (hint, why) = pick {
            let match = cards.first { $0.productName.localizedCaseInsensitiveContains(hint) }
            return (match, why)
        }
        return (nil, "General rewards")
    }
}


