// Rules: Simple persisted transaction store. No sensitive data.
// Inputs: User-entered spends
// Outputs: Stored records and change notifications
// Constraints: UserDefaults JSON; minimal schema

import Foundation

public struct TransactionRecord: Identifiable, Codable {
    public let id: UUID
    public let merchant: String
    public let amount: Double
    public let category: String // Use PurchaseCategory.rawValue if available
    public let date: Date

    public init(id: UUID = UUID(), merchant: String, amount: Double, category: String, date: Date = Date()) {
        self.id = id
        self.merchant = merchant
        self.amount = amount
        self.category = category
        self.date = date
    }
}

public final class TransactionStore {
    public static let shared = TransactionStore()
    private init() { load() }

    private let key = "tx_store_v1"
    private(set) public var records: [TransactionRecord] = []

    public func add(_ record: TransactionRecord) {
        records.insert(record, at: 0)
        save()
        notifyChanged()
    }

    public func all() -> [TransactionRecord] { records }

    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        if let arr = try? JSONDecoder().decode([TransactionRecord].self, from: data) {
            records = arr
        }
    }

    private func notifyChanged() {
        NotificationCenter.default.post(name: .transactionsChanged, object: nil)
    }
}

public extension Notification.Name {
    static let transactionsChanged = Notification.Name("TransactionsChanged")
}


