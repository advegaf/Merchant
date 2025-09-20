// Rules: Protocol for fetching cards with required art URLs for UI rendering
// Inputs: None (stub data)
// Outputs: Array of CardUI with valid artURL properties
// Constraints: Must provide real https URLs, filter out any with invalid/missing art

import Foundation

protocol CardArtProvider {
    func fetchCardsForReview() async -> [CardUI]
}