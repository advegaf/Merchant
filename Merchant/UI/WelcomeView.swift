// Rules: Beautiful welcome screen with card selection flow and Apple-precise styling
// Inputs: User name, card selection, onboarding flow
// Outputs: Smooth onboarding experience with card thumbnails
// Constraints: Follow Apple HIG, smooth animations, premium feel

import SwiftUI

struct WelcomeView: View {
    @Environment(UserProfileStore.self) private var userProfile
    @Environment(SelectedCardsStore.self) private var selectedCards
    @State private var allCards: [CardUI] = []
    @State private var provider = MockCardArtProvider()
    @State private var currentStep = 0
    @State private var animateIn = false

    let onComplete: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                CopilotDesign.Colors.background
                    .ignoresSafeArea()

                if currentStep == 0 {
                    WelcomeIntroView(
                        onContinue: {
                            withAnimation(CopilotDesign.Animations.smoothSpring) {
                                currentStep = 1
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                } else {
                    WelcomeCardSelectionView(
                        cards: allCards,
                        onComplete: onComplete
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
        }
        .task {
            if allCards.isEmpty {
                allCards = await provider.fetchCardsForReview()
            }
        }
    }
}

struct WelcomeIntroView: View {
    @Environment(UserProfileStore.self) private var userProfile
    @State private var animateContent = false
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: CopilotDesign.Spacing.xxxl) {
            Spacer()

            VStack(spacing: CopilotDesign.Spacing.xl) {
                // Welcome icon with beautiful animation
                ZStack {
                    Circle()
                        .fill(CopilotDesign.Colors.brandPrimary.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateContent ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateContent)

                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.brandPrimary)
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .opacity(animateContent ? 1.0 : 0.0)
                }

                VStack(spacing: CopilotDesign.Spacing.lg) {
                    Text("Welcome, \(userProfile.displayName)!")
                        .font(CopilotDesign.Typography.displayLarge)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)

                    Text("Let's optimize your card rewards and maximize every purchase you make.")
                        .font(CopilotDesign.Typography.bodyLarge)
                        .foregroundStyle(CopilotDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 30)
                }
            }

            Spacer()

            // Continue button
            VStack(spacing: CopilotDesign.Spacing.lg) {
                CleanButton("Get Started", style: .primary) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onContinue()
                }
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 50)

                Text("Choose your cards on the next screen")
                    .font(CopilotDesign.Typography.labelMedium)
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    .opacity(animateContent ? 1.0 : 0.0)
            }
        }
        .padding(.horizontal, CopilotDesign.Spacing.xl)
        .padding(.vertical, CopilotDesign.Spacing.xxxl)
        .onAppear {
            withAnimation(CopilotDesign.Animations.smoothSpring.delay(0.3)) {
                animateContent = true
            }
        }
    }
}

struct WelcomeCardSelectionView: View {
    @Environment(SelectedCardsStore.self) private var store
    let cards: [CardUI]
    let onComplete: () -> Void
    @State private var animateCards = false

    var body: some View {
        VStack(spacing: CopilotDesign.Spacing.xl) {
            // Header
            VStack(spacing: CopilotDesign.Spacing.md) {
                Text("Choose Your Cards")
                    .font(CopilotDesign.Typography.displaySmall)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(y: animateCards ? 0 : -20)

                Text("Select the credit cards you use most often. We'll help you maximize rewards on every purchase.")
                    .font(CopilotDesign.Typography.bodyMedium)
                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(y: animateCards ? 0 : -10)
            }
            .padding(.horizontal, CopilotDesign.Spacing.xl)

            // Cards grid
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 160), spacing: CopilotDesign.Spacing.lg)
                    ],
                    spacing: CopilotDesign.Spacing.lg
                ) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        WelcomeCardTile(
                            card: card,
                            isSelected: store.isSelected(card.selectionKey),
                            onTap: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                store.toggleSelection(for: card.selectionKey)
                            }
                        )
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 50)
                        .animation(
                            CopilotDesign.Animations.smoothSpring.delay(Double(index) * 0.1),
                            value: animateCards
                        )
                    }
                }
                .padding(.horizontal, CopilotDesign.Spacing.xl)
            }

            // Continue button
            VStack(spacing: CopilotDesign.Spacing.sm) {
                CleanButton(
                    store.selectedKeys.isEmpty ? "Skip for Now" : "Continue with \(store.selectedKeys.count) Cards",
                    style: store.selectedKeys.isEmpty ? .secondary : .primary
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    store.hasCompletedOnboarding = true
                    onComplete()
                }
                .opacity(animateCards ? 1.0 : 0.0)

                if !store.selectedKeys.isEmpty {
                    Text("You can always change these later in settings")
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                        .opacity(animateCards ? 1.0 : 0.0)
                }
            }
            .padding(.horizontal, CopilotDesign.Spacing.xl)
            .padding(.bottom, CopilotDesign.Spacing.xl)
        }
        .onAppear {
            withAnimation(CopilotDesign.Animations.smoothSpring.delay(0.5)) {
                animateCards = true
            }
        }
    }
}

struct WelcomeCardTile: View {
    let card: CardUI
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: CopilotDesign.Spacing.md) {
                // Card image
                AsyncImage(url: card.artURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(CopilotDesign.Colors.surface2)
                        .overlay {
                            ProgressView()
                                .tint(CopilotDesign.Colors.brandPrimary)
                        }
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                // Card info
                VStack(spacing: CopilotDesign.Spacing.xs) {
                    Text(card.productName)
                        .font(CopilotDesign.Typography.labelLarge)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text(card.network)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textSecondary)

                    if isSelected {
                        HStack(spacing: CopilotDesign.Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("Selected")
                                .font(CopilotDesign.Typography.labelSmall)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(CopilotDesign.Colors.brandPrimary)
                        .padding(.horizontal, CopilotDesign.Spacing.sm)
                        .padding(.vertical, CopilotDesign.Spacing.xs)
                        .background {
                            Capsule()
                                .fill(CopilotDesign.Colors.brandPrimary.opacity(0.1))
                        }
                    }
                }
            }
            .padding(CopilotDesign.Spacing.lg)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CopilotDesign.Colors.surface1)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                isSelected ? CopilotDesign.Colors.brandPrimary : Color.clear,
                                lineWidth: 2
                            )
                    }
                    .shadow(
                        color: isSelected ? CopilotDesign.Colors.brandPrimary.opacity(0.2) : Color.clear,
                        radius: isSelected ? 8 : 0,
                        x: 0,
                        y: isSelected ? 4 : 0
                    )
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(CopilotDesign.Animations.quickSpring, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

#Preview("Welcome Intro") {
    WelcomeIntroView(onContinue: {})
        .environment(UserProfileStore.shared)
}

#Preview("Card Selection") {
    WelcomeCardSelectionView(cards: [
        CardUI(
            institutionId: "chase",
            productName: "Chase Sapphire Preferred",
            last4: "1234",
            artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_preferred_card.png")!,
            isPremium: true,
            network: "Visa"
        )
    ], onComplete: {})
    .environment(SelectedCardsStore.shared)
    .background(CopilotDesign.Colors.background)
}