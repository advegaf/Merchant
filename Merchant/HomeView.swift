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
                let all = await cardProvider.fetchCardsForReview()
                let selected = SelectedCardsStore.shared.selectedKeys
                cards = selected.isEmpty ? all : all.filter { selected.contains($0.selectionKey) }
            }
        }
        .onChange(of: uiState.isSignedIn) { _, newValue in
            if newValue && cards.isEmpty {
                Task {
                    let all = await cardProvider.fetchCardsForReview()
                    let selected = SelectedCardsStore.shared.selectedKeys
                    cards = selected.isEmpty ? all : all.filter { selected.contains($0.selectionKey) }
                    uiState.presentCardPickerIfNeeded()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectedCardsChanged)) { _ in
            Task {
                let all = await cardProvider.fetchCardsForReview()
                let selected = SelectedCardsStore.shared.selectedKeys
                withAnimation {
                    cards = selected.isEmpty ? all : all.filter { selected.contains($0.selectionKey) }
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
                    // Live Activity-style current session
                    LiveSessionPanel()

                    // Quick Actions Grid
                    QuickActionsGrid()

                    // Now panel with current recommendation
                    NowRecommendationPanel()

                    // Cards section with enhanced styling
                    VStack(spacing: ModernSpacing.xl) {
                        HStack {
                            Text("Your Cards")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(ModernColors.textPrimary)
                            Spacer()
                            Button("Manage") { uiState.showCardPicker = true }
                            .font(.subheadline)
                            .foregroundStyle(ModernColors.accent)
                        }

                        CardsStack(cards: cards)
                            .frame(height: 280)
                    }

                    // Enhanced Weekly Summary with iOS-style cards
                    WeeklySummarySection()

                    // Insights section
                    if showInsights {
                        InsightsSection()
                    }

                    // Recent Activity Feed
                    RecentActivitySection()
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
                    // Mock card addition - will connect real cards later
                    withAnimation(CinematicSprings.elegant) {
                        uiState.signIn()
                    }
                }) {
                    HStack(spacing: ModernSpacing.lg) {
                        Image(systemName: "creditcard.and.123")
                            .font(.title3)
                        Text("Add Cards")
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

// MARK: - Enhanced iOS Components

struct LiveSessionPanel: View {
    @State private var isActive = true
    @State private var currentLocation = "The Local Bistro"
    @State private var sessionDuration = "12m"

    var body: some View {
        ModernGlassCard(style: .premium) {
            HStack(spacing: ModernSpacing.lg) {
                // Live indicator with pulsing animation
                ZStack {
                    Circle()
                        .fill(ModernColors.success)
                        .frame(width: 12, height: 12)
                        .scaleEffect(isActive ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isActive)

                    Circle()
                        .fill(ModernColors.success.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .scaleEffect(isActive ? 1.5 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isActive)
                }

                VStack(alignment: .leading, spacing: ModernSpacing.xs) {
                    HStack {
                        Text("Live Session")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(ModernColors.success)

                        Text("•")
                            .foregroundStyle(ModernColors.textTertiary)

                        Text(sessionDuration)
                            .font(.caption)
                            .foregroundStyle(ModernColors.textTertiary)
                    }

                    Text(currentLocation)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ModernColors.textPrimary)
                }

                Spacer()

                Button(action: {
                    withAnimation(CinematicSprings.elegant) {
                        isActive.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(ModernColors.accent)
                        .padding(ModernSpacing.sm)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                        }
                }
            }
            .padding(ModernSpacing.xl)
        }
        .onAppear {
            isActive = true
        }
    }
}

struct QuickActionsGrid: View {
    @Environment(UIState.self) private var uiState
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: ModernSpacing.lg) {
            QuickActionButton(
                icon: "location.fill",
                title: "Nearby",
                color: ModernColors.accent
            )

            QuickActionButton(
                icon: "chart.bar.fill",
                title: "Insights",
                color: ModernColors.premium
            )

            Button(action: {
                uiState.presentPlaidLink()
            }) {
                VStack(spacing: ModernSpacing.sm) {
                    Image(systemName: "link")
                        .font(.title2)
                        .foregroundStyle(ModernColors.reward)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    Circle()
                                        .stroke(ModernColors.reward.opacity(0.2), lineWidth: 1)
                                }
                        }

                    Text("Connect")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(ModernColors.textSecondary)
                }
            }

            QuickActionButton(
                icon: "gearshape.fill",
                title: "Settings",
                color: ModernColors.textSecondary
            )
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            CinematicHaptics.play(.selection)
        }) {
            VStack(spacing: ModernSpacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Circle()
                                    .stroke(color.opacity(0.2), lineWidth: 1)
                            }
                    }

                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(ModernColors.textSecondary)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(CinematicSprings.immediate, value: isPressed)
        .onLongPressGesture(minimumDuration: 0) { isPressed in
            self.isPressed = isPressed
        } perform: {}
    }
}

struct WeeklySummarySection: View {
    var body: some View {
        VStack(spacing: ModernSpacing.xl) {
            HStack {
                Text("This Week")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(ModernColors.textPrimary)
                Spacer()
                Button("View All") {
                    // TODO: Navigate to full insights
                }
                .font(.subheadline)
                .foregroundStyle(ModernColors.accent)
            }

            ModernGlassCard(style: .secondary) {
                VStack(spacing: ModernSpacing.lg) {
                    // Top metrics row
                    HStack(spacing: ModernSpacing.lg) {
                        WeeklyMetricTile(
                            value: "$127",
                            label: "Earned",
                            color: ModernColors.success,
                            icon: "arrow.up.circle.fill"
                        )

                        WeeklyMetricTile(
                            value: "4.2×",
                            label: "Avg Multiplier",
                            color: ModernColors.premium,
                            icon: "multiply.circle.fill"
                        )
                    }

                    // Progress indicator
                    VStack(alignment: .leading, spacing: ModernSpacing.sm) {
                        HStack {
                            Text("Optimization Score")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(ModernColors.textPrimary)
                            Spacer()
                            Text("92%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(ModernColors.success)
                        }

                        ProgressView(value: 0.92)
                            .tint(ModernColors.success)
                            .background(ModernColors.textQuaternary.opacity(0.2))
                    }
                }
                .padding(ModernSpacing.xl)
            }
        }
    }
}

struct WeeklyMetricTile: View {
    let value: String
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: ModernSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: ModernSpacing.xs) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(ModernColors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(ModernSpacing.lg)
        .background {
            RoundedRectangle(cornerRadius: ModernRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: ModernRadius.lg)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                }
        }
    }
}

struct RecentActivitySection: View {
    var body: some View {
        VStack(spacing: ModernSpacing.xl) {
            HStack {
                Text("Recent Activity")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(ModernColors.textPrimary)
                Spacer()
            }

            VStack(spacing: ModernSpacing.md) {
                ActivityRow(
                    merchant: "Starbucks Coffee",
                    amount: "$4.25",
                    points: "+13 pts",
                    time: "2h ago",
                    category: .dining
                )

                ActivityRow(
                    merchant: "Shell Gas Station",
                    amount: "$45.20",
                    points: "+90 pts",
                    time: "1d ago",
                    category: .gas
                )

                ActivityRow(
                    merchant: "Whole Foods Market",
                    amount: "$87.50",
                    points: "+175 pts",
                    time: "2d ago",
                    category: .groceries
                )
            }
        }
    }
}

struct ActivityRow: View {
    let merchant: String
    let amount: String
    let points: String
    let time: String
    let category: PurchaseCategory

    var body: some View {
        ModernGlassCard(style: .secondary) {
            HStack(spacing: ModernSpacing.lg) {
                // Category icon
                Image(systemName: categoryIcon(for: category))
                    .font(.title3)
                    .foregroundStyle(ModernColors.purchaseContextColor(for: category))
                    .frame(width: 40, height: 40)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Circle()
                                    .stroke(ModernColors.purchaseContextColor(for: category).opacity(0.2), lineWidth: 1)
                            }
                    }

                VStack(alignment: .leading, spacing: ModernSpacing.xs) {
                    Text(merchant)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(ModernColors.textPrimary)

                    Text(time)
                        .font(.caption)
                        .foregroundStyle(ModernColors.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: ModernSpacing.xs) {
                    Text(amount)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(ModernColors.textPrimary)

                    Text(points)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(ModernColors.success)
                }
            }
            .padding(ModernSpacing.lg)
        }
    }

    private func categoryIcon(for category: PurchaseCategory) -> String {
        switch category {
        case .dining: return "fork.knife"
        case .groceries: return "cart.fill"
        case .gas: return "fuelpump.fill"
        case .travel: return "airplane"
        case .shopping: return "bag.fill"
        case .utilities: return "house.fill"
        case .other: return "ellipsis.circle.fill"
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