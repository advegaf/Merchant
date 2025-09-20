// Rules: Static benefits reference for popular cards (concise, high-signal).
// Inputs: Card selection key
// Outputs: Short benefits description for UI
// Constraints: Approximate; label estimated where issuer sync isn’t live

import Foundation

public struct CardBenefitsCatalog {
    public static func benefits(for selectionKey: String) -> String {
        switch selectionKey {
        case _ where selectionKey.contains("Sapphire Preferred"): return "3× dining, 2× travel, primary rental CDW (est.)"
        case _ where selectionKey.contains("Sapphire Reserve"): return "3× dining/travel, Priority Pass, Lyft/Doordash (est.)"
        case _ where selectionKey.contains("Freedom Flex"): return "5% rotating categories, 3% dining/drugstores (est.)"
        case _ where selectionKey.contains("Freedom Unlimited"): return "3% dining/drugstores, 1.5% everywhere (est.)"
        case _ where selectionKey.contains("Platinum Card"): return "Airline lounge access, 5× flights (est.)"
        case _ where selectionKey.contains("Gold Card"): return "4× dining/groceries (est.)"
        case _ where selectionKey.contains("Green Card"): return "3× travel/dining (est.)"
        case _ where selectionKey.contains("Blue Cash Preferred"): return "6% groceries, 3% transit (est.)"
        case _ where selectionKey.contains("Blue Cash Everyday"): return "3% groceries/online/gas (est.)"
        case _ where selectionKey.contains("SavorOne"): return "3% dining/entertainment/grocery (est.)"
        case _ where selectionKey.contains("Savor Cash"): return "4% dining/entertainment (est.)"
        case _ where selectionKey.contains("Venture X"): return "2× everywhere, lounge access (est.)"
        case _ where selectionKey.contains("Venture Rewards"): return "2× everywhere (est.)"
        case _ where selectionKey.contains("Quicksilver"): return "1.5% everywhere (est.)"
        case _ where selectionKey.contains("Citi Premier"): return "3× dining/gas/groceries/airfare/hotels (est.)"
        case _ where selectionKey.contains("Citi Double Cash"): return "2% everywhere (est.)"
        case _ where selectionKey.contains("Citi Custom Cash"): return "5% on top monthly category (est.)"
        case _ where selectionKey.contains("Citi Rewards+"): return "Rounds up points, groceries/gas bonus (est.)"
        case _ where selectionKey.contains("Discover it Cash Back"): return "5% rotating categories (est.)"
        case _ where selectionKey.contains("Discover it Miles"): return "1.5× miles matched first year (est.)"
        case _ where selectionKey.contains("Active Cash"): return "2% everywhere cash back (est.)"
        case _ where selectionKey.contains("Autograph"): return "3× restaurants/travel/gas/phone (est.)"
        default: return "General rewards card (est.)"
        }
    }
}


