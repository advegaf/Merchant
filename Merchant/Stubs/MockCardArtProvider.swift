// Mock provider that returns sample cards using official issuer art URLs.

import Foundation

final class MockCardArtProvider: CardArtProvider {
	func fetchCardsForReview() async -> [CardUI] {
		// Top 20 Most Popular Credit Cards in Current Market 2024-2025
		let potentialCards = [
			// 1. Chase Sapphire Reserve - Premium Travel Card
			CardUI(
				institutionId: "chase",
				productName: "Chase Sapphire Reserve",
				last4: "1234",
				artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_reserve_card.png")!,
				isPremium: true,
				network: "Visa"
			),
			// 2. Chase Sapphire Preferred - Popular Travel Card
			CardUI(
				institutionId: "chase",
				productName: "Chase Sapphire Preferred",
				last4: "5678",
				artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_preferred_card.png")!,
				isPremium: true,
				network: "Visa"
			),
			// 3. American Express Platinum - Luxury Premium Card
			CardUI(
				institutionId: "amex",
				productName: "The Platinum Card from American Express",
				last4: "1111",
				artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/platinum-card.png")!,
				isPremium: true,
				network: "American Express"
			),
			// 4. Capital One Venture X - Top Rewards Card
			CardUI(
				institutionId: "capitalone",
				productName: "Capital One Venture X Rewards",
				last4: "9999",
				artURL: URL(string: "https://ecm.capitalone.com/WCM/card-art/venture-x-card@2x.png")!,
				isPremium: true,
				network: "Visa"
			),
			// 5. Chase Freedom Unlimited - Popular Cash Back
			CardUI(
				institutionId: "chase",
				productName: "Chase Freedom Unlimited",
				last4: "9012",
				artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/freedom_unlimited_card.png")!,
				isPremium: false,
				network: "Visa"
			),
			// 6. American Express Gold Card - Dining & Groceries
			CardUI(
				institutionId: "amex",
				productName: "American Express Gold Card",
				last4: "2222",
				artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/gold-card.png")!,
				isPremium: true,
				network: "American Express"
			),
			// 7. Chase Freedom Flex - Rotating Categories
			CardUI(
				institutionId: "chase",
				productName: "Chase Freedom Flex",
				last4: "3456",
				artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/freedom_flex_card.png")!,
				isPremium: false,
				network: "Mastercard"
			),
			// 8. Citi Double Cash - Simple Cash Back
			CardUI(
				institutionId: "citi",
				productName: "Citi Double Cash Card",
				last4: "7777",
				artURL: URL(string: "https://www.citi.com/CRD/images/card-art/citi-double-cash-card.png")!,
				isPremium: false,
				network: "Mastercard"
			),
			// 9. Capital One SavorOne - Dining & Entertainment
			CardUI(
				institutionId: "capitalone",
				productName: "Capital One SavorOne Cash Rewards",
				last4: "5555",
				artURL: URL(string: "https://ecm.capitalone.com/WCM/card/products/savorone-card-art@2x.png")!,
				isPremium: false,
				network: "Mastercard"
			),
			// 10. Wells Fargo Active Cash - 2% Everything
			CardUI(
				institutionId: "wellsfargo",
				productName: "Wells Fargo Active Cash Card",
				last4: "4455",
				artURL: URL(string: "https://www.wellsfargo.com/assets/images/credit-cards/active-cash-card.png")!,
				isPremium: false,
				network: "Visa"
			),
			// 11. Discover it Cash Back - Rotating 5%
			CardUI(
				institutionId: "discover",
				productName: "Discover it Cash Back",
				last4: "2233",
				artURL: URL(string: "https://www.discover.com/credit-cards/images/cardart/discover-it-cash-back.png")!,
				isPremium: false,
				network: "Discover"
			),
			// 12. Citi Premier - Travel & Points
			CardUI(
				institutionId: "citi",
				productName: "Citi Premier Card",
				last4: "8888",
				artURL: URL(string: "https://www.citi.com/CRD/images/card-art/citi-premier-card.png")!,
				isPremium: true,
				network: "Mastercard"
			),
			// 13. American Express Blue Cash Preferred - Groceries
			CardUI(
				institutionId: "amex",
				productName: "Blue Cash Preferred Card from American Express",
				last4: "3333",
				artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/blue-cash-preferred.png")!,
				isPremium: false,
				network: "American Express"
			),
			// 14. Capital One Venture - Travel Miles
			CardUI(
				institutionId: "capitalone",
				productName: "Capital One Venture Rewards",
				last4: "0000",
				artURL: URL(string: "https://ecm.capitalone.com/WCM/card-art/venture-card@2x.png")!,
				isPremium: true,
				network: "Visa"
			),
			// 15. Citi Custom Cash - 5% Categories
			CardUI(
				institutionId: "citi",
				productName: "Citi Custom Cash Card",
				last4: "6666",
				artURL: URL(string: "https://www.citi.com/CRD/images/card-art/citi-custom-cash-card.png")!,
				isPremium: false,
				network: "Mastercard"
			),
			// 16. Bank of America Premium Rewards - Travel
			CardUI(
				institutionId: "bankofamerica",
				productName: "Bank of America Premium Rewards",
				last4: "8642",
				artURL: URL(string: "https://www.bankofamerica.com/content/images/ContextualSiteGraphics/CreditCardArt/en_US/Approved/CCSG_premium_rewards_card_v1.png")!,
				isPremium: true,
				network: "Visa"
			),
			// 17. Wells Fargo Autograph - Cell Phones & Streaming
			CardUI(
				institutionId: "wellsfargo",
				productName: "Wells Fargo Autograph Card",
				last4: "5566",
				artURL: URL(string: "https://www.wellsfargo.com/assets/images/credit-cards/autograph-card.png")!,
				isPremium: false,
				network: "Visa"
			),
			// 18. US Bank Altitude Go - Dining & Streaming
			CardUI(
				institutionId: "usbank",
				productName: "U.S. Bank Altitude Go Visa",
				last4: "9753",
				artURL: URL(string: "https://www.usbank.com/content/dam/usb-consumer/credit-cards/altitude-go/altitude-go-card-art.png")!,
				isPremium: false,
				network: "Visa"
			),
			// 19. American Express Blue Cash Everyday - No Annual Fee
			CardUI(
				institutionId: "amex",
				productName: "Blue Cash Everyday Card from American Express",
				last4: "4444",
				artURL: URL(string: "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/blue-cash-everyday.png")!,
				isPremium: false,
				network: "American Express"
			),
			// 20. Capital One Quicksilver - Simple 1.5% Cash Back
			CardUI(
				institutionId: "capitalone",
				productName: "Capital One Quicksilver Cash Rewards",
				last4: "7777",
				artURL: URL(string: "https://ecm.capitalone.com/WCM/card/products/quicksilver-card-art@2x.png")!,
				isPremium: false,
				network: "Visa"
			)
		]

		// Strict exact-match filter against verified registry; drop anything not exactly matched/whitelisted
		let verified: [CardUI] = potentialCards.compactMap { card in
			guard let url = VerifiedCardArtRegistry.exactURL(institutionId: card.institutionId, productName: card.productName) else { return nil }
			return CardUI(
				institutionId: card.institutionId,
				productName: card.productName,
				last4: card.last4,
				artURL: url,
				isPremium: card.isPremium,
				network: card.network
			)
		}

		if FeatureFlags.DemoPerformanceMode {
			// Optionally perform a fast validation to ensure demo images load
			let limited = Array(verified.prefix(12))
			let validated = await fastValidate(limited)
			return validated
		}

		return verified
	}

	private func fastValidate(_ cards: [CardUI]) async -> [CardUI] {
		await withTaskGroup(of: CardUI?.self) { group in
			for card in cards {
				group.addTask {
					var request = URLRequest(url: card.artURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
					request.httpMethod = "GET"
					do {
						let (data, response) = try await URLSession.shared.data(for: request)
						guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
						// Prefer PNGs but accept any image successfully fetched
						if data.count >= 8 {
							let pngMagic: [UInt8] = [137,80,78,71,13,10,26,10]
							let prefix = Array(data.prefix(8))
							_ = prefix.elementsEqual(pngMagic)
						}
						return card
					} catch {
						return nil
					}
				}
			}
			var result: [CardUI] = []
			for await validated in group { if let c = validated { result.append(c) } }
			return result
		}
	}
}