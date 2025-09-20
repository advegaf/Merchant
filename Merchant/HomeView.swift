// Rules: Premium home screen with sophisticated layout, true dark theme, award-level visual hierarchy
// Inputs: UIState authentication status, card data
// Outputs: Blurred content + auth overlay OR premium home with cards and insights
// Constraints: True dark background, electric neon accents, liquid glass depth

import SwiftUI

struct HomeView: View {
    @Environment(UIState.self) private var uiState
    @State private var cards: [CardUI] = []
    @State private var cardProvider = MockCardArtProvider()
    @State private var showInsights = false

    var body: some View {
        ZStack {
            ModernBackground()

            if uiState.isSignedIn {
                SignedInHomeView(cards: cards, showInsights: $showInsights)
            } else {
                SignedOutOverlay()
            }
        }
        .task {
            if uiState.isSignedIn && cards.isEmpty {
                cards = await cardProvider.fetchCardsForReview()
            }
        }
        .onChange(of: uiState.isSignedIn) { _, newValue in
            if newValue && cards.isEmpty {
                Task {
                    cards = await cardProvider.fetchCardsForReview()
                }
            }
        }
    }
}

struct SignedInHomeView: View {
    let cards: [CardUI]
    @Binding var showInsights: Bool
    @Environment(UIState.self) private var uiState

    var body: some View {
        ScrollView {
            VStack(spacing: ModernSpacing.xxxl) {
                // Header with greeting and insights toggle
                PremiumHeader(showInsights: $showInsights)

                if !cards.isEmpty {
                    // Now panel with current recommendation
                    NowRecommendationPanel()

                    // Cards section
                    VStack(spacing: ModernSpacing.xl) {
                        HStack {
                            Text("Your Cards")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(ModernColors.textPrimary)
                            Spacer()
                            Button("Manage") {
                                // TODO: Navigate to card management
                            }
                            .font(.subheadline)
                            .foregroundStyle(ModernColors.accent)
                        }

                        CardsStack(cards: cards)
                            .frame(height: 280)
                    }

                    // Insights section
                    if showInsights {
                        InsightsSection()
                    }
                } else {
                    // Empty state with premium design
                    PremiumEmptyState()
                }
            }
            .padding(.horizontal, ModernSpacing.xl)
            .padding(.top, ModernSpacing.xxl)
        }
        .scrollIndicators(.hidden)
    }
}

struct PremiumHeader: View {
    @Binding var showInsights: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: ModernSpacing.sm) {
                Text("Good evening")
                    .font(.subheadline)
                    .foregroundStyle(ModernColors.textSecondary)

                Text("Merchant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(ModernColors.accent)
            }

            Spacer()

            HStack(spacing: ModernSpacing.lg) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showInsights.toggle()
                    }
                }) {
                    Image(systemName: showInsights ? "chart.bar.fill" : "chart.bar")
                        .font(.title2)
                        .foregroundStyle(showInsights ? ModernColors.accent : ModernColors.textSecondary)
                }

                Button(action: {
                    // TODO: Profile action
                }) {
                    ModernGlassCard(style: .secondary) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(ModernColors.textSecondary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
    }
}

struct NowRecommendationPanel: View {
    var body: some View {
        ModernGlassCard(style: .premium) {
            VStack(spacing: ModernSpacing.xl) {
                HStack {
                    VStack(alignment: .leading, spacing: ModernSpacing.sm) {
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundStyle(ModernColors.accent)
                            Text("The Local Bistro")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(ModernColors.accent)
                        }

                        Text("Use Sapphire Preferred")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(ModernColors.textPrimary)

                        Text("Earn 3× points on dining • +$47 expected")
                            .font(.subheadline)
                            .foregroundStyle(ModernColors.textSecondary)
                    }

                    Spacer()

                    VStack {
                        Text("3×")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(ModernColors.reward)

                        Text("DINING")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(ModernColors.textTertiary)
                            .tracking(1)
                    }
                }

                HStack {
                    Button("Why this card?") {
                        // TODO: Show explanation
                    }
                    .font(.subheadline)
                    .foregroundStyle(ModernColors.accent)

                    Spacer()

                    Button(action: {
                        // TODO: Quick action
                    }) {
                        HStack(spacing: ModernSpacing.sm) {
                            Text("Use Card")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, ModernSpacing.xl)
                        .padding(.vertical, ModernSpacing.md)
                        .background(ModernColors.accent, in: RoundedRectangle(cornerRadius: ModernRadius.button))
                    }
                }
            }
            .padding(ModernSpacing.xxxl)
        }
    }
}

struct InsightsSection: View {
    var body: some View {
        VStack(spacing: ModernSpacing.xl) {
            HStack {
                Text("This Week")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(ModernColors.textPrimary)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: ModernSpacing.xl) {
                InsightTile(
                    title: "$127",
                    subtitle: "Earned",
                    color: ModernColors.reward,
                    icon: "dollarsign.circle.fill"
                )

                InsightTile(
                    title: "4.2×",
                    subtitle: "Avg Multiplier",
                    color: ModernColors.accent,
                    icon: "arrow.up.circle.fill"
                )

                InsightTile(
                    title: "18",
                    subtitle: "Transactions",
                    color: ModernColors.success,
                    icon: "creditcard.circle.fill"
                )

                InsightTile(
                    title: "92%",
                    subtitle: "Optimization",
                    color: ModernColors.accent,
                    icon: "checkmark.circle.fill"
                )
            }
        }
    }
}

struct InsightTile: View {
    let title: String
    let subtitle: String
    let color: Color
    let icon: String

    var body: some View {
        ModernGlassCard(style: .secondary) {
            VStack(spacing: ModernSpacing.lg) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: ModernSpacing.sm) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(color)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(ModernColors.textTertiary)
                }
            }
            .padding(ModernSpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PremiumEmptyState: View {
    @Environment(UIState.self) private var uiState

    var body: some View {
        VStack(spacing: ModernSpacing.huge) {
            Spacer()

            VStack(spacing: ModernSpacing.xxxl) {
                // Icon with glow effect
                ZStack {
                    Circle()
                        .fill(ModernColors.accent.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)

                    ModernGlassCard(style: .premium) {
                        Image(systemName: "creditcard.and.123")
                            .font(.system(size: 48))
                            .foregroundStyle(ModernColors.accent)
                            .frame(width: 120, height: 120)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 60))
                }

                VStack(spacing: ModernSpacing.xl) {
                    Text("Optimize Every Purchase")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(ModernColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Connect your cards to get AI-powered recommendations that maximize your rewards at every location.")
                        .font(.body)
                        .foregroundStyle(ModernColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }

                Button(action: {
                    uiState.showPlaidLinkSheet = true
                }) {
                    HStack(spacing: ModernSpacing.lg) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Connect Cards")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ModernSpacing.xl)
                    .background(ModernColors.accent, in: RoundedRectangle(cornerRadius: ModernRadius.container))
                }
                .shadow(
                    color: ModernColors.accent.opacity(0.3),
                    radius: 20,
                    x: 0,
                    y: 8
                )
            }

            Spacer()
        }
        .padding(.horizontal, ModernSpacing.huge)
    }
}

struct SignedOutOverlay: View {
    @Environment(UIState.self) private var uiState

    var body: some View {
        // Blurred background content
        VStack(spacing: ModernSpacing.xxxl) {
            PremiumEmptyState()
        }
        .blur(radius: 20)
        .overlay {
            // Sign-in overlay
            VStack(spacing: ModernSpacing.huge) {
                VStack(spacing: ModernSpacing.xxxl) {
                    // App icon with glow
                    ZStack {
                        Circle()
                            .fill(ModernColors.accent.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .blur(radius: 30)

                        Image(systemName: "sparkles")
                            .font(.system(size: 64))
                            .foregroundStyle(ModernColors.accent)
                    }

                    VStack(spacing: ModernSpacing.xl) {
                        Text("Welcome to Merchant")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(ModernColors.textPrimary)

                        Text("AI-powered card optimization for maximum rewards")
                            .font(.title3)
                            .foregroundStyle(ModernColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                VStack(spacing: ModernSpacing.lg) {
                    Button(action: {
                        uiState.signIn()
                    }) {
                        HStack(spacing: ModernSpacing.lg) {
                            Image(systemName: "applelogo")
                                .font(.title3)
                            Text("Continue with Apple")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ModernSpacing.xl)
                        .background(.white, in: RoundedRectangle(cornerRadius: ModernRadius.container))
                    }

                    Button(action: {
                        uiState.signIn()
                    }) {
                        HStack(spacing: ModernSpacing.lg) {
                            Image(systemName: "envelope.fill")
                                .font(.title3)
                            Text("Continue with Email")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(ModernColors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ModernSpacing.xl)
                        .background(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernRadius.container)
                                .stroke(ModernColors.accent, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, ModernSpacing.huge)
        }
    }
}

#Preview("Signed Out") {
    HomeView()
        .environment(UIState())
}

#Preview("Signed In") {
    let uiState = UIState()
    uiState.isSignedIn = true

    return HomeView()
        .environment(uiState)
}