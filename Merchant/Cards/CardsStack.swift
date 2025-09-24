// Interactive card stack with gestures and animations for browsing cards.

import SwiftUI

struct CardsStack: View {
	let cards: [CardUI]
	@State private var focusIndex = 0
	@State private var dragOffset = CGSize.zero
	@State private var selectedCard: CardUI?
	@State private var isDragging = false
	@State private var gestureVelocity = CGSize.zero
	@State private var isAnticipating = false
	@State private var cardRotations: [Int: Double] = [:]
	@State private var cardScales: [Int: CGFloat] = [:]
	@State private var sparkleParticles: [ParticleEffects.SparkleParticle] = []
	@State private var showSparkles = false

	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@Namespace private var cardNamespace

	private var demoOptimizedCards: [CardUI] {
		if FeatureFlags.DemoPerformanceMode {
			// Render at most 8 cards and rely on verified URLs when available
			let limited = Array(cards.prefix(8))
			return limited
		}
		return cards
	}

	var body: some View {
		ZStack {
			// Sparkle particle effects
			if showSparkles && !FeatureFlags.DemoPerformanceMode {
				ForEach(sparkleParticles) { particle in
					Image(systemName: "sparkle")
						.font(.caption2)
						.foregroundStyle(ModernColors.reward)
						.offset(
							x: particle.endX - particle.startX,
							y: particle.endY - particle.startY
						)
						.rotationEffect(.degrees(particle.rotation))
						.scaleEffect(particle.scale)
						.opacity(showSparkles ? 0 : 1)
						.animation(
							CinematicSprings.playful.delay(particle.delay),
							value: showSparkles
						)
				}
			}

			ForEach(Array(demoOptimizedCards.enumerated()), id: \.element.id) { index, card in
				let isTopCard = index == focusIndex
				let cardScale = enhancedScale(for: index)
				let cardYOffset = enhancedYOffset(for: index)
				let cardXOffset = enhancedXOffset(for: index)
				let _ = enhancedRotation(for: index)
				let cardOpacity = enhancedOpacity(for: index)
				let cardZIndex = Double(demoOptimizedCards.count - index)

				CardTile(
					card: card,
					isTopCard: isTopCard,
					zIndex: cardZIndex,
					namespace: cardNamespace
				)
				.scaleEffect(cardScale)
				.offset(x: cardXOffset, y: cardYOffset)
				// Straight stack: remove 3D tilt
				.rotation3DEffect(.degrees(0), axis: (x: 0, y: 0, z: 0))
				.opacity(cardOpacity)
				.animation(
					index == focusIndex ? CinematicSprings.elegant : CinematicSprings.ambient,
					value: focusIndex
				)
				.animation(CinematicSprings.immediate, value: isDragging)
				.animation(CinematicSprings.immediate, value: isAnticipating)
				.shadow(
					color: .black.opacity(isTopCard ? 0.5 : 0.2),
					radius: isTopCard ? 24 : 12,
					x: cardXOffset * 0.1,
					y: isTopCard ? 16 : 6
				)
				.physicsAware(id: card.id)
				.cinematicEntrance(.scaleBlur)
				.onTapGesture { handleAdvancedCardTap(index: index, card: card) }
				.gesture(createAdvancedDragGesture(for: index))
			}
		}
		.fullScreenCover(item: $selectedCard) { card in
			CardHeroDetail(card: card, namespace: cardNamespace) { selectedCard = nil }
			.cinematicEntrance(.flipFromBottom)
		}
		.onAppear { initializeCardAnimations() }
	}

	// MARK: - Advanced Interaction Handlers

	private func handleAdvancedCardTap(index: Int, card: CardUI) {
		if index == focusIndex {
			withAnimation(CinematicSprings.immediate) {
				isAnticipating = true
				cardScales[index] = 0.98
			}

			if card.isPremium && !FeatureFlags.DemoPerformanceMode {
				triggerSparkleEffect(at: index)
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				withAnimation(CinematicSprings.dramatic) {
					self.selectedCard = card
					self.isAnticipating = false
					self.cardScales[index] = 1.0
				}
			}

			CinematicHaptics.play(.impact(intensity: 0.5))
		} else {
			withAnimation(CinematicSprings.elegant) { focusIndex = index }

			if !FeatureFlags.DemoPerformanceMode {
				for i in 0..<demoOptimizedCards.count {
					let delay = TimeInterval(abs(i - index)) * 0.05
					DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
						withAnimation(CinematicSprings.ambient) {
							cardRotations[i] = (i == index) ? 0 : Double(2 * (i < index ? -1 : 1))
						}
					}
				}
			}

			CinematicHaptics.play(.selection)
		}
	}

	private func createAdvancedDragGesture(for index: Int) -> some Gesture {
		DragGesture(minimumDistance: 5)
			.onChanged { value in
				if index == focusIndex {
					dragOffset = value.translation
					gestureVelocity = value.velocity
					isDragging = true

					let progress = min(abs(value.translation.width) / 120, 1.0)
					let _ = Float(progress)

					cardRotations[index] = Double(value.translation.width * 0.03)
					cardScales[index] = 1.0 + (progress * 0.03)

					for i in 0..<demoOptimizedCards.count where i != index {
						let distance = abs(i - index)
						let parallaxFactor = 1.0 / Double(distance + 1)
						cardRotations[i] = Double(value.translation.width * 0.01 * parallaxFactor)
					}
				}
			}
			.onEnded { value in
				if index == focusIndex {
					handleAdvancedDragEnd(value.translation, velocity: value.velocity)
					if value.translation.height < -100 { handleAdvancedCardTap(index: index, card: demoOptimizedCards[index]) }
				} else if value.translation.height < -100 {
					withAnimation(CinematicSprings.elegant) { focusIndex = index }
					CinematicHaptics.play(.selection)
				}
			}
	}

	private func handleAdvancedDragEnd(_ translation: CGSize, velocity: CGSize) {
		let threshold: CGFloat = 50
		let velocityThreshold: CGFloat = 250

		let momentumDistance = velocity.width * 0.001
		let totalDistance = translation.width + momentumDistance
		let shouldSwipe = abs(translation.width) > threshold || abs(velocity.width) > velocityThreshold

		if shouldSwipe {
			if (totalDistance > 0) && focusIndex > 0 {
				withAnimation(CinematicCurves.overshoot) { focusIndex -= 1 }
				CinematicHaptics.play(.confident)
				if !FeatureFlags.DemoPerformanceMode { triggerCardChangeEffect(direction: -1) }
			} else if (totalDistance < 0) && focusIndex < demoOptimizedCards.count - 1 {
				withAnimation(CinematicCurves.overshoot) { focusIndex += 1 }
				CinematicHaptics.play(.confident)
				if !FeatureFlags.DemoPerformanceMode { triggerCardChangeEffect(direction: 1) }
			}
		}

		let returnDuration = 0.5
		let returnAnimation = Animation.timingCurve(0.25, 1.0, 0.5, 1.0, duration: returnDuration)
		withAnimation(returnAnimation) {
			dragOffset = .zero
			isDragging = false
			for i in 0..<demoOptimizedCards.count { cardRotations[i] = 0; cardScales[i] = 1.0 }
		}
	}

	// MARK: - Cinematic Animation Functions

	private func initializeCardAnimations() {
		for i in 0..<demoOptimizedCards.count { cardRotations[i] = 0; cardScales[i] = 1.0 }
		if FeatureFlags.DemoPerformanceMode { return }
		let delays = AnimationSequence.staggeredReveal(items: demoOptimizedCards, delay: 0.08)
		for (index, card) in demoOptimizedCards.enumerated() {
			if let delay = delays[card] {
				DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
					withAnimation(CinematicSprings.elegant) { cardScales[index] = 1.0 }
				}
			}
		}
	}

	private func triggerSparkleEffect(at index: Int) {
		guard !reduceMotion else { return }
		let center = CGPoint(x: 0, y: 0)
		sparkleParticles = ParticleEffects.generateSparkles(center: center, count: 8, radius: 30)
		withAnimation(.easeOut(duration: 0.1)) { showSparkles = true }
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { withAnimation(.easeIn(duration: 0.2)) { showSparkles = false } }
	}

	private func triggerCardChangeEffect(direction: Int) {
		guard !reduceMotion else { return }
		for i in 0..<demoOptimizedCards.count {
			let delay = TimeInterval(abs(i - focusIndex)) * 0.03
			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
				withAnimation(CinematicSprings.playful) { cardRotations[i] = Double(direction) * -1.5 }
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { withAnimation(CinematicSprings.ambient) { cardRotations[i] = 0 } }
			}
		}
	}

	private func enhancedScale(for index: Int) -> CGFloat {
		let distance = abs(index - focusIndex)
		let baseScale = 1.0 - (CGFloat(distance) * 0.04)
		let customScale = cardScales[index] ?? 1.0
		let anticipationScale = isAnticipating && index == focusIndex ? 0.98 : 1.0
		return baseScale * customScale * anticipationScale
	}

	private func enhancedYOffset(for index: Int) -> CGFloat {
		let distance = abs(index - focusIndex)
		let baseOffset = CGFloat(distance) * 18
		if index == focusIndex && isDragging { return baseOffset + (dragOffset.height * 0.08) }
		let ambientOffset = reduceMotion || FeatureFlags.DemoPerformanceMode ? 0 : sin(Date().timeIntervalSince1970 + Double(index)) * 0.5
		return baseOffset + ambientOffset
	}

	private func enhancedXOffset(for index: Int) -> CGFloat { 0 }

	private func enhancedRotation(for index: Int) -> Double {
		if reduceMotion || FeatureFlags.DemoPerformanceMode { return 0 }
		let baseRotation = Double(index - focusIndex) * -2.0
		let customRotation = cardRotations[index] ?? 0
		if index == focusIndex && isDragging {
			let dragRotation = Double(dragOffset.width) * 0.025
			let velocityRotation = Double(gestureVelocity.width) * 0.0001
			return baseRotation + dragRotation + velocityRotation + customRotation
		}
		return baseRotation + customRotation
	}

	private func enhancedOpacity(for index: Int) -> Double {
		let distance = abs(index - focusIndex)
		switch distance {
		case 0: return isAnticipating ? 0.95 : 1.0
		case 1: return 0.88
		case 2: return 0.65
		case 3: return 0.4
		default: return 0.2
		}
	}
}

#Preview {
	let mockCards = [
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
		)
	]

	return ZStack {
		ModernBackground()
		CardsStack(cards: mockCards)
			.frame(height: 280)
			.padding()
	}
	.preferredColorScheme(.dark)
}

