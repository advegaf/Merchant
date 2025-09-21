// Rules: Beautiful transactions list matching app aesthetic with filtering and search
// Inputs: TransactionStore, RecentActivityProvider
// Outputs: Styled transaction list with rich data and search capabilities
// Constraints: Modern UI, liquid glass effects, proper categorization

import SwiftUI

struct TransactionsListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var activityProvider = RecentActivityProvider()
    @State private var records: [TransactionRecord] = []
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var animateContent = false

    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case recent = "Recent"
        case dining = "Dining"
        case groceries = "Groceries"
        case gas = "Gas"
        case travel = "Travel"

        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .recent: return "clock.fill"
            case .dining: return "fork.knife.circle.fill"
            case .groceries: return "cart.fill"
            case .gas: return "fuelpump.fill"
            case .travel: return "airplane"
            }
        }
    }

    var filteredTransactions: [ActivityEntry] {
        var filtered = activityProvider.activities

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.merchant.localizedCaseInsensitiveContains(searchText) ||
                $0.category.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch selectedFilter {
        case .all:
            break
        case .recent:
            let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 3600)
            filtered = filtered.filter { $0.timestamp >= sevenDaysAgo }
        case .dining:
            filtered = filtered.filter { $0.category == .dining || $0.category == .restaurants }
        case .groceries:
            filtered = filtered.filter { $0.category == .groceries }
        case .gas:
            filtered = filtered.filter { $0.category == .gas }
        case .travel:
            filtered = filtered.filter { $0.category == .travel || $0.category == .hotels || $0.category == .airfare }
        }

        return filtered.sorted { $0.timestamp > $1.timestamp }
    }

    var totalSpent: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

    var totalEarned: Double {
        filteredTransactions.reduce(0) { $0 + $1.cashValueEarned }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Summary
                    VStack(spacing: 20) {
                        HStack {
                            Text("Transaction History")
                                .font(CopilotDesign.Typography.displayMedium)
                                .foregroundStyle(CopilotDesign.Colors.textPrimary)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)

                            Spacer()
                        }

                        // Summary Cards
                        HStack(spacing: 16) {
                            SummaryCard(
                                title: "Total Spent",
                                value: String(format: "$%.2f", totalSpent),
                                icon: "creditcard.fill",
                                color: CopilotDesign.Colors.info
                            )

                            SummaryCard(
                                title: "Rewards Earned",
                                value: String(format: "$%.2f", totalEarned),
                                icon: "star.fill",
                                color: CopilotDesign.Colors.success
                            )
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)

                        // Search Bar
                        SearchBar(text: $searchText)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 10)

                        // Filter Tabs
                        FilterTabs(selectedFilter: $selectedFilter)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    // Transactions List
                    LazyVStack(spacing: 12) {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .padding(.horizontal, 20)
                        }

                        if filteredTransactions.isEmpty {
                            EmptyTransactionsView(filter: selectedFilter, hasSearchText: !searchText.isEmpty)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 40)
                        }
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)

                    Spacer(minLength: 100)
                }
            }
            .background(.ultraThinMaterial)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        let h = UIImpactFeedbackGenerator(style: .light)
                        h.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.2)) { dismiss() }
                    }
                }
            }
        }
        .onAppear {
            records = TransactionStore.shared.all()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .transactionsChanged)) { _ in
            records = TransactionStore.shared.all()
        }
    }
}

// MARK: - Supporting Components

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        CleanCard {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(CopilotDesign.Typography.numberLarge)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)

                    Text(title)
                        .font(CopilotDesign.Typography.labelMedium)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        CleanCard(style: .flat) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)

                TextField("Search transactions...", text: $text)
                    .font(CopilotDesign.Typography.bodyMedium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct FilterTabs: View {
    @Binding var selectedFilter: TransactionsListSheet.TransactionFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TransactionsListSheet.TransactionFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct FilterTab: View {
    let filter: TransactionsListSheet.TransactionFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: filter.icon)
                    .font(.system(size: 14, weight: .medium))

                Text(filter.rawValue)
                    .font(CopilotDesign.Typography.labelMedium)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? Color.white : CopilotDesign.Colors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(isSelected ? CopilotDesign.Colors.accent : CopilotDesign.Colors.surface)
                    .overlay {
                        if !isSelected {
                            Capsule()
                                .strokeBorder(CopilotDesign.Colors.border, lineWidth: 1)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

struct TransactionRow: View {
    let transaction: ActivityEntry

    private var categoryColor: Color {
        switch transaction.category {
        case .dining, .restaurants: return CopilotDesign.Colors.brandOrange
        case .groceries: return CopilotDesign.Colors.brandGreen
        case .gas: return CopilotDesign.Colors.brandBlue
        case .travel, .hotels, .airfare: return CopilotDesign.Colors.info
        default: return CopilotDesign.Colors.accent
        }
    }

    var body: some View {
        CleanCard(style: .flat) {
            HStack(spacing: 16) {
                // Category Icon
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: transaction.category.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(categoryColor)
                    }

                // Transaction Details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(transaction.merchant)
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        Text(transaction.formattedAmount)
                            .font(CopilotDesign.Typography.numberSmall)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                    }

                    HStack {
                        Text(transaction.category.displayName)
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)

                        Text("•")
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)

                        Text(transaction.formattedTime)
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)

                        Spacer()

                        Text(transaction.formattedPoints)
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.success)
                    }

                    // Card Used
                    Text(transaction.cardUsed)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                        .opacity(0.8)
                }
            }
            .padding(16)
        }
    }
}

struct EmptyTransactionsView: View {
    let filter: TransactionsListSheet.TransactionFilter
    let hasSearchText: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: hasSearchText ? "magnifyingglass" : "list.bullet")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(CopilotDesign.Colors.textTertiary)

            VStack(spacing: 8) {
                Text(hasSearchText ? "No Results Found" : "No Transactions")
                    .font(CopilotDesign.Typography.headlineMedium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                Text(hasSearchText ?
                     "Try adjusting your search terms" :
                     "Your \(filter.rawValue.lowercased()) transactions will appear here")
                    .font(CopilotDesign.Typography.bodyMedium)
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}


