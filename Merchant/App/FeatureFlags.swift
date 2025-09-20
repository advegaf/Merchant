// Rules: App feature flags holder. No business rules here.
// Inputs: Build configuration
// Outputs: Flags used to gate features
// Constraints: Keep simple; default development-on for PlaidSync

import Foundation

enum FeatureFlags {
    static var PlaidSync: Bool {
        #if DEBUG
        return true
        #else
        return true
        #endif
    }

    static var LocationNotifications: Bool {
        #if DEBUG
        return true
        #else
        return true
        #endif
    }
}


