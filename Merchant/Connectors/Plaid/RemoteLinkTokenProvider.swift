// Rules: Backend-driven Link token flow; never store Plaid secrets in app.
// Inputs: Server base URL via Info.plist key PLAID_SERVER_BASE_URL
// Outputs: link_token fetch and public_token exchange
// Constraints: Use async/await; redact errors; TLS only

import Foundation

public struct PlaidAPIConfig {
    public static func serverBaseURL() -> URL? {
        if let value = Bundle.main.object(forInfoDictionaryKey: "PLAID_SERVER_BASE_URL") as? String,
           let url = URL(string: value) {
            return url
        }
        return nil
    }
}

public final class RemoteLinkTokenProvider: LinkTokenProviding {
    private let baseURL: URL
    private let session: URLSession

    public init?(baseURL: URL?) {
        guard let baseURL else { return nil }
        self.baseURL = baseURL
        self.session = URLSession(configuration: .ephemeral)
    }

    public func fetchLinkToken() async throws -> String {
        let url = baseURL.appendingPathComponent("plaid/link_token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["clientUserId": UUID().uuidString]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "PlaidAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create link token"])
        }
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let token = obj?["link_token"] as? String
        guard let token else {
            throw NSError(domain: "PlaidAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing link_token"])
        }
        return token
    }

    public func exchange(publicToken: String) async throws {
        let url = baseURL.appendingPathComponent("plaid/exchange_public_token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["public_token": publicToken]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "PlaidAPI", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to exchange public token"])
        }
    }
}


