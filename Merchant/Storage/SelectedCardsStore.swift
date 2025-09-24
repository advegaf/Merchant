
import Foundation
import SwiftUI

@Observable
public final class SelectedCardsStore {
    public static let shared = SelectedCardsStore()
    private init() {
        load()
    }

    private let selectionKey = "selected_card_keys_v1"
    private let onboardingKey = "cards_onboarding_completed_v1"
    public static let maxSelectedCards = 5
    private(set) public var selectedKeys: Set<String> = []
    public var hasCompletedOnboarding: Bool = false {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: onboardingKey) }
    }

    public func toggleSelection(for key: String) {
        if selectedKeys.contains(key) {
            selectedKeys.remove(key)
            save()
            notifyChanged()
            return
        }
        guard selectedKeys.count < SelectedCardsStore.maxSelectedCards else {
            // At capacity: ignore addition
            notifyChanged()
            return
        }
        selectedKeys.insert(key)
        save()
        notifyChanged()
    }

    public func isSelected(_ key: String) -> Bool { selectedKeys.contains(key) }

    public func setSelections(_ keys: Set<String>) {
        if keys.count <= SelectedCardsStore.maxSelectedCards {
            selectedKeys = keys
        } else {
            // Clamp to first N deterministically for stability
            let limited = Array(keys).sorted().prefix(SelectedCardsStore.maxSelectedCards)
            selectedKeys = Set(limited)
        }
        save()
        notifyChanged()
    }

    public func clear() {
        selectedKeys.removeAll()
        save()
        notifyChanged()
    }

    public var remainingCapacity: Int { max(0, SelectedCardsStore.maxSelectedCards - selectedKeys.count) }
    public var isAtCapacity: Bool { remainingCapacity == 0 }

    private func save() {
        UserDefaults.standard.set(Array(selectedKeys), forKey: selectionKey)
    }

    private func load() {
        if let arr = UserDefaults.standard.array(forKey: selectionKey) as? [String] {
            let loaded = Set(arr)
            if loaded.count <= SelectedCardsStore.maxSelectedCards {
                selectedKeys = loaded
            } else {
                // Clamp overflowed prior data
                let limited = Array(loaded).sorted().prefix(SelectedCardsStore.maxSelectedCards)
                selectedKeys = Set(limited)
            }
        }
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }

    private func notifyChanged() {
        NotificationCenter.default.post(name: .selectedCardsChanged, object: nil)
    }

    // Convenience: product names derived from stored selection keys "institution|productName"
    public var selectedProductNames: [String] {
        return selectedKeys.compactMap { key in
            let parts = key.split(separator: "|", maxSplits: 1).map(String.init)
            return parts.count == 2 ? parts[1] : nil
        }
    }
}

public extension Notification.Name {
    static let selectedCardsChanged = Notification.Name("SelectedCardsChanged")
}

extension CardUI {
    var selectionKey: String { "\(institutionId)|\(productName)" }
}


