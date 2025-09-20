// Rules: ViewModel orchestrating Plaid Link flow. No secrets here.
// Inputs: Link token provider, Plaid coordinator
// Outputs: Begin flow, report errors
// Constraints: Use async/await; short-lived tokens in Keychain via KeychainStore

import Foundation

public protocol LinkTokenProviding {
    func fetchLinkToken() async throws -> String
    func exchange(publicToken: String) async throws
}

public final class PlaidLinkViewModel {
    public var hasError: Bool = false
    public var errorMessage: String? = nil

    public var linkTokenProvider: LinkTokenProviding?
    public var coordinator: PlaidLinkCoordinating

    public init(linkTokenProvider: LinkTokenProviding? = nil,
                coordinator: PlaidLinkCoordinating = DefaultPlaidLinkCoordinator()) {
        self.linkTokenProvider = linkTokenProvider
        self.coordinator = coordinator
    }

    public func beginLinkFlow() async throws -> Bool {
        guard let provider = linkTokenProvider else {
            self.hasError = true
            self.errorMessage = "Missing LinkTokenProvider. Configure backend endpoint to create link_token."
            return false
        }

        do {
            let linkToken = try await provider.fetchLinkToken()
            let outcome = try await coordinator.openLink(using: linkToken)
            switch outcome {
            case .success(let publicToken):
                try await provider.exchange(publicToken: publicToken)
                return true
            case .cancelled:
                return false
            }
        } catch {
            self.hasError = true
            self.errorMessage = (error as NSError).localizedDescription
            return false
        }
    }
}


