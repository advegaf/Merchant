// Rules: Plaid Link coordinator. No secrets; redacted logs; sandbox-first.
// Inputs: link_token from backend, presenting view controller context
// Outputs: public_token on success, or cancellation
// Constraints: Guard LinkKit at compile-time; no UI logic here

import Foundation
import SwiftUI
import UIKit

public enum PlaidLinkOutcome {
    case success(publicToken: String)
    case cancelled
}

public protocol PlaidLinkCoordinating {
    func openLink(using linkToken: String) async throws -> PlaidLinkOutcome
}

public enum PlaidLinkCoordinatorError: Error, LocalizedError {
    case linkKitUnavailable
    case unableToPresent
    case failedToOpen

    public var errorDescription: String? {
        switch self {
        case .linkKitUnavailable: return "Plaid LinkKit is not integrated. Add the SPM package to enable."
        case .unableToPresent: return "Unable to present Plaid Link UI."
        case .failedToOpen: return "Failed to open Plaid Link."
        }
    }
}

public struct DefaultPlaidLinkCoordinator: PlaidLinkCoordinating {
    public init() {}

    public func openLink(using linkToken: String) async throws -> PlaidLinkOutcome {
        #if canImport(LinkKit)
        return try await withCheckedThrowingContinuation { continuation in
            // Create configuration
            let onSuccess: (PLKLinkSuccess?) -> Void = { success in
                let publicToken = success?.publicToken ?? ""
                continuation.resume(returning: .success(publicToken: publicToken))
            }

            let onExit: (PLKLinkExit?) -> Void = { exit in
                if let error = exit?.error {
                    // Redact details
                    continuation.resume(throwing: NSError(domain: "PlaidLink", code: -1, userInfo: [NSLocalizedDescriptionKey: "Link exited: \(error.code.rawValue)"]))
                } else {
                    continuation.resume(returning: .cancelled)
                }
            }

            let linkConfig = PLKLinkTokenConfiguration(token: linkToken, onSuccess: onSuccess)
            linkConfig.onExit = onExit

            guard let linkViewController = PLKPlaidLinkViewController(linkToken: linkToken, onSuccess: onSuccess, onExit: onExit) else {
                continuation.resume(throwing: PlaidLinkCoordinatorError.failedToOpen)
                return
            }

            linkViewController.modalPresentationStyle = .formSheet

            guard let top = DefaultPlaidLinkCoordinator.topViewController() else {
                continuation.resume(throwing: PlaidLinkCoordinatorError.unableToPresent)
                return
            }

            top.present(linkViewController, animated: true)
        }
        #else
        throw PlaidLinkCoordinatorError.linkKitUnavailable
        #endif
    }

    private static func topViewController(base: UIViewController? = DefaultPlaidLinkCoordinator.keyWindow()?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}


