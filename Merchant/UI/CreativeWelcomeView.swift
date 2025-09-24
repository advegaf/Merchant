
import SwiftUI

struct CreativeWelcomeView: View {
    @Environment(UserProfileStore.self) private var userProfile
    @Environment(SelectedCardsStore.self) private var selectedCards
    @State private var allCards: [CardUI] = []
    @State private var provider = MockCardArtProvider()
    @State private var currentStep = 0
    @State private var backgroundGradientOffset: CGFloat = 0
    @State private var floatingCardsOffset: [CGFloat] = Array(repeating: 0, count: 5)

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Dynamic gradient background
            AnimatedGradientBackground()

            // Floating card elements
            FloatingCardElements()

            // Main content
            if currentStep == 0 {
                CreativeIntroStep {
                    withAnimation(CopilotDesign.Animations.dramaticSpring) {
                        currentStep = 1
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            } else {
                CreativeCardSelectionStep(cards: allCards, onComplete: onComplete)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
            }
        }
        .task {
            if allCards.isEmpty {
                allCards = await provider.fetchCardsForReview()
            }
        }
        .onAppear {
            startBackgroundAnimation()
        }
    }

    private func startBackgroundAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            backgroundGradientOffset = 1.0
        }

        // Animate floating cards
        for i in 0..<floatingCardsOffset.count {
            withAnimation(
                .easeInOut(duration: Double.random(in: 2...4))
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.5)
            ) {
                floatingCardsOffset[i] = Double.random(in: -30...30)
            }
        }
    }
}

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                CopilotDesign.Colors.background,
                CopilotDesign.Colors.accent.opacity(0.1),
                CopilotDesign.Colors.info.opacity(0.05),
                CopilotDesign.Colors.background
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

struct FloatingCardElements: View {
    @State private var floatingOffsets: [CGSize] = Array(repeating: .zero, count: 8)

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                CopilotDesign.Colors.accent.opacity(0.1),
                                CopilotDesign.Colors.info.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 38)
                    .blur(radius: 1)
                    .offset(floatingOffsets[index])
                    .opacity(0.3)
            }
        }
        .onAppear {
            for i in 0..<floatingOffsets.count {
                let randomDelay = Double.random(in: 0...2)
                let randomDuration = Double.random(in: 3...6)

                withAnimation(
                    .easeInOut(duration: randomDuration)
                    .repeatForever(autoreverses: true)
                    .delay(randomDelay)
                ) {
                    floatingOffsets[i] = CGSize(
                        width: Double.random(in: -100...100),
                        height: Double.random(in: -150...150)
                    )
                }
            }
        }
    }
}

struct CreativeIntroStep: View {
    @Environment(UserProfileStore.self) private var userProfile
    @State private var animateContent = false
    @State private var logoScale: CGFloat = 0.8
    @State private var titleOffset: CGFloat = 50
    @State private var descriptionOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.9

    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                // Creative logo with pulse effect
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    CopilotDesign.Colors.accent.opacity(0.3),
                                    CopilotDesign.Colors.accent.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(logoScale)

                    // Main icon background
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            CopilotDesign.Colors.accent.opacity(0.5),
                                            CopilotDesign.Colors.info.opacity(0.3),
                                            CopilotDesign.Colors.accent.opacity(0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        }

                    // Icon
                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    CopilotDesign.Colors.accent,
                                    CopilotDesign.Colors.info
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(logoScale)

                // Text content
                VStack(spacing: 24) {
                    Text("Welcome to Merchant")
                        .font(CopilotDesign.Typography.displayLarge)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    CopilotDesign.Colors.textPrimary,
                                    CopilotDesign.Colors.accent.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .offset(y: titleOffset)

                    Text("The smartest way to maximize your credit card rewards. Get personalized recommendations based on where you shop.")
                        .font(CopilotDesign.Typography.bodyLarge)
                        .foregroundStyle(CopilotDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .opacity(descriptionOpacity)
                }
                .padding(.horizontal, 32)
            }

            Spacer()

            // Continue button with premium styling
            VStack(spacing: 16) {
                CleanButton(
                    "Begin Journey",
                    style: .primary,
                    size: .large
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                    onContinue()
                }
                .scaleEffect(buttonScale)
                .shadow(
                    color: CopilotDesign.Colors.accent.opacity(0.3),
                    radius: 20,
                    x: 0,
                    y: 10
                )

                Text("Your rewards journey starts here")
                    .font(CopilotDesign.Typography.labelMedium)
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    .opacity(descriptionOpacity)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .onAppear {
            // Staggered animations
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                logoScale = 1.0
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
                titleOffset = 0
            }

            withAnimation(.easeInOut(duration: 0.8).delay(0.8)) {
                descriptionOpacity = 1.0
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.1)) {
                buttonScale = 1.0
            }

            // Continuous pulse effect
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.5)) {
                logoScale = 1.05
            }
        }
    }
}

struct CreativeCardSelectionStep: View {
    @Environment(SelectedCardsStore.self) private var store
    let cards: [CardUI]
    let onComplete: () -> Void
    @State private var animateCards = false
    @State private var headerScale: CGFloat = 0.9

    var body: some View {
        VStack(spacing: 0) {
            // Header with glass effect
            VStack(spacing: 20) {
                Text("Choose Your Cards")
                    .font(CopilotDesign.Typography.displayMedium)
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                CopilotDesign.Colors.textPrimary,
                                CopilotDesign.Colors.accent.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(headerScale)

                Text("Select your credit cards to get personalized recommendations and maximize your rewards.")
                    .font(CopilotDesign.Typography.bodyMedium)
                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(animateCards ? 1 : 0)
            }
            .padding(.horizontal, 32)
            .padding(.top, 40)

            // Cards grid with staggered animation
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 160), spacing: 20)
                    ],
                    spacing: 20
                ) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        CreativeCardSelectionTile(
                            card: card,
                            isSelected: store.isSelected(card.selectionKey),
                            animationDelay: Double(index) * 0.1
                        ) {
                            withAnimation(CopilotDesign.Animations.smoothSpring) {
                                store.toggleSelection(for: card.selectionKey)
                            }

                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 50)
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
            VStack(spacing: 12) {
                CleanButton(
                    store.selectedKeys.isEmpty ? "Skip for Now" : "Continue with \(store.selectedKeys.count) Cards",
                    style: store.selectedKeys.isEmpty ? .secondary : .primary,
                    size: .large
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                    store.hasCompletedOnboarding = true
                    onComplete()
                }
                .shadow(
                    color: store.selectedKeys.isEmpty
                        ? Color.clear
                        : CopilotDesign.Colors.accent.opacity(0.3),
                    radius: 20,
                    x: 0,
                    y: 10
                )

                if !store.selectedKeys.isEmpty {
                    Text("\(store.selectedKeys.count) cards selected")
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.success)
                        .opacity(animateCards ? 1 : 0)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                headerScale = 1.0
            }

            withAnimation(.easeInOut(duration: 0.6).delay(0.5)) {
                animateCards = true
            }
        }
    }
}

struct CreativeCardSelectionTile: View {
    let card: CardUI
    let isSelected: Bool
    let animationDelay: Double
    let onTap: () -> Void

    @State private var isPressed = false
    @State private var rotationEffect: Double = 0

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Card image with glass effect
                ZStack {
                    AsyncImage(url: card.artURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                VStack {
                                    ProgressView()
                                        .tint(CopilotDesign.Colors.accent)
                                    Text("Loading...")
                                        .font(CopilotDesign.Typography.labelSmall)
                                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                                }
                            }
                    }
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            CopilotDesign.Colors.accent,
                                            CopilotDesign.Colors.info
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        }
                    }
                    .rotationEffect(.degrees(rotationEffect))
                }

                // Card info
                VStack(spacing: 8) {
                    Text(card.productName)
                        .font(CopilotDesign.Typography.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text(card.network)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)

                    // Selection indicator
                    if isSelected {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text("Selected")
                                .font(CopilotDesign.Typography.labelSmall)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [CopilotDesign.Colors.accent, CopilotDesign.Colors.info],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    Capsule()
                                        .strokeBorder(
                                            CopilotDesign.Colors.accent.opacity(0.3),
                                            lineWidth: 1
                                        )
                                }
                        }
                    }
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                isSelected
                                    ? LinearGradient(
                                        colors: [
                                            CopilotDesign.Colors.accent.opacity(0.5),
                                            CopilotDesign.Colors.info.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: isSelected
                            ? CopilotDesign.Colors.accent.opacity(0.2)
                            : Color.clear,
                        radius: 20,
                        x: 0,
                        y: 10
                    )
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(CopilotDesign.Animations.quickSpring, value: isPressed)
        .animation(CopilotDesign.Animations.smoothSpring, value: isSelected)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .onAppear {
            withAnimation(
                .linear(duration: 6)
                .repeatForever(autoreverses: false)
                .delay(animationDelay)
            ) {
                rotationEffect = isSelected ? 360 : 0
            }
        }
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotationEffect += 360
                }
            }
        }
    }
}

#Preview {
    CreativeWelcomeView {
        print("Onboarding completed")
    }
    .environment(UserProfileStore.shared)
    .environment(SelectedCardsStore.shared)
}