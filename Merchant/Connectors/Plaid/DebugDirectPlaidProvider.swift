// Rules: DEBUG-only provider to create link_token directly with Plaid for personal dev.
// Inputs: Info.plist keys PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV (sandbox/development)
// Outputs: link_token and public_token exchange (NO storing access_token)
// Constraints: Compiles only in DEBUG; do not ship to production.

import Foundation

#if DEBUG
public final class DebugDirectPlaidProvider: LinkTokenProviding {
    private let session = URLSession(configuration: .ephemeral)
    private let env: String
    private let clientId: String
    private let secret: String

    public init?() {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "PLAID_CLIENT_ID") as? String,
              let secret = Bundle.main.object(forInfoDictionaryKey: "PLAID_SECRET") as? String,
              !clientId.isEmpty, !secret.isEmpty else { return nil }
        self.clientId = clientId
        self.secret = secret
        self.env = (Bundle.main.object(forInfoDictionaryKey: "PLAID_ENV") as? String) ?? "sandbox"
    }

    public func fetchLinkToken() async throws -> String {
        let url = URL(string: "https://\(host())/link/token/create")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "client_id": clientId,
            "secret": secret,
            "client_name": "Merchant",
            "language": "en",
            "country_codes": ["US"],
            "user": ["client_user_id": UUID().uuidString],
            "products": ["transactions"]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "PlaidDirect", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create link token"])
        }
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let token = obj?["link_token"] as? String else {
            throw NSError(domain: "PlaidDirect", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing link_token"])
        }
        return token
    }

    public func exchange(publicToken: String) async throws {
        let url = URL(string: "https://\(host())/item/public_token/exchange")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "client_id": clientId,
            "secret": secret,
            "public_token": publicToken
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "PlaidDirect", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to exchange token"])
        }
    }

    private func host() -> String {
        switch env.lowercased() {
        case "development": return "development.plaid.com"
        case "production": return "production.plaid.com"
        default: return "sandbox.plaid.com"
        }
    }
}
#endif


