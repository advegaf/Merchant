
import Foundation

final class MockCardArtProvider: CardArtProvider {
    func fetchCardsForReview() async -> [CardUI] {
        let potentialCards = [
            CardUI(
                institutionId: "chase",
                productName: "Chase Sapphire Preferred",
                last4: "1234",
                artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_preferred_card.png")!,
                isPremium: true,
                network: "Visa"
            ),
            CardUI(
                institutionId: "amex",
                productName: "Platinum Card",
                last4: "5678",
                artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/platinum-card.png")!,
                isPremium: true,
                network: "American Express"
            ),
            CardUI(
                institutionId: "citi",
                productName: "Citi Double Cash",
                last4: "9012",
                artURL: URL(string: "https://www.citi.com/CRD/images/citi-double-cash-card/citi-double-cash-card-art.png")!,
                isPremium: false,
                network: "Mastercard"
            ),
            CardUI(
                institutionId: "discover",
                productName: "Discover it Cash Back",
                last4: "3456",
                artURL: URL(string: "https://www.discover.com/content/dam/discover/en_us/credit-cards/card-acquisitions/cashback-landing/discover-it-cashback-card-art.png")!,
                isPremium: false,
                network: "Discover"
            ),
            CardUI(
                institutionId: "capital_one",
                productName: "Venture X",
                last4: "7890",
                artURL: URL(string: "https://ecm.capitalone.com/WCM/card/products/venture-x-card-art.png")!,
                isPremium: true,
                network: "Visa"
            )
        ]

        try? await Task.sleep(for: .milliseconds(800))

        return await validateCardArt(potentialCards)
    }

    private func validateCardArt(_ cards: [CardUI]) async -> [CardUI] {
        var validCards: [CardUI] = []

        await withTaskGroup(of: (CardUI, Bool).self) { group in
            for card in cards {
                group.addTask {
                    let isValid = await self.isURLValid(card.artURL)
                    return (card, isValid)
                }
            }

            for await (card, isValid) in group {
                if isValid {
                    validCards.append(card)
                }
            }
        }

        return validCards
    }

    private func isURLValid(_ url: URL) async -> Bool {
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}