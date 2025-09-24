
import Foundation

enum PrivacyKeys {
    static var hasLocationWhenInUse: Bool {
        Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil
    }
    static var hasLocationAlways: Bool {
        Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil
    }
    static var hasUserNotifications: Bool {
        Bundle.main.object(forInfoDictionaryKey: "NSUserNotificationUsageDescription") != nil || true
    }
}


