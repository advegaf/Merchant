// Registry of official card art URLs by issuer and product; exact matches only.

import Foundation

struct VerifiedCardArtRegistry {
	// Whitelisted issuer hosts for official art
	static let allowedHosts: Set<String> = [
		"creditcards.chase.com",
		"icm.aexp-static.com",
		"ecm.capitalone.com",
		"www.citi.com",
		"aemapi.citi.com",
		"www.discover.com",
		"www.wellsfargo.com",
		"www.bankofamerica.com",
		"www.usbank.com"
	]

	// Exact-match map: "institutionId|productName" -> URL string
	private static let exactArtMap: [String: String] = [
		// Chase
		// Updated to official content/dam path provided
		"chase|Chase Sapphire Preferred": "https://creditcards.chase.com/content/dam/jpmc-marketplace/card-art/sapphire_preferred_card.png",
		"chase|Chase Sapphire Reserve": "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_reserve_card.png",
		"chase|Chase Freedom Unlimited": "https://creditcards.chase.com/K-Marketplace/images/cardart/freedom_unlimited_card.png",
		"chase|Chase Freedom Flex": "https://creditcards.chase.com/K-Marketplace/images/cardart/freedom_flex_card.png",

		// American Express
		"amex|The Platinum Card from American Express": "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/platinum-card.png",
		"amex|American Express Gold Card": "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/gold-card.png",
		"amex|Blue Cash Preferred Card from American Express": "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/blue-cash-preferred.png",
		"amex|Blue Cash Everyday Card from American Express": "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/blue-cash-everyday.png",

		// Capital One (updated to provided product paths)
		"capitalone|Capital One Venture X Rewards": "https://ecm.capitalone.com/WCM/card/products/venture-x-card-art.png",
		"capitalone|Capital One Venture Rewards": "https://ecm.capitalone.com/WCM/card-art/venture-card@2x.png",
		"capitalone|Capital One VentureOne Rewards": "https://ecm.capitalone.com/WCM/card-art/ventureone-card@2x.png",
		"capitalone|Capital One Savor Cash Rewards": "https://ecm.capitalone.com/WCM/card/products/new-savor-card-art.png",
		"capitalone|Capital One SavorOne Cash Rewards": "https://ecm.capitalone.com/WCM/card/products/savorone-card-art@2x.png",
		"capitalone|Capital One Quicksilver Cash Rewards": "https://ecm.capitalone.com/WCM/card/products/quicksilver_cardart.png",
		"capitalone|Capital One QuicksilverOne Cash Rewards": "https://ecm.capitalone.com/WCM/card/products/quicksilverone-card-art@2x.png",
		"capitalone|Capital One Journey Student Rewards": "https://ecm.capitalone.com/WCM/card/products/journey-card-art@2x.png",
		"capitalone|Capital One Spark Cash Plus (Business)": "https://ecm.capitalone.com/WCM/card/products/spark-cash-plus-card-art@2x.png",
		"capitalone|Capital One Spark Miles (Business)": "https://ecm.capitalone.com/WCM/card/products/spark-miles-card-art@2x.png",
		"capitalone|Capital One Walmart Rewards": "https://ecm.capitalone.com/WCM/card/products/walmart-rewards-card-art@2x.png",
		"capitalone|Capital One GM Rewards": "https://ecm.capitalone.com/WCM/card/products/gm-rewards-card-art@2x.png",

		// Citi (accept official .webp asset host)
		"citi|Citi Double Cash Card": "https://aemapi.citi.com/content/dam/cfs/uspb/usmkt/cards/en/static/images/citi-double-cash-credit-card/citi-double-cash-credit-card_306x192.webp",
		"citi|Citi Premier Card": "https://www.citi.com/CRD/images/card-art/citi-premier-card.png",
		"citi|Citi Custom Cash Card": "https://www.citi.com/CRD/images/card-art/citi-custom-cash-card.png",

		// Discover
		"discover|Discover it Cash Back": "https://www.discover.com/credit-cards/images/cardart/discover-it-cash-back.png",

		// Wells Fargo
		"wellsfargo|Wells Fargo Active Cash Card": "https://www.wellsfargo.com/assets/images/credit-cards/active-cash-card.png",
		"wellsfargo|Wells Fargo Autograph Card": "https://www.wellsfargo.com/assets/images/credit-cards/autograph-card.png",

		// Bank of America
		"bankofamerica|Bank of America Premium Rewards": "https://www.bankofamerica.com/content/images/ContextualSiteGraphics/CreditCardArt/en_US/Approved/CCSG_premium_rewards_card_v1.png",

		// U.S. Bank
		"usbank|U.S. Bank Altitude Go Visa": "https://www.usbank.com/content/dam/usb-consumer/credit-cards/altitude-go/altitude-go-card-art.png"
	]

	static func exactURL(institutionId: String, productName: String) -> URL? {
		let key = "\(institutionId)|\(productName)"
		guard let urlString = exactArtMap[key], let url = URL(string: urlString) else { return nil }
		guard let host = url.host, allowedHosts.contains(host) else { return nil }
		guard url.scheme == "https" else { return nil }
		return url
	}
}
