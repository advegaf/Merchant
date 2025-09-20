// Rules: Award-winning card stack with revolutionary physics and cinematic animations
// Inputs: Array of CardUI with valid artURLs, focus index, gesture states
// Outputs: Physics-based interactions, anticipatory animations, contextual haptics
// Constraints: 60fps performance, iOS 26+, Apple Design Award quality

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

    var body: some View {
        ZStack {
            // Sparkle particle effects
            if showSparkles {
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

            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                let isTopCard = index == focusIndex
                let cardScale = enhancedScale(for: index)
                let cardYOffset = enhancedYOffset(for: index)
                let cardXOffset = enhancedXOffset(for: index)
                let cardRotation = enhancedRotation(for: index)
                let cardOpacity = enhancedOpacity(for: index)
                let cardZIndex = Double(cards.count - index)

                CardTile(
                    card: card,
                    isTopCard: isTopCard,
                    zIndex: cardZIndex,
                    namespace: cardNamespace
                )
                .scaleEffect(cardScale)
                .offset(x: cardXOffset, y: cardYOffset)
                .rotation3DEffect(
                    .degrees(cardRotation),
                    axis: (x: 0.1, y: 1, z: 0.05),
                    perspective: 0.8
                )
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
                .onTapGesture {
                    handleAdvancedCardTap(index: index, card: card)
                }
                .gesture(createAdvancedDragGesture(for: index))
            }
        }
        .fullScreenCover(item: $selectedCard) { card in
            CardHeroDetail(card: card, namespace: cardNamespace) {
                selectedCard = nil
            }
            .cinematicEntrance(.flipFromBottom)
        }
        .onAppear {
            initializeCardAnimations()
        }
    }

    // MARK: - Advanced Interaction Handlers

    private func handleAdvancedCardTap(index: Int, card: CardUI) {
        if index == focusIndex {
            // Anticipation animation before expand
            withAnimation(CinematicSprings.immediate) {
                isAnticipating = true
                cardScales[index] = 0.98
            }

            // Sparkle effect for premium cards
            if card.isPremium {
                triggerSparkleEffect(at: index)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(CinematicSprings.dramatic) {
                    self.selectedCard = card
                    self.isAnticipating = false
                    self.cardScales[index] = 1.0
                }
            }

            CinematicHaptics.playCardInteraction()
        } else {
            // Focus change with cascade effect
            let direction = index > focusIndex ? 1 : -1

            withAnimation(CinematicSprings.elegant) {
                focusIndex = index
            }

            // Cascade animation for surrounding cards
            for i in 0..<cards.count {
                let delay = TimeInterval(abs(i - index)) * 0.05
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(CinematicSprings.ambient) {
                        cardRotations[i] = (i == index) ? 0 : Double(direction * 2)
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

                    // Real-time physics preview
                    let progress = min(abs(value.translation.width) / 120, 1.0)
                    let intensity = Float(progress)

                    // Dynamic rotation based on drag direction and intensity
                    cardRotations[index] = Double(value.translation.width * 0.03)

                    // Anticipatory scaling
                    cardScales[index] = 1.0 + (progress * 0.03)

                    // Parallax effect on background cards
                    for i in 0..<cards.count where i != index {
                        let distance = abs(i - index)
                        let parallaxFactor = 1.0 / Double(distance + 1)
                        cardRotations[i] = Double(value.translation.width * 0.01 * parallaxFactor)
                    }
                }
            }
            .onEnded { value in
                if index == focusIndex {
                    handleAdvancedDragEnd(value.translation, velocity: value.velocity)
                    // If swiped up enough, open detail
                    if value.translation.height < -100 {
                        handleAdvancedCardTap(index: index, card: cards[index])
                    }
                }
            }
    }

    private func handleAdvancedDragEnd(_ translation: CGSize, velocity: CGSize) {
        let threshold: CGFloat = 50
        let velocityThreshold: CGFloat = 250

        // Smart gesture recognition with momentum prediction
        let momentumDistance = velocity.width * 0.001 // Predict where gesture would end
        let totalDistance = translation.width + momentumDistance
        let shouldSwipe = abs(translation.width) > threshold || abs(velocity.width) > velocityThreshold

        if shouldSwipe {
            if (totalDistance > 0) && focusIndex > 0 {
                // Swipe right - previous card with momentum-based animation
                let _ = min(abs(velocity.width) / 1000, 0.2) // momentum for future use

                withAnimation(CinematicCurves.overshoot) {
                    focusIndex -= 1
                }

                CinematicHaptics.play(.confident)
                triggerCardChangeEffect(direction: -1)

            } else if (totalDistance < 0) && focusIndex < cards.count - 1 {
                // Swipe left - next card
                withAnimation(CinematicCurves.overshoot) {
                    focusIndex += 1
                }

                CinematicHaptics.play(.confident)
                triggerCardChangeEffect(direction: 1)
            }
        }

        // Sophisticated return animation with physics-based timing
        let returnDuration = 0.6 + min(abs(velocity.width) / 2000, 0.4)
        let returnAnimation = Animation.timingCurve(0.25, 1.0, 0.5, 1.0, duration: returnDuration)

        withAnimation(returnAnimation) {
            dragOffset = .zero
            isDragging = false

            // Reset all card transformations
            for i in 0..<cards.count {
                cardRotations[i] = 0
                cardScales[i] = 1.0
            }
        }
    }

    // MARK: - Cinematic Animation Functions

    private func initializeCardAnimations() {
        // Initialize state dictionaries
        for i in 0..<cards.count {
            cardRotations[i] = 0
            cardScales[i] = 1.0
        }

        // Staggered entrance animation
        let delays = AnimationSequence.staggeredReveal(items: cards, delay: 0.08)
        for (index, card) in cards.enumerated() {
            if let delay = delays[card] {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(CinematicSprings.elegant) {
                        cardScales[index] = 1.0
                    }
                }
            }
        }
    }

    private func triggerSparkleEffect(at index: Int) {
        guard !reduceMotion else { return }

        let center = CGPoint(x: 0, y: 0) // Relative to card center
        sparkleParticles = ParticleEffects.generateSparkles(center: center, count: 8, radius: 30)

        withAnimation(.easeOut(duration: 0.1)) {
            showSparkles = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.2)) {
                showSparkles = false
            }
        }
    }

    private func triggerCardChangeEffect(direction: Int) {
        guard !reduceMotion else { return }

        // Cascade wave effect
        for i in 0..<cards.count {
            let delay = TimeInterval(abs(i - focusIndex)) * 0.03
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(CinematicSprings.playful) {
                    cardRotations[i] = Double(direction) * -1.5
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(CinematicSprings.ambient) {
                        cardRotations[i] = 0
                    }
                }
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

        // Sophisticated parallax during drag
        if index == focusIndex && isDragging {
            return baseOffset + (dragOffset.height * 0.08)
        }

        // Subtle ambient motion for background cards
        let ambientOffset = sin(Date().timeIntervalSince1970 + Double(index)) * 0.5
        return baseOffset + (reduceMotion ? 0 : ambientOffset)
    }

    private func enhancedXOffset(for index: Int) -> CGFloat {
        let baseOffset = CGFloat(index - focusIndex) * 6

        // Primary drag effect with momentum
        if index == focusIndex && isDragging {
            let momentumFactor = min(abs(gestureVelocity.width) / 1000, 1.0)
            return baseOffset + (dragOffset.width * (0.7 + momentumFactor * 0.2))
        }

        // Advanced parallax for background cards
        if index != focusIndex && isDragging {
            let distance = abs(CGFloat(index - focusIndex))
            let parallaxFactor = 1.0 / (distance + 1)
            let directionFactor = index > focusIndex ? 1.0 : -1.0
            return baseOffset + (dragOffset.width * parallaxFactor * 0.15 * directionFactor)
        }

        return baseOffset
    }

    private func enhancedRotation(for index: Int) -> Double {
        if reduceMotion { return 0 }

        let baseRotation = Double(index - focusIndex) * -2.0
        let customRotation = cardRotations[index] ?? 0

        // Enhanced rotation during drag with velocity consideration
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
        case 0:
            return isAnticipating ? 0.95 : 1.0
        case 1:
            return 0.88
        case 2:
            return 0.65
        case 3:
            return 0.4
        default:
            return 0.2
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