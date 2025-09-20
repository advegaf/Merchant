// Rules: UI contract for card representation, requires valid artURL for rendering
// Inputs: Card data from connectors/providers
// Outputs: Identifiable card model with required art asset
// Constraints: artURL must be valid URL, no placeholders allowed

import Foundation

struct CardUI: Identifiable, Equatable {
    let id: UUID
    let institutionId: String
    let productName: String
    let last4: String
    let artURL: URL
    let isPremium: Bool
    let network: String

    init(id: UUID = UUID(), institutionId: String, productName: String, last4: String, artURL: URL, isPremium: Bool = false, network: String) {
        self.id = id
        self.institutionId = institutionId
        self.productName = productName
        self.last4 = last4
        self.artURL = artURL
        self.isPremium = isPremium
        self.network = network
    }
}