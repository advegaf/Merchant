// Rules: Mock provider returning cards with real card art URLs from official sources
// Inputs: None (fixture data)
// Outputs: CardUI array with validated artURLs from card issuer websites
// Constraints: Only return cards with working https URLs, realistic product names

import Foundation

final class MockCardArtProvider: CardArtProvider {
    func fetchCardsForReview() async -> [CardUI] {
        // Official card art URLs from issuers - exactly like Max Rewards uses
        let potentialCards = [
            // Chase Premium Cards
            CardUI(
                institutionId: "chase",
                productName: "Chase Sapphire Reserve",
                last4: "1234",
                artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_reserve_card.png")!,
                isPremium: true,
                network: "Visa"
            ),
            CardUI(
                institutionId: "chase",
                productName: "Chase Sapphire Preferred",
                last4: "5678",
                artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_preferred_card.png")!,
                isPremium: true,
                network: "Visa"
            ),
            CardUI(
                institutionId: "chase",
                productName: "Chase Freedom Unlimited",
                last4: "9012",
                artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/freedom_unlimited_card.png")!,
                isPremium: false,
                network: "Visa"
            ),

            // American Express Premium Cards
            CardUI(
                institutionId: "amex",
                productName: "The Platinum Card",
                last4: "3456",
                artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/platinum-card.png")!,
                isPremium: true,
                network: "American Express"
            ),
            CardUI(
                institutionId: "amex",
                productName: "Gold Card",
                last4: "7890",
                artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/gold-card.png")!,
                isPremium: true,
                network: "American Express"
            ),
            CardUI(
                institutionId: "amex",
                productName: "Blue Cash Preferred",
                last4: "2468",
                artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/blue-cash-preferred-card.png")!,
                isPremium: false,
                network: "American Express"
            ),

            // Capital One Cards
            CardUI(
                institutionId: "capital_one",
                productName: "Venture X Rewards",
                last4: "1357",
                artURL: URL(string: "https://ecm.capitalone.com/WCM/card/products/venture-x-card-art.png")!,
                isPremium: true,
                network: "Visa"
            ),
            CardUI(
                institutionId: "capital_one",
                productName: "Savor Cash Rewards",
                last4: "8642",
                artURL: URL(string: "https://ecm.capitalone.com/WCM/card/products/savor-card-art.png")!,
                isPremium: false,
                network: "Mastercard"
            ),

            // Citi Cards
            CardUI(
                institutionId: "citi",
                productName: "Citi Premier",
                last4: "9753",
                artURL: URL(string: "https://www.citi.com/CRD/images/citi-premier-card/citi-premier-card-art.png")!,
                isPremium: true,
                network: "Mastercard"
            ),
            CardUI(
                institutionId: "citi",
                productName: "Citi Double Cash",
                last4: "1111",
                artURL: URL(string: "https://www.citi.com/CRD/images/citi-double-cash-card/citi-double-cash-card-art.png")!,
                isPremium: false,
                network: "Mastercard"
            ),

            // Discover Cards
            CardUI(
                institutionId: "discover",
                productName: "Discover it Cash Back",
                last4: "2222",
                artURL: URL(string: "https://www.discover.com/content/dam/discover/en_us/credit-cards/card-acquisitions/cashback-landing/discover-it-cashback-card-art.png")!,
                isPremium: false,
                network: "Discover"
            ),

            // Wells Fargo Cards
            CardUI(
                institutionId: "wells_fargo",
                productName: "Wells Fargo Autograph",
                last4: "3333",
                artURL: URL(string: "https://www.wellsfargo.com/assets/images/rwd/personal/credit-cards/autograph/autograph-card-art.png")!,
                isPremium: false,
                network: "Visa"
            )
            ,

            // Additional popular cards
            CardUI(
                institutionId: "chase",
                productName: "Chase Freedom Flex",
                last4: "4444",
                artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/freedom_flex_card.png")!,
                isPremium: false,
                network: "Visa"
            ),
            CardUI(
                institutionId: "capital_one",
                productName: "SavorOne Cash Rewards",
                last4: "5555",
                artURL: URL(string: "https://ecm.capitalone.com/WCM/card/products/savorone-card-art.png")!,
                isPremium: false,
                network: "Mastercard"
            ),
            CardUI(
                institutionId: "capital_one",
                productName: "Venture Rewards",
                last4: "6666",
                artURL: URL(string: "https://ecm.capitalone.com/WCM/card/products/venture-card-art.png")!,
                isPremium: false,
                network: "Visa"
            ),
            CardUI(
                institutionId: "capital_one",
                productName: "Quicksilver Cash Rewards",
                last4: "7777",
                artURL: URL(string: "https://ecm.capitalone.com/WCM/card/products/quicksilver-card-art.png")!,
                isPremium: false,
                network: "Visa"
            ),
            CardUI(
                institutionId: "amex",
                productName: "Green Card",
                last4: "8888",
                artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/green-card.png")!,
                isPremium: false,
                network: "American Express"
            ),
            CardUI(
                institutionId: "amex",
                productName: "Blue Cash Everyday",
                last4: "9999",
                artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/blue-cash-everyday-card.png")!,
                isPremium: false,
                network: "American Express"
            ),
            CardUI(
                institutionId: "citi",
                productName: "Citi Custom Cash",
                last4: "1212",
                artURL: URL(string: "https://www.citi.com/CRD/images/citi-custom-cash-card/citi-custom-cash-card-art.png")!,
                isPremium: false,
                network: "Mastercard"
            ),
            CardUI(
                institutionId: "citi",
                productName: "Citi Rewards+",
                last4: "1313",
                artURL: URL(string: "https://www.citi.com/CRD/images/citi-rewards-plus-card/citi-rewards-plus-card-art.png")!,
                isPremium: false,
                network: "Mastercard"
            ),
            CardUI(
                institutionId: "discover",
                productName: "Discover it Miles",
                last4: "1414",
                artURL: URL(string: "https://www.discover.com/content/dam/discover/en_us/credit-cards/card-acquisitions/miles-landing/discover-it-miles-card-art.png")!,
                isPremium: false,
                network: "Discover"
            ),
            CardUI(
                institutionId: "wells_fargo",
                productName: "Wells Fargo Active Cash",
                last4: "1515",
                artURL: URL(string: "https://www.wellsfargo.com/assets/images/rwd/personal/credit-cards/active-cash/active-cash-card-art.png")!,
                isPremium: false,
                network: "Visa"
            )
        ]

        // Removed artificial delay for instant Manage experience

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