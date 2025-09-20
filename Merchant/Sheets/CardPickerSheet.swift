// Rules: Onboarding card picker to choose preferred cards. No network.
// Inputs: MockCardArtProvider cards, SelectedCardsStore
// Outputs: User selections persisted; benefits view inline
// Constraints: Keep UI simple; thumbnails only; no layout refactor

import SwiftUI

struct CardPickerSheet: View {
    @Environment(SelectedCardsStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var allCards: [CardUI] = []
    @State private var provider = MockCardArtProvider()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                    ForEach(allCards) { card in
                        VStack(spacing: 8) {
                            AsyncImage(url: card.artURL) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                Rectangle().fill(.ultraThinMaterial)
                            }
                            .frame(height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

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
                        .onTapGesture { store.toggleSelection(for: card.selectionKey) }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Choose Your Cards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        store.hasCompletedOnboarding = true
                        dismiss()
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
}

