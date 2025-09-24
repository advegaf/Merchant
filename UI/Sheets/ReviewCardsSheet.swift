
import SwiftUI

struct ReviewCardsSheet: View {
    @Environment(UIState.self) private var uiState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCards: Set<UUID> = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: ThemeSpacing.xl) {
                if uiState.cardsToReview.isEmpty {
                    VStack(spacing: ThemeSpacing.l) {
                        Spacer()

                        Image(systemName: "creditcard.trianglebadge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        VStack(spacing: ThemeSpacing.s) {
                            Text("No Cards Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            Text("We couldn't find any supported cards with available artwork. Try linking additional accounts.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()

                        Button("Close") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ThemeSpacing.l)
                        .background {
                            GlassCard {
                                Color.clear
                            }
                        }
                    }
                    .padding(ThemeSpacing.xl)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ThemeSpacing.l) {
                            ForEach(uiState.cardsToReview) { card in
                                CardReviewRow(
                                    card: card,
                                    isSelected: selectedCards.contains(card.id)
                                ) {
                                    toggleSelection(for: card.id)
                                }
                            }
                        }
                        .padding(ThemeSpacing.xl)
                    }

                    VStack(spacing: ThemeSpacing.l) {
                        Button(action: confirmSelection) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.black)
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Add \(selectedCards.count) Card\(selectedCards.count == 1 ? "" : "s")")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ThemeSpacing.l)
                            .background(
                                selectedCards.isEmpty ? Color.gray : ThemeColor.primaryNeon,
                                in: RoundedRectangle(cornerRadius: ThemeRadius.container)
                            )
                        }
                        .disabled(selectedCards.isEmpty || isLoading)

                        CleanButton("Cancel", style: .glass, size: .small) {
                            dismiss()
                        }
                    }
                    .padding(ThemeSpacing.xl)
                }
            }
            .background {
                NeonBackground()
            }
            .navigationTitle("Review Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedCards = Set(uiState.cardsToReview.map(\.id))
        }
    }

    private func toggleSelection(for cardId: UUID) {
        if selectedCards.contains(cardId) {
            selectedCards.remove(cardId)
        } else {
            selectedCards.insert(cardId)
        }

        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        #endif
    }

    private func confirmSelection() {
        isLoading = true

        Task {
            try? await Task.sleep(for: .milliseconds(800))

            await MainActor.run {
                let confirmedCards = uiState.cardsToReview.filter { selectedCards.contains($0.id) }
                uiState.completeCardReview(selectedCards: confirmedCards)
                isLoading = false
                dismiss()
            }
        }
    }
}

struct CardReviewRow: View {
    let card: CardUI
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            GlassCard {
                HStack(spacing: ThemeSpacing.l) {
                    AsyncImage(url: card.artURL) { image in
                        image
                            .resizable()
                            .aspectRatio(1.6, contentMode: .fit)
                            .frame(width: 60, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .frame(width: 60, height: 40)
                            .overlay {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .tint(ThemeColor.primaryNeon)
                            }
                    }

                    VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                        Text(card.productName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)

                        HStack {
                            Text("•••• \(card.last4)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fontDesign(.monospaced)

                            Spacer()

                            Text(card.network)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, ThemeSpacing.s)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                }
                        }
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isSelected ? ThemeColor.primaryNeon : .secondary)
                }
                .padding(ThemeSpacing.l)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("With Cards") {
    let uiState = UIState()
    uiState.cardsToReview = [
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
        )
    ]

    return ReviewCardsSheet()
        .environment(uiState)
}

#Preview("Empty State") {
    let uiState = UIState()
    uiState.cardsToReview = []

    return ReviewCardsSheet()
        .environment(uiState)
}