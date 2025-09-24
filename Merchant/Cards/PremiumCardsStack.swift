// Stack of cards with smooth transitions and tap-driven navigation.

import SwiftUI

struct PremiumCardsStack: View {
    let cards: [CardUI]
    @State private var currentIndex = 0
    @State private var selectedCard: CardUI?
    @State private var dragOffset = CGSize.zero
    @State private var cardOffsets: [CGSize] = []
    @State private var cardScales: [CGFloat] = []

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var cardNamespace

    var body: some View {
        ZStack {
            let maxVisible = 5
            let startIndex = max(0, currentIndex)
            let endIndex = min(cards.count, currentIndex + maxVisible)
            ForEach(Array(cards[startIndex..<endIndex].enumerated()), id: \.element.id) { local, card in
                let index = startIndex + local
                let isCurrentCard = index == currentIndex
                let cardOffset = getCardOffset(for: index)
                let cardScale = getCardScale(for: index)
                let cardOpacity = getCardOpacity(for: index)

                PremiumCardTile(
                    card: card,
                    isTopCard: isCurrentCard,
                    zIndex: zIndexValue(for: index),
                    namespace: cardNamespace,
                    onSwipeUp: {
                        advanceToNextCard()
                    },
                    onPromote: {
                        focusCard(at: index)
                    }
                )
                .scaleEffect(cardScale)
                .offset(cardOffset)
                .opacity(cardOpacity)
                .zIndex(zIndexValue(for: index))
                .highPriorityGesture(
                    TapGesture().onEnded {
                        // Tap rotates/focuses — no swipe, no detail by default
                        if isCurrentCard {
                            advanceToNextCard()
                        } else {
                            focusCard(at: index)
                        }
                    }
                )
                .contentShape(Rectangle())
            }
        }
        .fullScreenCover(item: $selectedCard) { card in
            PremiumCardDetail(card: card, namespace: cardNamespace) {
                selectedCard = nil
            }
        }
        .onAppear {
            initializeCardPositions()
        }
        // Tap-only interaction per requirement (no sliding)
    }

    // MARK: - Card Positioning

    private func getCardOffset(for index: Int) -> CGSize {
        let distance = min(max(index - currentIndex, 0), 4)
        let baseYOffset = CGFloat(distance) * 10 // subtle overlap
        let baseXOffset: CGFloat = 0             // No horizontal offset

        // Apply drag offset to current card
        if index == currentIndex {
            return CGSize(
                width: baseXOffset + dragOffset.width * 0.3,
                height: baseYOffset + dragOffset.height * 0.1
            )
        }

        return CGSize(width: baseXOffset, height: baseYOffset)
    }

    private func getCardScale(for index: Int) -> CGFloat {
        let distance = min(abs(index - currentIndex), 4)
        let baseScale = 1.0 - (CGFloat(distance) * 0.03)

        // Slightly enlarge current card when dragging
        if index == currentIndex && abs(dragOffset.width) > 20 {
            return baseScale + 0.02
        }

        return max(baseScale, 0.8)
    }

    private func getCardOpacity(for index: Int) -> Double {
        let distance = min(abs(index - currentIndex), 4)
        switch distance {
        case 0: return 1.0
        case 1: return 0.92
        case 2: return 0.82
        case 3: return 0.72
        default: return 0.6
        }
    }

    // MARK: - Navigation

    private func advanceToNextCard() {
        guard currentIndex < cards.count - 1 else {
            // If at last card, cycle back to first
            withAnimation(CopilotDesign.Animations.smoothSpring) {
                currentIndex = 0
            }
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            return
        }

        withAnimation(CopilotDesign.Animations.gentleSpring) {
            currentIndex += 1
        }

        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    private func goToPreviousCard() {
        guard currentIndex > 0 else {
            // If at first card, cycle to last
            withAnimation(CopilotDesign.Animations.smoothSpring) {
                currentIndex = cards.count - 1
            }
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            return
        }

        withAnimation(CopilotDesign.Animations.gentleSpring) {
            currentIndex -= 1
        }

        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    private func focusCard(at index: Int) {
        guard index != currentIndex && index >= 0 && index < cards.count else { return }

        withAnimation(CopilotDesign.Animations.gentleSpring) {
            currentIndex = index
        }

        // Selection haptic
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }

    private func handleHorizontalSwipe(_ translation: CGSize) {
        let threshold: CGFloat = 80
        let velocity = translation.width

        if velocity > threshold {
            // Swipe right - previous card
            goToPreviousCard()
        } else if velocity < -threshold {
            // Swipe left - next card
            advanceToNextCard()
        }

        // Note: drag offset reset is handled in gesture onEnded
    }

    private func initializeCardPositions() {
        cardOffsets = Array(repeating: .zero, count: cards.count)
        cardScales = Array(repeating: 1.0, count: cards.count)

        // Staggered entrance animation
        for (index, _) in cards.enumerated() {
            let delay = Double(index) * 0.1

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(CopilotDesign.Animations.smoothSpring) {
                    // Cards animate into position
                }
            }
        }
    }

    // MARK: - Z-Index Ordering

    private func zIndexValue(for index: Int) -> Double {
        // Ensure the current (top) card is always above others; then order by distance.
        if index == currentIndex { return 1000 }
        let distance = abs(index - currentIndex)
        return Double(1000 - distance)
    }
}

// MARK: - Premium Card Detail View

struct PremiumCardDetail: View {
    let card: CardUI
    let namespace: Namespace.ID
    let onDismiss: () -> Void

    @State private var showDetails = false

    var body: some View {
        NavigationStack {
            ZStack {
                CopilotDesign.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CopilotDesign.Spacing.xl) {
                        // Hero card
                        PremiumCardTile(
                            card: card,
                            isTopCard: false,
                            zIndex: 1,
                            namespace: namespace,
                            onSwipeUp: {}
                        )
                        .frame(height: 240)
                        .matchedGeometryEffect(id: card.id, in: namespace)

                        // Card details
                        if showDetails {
                            VStack(spacing: CopilotDesign.Spacing.lg) {
                                CleanCard(style: .elevated) {
                                    VStack(alignment: .leading, spacing: CopilotDesign.Spacing.md) {
                                        Text("Card Details")
                                            .font(CopilotDesign.Typography.headlineMedium)
                                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                        VStack(alignment: .leading, spacing: CopilotDesign.Spacing.sm) {
                                            DetailRow(label: "Product", value: card.productName)
                                            DetailRow(label: "Network", value: card.network)
                                            DetailRow(label: "Last 4 Digits", value: card.last4)
                                            DetailRow(label: "Status", value: card.isPremium ? "Premium" : "Standard")
                                        }
                                    }
                                    .padding(CopilotDesign.Spacing.lg)
                                }

                                CleanCard(style: .elevated) {
                                    VStack(alignment: .leading, spacing: CopilotDesign.Spacing.md) {
                                        Text("Rewards & Benefits")
                                            .font(CopilotDesign.Typography.headlineMedium)
                                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                        let benefits = CardBenefitsCatalog.details(for: card.selectionKey)
                                        VStack(alignment: .leading, spacing: CopilotDesign.Spacing.sm) {
                                            // Top multipliers (exclude coffee)
                                            ForEach(Array(benefits.multipliers.filter { $0.key != "coffee" }.sorted { $0.value > $1.value }.prefix(3)), id: \.key) { key, mult in
                                                BenefitRow(
                                                    icon: "creditcard",
                                                    title: String(format: "%.0f× %@", mult, labelForCategoryKey(key)),
                                                    description: benefits.isEstimated ? "Estimated" : ""
                                                )
                                            }
                                            // Perks
                                            ForEach(benefits.perks, id: \.self) { perk in
                                                BenefitRow(icon: "sparkles", title: perk, description: "")
                                            }
                                        }
                                    }
                                    .padding(CopilotDesign.Spacing.lg)
                                }
                            }
                            .padding(.horizontal, CopilotDesign.Spacing.lg)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, CopilotDesign.Spacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        onDismiss()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(CopilotDesign.Animations.smoothSpring.delay(0.3)) {
                showDetails = true
            }
        }
    }
}

private func labelForCategoryKey(_ key: String) -> String {
    switch key {
    case "everything": return "everywhere"
    case "drugstores": return "drugstores"
    case "entertainment": return "entertainment"
    case "groceries": return "groceries"
    case "gas": return "gas"
    case "transit": return "transit"
    case "streaming": return "streaming"
    case "online": return "online"
    case "dining", "restaurants": return "dining"
    case "coffee": return "coffee"
    case "travel": return "travel"
    case "flights": return "flights"
    case "hotels": return "hotels"
    case "airfare": return "airfare"
    case "rotating": return "rotating"
    case "top": return "top monthly category"
    default: return key
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(CopilotDesign.Typography.bodyMedium)
                .foregroundStyle(CopilotDesign.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(CopilotDesign.Typography.bodyMedium)
                .fontWeight(.medium)
                .foregroundStyle(CopilotDesign.Colors.textPrimary)
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: CopilotDesign.Spacing.sm) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(CopilotDesign.Colors.brandGreen)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: CopilotDesign.Spacing.xs) {
                Text(title)
                    .font(CopilotDesign.Typography.labelLarge)
                    .fontWeight(.medium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                Text(description)
                    .font(CopilotDesign.Typography.bodySmall)
                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
            }

            Spacer()
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
            productName: "Double Cash",
            last4: "9012",
            artURL: URL(string: "https://www.citi.com/CRD/images/citi-double-cash-card/citi-double-cash-card-art.png")!,
            isPremium: false,
            network: "Mastercard"
        )
    ]

    return ZStack {
        CopilotDesign.Colors.background
            .ignoresSafeArea()

        PremiumCardsStack(cards: mockCards)
            .frame(height: 300)
            .padding()
    }
    .preferredColorScheme(.dark)
}