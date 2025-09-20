// Rules: Persist selected card choices locally; simple, testable, auditable keys.
// Inputs: Card selection keys (institution|productName)
// Outputs: Stored selection and onboarding completion flag
// Constraints: UserDefaults only; no sensitive data

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
    private(set) public var selectedKeys: Set<String> = []

    public var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingKey) }
    }

    public func toggleSelection(for key: String) {
        if selectedKeys.contains(key) { selectedKeys.remove(key) } else { selectedKeys.insert(key) }
        save()
        notifyChanged()
    }

    public func isSelected(_ key: String) -> Bool { selectedKeys.contains(key) }

    public func setSelections(_ keys: Set<String>) {
        selectedKeys = keys
        save()
        notifyChanged()
    }

    public func clear() {
        selectedKeys.removeAll()
        save()
        notifyChanged()
    }

    private func save() {
        UserDefaults.standard.set(Array(selectedKeys), forKey: selectionKey)
    }

    private func load() {
        if let arr = UserDefaults.standard.array(forKey: selectionKey) as? [String] {
            selectedKeys = Set(arr)
        }
    }

    private func notifyChanged() {
        NotificationCenter.default.post(name: .selectedCardsChanged, object: nil)
    }
}

public extension Notification.Name {
    static let selectedCardsChanged = Notification.Name("SelectedCardsChanged")
}

extension CardUI {
    var selectionKey: String { "\(institutionId)|\(productName)" }
}


