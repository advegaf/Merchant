
import Foundation
import Combine

struct ActivityEntry: Identifiable {
    let id = UUID()
    let merchant: String
    let amount: Double
    let category: SpendingCategory
    let cardUsed: String
    let pointsEarned: Double
    let cashValueEarned: Double
    let timestamp: Date

    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }

    var formattedPoints: String {
        if pointsEarned >= 1000 {
            return String(format: "+%.1fk pts", pointsEarned / 1000)
        } else {
            return String(format: "+%.0f pts", pointsEarned)
        }
    }

    var formattedTime: String {
        let now = Date()
        let interval = now.timeIntervalSince(timestamp)

        if interval < 3600 { // Less than 1 hour
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 { // Less than 1 day
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else { // Days
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

class RecentActivityProvider: ObservableObject {
    @Published var activities: [ActivityEntry] = []
    private var cancellables: Set<AnyCancellable> = []

    init() {
        reloadFromStore()
        NotificationCenter.default.publisher(for: .transactionsChanged)
            .sink { [weak self] _ in self?.reloadFromStore() }
            .store(in: &cancellables)
    }

    private func reloadFromStore() {
        let records = TransactionStore.shared.all()
        activities = records.map { rec in
            let category = SpendingCategory(rawValue: rec.category) ?? .everything
            let cardName = rec.cardUsed ?? ""
            let earnings = EnhancedRulesEngine.shared.earnings(forCardName: cardName, category: category, amount: rec.amount)
            return ActivityEntry(
                merchant: rec.merchant,
                amount: rec.amount,
                category: category,
                cardUsed: cardName,
                pointsEarned: earnings.points,
                cashValueEarned: earnings.cashValue,
                timestamp: rec.date
            )
        }
    }
}