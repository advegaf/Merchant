// Rules: Beautiful manual spend input matching app aesthetic with card selection
// Inputs: merchant, amount, category, selected card
// Outputs: Adds TransactionRecord to store with calculated rewards
// Constraints: Modern UI, liquid glass effects, proper validation

import SwiftUI

struct AddSpendSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SelectedCardsStore.self) private var selectedCards
    @State private var merchant: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: SpendingCategory = .dining
    @State private var selectedCard: CardUI?
    @State private var showCardPicker = false
    @State private var animateContent = false
    @State private var cards: [CardUI] = []
    @State private var cardProvider = MockCardArtProvider()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Add Transaction")
                            .font(CopilotDesign.Typography.displayMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)

                        Text("Track your spending and earn rewards")
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textSecondary)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 15)
                    }

                    // Form Content
                    VStack(spacing: 20) {
                        // Merchant Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Merchant")
                                .font(CopilotDesign.Typography.labelMedium)
                                .foregroundStyle(CopilotDesign.Colors.textSecondary)

                            CleanCard(style: .flat) {
                                HStack {
                                    Image(systemName: "storefront.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(CopilotDesign.Colors.accent)

                                    TextField("Starbucks, Target, etc.", text: $merchant)
                                        .font(CopilotDesign.Typography.bodyMedium)
                                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                                }
                                .padding(16)
                            }
                        }

                        // Amount Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(CopilotDesign.Typography.labelMedium)
                                .foregroundStyle(CopilotDesign.Colors.textSecondary)

                            CleanCard(style: .flat) {
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(CopilotDesign.Colors.success)

                                    TextField("0.00", text: $amount)
                                        .font(CopilotDesign.Typography.numberMedium)
                                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                                        .keyboardType(.decimalPad)
                                }
                                .padding(16)
                            }
                        }

                        // Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(CopilotDesign.Typography.labelMedium)
                                .foregroundStyle(CopilotDesign.Colors.textSecondary)

                            CategoryPicker(selectedCategory: $selectedCategory)
                        }

                        // Card Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card Used")
                                .font(CopilotDesign.Typography.labelMedium)
                                .foregroundStyle(CopilotDesign.Colors.textSecondary)

                            if let card = selectedCard {
                                SelectedCardDisplay(card: card) {
                                    showCardPicker = true
                                }
                            } else {
                                EmptyCardSelector {
                                    showCardPicker = true
                                }
                            }
                        }

                        // Rewards Preview
                        if let card = selectedCard, let amount = Double(amount), amount > 0 {
                            RewardsPreview(card: card, category: selectedCategory, amount: amount)
                        }
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(.ultraThinMaterial)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CleanButton("Cancel", style: .glass, size: .small) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Save", style: .glass, size: .small) {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .sheet(isPresented: $showCardPicker) {
            QuickCardPicker(cards: cards, selectedCard: $selectedCard)
        }
        .task {
            await loadCards()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }

    private var canSave: Bool {
        guard !merchant.isEmpty,
              let amt = Double(amount), amt > 0,
              selectedCard != nil else { return false }
        return true
    }

    private func save() {
        guard let amt = Double(amount),
              let card = selectedCard else { return }

        let rec = TransactionRecord(
            merchant: merchant,
            amount: amt,
            category: selectedCategory.rawValue,
            date: Date(),
            cardUsed: card.productName
        )
        TransactionStore.shared.add(rec)

        // Add to recent activity
        let _ = ActivityEntry(
            merchant: merchant,
            amount: amt,
            category: selectedCategory,
            cardUsed: card.productName,
            pointsEarned: calculatePoints(amount: amt, category: selectedCategory),
            cashValueEarned: calculateCashValue(amount: amt, category: selectedCategory),
            timestamp: Date()
        )

        dismiss()
    }

    private func loadCards() async {
        let allCards = await cardProvider.fetchCardsForReview()
        let selectedKeys = SelectedCardsStore.shared.selectedKeys
        cards = selectedKeys.isEmpty ? allCards : allCards.filter { selectedKeys.contains($0.selectionKey) }

        // Auto-select first card if available
        if selectedCard == nil && !cards.isEmpty {
            selectedCard = cards.first
        }
    }

    private func calculatePoints(amount: Double, category: SpendingCategory) -> Double {
        if let card = selectedCard {
            let earnings = EnhancedRulesEngine.shared.earnings(forCardName: card.productName, category: category, amount: amount)
            // Only return points meaningfully for points-earning cards; for cash back, approximate points at 100 per $1 cash value
            if earnings.description.contains("% cash back") {
                return earnings.cashValue * 100.0
            }
            return earnings.points
        }
        let userCards = SelectedCardsStore.shared.selectedProductNames
        let recommendation = EnhancedRulesEngine.shared.recommendCard(for: category, amount: amount, userCards: userCards)
        return recommendation.earnings.points
    }

    private func calculateCashValue(amount: Double, category: SpendingCategory) -> Double {
        if let card = selectedCard {
            let earnings = EnhancedRulesEngine.shared.earnings(forCardName: card.productName, category: category, amount: amount)
            return earnings.cashValue
        }
        let userCards = SelectedCardsStore.shared.selectedProductNames
        let recommendation = EnhancedRulesEngine.shared.recommendCard(for: category, amount: amount, userCards: userCards)
        return recommendation.earnings.cashValue
    }
}

// MARK: - Supporting Components

struct CategoryPicker: View {
    @Binding var selectedCategory: SpendingCategory

    let categories: [SpendingCategory] = [.dining, .groceries, .gas, .travel, .streaming, .drugstores, .departmentStores, .online]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(categories, id: \.self) { category in
                CategoryButton(
                    category: category,
                    isSelected: selectedCategory == category
                ) {
                    selectedCategory = category
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: SpendingCategory
    let isSelected: Bool
    let action: () -> Void

    private var label: String {
        switch category {
        case .dining:
            return "Dining"
        case .departmentStores:
            return "Retail Stores"
        default:
            return category.displayName
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white : CopilotDesign.Colors.textSecondary)

                Text(label)
                    .font(CopilotDesign.Typography.labelSmall)
                    .foregroundStyle(isSelected ? Color.white : CopilotDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? CopilotDesign.Colors.accent : CopilotDesign.Colors.surface)
                    .overlay {
                        if !isSelected {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(CopilotDesign.Colors.border, lineWidth: 1)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

struct SelectedCardDisplay: View {
    let card: CardUI
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CleanCard(style: .flat) {
                HStack(spacing: 12) {
                    AsyncImage(url: card.artURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CopilotDesign.Colors.surface2)
                            .overlay {
                                Image(systemName: "creditcard.fill")
                                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
                            }
                    }
                    .frame(width: 50, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.productName)
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                            .lineLimit(1)

                        Text("•••• \(card.last4)")
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
    }
}

struct EmptyCardSelector: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CleanCard(style: .flat) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(CopilotDesign.Colors.surface2)
                        .frame(width: 50, height: 32)
                        .overlay {
                            Image(systemName: "plus")
                                .foregroundStyle(CopilotDesign.Colors.accent)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Select Card")
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                        Text("Choose which card you used")
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
    }
}

struct RewardsPreview: View {
    let card: CardUI
    let category: SpendingCategory
    let amount: Double

    private var earnings: (points: Double, cash: Double, desc: String) {
        let e = EnhancedRulesEngine.shared.earnings(forCardName: card.productName, category: category, amount: amount)
        return (e.points, e.cashValue, e.description)
    }

    var body: some View {
        CleanCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(CopilotDesign.Colors.accent)

                    Text("Estimated Rewards")
                        .font(CopilotDesign.Typography.labelMedium)
                        .foregroundStyle(CopilotDesign.Colors.textSecondary)

                    Spacer()
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("+\(Int(earnings.points)) pts")
                            .font(CopilotDesign.Typography.numberMedium)
                            .foregroundStyle(CopilotDesign.Colors.success)

                        Text("~$\(String(format: "%.2f", earnings.cash)) value")
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }

                    Spacer()

                    Text(multiplierText)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .fill(CopilotDesign.Colors.accent.opacity(0.1))
                        }
                }
            }
            .padding(16)
        }
    }

    private var multiplierText: String {
        if let exact = EnhancedRulesEngine.shared.rewardRate(forCardName: card.productName, category: category) {
            if exact.isPercentage {
                return String(format: "%.0f%% cash back", exact.rate)
            } else {
                return String(format: "%.1f× multiplier", exact.rate)
            }
        }
        return earnings.desc
    }
}

struct QuickCardPicker: View {
    @Environment(\.dismiss) private var dismiss
    let cards: [CardUI]
    @Binding var selectedCard: CardUI?

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(cards) { card in
                        CardPickerTile(
                            card: card,
                            isSelected: selectedCard?.id == card.id
                        ) {
                            selectedCard = card
                            dismiss()
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Select Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CardPickerTile: View {
    let card: CardUI
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CleanCard(style: isSelected ? .elevated : .flat) {
                VStack(spacing: 12) {
                    AsyncImage(url: card.artURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CopilotDesign.Colors.surface2)
                            .overlay {
                                Image(systemName: "creditcard.fill")
                                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
                            }
                    }
                    .frame(height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(spacing: 4) {
                        Text(card.productName)
                            .font(CopilotDesign.Typography.labelMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Text("•••• \(card.last4)")
                            .font(CopilotDesign.Typography.labelSmall)
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }
                }
                .padding(16)
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(CopilotDesign.Colors.accent, lineWidth: 2)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}


