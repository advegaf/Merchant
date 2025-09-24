// Pick your cards for recommendations during onboarding.

import SwiftUI

struct CardPickerSheet: View {
    @Environment(SelectedCardsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var allCards: [CardUI] = []
    @State private var provider = MockCardArtProvider()
    @State private var showCapacityHint = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Page Title
                    HStack {
                        Text("Choose Your Cards")
                            .font(CopilotDesign.Typography.displayMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    if store.isAtCapacity {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(CopilotDesign.Colors.warning)
                            Text("You can select up to \(SelectedCardsStore.maxSelectedCards) cards.")
                                .font(CopilotDesign.Typography.labelSmall)
                                .foregroundStyle(CopilotDesign.Colors.textSecondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                        .opacity(showCapacityHint ? 1 : 0.8)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                    ForEach(allCards) { card in
                        VStack(spacing: 8) {
                            HighQualityAsyncImage(url: card.artURL, contentMode: .fit, cornerRadius: 12) {
                                Rectangle().fill(.ultraThinMaterial)
                            }
                            .frame(height: 90)

                            Text(card.productName)
                                .font(.caption)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)

                            if store.isSelected(card.selectionKey) {
                                Text(CardBenefitsCatalog.benefits(for: card.selectionKey))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(store.isSelected(card.selectionKey) ? .green : .clear, lineWidth: 2)
                                )
                        )
                        .overlay(alignment: .topTrailing) {
                            if !store.isSelected(card.selectionKey) && store.isAtCapacity {
                                Text("Max")
                                    .font(CopilotDesign.Typography.labelSmall)
                                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background { Capsule().fill(CopilotDesign.Colors.surface2) }
                                    .padding(6)
                            }
                        }
                        .onTapGesture { handleTap(for: card) }
                        .accessibilityAddTraits(store.isSelected(card.selectionKey) ? [.isSelected] : [])
                        .accessibilityLabel(card.productName)
                        .accessibilityHint(store.isSelected(card.selectionKey) ? "Deselect card" : (store.isAtCapacity ? "Maximum selected" : "Select card"))
                    }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 50)
                }
            }
            .background(.ultraThinMaterial)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        let h = UIImpactFeedbackGenerator(style: .light)
                        h.impactOccurred()
                        store.hasCompletedOnboarding = true
                        withAnimation(.easeInOut(duration: 0.2)) { dismiss() }
                    }
                }
            }
        }
        .task {
            if allCards.isEmpty {
                allCards = await provider.fetchCardsForReview()
            }
        }
    }

    private func handleTap(for card: CardUI) {
        let key = card.selectionKey
        if store.isSelected(key) {
            store.toggleSelection(for: key)
            return
        }
        guard !store.isAtCapacity else {
            let notif = UINotificationFeedbackGenerator()
            notif.notificationOccurred(.error)
            withAnimation(.easeInOut(duration: 0.2)) {
                showCapacityHint = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.2)) { showCapacityHint = false }
            }
            return
        }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        store.toggleSelection(for: key)
    }
}

