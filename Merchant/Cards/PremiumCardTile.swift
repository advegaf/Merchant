
import SwiftUI

struct PremiumCardTile: View {
	let card: CardUI
	let isTopCard: Bool
	let zIndex: Double
	let namespace: Namespace.ID
	let onSwipeUp: () -> Void
	var onPromote: (() -> Void)? = nil

	@State private var imageLoaded = false
	@State private var artLoadFailed = false
	@State private var dragOffset = CGSize.zero
	@State private var isPressed = false

	var body: some View {
		if !artLoadFailed {
			GeometryReader { geometry in
				ZStack {
					// Official card art with premium styling
					HighQualityAsyncImage(
						url: card.artURL,
						contentMode: .fill,
						cornerRadius: 16
					) {
						// Loading state with clean skeleton
						ZStack {
							CopilotDesign.Colors.surface2

							VStack(spacing: CopilotDesign.Spacing.sm) {
								ProgressView()
									.tint(CopilotDesign.Colors.brandBlue)
									.scaleEffect(0.8)

								Text("Loading...")
									.font(CopilotDesign.Typography.labelSmall)
									.foregroundStyle(CopilotDesign.Colors.textTertiary)
							}
						}
					}
					.clipShape(RoundedRectangle(cornerRadius: 16))
					.onAppear {
						Task { await validateImage() }
					}

					// Remove heavy overlays for full transparency aesthetic

					// Clean minimal overlays
					VStack {
						// Top section - just network indicator
						HStack {
							// Removed PREMIUM badge
							Spacer()

							// Network badge (minimal)
							Text(card.network.uppercased())
								.font(CopilotDesign.Typography.labelSmall)
								.fontWeight(.bold)
								.tracking(0.5)
								.foregroundStyle(.white)
								.padding(.horizontal, CopilotDesign.Spacing.sm)
								.padding(.vertical, 4)
								.background {
									Capsule()
										.fill(.ultraThinMaterial)
								}
						}
						.padding(.horizontal, CopilotDesign.Spacing.sm)
						.padding(.top, CopilotDesign.Spacing.sm)

						Spacer()

						// Bottom section - clean card info
						HStack {
							VStack(alignment: .leading, spacing: CopilotDesign.Spacing.xs) {
								Text(card.productName)
									.font(CopilotDesign.Typography.headlineSmall)
									.fontWeight(.bold)
									.foregroundStyle(.white)
									.lineLimit(2)
									.minimumScaleFactor(0.85)

								Text("•••• \(card.last4)")
									.font(CopilotDesign.Typography.numberSmall)
									.foregroundStyle(.white.opacity(0.9))
							}

							Spacer()

							// Tap hint instead of swipe
							if isTopCard {
								Text("Tap To Rotate")
									.font(.system(size: 10, weight: .semibold))
									.tracking(0.5)
									.foregroundStyle(.white.opacity(0.85))
									.padding(.horizontal, 10)
									.padding(.vertical, 6)
									.background {
										Capsule().fill(.ultraThinMaterial)
									}
							}
						}
					}
					.padding(CopilotDesign.Spacing.lg)
					.opacity(imageLoaded ? 1 : 0)
				}
			}
			.matchedGeometryEffect(id: card.id, in: namespace)
			.aspectRatio(1.586, contentMode: .fit) // Standard credit card ratio
			.scaleEffect(isPressed ? 0.98 : 1.0)
			.offset(dragOffset)
			.animation(CopilotDesign.Animations.quickSpring, value: isPressed)
			.animation(CopilotDesign.Animations.smoothSpring, value: imageLoaded)
		}
	}

	private func validateImage() async {
		// Fast HEAD-like check using a small data fetch; if fails, hide card
		var request = URLRequest(url: card.artURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
		request.httpMethod = "GET"
		do {
			let (data, response) = try await URLSession.shared.data(for: request)
			guard (response as? HTTPURLResponse)?.statusCode == 200 else { artLoadFailed = true; return }
			// Heuristic: PNG signature check for demo reliability
			if data.count >= 8 {
				let pngMagic: [UInt8] = [137,80,78,71,13,10,26,10]
				let prefix = Array(data.prefix(8))
				if prefix.elementsEqual(pngMagic) {
					imageLoaded = true
				} else {
					// If not PNG, still allow other formats for now
					imageLoaded = true
				}
			} else {
				imageLoaded = true
			}
		} catch {
			artLoadFailed = true
		}
	}
}

#Preview {
    @Previewable @Namespace var namespace

    let card = CardUI(
        institutionId: "chase",
        productName: "Chase Sapphire Preferred",
        last4: "1234",
        artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_preferred_card.png")!,
        isPremium: true,
        network: "Visa"
    )

    return ZStack {
        CopilotDesign.Colors.background
            .ignoresSafeArea()

        PremiumCardTile(
            card: card,
            isTopCard: true,
            zIndex: 1,
            namespace: namespace,
            onSwipeUp: {}
        )
        .frame(width: 300, height: 189)
        .padding()
    }
    .preferredColorScheme(.dark)
}