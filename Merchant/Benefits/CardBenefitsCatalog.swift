// Rules: Static benefits reference for popular cards (concise, high-signal).
// Inputs: Card selection key
// Outputs: Short benefits description for UI
// Constraints: Approximate; label estimated where issuer sync isn’t live

import Foundation

public struct CardBenefits {
    public let multipliers: [String: Double] // category key -> multiplier (e.g., "dining": 3.0)
    public let perks: [String]
    public let isEstimated: Bool

    public func multiplier(for categoryKey: String) -> Double {
        multipliers[categoryKey] ?? multipliers["everything"] ?? 1.0
    }
}

public struct CardBenefitsCatalog {
    // Canonicalized category keys used across the app
    // dining, coffee, groceries, gas, travel, drugstores, transit, entertainment, streaming, online, everything

    public static func details(for selectionKey: String) -> CardBenefits {
        // Chase
        if selectionKey.contains("Sapphire Preferred") {
            return CardBenefits(
                multipliers: [
                    "dining": 3,
                    "travel": 2,
                    "streaming": 2,
                    "online": 2,
                    "everything": 1
                ],
                perks: ["Primary rental CDW", "Transfer partners"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Sapphire Reserve") {
            return CardBenefits(
                multipliers: [
                    "dining": 3,
                    "travel": 3,
                    "everything": 1
                ],
                perks: ["Priority Pass", "Travel protections"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Freedom Unlimited") {
            return CardBenefits(
                multipliers: [
                    "travel": 5,
                    "dining": 3,
                    "drugstores": 3,
                    "everything": 1.5
                ],
                perks: ["No annual fee"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Freedom Flex") {
            return CardBenefits(
                multipliers: [
                    "rotating": 5,
                    "travel": 5,
                    "dining": 3,
                    "drugstores": 3,
                    "everything": 1
                ],
                perks: ["Quarterly rotating categories"],
                isEstimated: false
            )
        }

        // Amex
        if selectionKey.contains("Platinum Card") {
            return CardBenefits(
                multipliers: [
                    "flights": 5,
                    "travel": 5, // flights booked direct/amex travel
                    "everything": 1
                ],
                perks: ["Centurion Lounge", "Fine Hotels & Resorts"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Gold Card") {
            return CardBenefits(
                multipliers: [
                    "dining": 4,
                    "groceries": 4,
                    "everything": 1
                ],
                perks: ["Monthly dining credit"],
                isEstimated: false
            )
        }

        // Citi
        if selectionKey.contains("Double Cash") {
            return CardBenefits(
                multipliers: [
                    "everything": 2
                ],
                perks: ["No annual fee"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Custom Cash") {
            return CardBenefits(
                multipliers: [
                    "top": 5,
                    "groceries": 5,
                    "dining": 5,
                    "gas": 5,
                    "transit": 5,
                    "drugstores": 5,
                    "everything": 1
                ],
                perks: ["5% on top monthly category up to cap"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Premier") {
            return CardBenefits(
                multipliers: [
                    "dining": 3,
                    "groceries": 3,
                    "gas": 3,
                    "airfare": 3,
                    "hotels": 3,
                    "travel": 3,
                    "everything": 1
                ],
                perks: ["Transfer partners"],
                isEstimated: false
            )
        }

        // Discover
        if selectionKey.contains("Discover it Cash Back") {
            return CardBenefits(
                multipliers: [
                    "rotating": 5,
                    "everything": 1
                ],
                perks: ["First year Cashback Match"],
                isEstimated: false
            )
        }

        // Capital One
        if selectionKey.contains("SavorOne") {
            return CardBenefits(
                multipliers: [
                    "dining": 3,
                    "entertainment": 3,
                    "groceries": 3,
                    "everything": 1
                ],
                perks: ["No annual fee"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Savor") && !selectionKey.contains("SavorOne") {
            return CardBenefits(
                multipliers: [
                    "dining": 4,
                    "entertainment": 4,
                    "groceries": 3,
                    "everything": 1
                ],
                perks: ["Entertainment partner perks"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Venture X") {
            return CardBenefits(
                multipliers: [
                    "hotels": 10,
                    "airfare": 5,
                    "travel": 5,
                    "everything": 2
                ],
                perks: ["Lounge access", "$300 travel credit"],
                isEstimated: false
            )
        }
        if selectionKey.contains("VentureOne") {
            return CardBenefits(
                multipliers: [
                    "everything": 1.25
                ],
                perks: ["No annual fee"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Venture") {
            return CardBenefits(
                multipliers: [
                    "everything": 2
                ],
                perks: ["Miles transfer partners"],
                isEstimated: false
            )
        }
        if selectionKey.contains("QuicksilverOne") {
            return CardBenefits(
                multipliers: [
                    "everything": 1.5
                ],
                perks: ["No foreign transaction fees"],
                isEstimated: false
            )
        }
        if selectionKey.contains("Quicksilver") {
            return CardBenefits(
                multipliers: [
                    "everything": 1.5
                ],
                perks: ["No annual fee"],
                isEstimated: false
            )
        }

        // Default generic card
        return CardBenefits(
            multipliers: ["everything": 1],
            perks: [],
            isEstimated: true
        )
    }

    public static func benefits(for selectionKey: String) -> String {
        let d = details(for: selectionKey)
        // Compose a short line highlighting strongest categories
        let top = d.multipliers
            .filter { $0.key != "coffee" }
            .sorted { $0.value > $1.value }
            .prefix(3)
        let parts = top.map { key, mult in
            let label = humanLabel(for: key)
            return String(format: "%.0f× %@", mult, label)
        }
        let suffix = d.isEstimated ? " (est.)" : ""
        return parts.joined(separator: ", ") + suffix
    }

    private static func humanLabel(for key: String) -> String {
        switch key {
        case "everything": return "everywhere"
        case "drugstores": return "drugstores"
        case "entertainment": return "entertainment"
        case "groceries": return "groceries"
        case "gas": return "gas"
        case "transit": return "transit"
        case "streaming": return "streaming"
        case "online": return "online"
        case "dining", "restaurants": return "dining"
        case "coffee": return "coffee"
        case "travel": return "travel"
        case "flights": return "flights"
        case "hotels": return "hotels"
        case "airfare": return "airfare"
        case "rotating": return "rotating"
        case "top": return "top monthly category"
        default: return key
        }
    }
}


