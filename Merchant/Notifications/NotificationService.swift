
import Foundation
import UserNotifications

public struct NotificationAuditEntry: Codable {
    public let id: String
    public let title: String
    public let body: String
    public let date: Date
    public let reason: String
}

public protocol NotificationServicing {
    func requestAuthorization() async -> Bool
    func scheduleSuggestion(title: String, body: String, venueKey: String, reason: String) async
}

public final class NotificationService: NotificationServicing {
    private let center = UNUserNotificationCenter.current()
    private let rateLimitInterval: TimeInterval = 60 * 60 // 1 hour per venue
    private let storageKeyPrefix = "notif_last_venue_"
    private let auditKey = "notif_audit_log"
    private let categoryIdentifier = "MERCHANT_SUGGESTION"
    static let openWalletActionId = "OPEN_WALLET"

    public init() {}

    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            registerCategories()
            return granted
        } catch { return false }
    }

    public func scheduleSuggestion(title: String, body: String, venueKey: String, reason: String) async {
        guard await isAllowed(venueKey: venueKey) else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = categoryIdentifier
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        do {
            try await center.add(request)
            updateLastFire(for: venueKey)
            appendAudit(NotificationAuditEntry(id: request.identifier, title: title, body: body, date: Date(), reason: reason))
        } catch {
            // swallow; local only
        }
    }

    private func registerCategories() {
        let openWallet = UNNotificationAction(
            identifier: Self.openWalletActionId,
            title: "Open Wallet",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [openWallet],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    private func isAllowed(venueKey: String) async -> Bool {
        let last = UserDefaults.standard.double(forKey: storageKeyPrefix + venueKey)
        let now = Date().timeIntervalSince1970
        return last == 0 || (now - last) > rateLimitInterval
    }

    private func updateLastFire(for venueKey: String) {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: storageKeyPrefix + venueKey)
    }

    private func appendAudit(_ entry: NotificationAuditEntry) {
        var log = (try? loadAudit()) ?? []
        log.append(entry)
        if let data = try? JSONEncoder().encode(log) {
            UserDefaults.standard.set(data, forKey: auditKey)
        }
    }

    private func loadAudit() throws -> [NotificationAuditEntry] {
        guard let data = UserDefaults.standard.data(forKey: auditKey) else { return [] }
        return try JSONDecoder().decode([NotificationAuditEntry].self, from: data)
    }
}


