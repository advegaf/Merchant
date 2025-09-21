// Rules: Clean, professional home screen with consistent design system
// Inputs: UIState authentication status, card data, user profile
// Outputs: Polished dashboard with proper hierarchy and spacing
// Constraints: Clean animations, consistent spacing, professional feel

import SwiftUI

struct HomeView: View {
    @Environment(UIState.self) private var uiState
    @Environment(SelectedCardsStore.self) private var selectedCards
    @Environment(UserProfileStore.self) private var userProfile
    @State private var cards: [CardUI] = []
    @State private var cardProvider = MockCardArtProvider()
    @State private var selectedTab: TabBarItem = .home

    var body: some View {
        ZStack {
            CopilotDesign.Colors.background
                .ignoresSafeArea()

            if !selectedCards.hasCompletedOnboarding {
                CleanWelcomeView {
                    SelectedCardsStore.shared.hasCompletedOnboarding = true
                }
                .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    // Scrollable content with header inside
                    MainContent(cards: cards)
                }
            }
        }
        .task {
            if cards.isEmpty {
                await reloadCards()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectedCardsChanged)) { _ in
            Task { await reloadCards() }
        }
        .sheet(isPresented: Binding(
            get: { uiState.showNearbySheet },
            set: { uiState.showNearbySheet = $0 }
        )) {
            NearbySheet()
        }
        .sheet(isPresented: Binding(
            get: { uiState.showAddSpendSheet },
            set: { uiState.showAddSpendSheet = $0 }
        )) {
            AddSpendSheet()
        }
        .sheet(isPresented: Binding(
            get: { uiState.showTransactionsSheet },
            set: { uiState.showTransactionsSheet = $0 }
        )) {
            TransactionsListSheet()
        }
        .sheet(isPresented: Binding(
            get: { uiState.showNotificationSettings },
            set: { uiState.showNotificationSettings = $0 }
        )) {
            NotificationSettingsSheet()
        }
        .sheet(isPresented: Binding(
            get: { uiState.showOptimizationBreakdown },
            set: { uiState.showOptimizationBreakdown = $0 }
        )) {
            OptimizationBreakdownSheet()
        }
        .sheet(isPresented: Binding(
            get: { uiState.showCardPicker },
            set: { uiState.showCardPicker = $0 }
        )) {
            CardPickerSheet()
                .environment(SelectedCardsStore.shared)
        }
        .sheet(isPresented: Binding(
            get: { uiState.showSettingsSheet },
            set: { uiState.showSettingsSheet = $0 }
        )) {
            BeautifulSettingsSheet()
        }
        .sheet(isPresented: Binding(
            get: { uiState.showNearbyCategories },
            set: { uiState.showNearbyCategories = $0 }
        )) {
            NearbyCategoriesSheet()
        }
    }
}

// MARK: - Data Loading

extension HomeView {
    fileprivate func reloadCards() async {
        let all = await cardProvider.fetchCardsForReview()
        let selected = SelectedCardsStore.shared.selectedKeys
        if selected.isEmpty {
            cards = all
        } else {
            let filtered = all.filter { selected.contains($0.selectionKey) }
            cards = filtered.isEmpty ? all : filtered
        }
    }
}

struct MainContent: View {
    let cards: [CardUI]
    @Environment(UIState.self) private var uiState
    @Environment(UserProfileStore.self) private var userProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header (scrolls; not sticky)
                HeaderSection()

                // Cards Section
                if !cards.isEmpty {
                    CardsSection(cards: cards)
                }

                // Nearby quick action (moved below cards)
                NearbyQuickButton()


                // Stats Section
                StatsSection()

                // Recent Activity
                ActivitySection()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

struct HeaderSection: View {
    @Environment(UserProfileStore.self) private var userProfile
    @Environment(UIState.self) private var uiState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Good evening")
                    .font(CopilotDesign.Typography.bodyMedium)
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)

                Text(userProfile.displayName)
                    .font(CopilotDesign.Typography.displayMedium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
            }

            Spacer()

            // Settings button
            Button(action: { uiState.showSettingsSheet = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                    .frame(width: 40, height: 40)
                    .background { Circle().fill(.ultraThinMaterial) }
            }
            .buttonStyle(.plain)
        }
    }
}

struct NearbyQuickButton: View {
    @Environment(UIState.self) private var uiState
    var body: some View {
        Button(action: { uiState.showNearbySheet = true }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(CopilotDesign.Colors.accent.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "location.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Nearby")
                        .font(CopilotDesign.Typography.bodyMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                    Text("Location Based Recommendations")
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .buttonStyle(.plain)
    }
}

// RecommendationQuickButton removed per request

struct CardsSection: View {
    let cards: [CardUI]
    @Environment(UIState.self) private var uiState

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Cards")
                    .font(CopilotDesign.Typography.headlineMedium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                Spacer()

                Button(action: {
                    uiState.showCardPicker = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 12, weight: .medium))
                        Text("Manage")
                            .font(CopilotDesign.Typography.labelSmall)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(CopilotDesign.Colors.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(CopilotDesign.Colors.accent.opacity(0.1))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(CopilotDesign.Colors.accent.opacity(0.2), lineWidth: 1)
                            }
                    }
                }
                .buttonStyle(.plain)
            }

            PremiumCardsStack(cards: cards)
                .frame(height: 240)
        }
    }
}

struct StatsSection: View {
    @Environment(UIState.self) private var uiState
    @StateObject private var activityProvider = RecentActivityProvider()

    private var weeklyStats: (earned: Double, avgMultiplier: Double, transactions: Int, optimization: Double) {
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        let weeklyTransactions = activityProvider.activities.filter { $0.timestamp >= oneWeekAgo }

        let totalEarnedCash = weeklyTransactions.reduce(0) { $0 + $1.cashValueEarned }
        let totalSpent = weeklyTransactions.reduce(0) { $0 + $1.amount }
        let totalPoints = weeklyTransactions.reduce(0) { $0 + $1.pointsEarned }
        let avgMultiplier = totalSpent > 0 ? (totalPoints / totalSpent) : 0
        let transactionCount = weeklyTransactions.count

        // Assume an achievable max of 5x for optimization gauge
        let maxPossiblePoints = totalSpent * 5.0
        let optimization = maxPossiblePoints > 0 ? (totalPoints / maxPossiblePoints) * 100 : 0

        return (totalEarnedCash, avgMultiplier, transactionCount, optimization)
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("This Week")
                    .font(CopilotDesign.Typography.headlineMedium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                let hasData = weeklyStats.transactions > 0

                StatCard(
                    value: hasData ? String(format: "$%.0f", weeklyStats.earned) : "$0",
                    label: "Earned",
                    trend: hasData ? "+12%" : "—",
                    color: CopilotDesign.Colors.success
                )

                StatCard(
                    value: hasData ? String(format: "%.1f×", weeklyStats.avgMultiplier) : "—",
                    label: "Avg multiplier",
                    trend: hasData ? "+5%" : "—",
                    color: CopilotDesign.Colors.accent
                )

                StatCard(
                    value: "\(weeklyStats.transactions)",
                    label: "Transactions",
                    trend: hasData ? (weeklyStats.transactions > 5 ? "+\(weeklyStats.transactions - 5)" : "−\(5 - weeklyStats.transactions)") : "—",
                    color: CopilotDesign.Colors.info
                )

                StatCard(
                    value: hasData ? String(format: "%.0f%%", weeklyStats.optimization) : "—",
                    label: "Optimization",
                    trend: hasData ? "+8%" : "—",
                    color: CopilotDesign.Colors.success
                ) {
                    uiState.showOptimizationBreakdown = true
                }
            }
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let trend: String
    let color: Color
    let action: (() -> Void)?

    init(value: String, label: String, trend: String, color: Color, action: (() -> Void)? = nil) {
        self.value = value
        self.label = label
        self.trend = trend
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            CleanCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 8, height: 8)
                    Spacer()
                    Text(trend)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .fill(color.opacity(0.1))
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(CopilotDesign.Typography.numberLarge)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)

                    Text(label)
                        .font(CopilotDesign.Typography.labelMedium)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }
            }
            .padding(16)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ActivitySection: View {
    @Environment(UIState.self) private var uiState
    @StateObject private var activityProvider = RecentActivityProvider()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(CopilotDesign.Typography.headlineMedium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
                Spacer()
                HStack(spacing: 8) {
                    Button(action: {
                        uiState.showAddSpendSheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12, weight: .medium))
                            Text("Add")
                                .font(CopilotDesign.Typography.labelSmall)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(CopilotDesign.Colors.success)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(CopilotDesign.Colors.success.opacity(0.1))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(CopilotDesign.Colors.success.opacity(0.2), lineWidth: 1)
                                }
                        }
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        uiState.showTransactionsSheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 12, weight: .medium))
                            Text("View All")
                                .font(CopilotDesign.Typography.labelSmall)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(CopilotDesign.Colors.info)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(CopilotDesign.Colors.info.opacity(0.1))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(CopilotDesign.Colors.info.opacity(0.2), lineWidth: 1)
                                }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(spacing: 12) {
                ForEach(Array(activityProvider.activities.prefix(3))) { activity in
                    CleanActivityRow(
                        merchant: activity.merchant,
                        amount: activity.formattedAmount,
                        points: activity.formattedPoints,
                        category: activity.category.displayName,
                        time: activity.formattedTime
                    )
                }
            }
        }
    }
}

struct CleanActivityRow: View {
    let merchant: String
    let amount: String
    let points: String
    let category: String
    let time: String

    var body: some View {
        CleanCard(style: .flat) {
            HStack(spacing: 16) {
                // Category icon
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: categoryIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(categoryColor)
                    }

                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(merchant)
                        .font(CopilotDesign.Typography.bodyMedium)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)

                    Text("\(category) • \(time)")
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }

                Spacer()

                // Amount and points
                VStack(alignment: .trailing, spacing: 4) {
                    Text(amount)
                        .font(CopilotDesign.Typography.numberSmall)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)

                    Text(points)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.success)
                }
            }
            .padding(16)
        }
    }

    private var categoryIcon: String {
        switch category.lowercased() {
        case "dining": return "fork.knife.circle.fill"
        case "gas": return "fuelpump.fill"
        case "groceries": return "cart.fill"
        default: return "creditcard.fill"
        }
    }

    private var categoryColor: Color {
        switch category.lowercased() {
        case "dining": return CopilotDesign.Colors.brandOrange
        case "gas": return CopilotDesign.Colors.brandBlue
        case "groceries": return CopilotDesign.Colors.brandGreen
        default: return CopilotDesign.Colors.accent
        }
    }
}

// MARK: - Rotating Cards Stack

struct RotatingCardsStack: View {
    let cards: [CardUI]
    @State private var currentIndex = 0
    @State private var isRotating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    RotatingCardView(
                        card: card,
                        index: index,
                        currentIndex: currentIndex,
                        totalCards: cards.count
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            rotateToNext()
                        }
                    }
                }
            }
        }
    }

    private func rotateToNext() {
        guard !cards.isEmpty else { return }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        currentIndex = (currentIndex + 1) % cards.count
    }

    private func rotateToPrevious() {
        guard !cards.isEmpty else { return }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        currentIndex = (currentIndex - 1 + cards.count) % cards.count
    }
}

struct RotatingCardView: View {
    let card: CardUI
    let index: Int
    let currentIndex: Int
    let totalCards: Int

    private var cardOffset: CGFloat {
        let relativeIndex = (index - currentIndex + totalCards) % totalCards
        return CGFloat(relativeIndex) * 20 - 40
    }

    private var cardScale: CGFloat {
        let relativeIndex = (index - currentIndex + totalCards) % totalCards
        if relativeIndex == 0 {
            return 1.0
        } else {
            return 0.9 + CGFloat(3 - relativeIndex) * 0.03
        }
    }

    private var cardOpacity: Double {
        let relativeIndex = (index - currentIndex + totalCards) % totalCards
        if relativeIndex <= 2 {
            return 1.0 - Double(relativeIndex) * 0.3
        } else {
            return 0.1
        }
    }

    private var cardRotation: Double {
        let relativeIndex = (index - currentIndex + totalCards) % totalCards
        return Double(relativeIndex) * 5.0
    }

    var body: some View {
        VStack(spacing: 12) {
            HighQualityAsyncImage(url: card.artURL, contentMode: .fit, cornerRadius: 16) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CopilotDesign.Colors.surface2)
                    .overlay {
                        VStack {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(CopilotDesign.Colors.textTertiary)

                            Text(card.productName)
                                .font(CopilotDesign.Typography.labelMedium)
                                .foregroundStyle(CopilotDesign.Colors.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                    }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 10,
                x: 0,
                y: 5
            )

            if index == currentIndex {
                VStack(spacing: 4) {
                    Text(card.productName)
                        .font(CopilotDesign.Typography.bodyMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text("•••• \(card.last4)")
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .offset(x: cardOffset, y: 0)
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .rotation3DEffect(
            .degrees(cardRotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .zIndex(index == currentIndex ? 1000 : Double(1000 - index))
    }
}

#Preview {
    HomeView()
        .environment(UIState())
        .environment(SelectedCardsStore.shared)
        .environment(UserProfileStore.shared)
}