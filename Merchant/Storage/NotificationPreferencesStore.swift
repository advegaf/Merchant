
import Foundation
import SwiftUI

@Observable
public final class NotificationPreferencesStore {
    public static let shared = NotificationPreferencesStore()
    private init() { load() }

    private let key = "notif_prefs_v1"

    public var enabled: Bool = true
    public var restaurants: Bool = true
    public var coffee: Bool = true
    public var groceries: Bool = true
    public var gas: Bool = true

    public func save() {
        let dict: [String: Any] = [
            "enabled": enabled,
            "restaurants": restaurants,
            "coffee": coffee,
            "groceries": groceries,
            "gas": gas
        ]
        UserDefaults.standard.set(dict, forKey: key)
    }

    private func load() {
        guard let dict = UserDefaults.standard.dictionary(forKey: key) else { return }
        enabled = dict["enabled"] as? Bool ?? true
        restaurants = dict["restaurants"] as? Bool ?? true
        coffee = dict["coffee"] as? Bool ?? true
        groceries = dict["groceries"] as? Bool ?? true
        gas = dict["gas"] as? Bool ?? true
    }
}


