// Reward categories, rates, and simple helpers for computing earnings.

import Foundation

// MARK: - Spending Categories

enum SpendingCategory: String, CaseIterable, Codable {
    case dining = "dining"
    case groceries = "groceries"
    case gas = "gas"
    case travel = "travel"
    case streaming = "streaming"
    case transit = "transit"
    case drugstores = "drugstores"
    case departmentStores = "department_stores"
    case wholesale = "wholesale"
    case everything = "everything"
    case hotels = "hotels"
    case airfare = "airfare"
    case rideshare = "rideshare"
    case coffee = "coffee"
    case restaurants = "restaurants"
    case online = "online"

    var displayName: String {
        switch self {
        case .dining: return "Dining & Restaurants"
        case .groceries: return "Grocery Stores"
        case .gas: return "Gas Stations"
        case .travel: return "Travel"
        case .streaming: return "Streaming Services"
        case .transit: return "Transit"
        case .drugstores: return "Drugstores"
        case .departmentStores: return "Department Stores"
        case .wholesale: return "Wholesale Clubs"
        case .everything: return "Everything Else"
        case .hotels: return "Hotels"
        case .airfare: return "Airfare"
        case .rideshare: return "Rideshare & Taxis"
        case .coffee: return "Coffee Shops"
        case .restaurants: return "Restaurants"
        case .online: return "Online Shopping"
        }
    }

    var icon: String {
        switch self {
        case .dining, .restaurants: return "fork.knife"
        case .groceries: return "cart.fill"
        case .gas: return "fuelpump.fill"
        case .travel: return "airplane"
        case .streaming: return "tv.fill"
        case .transit: return "bus.fill"
        case .drugstores: return "cross.fill"
        case .departmentStores: return "bag.fill"
        case .wholesale: return "building.2.fill"
        case .everything: return "creditcard.fill"
        case .hotels: return "bed.double.fill"
        case .airfare: return "airplane.departure"
        case .rideshare: return "car.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .online: return "globe.americas.fill"
        }
    }

    var color: String {
        switch self {
        case .dining, .restaurants, .coffee: return "brandOrange"
        case .groceries: return "brandGreen"
        case .gas: return "brandBlue"
        case .travel, .hotels, .airfare: return "info"
        case .streaming: return "accent"
        case .transit, .rideshare: return "warning"
        case .drugstores: return "error"
        case .departmentStores, .wholesale: return "success"
        case .everything: return "textTertiary"
        case .online: return "info"
        }
    }
}

// MARK: - Reward Rate Structure

struct RewardRate: Codable {
    let category: SpendingCategory
    let rate: Double // Points per dollar or % cash back
    let isPercentage: Bool // true for cash back, false for points
    let annualCap: Double? // nil for no cap
    let quarterlyLimit: Double? // For rotating categories
    let isRotating: Bool // True for quarterly rotating categories
    let monthlyLimit: Double? // For monthly-capped categories (e.g., Citi Custom Cash)

    init(category: SpendingCategory, rate: Double, isPercentage: Bool = false, annualCap: Double? = nil, quarterlyLimit: Double? = nil, isRotating: Bool = false, monthlyLimit: Double? = nil) {
        self.category = category
        self.rate = rate
        self.isPercentage = isPercentage
        self.annualCap = annualCap
        self.quarterlyLimit = quarterlyLimit
        self.isRotating = isRotating
        self.monthlyLimit = monthlyLimit
    }
}

// MARK: - Enhanced Card Model

struct EnhancedCardModel: Codable, Identifiable {
    var id = UUID()
    let institutionId: String
    let productName: String
    let network: String
    let isPremium: Bool
    let annualFee: Double
    let rewardRates: [RewardRate]
    let baseRate: RewardRate // Default rate for non-bonus categories
    let signupBonus: String?
    let benefits: [String]

    // Calculate potential earnings for a category and amount
    func calculateEarnings(for category: SpendingCategory, amount: Double, spentThisYear: Double = 0, spentThisMonth: Double = 0) -> (points: Double, cashValue: Double, description: String) {
        // Find the best rate for this category
        let applicableRate = rewardRates.first { $0.category == category } ?? baseRate

        var effectiveAmount = amount

        // Check annual cap
        if let cap = applicableRate.annualCap {
            let remainingCap = max(0, cap - spentThisYear)
            effectiveAmount = min(amount, remainingCap)
        }

        // Check quarterly limit for rotating categories
        if let quarterlyLimit = applicableRate.quarterlyLimit {
            effectiveAmount = min(effectiveAmount, quarterlyLimit)
        }

        // Check monthly limit for monthly-capped categories
        if let monthlyLimit = applicableRate.monthlyLimit {
            let remaining = max(0, monthlyLimit - spentThisMonth)
            effectiveAmount = min(effectiveAmount, remaining)
        }

        // Points are treated as units-per-dollar for transferable currencies.
        // For cash back, calculate cash value using percent (rate/100).
        let points = effectiveAmount * applicableRate.rate
        let cashValue = applicableRate.isPercentage ? (effectiveAmount * (applicableRate.rate / 100.0)) : (points * 0.01)

        let description = applicableRate.isPercentage
            ? "\(applicableRate.rate)% cash back"
            : "\(applicableRate.rate)× points"

        return (points: points, cashValue: cashValue, description: description)
    }
}

// MARK: - Card Database

class CardRewardDatabase {
    static let shared = CardRewardDatabase()

    private init() {}

    lazy var cards: [EnhancedCardModel] = [
        // Chase Sapphire Reserve
        EnhancedCardModel(
            institutionId: "chase",
            productName: "Chase Sapphire Reserve",
            network: "Visa",
            isPremium: true,
            annualFee: 550,
            rewardRates: [
                RewardRate(category: .dining, rate: 3.0),
                RewardRate(category: .travel, rate: 3.0),
                RewardRate(category: .hotels, rate: 3.0),
                RewardRate(category: .airfare, rate: 3.0)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0),
            signupBonus: "60,000 points after $4,000 spent",
            benefits: ["Priority Pass", "$300 Travel Credit", "No Foreign Transaction Fees"]
        ),

        // Chase Sapphire Preferred
        EnhancedCardModel(
            institutionId: "chase",
            productName: "Chase Sapphire Preferred",
            network: "Visa",
            isPremium: true,
            annualFee: 95,
            rewardRates: [
                RewardRate(category: .dining, rate: 2.0),
                RewardRate(category: .travel, rate: 2.0),
                RewardRate(category: .streaming, rate: 2.0)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0),
            signupBonus: "60,000 points after $4,000 spent",
            benefits: ["25% More Value on Travel", "No Foreign Transaction Fees"]
        ),

        // Chase Freedom Unlimited
        EnhancedCardModel(
            institutionId: "chase",
            productName: "Chase Freedom Unlimited",
            network: "Visa",
            isPremium: false,
            annualFee: 0,
            rewardRates: [
                RewardRate(category: .dining, rate: 3.0, isPercentage: true),
                RewardRate(category: .drugstores, rate: 3.0, isPercentage: true),
                RewardRate(category: .travel, rate: 5.0, isPercentage: true)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.5, isPercentage: true),
            signupBonus: "$200 after $500 spent",
            benefits: ["No Annual Fee", "Cell Phone Protection"]
        ),

        // Chase Freedom Flex
        EnhancedCardModel(
            institutionId: "chase",
            productName: "Chase Freedom Flex",
            network: "Mastercard",
            isPremium: false,
            annualFee: 0,
            rewardRates: [
                RewardRate(category: .groceries, rate: 5.0, isPercentage: true, quarterlyLimit: 1500, isRotating: true),
                RewardRate(category: .gas, rate: 5.0, isPercentage: true, quarterlyLimit: 1500, isRotating: true),
                RewardRate(category: .dining, rate: 3.0, isPercentage: true),
                RewardRate(category: .drugstores, rate: 3.0, isPercentage: true),
                RewardRate(category: .travel, rate: 5.0, isPercentage: true)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0),
            signupBonus: "$200 after $500 spent",
            benefits: ["5% Rotating Categories", "No Annual Fee"]
        ),

        // Amex Platinum
        EnhancedCardModel(
            institutionId: "amex",
            productName: "The Platinum Card from American Express",
            network: "American Express",
            isPremium: true,
            annualFee: 695,
            rewardRates: [
                RewardRate(category: .airfare, rate: 5.0),
                RewardRate(category: .hotels, rate: 5.0)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0),
            signupBonus: "80,000 points after $6,000 spent",
            benefits: ["Centurion Lounge Access", "$200 Hotel Credit", "$200 Airline Credit"]
        ),

        // Amex Gold
        EnhancedCardModel(
            institutionId: "amex",
            productName: "American Express Gold Card",
            network: "American Express",
            isPremium: true,
            annualFee: 250,
            rewardRates: [
                RewardRate(category: .dining, rate: 4.0),
                RewardRate(category: .groceries, rate: 4.0, annualCap: 25000)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0),
            signupBonus: "60,000 points after $4,000 spent",
            benefits: ["$120 Dining Credit", "$120 Uber Credit"]
        ),

        // Amex Blue Cash Preferred
        EnhancedCardModel(
            institutionId: "amex",
            productName: "Blue Cash Preferred Card from American Express",
            network: "American Express",
            isPremium: false,
            annualFee: 95,
            rewardRates: [
                RewardRate(category: .groceries, rate: 6.0, isPercentage: true, annualCap: 6000),
                RewardRate(category: .streaming, rate: 6.0, isPercentage: true),
                RewardRate(category: .transit, rate: 3.0, isPercentage: true),
                RewardRate(category: .gas, rate: 3.0, isPercentage: true)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0, isPercentage: true),
            signupBonus: "$300 after $3,000 spent",
            benefits: ["6% on Groceries", "6% on Streaming"]
        ),

        // Citi Custom Cash
        EnhancedCardModel(
            institutionId: "citi",
            productName: "Citi Custom Cash Card",
            network: "Mastercard",
            isPremium: false,
            annualFee: 0,
            rewardRates: [
                RewardRate(category: .gas, rate: 5.0, isPercentage: true, monthlyLimit: 500),
                RewardRate(category: .groceries, rate: 5.0, isPercentage: true, monthlyLimit: 500),
                RewardRate(category: .dining, rate: 5.0, isPercentage: true, monthlyLimit: 500),
                RewardRate(category: .drugstores, rate: 5.0, isPercentage: true, monthlyLimit: 500),
                RewardRate(category: .transit, rate: 5.0, isPercentage: true, monthlyLimit: 500)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0, isPercentage: true),
            signupBonus: "$200 after $1,500 spent",
            benefits: ["5% on Top Category", "No Annual Fee"]
        ),

        // Citi Double Cash - 2% everywhere
        EnhancedCardModel(
            institutionId: "citi",
            productName: "Citi Double Cash Card",
            network: "Mastercard",
            isPremium: false,
            annualFee: 0,
            rewardRates: [],
            baseRate: RewardRate(category: .everything, rate: 2.0, isPercentage: true),
            signupBonus: nil,
            benefits: ["Simple 2% cash back on everything"]
        ),

        // Capital One Venture X
        EnhancedCardModel(
            institutionId: "capitalone",
            productName: "Capital One Venture X Rewards",
            network: "Visa",
            isPremium: true,
            annualFee: 395,
            rewardRates: [
                RewardRate(category: .hotels, rate: 10.0),
                RewardRate(category: .airfare, rate: 5.0)
            ],
            baseRate: RewardRate(category: .everything, rate: 2.0),
            signupBonus: "75,000 miles after $4,000 spent",
            benefits: ["Priority Pass", "$300 Annual Travel Credit", "2× on Everything"]
        ),

        // Capital One Venture - 2x miles everywhere
        EnhancedCardModel(
            institutionId: "capitalone",
            productName: "Capital One Venture Rewards",
            network: "Visa",
            isPremium: true,
            annualFee: 95,
            rewardRates: [],
            baseRate: RewardRate(category: .everything, rate: 2.0),
            signupBonus: "75,000 miles after $4,000 spent",
            benefits: ["2× on Everything", "Transfer Partners"]
        ),

        // Capital One Quicksilver - 1.5% everywhere
        EnhancedCardModel(
            institutionId: "capitalone",
            productName: "Capital One Quicksilver Cash Rewards",
            network: "Visa",
            isPremium: false,
            annualFee: 0,
            rewardRates: [],
            baseRate: RewardRate(category: .everything, rate: 1.5, isPercentage: true),
            signupBonus: "$200 after $500 spent",
            benefits: ["No Annual Fee", "1.5% on Everything"]
        ),

        // Capital One SavorOne - 3% dining/entertainment/groceries/streaming
        EnhancedCardModel(
            institutionId: "capitalone",
            productName: "Capital One SavorOne Cash Rewards",
            network: "Mastercard",
            isPremium: false,
            annualFee: 0,
            rewardRates: [
                RewardRate(category: .dining, rate: 3.0, isPercentage: true),
                RewardRate(category: .groceries, rate: 3.0, isPercentage: true),
                RewardRate(category: .streaming, rate: 3.0, isPercentage: true)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0, isPercentage: true),
            signupBonus: "$200 after $500 spent",
            benefits: ["3% Dining & Entertainment", "3% Groceries & Streaming"]
        ),

        // Wells Fargo Active Cash - 2%
        EnhancedCardModel(
            institutionId: "wellsfargo",
            productName: "Wells Fargo Active Cash Card",
            network: "Visa",
            isPremium: false,
            annualFee: 0,
            rewardRates: [],
            baseRate: RewardRate(category: .everything, rate: 2.0, isPercentage: true),
            signupBonus: nil,
            benefits: ["2% Cash Back on Everything"]
        ),

        // Discover it Cash Back - 5% rotating (example categories), 1% base
        EnhancedCardModel(
            institutionId: "discover",
            productName: "Discover it Cash Back",
            network: "Discover",
            isPremium: false,
            annualFee: 0,
            rewardRates: [
                RewardRate(category: .groceries, rate: 5.0, isPercentage: true, quarterlyLimit: 1500, isRotating: true),
                RewardRate(category: .gas, rate: 5.0, isPercentage: true, quarterlyLimit: 1500, isRotating: true)
            ],
            baseRate: RewardRate(category: .everything, rate: 1.0, isPercentage: true),
            signupBonus: nil,
            benefits: ["5% Rotating Categories (activation required)"]
        )
    ]

    func findBestCard(for category: SpendingCategory, amount: Double, availableCards: [String]) -> (card: EnhancedCardModel, earnings: (points: Double, cashValue: Double, description: String))? {
        let filteredCards = cards.filter { availableCards.contains($0.productName) }

        var bestCard: EnhancedCardModel?
        var bestEarnings: (points: Double, cashValue: Double, description: String) = (0, 0, "")

        for card in filteredCards {
            let earnings = card.calculateEarnings(for: category, amount: amount)
            if earnings.cashValue > bestEarnings.cashValue {
                bestCard = card
                bestEarnings = earnings
            }
        }

        guard let card = bestCard else { return nil }
        return (card: card, earnings: bestEarnings)
    }
}

// MARK: - Enhanced Rules Engine

class EnhancedRulesEngine {
    static let shared = EnhancedRulesEngine()
    private let database = CardRewardDatabase.shared

    private init() {}

    func recommendCard(
        for category: SpendingCategory,
        amount: Double,
        userCards: [String],
        spendingHistory: [SpendingCategory: Double] = [:]
    ) -> (card: EnhancedCardModel?, earnings: (points: Double, cashValue: Double, description: String), reason: String) {

        guard !userCards.isEmpty else {
            return (nil, (0, 0, "No cards available"), "Add cards to get recommendations")
        }

        let result = database.findBestCard(for: category, amount: amount, availableCards: userCards)

        guard let bestCard = result?.card, let earnings = result?.earnings else {
            return (nil, (0, 0, "No match"), "No optimal card found")
        }

        let reason = "Earn \(earnings.description) with \(bestCard.productName)"
        return (bestCard, earnings, reason)
    }

    func calculateTotalEarnings(transactions: [(category: SpendingCategory, amount: Double)], userCards: [String]) -> Double {
        var totalEarnings = 0.0

        for transaction in transactions {
            let recommendation = recommendCard(
                for: transaction.category,
                amount: transaction.amount,
                userCards: userCards
            )
            totalEarnings += recommendation.earnings.cashValue
        }

        return totalEarnings
    }

    // Calculate earnings for a specific card name the user actually used
    func earnings(forCardName cardName: String, category: SpendingCategory, amount: Double) -> (points: Double, cashValue: Double, description: String) {
        if let card = database.cards.first(where: { $0.productName == cardName }) {
            return card.calculateEarnings(for: category, amount: amount)
        }
        // Fallback: generic 1x baseline
        let baseline = RewardRate(category: .everything, rate: 1.0)
        let temp = EnhancedCardModel(
            institutionId: "unknown",
            productName: cardName,
            network: "",
            isPremium: false,
            annualFee: 0,
            rewardRates: [],
            baseRate: baseline,
            signupBonus: nil,
            benefits: []
        )
        return temp.calculateEarnings(for: category, amount: amount)
    }

    // Exact reward rate lookup for UI display (avoids string parsing)
    func rewardRate(forCardName cardName: String, category: SpendingCategory) -> (rate: Double, isPercentage: Bool)? {
        guard let card = database.cards.first(where: { $0.productName == cardName }) else { return nil }
        let applicable = card.rewardRates.first { $0.category == category } ?? card.baseRate
        return (applicable.rate, applicable.isPercentage)
    }
}