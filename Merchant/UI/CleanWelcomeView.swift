// Rules: Clean, professional welcome flow with consistent design
// Inputs: User onboarding state, card selection
// Outputs: Smooth welcome experience with card selection
// Constraints: Clean animations, proper hierarchy, professional feel

import SwiftUI

struct CleanWelcomeView: View {
    @Environment(UserProfileStore.self) private var userProfile
    @Environment(SelectedCardsStore.self) private var selectedCards
    @State private var allCards: [CardUI] = []
    @State private var provider = MockCardArtProvider()
    @State private var currentStep = 0

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            CopilotDesign.Colors.background
                .ignoresSafeArea()

            if currentStep == 0 {
                NameEntryStep {
                    withAnimation(CopilotDesign.Animations.smoothSpring) {
                        currentStep = 1
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else if currentStep == 1 {
                WelcomeIntroStep {
                    withAnimation(CopilotDesign.Animations.smoothSpring) {
                        currentStep = 2
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                CardSelectionStep(cards: allCards) {
                    let h = UIImpactFeedbackGenerator(style: .light)
                    h.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onComplete()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .task {
            if allCards.isEmpty {
                allCards = await provider.fetchCardsForReview()
            }
        }
    }
}

struct WelcomeIntroStep: View {
    @Environment(UserProfileStore.self) private var userProfile
    @State private var animateContent = false
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                // App icon
                ZStack {
                    Circle()
                        .fill(CopilotDesign.Colors.accent.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .scaleEffect(animateContent ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateContent)

                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.accent)
                }
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.8)

                // Text content
                VStack(spacing: 16) {
                    Text("Welcome, \(userProfile.displayName)!")
                        .font(CopilotDesign.Typography.displayLarge)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Let's set up your cards to maximize rewards on every purchase.")
                        .font(CopilotDesign.Typography.bodyLarge)
                        .foregroundStyle(CopilotDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            }

            Spacer()

            // Continue button
            VStack(spacing: 12) {
                CleanButton("Get Started") {
                    onContinue()
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)

                Text("This will only take a moment")
                    .font(CopilotDesign.Typography.labelMedium)
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    .opacity(animateContent ? 1 : 0)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .onAppear {
            withAnimation(CopilotDesign.Animations.smoothSpring.delay(0.5)) {
                animateContent = true
            }
        }
    }
}

struct CardSelectionStep: View {
    @Environment(SelectedCardsStore.self) private var store
    let cards: [CardUI]
    let onComplete: () -> Void
    @State private var animateCards = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("Choose Your Cards")
                    .font(CopilotDesign.Typography.displaySmall)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                Text("Select the credit cards you use most often. We'll help you maximize rewards.")
                    .font(CopilotDesign.Typography.bodyMedium)
                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .padding(.top, 40)
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : -20)

            // Cards grid
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 140), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        CardSelectionTile(
                            card: card,
                            isSelected: store.isSelected(card.selectionKey),
                            onTap: {
                                store.toggleSelection(for: card.selectionKey)
                            }
                        )
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 30)
                        .animation(
                            CopilotDesign.Animations.smoothSpring.delay(Double(index) * 0.05),
                            value: animateCards
                        )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
            }

            // Continue button
            VStack(spacing: 8) {
                CleanButton(
                    store.selectedKeys.isEmpty ? "Skip for Now" : "Continue",
                    style: store.selectedKeys.isEmpty ? .secondary : .primary
                ) {
                    store.hasCompletedOnboarding = true
                    onComplete()
                }

                if !store.selectedKeys.isEmpty {
                    Text("\(store.selectedKeys.count) cards selected")
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(animateCards ? 1 : 0)
        }
        .onAppear {
            withAnimation(CopilotDesign.Animations.smoothSpring.delay(0.3)) {
                animateCards = true
            }
        }
    }
}

struct CardSelectionTile: View {
    let card: CardUI
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Card image
                AsyncImage(url: card.artURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(CopilotDesign.Colors.surface)
                        .overlay {
                            ProgressView()
                                .tint(CopilotDesign.Colors.accent)
                        }
                }
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                // Card info
                VStack(spacing: 4) {
                    Text(card.productName)
                        .font(CopilotDesign.Typography.labelMedium)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text(card.network)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }

                // Selection indicator
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                        Text("Selected")
                            .font(CopilotDesign.Typography.labelSmall)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(CopilotDesign.Colors.accent)
                    }
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(CopilotDesign.Colors.surface)
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(CopilotDesign.Colors.accent, lineWidth: 2)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .buttonStyle(PressableButtonStyle(scale: 0.95))
    }
}

// MARK: - Name Entry Step

struct NameEntryStep: View {
    @Environment(UserProfileStore.self) private var userProfile
    @State private var name: String = ""
    @State private var animateContent = false
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Text("Welcome")
                    .font(CopilotDesign.Typography.displayLarge)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : -10)

                Text("What should we call you?")
                    .font(CopilotDesign.Typography.bodyLarge)
                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : -8)

                CleanCard {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(CopilotDesign.Colors.accent)
                        TextField("Your name", text: $name)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .font(CopilotDesign.Typography.bodyLarge)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                    }
                    .padding(16)
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 10)
            }
            .padding(.horizontal, 32)

            Spacer()

            CleanButton("Continue", style: .primary, size: .medium) {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                userProfile.displayName = trimmed
                userProfile.save()
                onContinue()
            }
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(animateContent ? 1 : 0)

        }
        .onAppear {
            name = userProfile.displayName == "Angel" ? "" : userProfile.displayName
            withAnimation(CopilotDesign.Animations.smoothSpring.delay(0.2)) {
                animateContent = true
            }
        }
    }
}

#Preview("Welcome Intro") {
    WelcomeIntroStep {}
        .environment(UserProfileStore.shared)
        .background(CopilotDesign.Colors.background)
}

#Preview("Card Selection") {
    CardSelectionStep(cards: [
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