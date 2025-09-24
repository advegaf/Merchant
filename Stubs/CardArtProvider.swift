
import Foundation

protocol CardArtProvider {
    func fetchCardsForReview() async -> [CardUI]
}