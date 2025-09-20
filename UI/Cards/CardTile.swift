// Rules: Individual card tile with AsyncImage art loading, premium styling, network badge
// Inputs: CardUI with artURL, focus state, z-index, matched geometry namespace
// Outputs: Rendered card with official art, fallback on load failure
// Constraints: Remove from view if art fails, premium gold accent for premium cards

import SwiftUI

struct CardTile: View {
    let card: CardUI
    let isTopCard: Bool
    let zIndex: Double
    let namespace: Namespace.ID
    @State private var artLoadFailed = false

    var body: some View {
        if !artLoadFailed {
            ZStack {
                AsyncImage(url: card.artURL) { image in
                    image
                        .resizable()
                        .aspectRatio(1.6, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: ThemeRadius.card))
                } placeholder: {
                    RoundedRectangle(cornerRadius: ThemeRadius.card)
                        .fill(.ultraThinMaterial)
                        .aspectRatio(1.6, contentMode: .fit)
                        .overlay {
                            ProgressView()
                                .tint(ThemeColor.primaryNeon)
                        }
                }
                .onAppear {
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        let (_, response) = try await URLSession.shared.data(from: card.artURL)
                        if (response as? HTTPURLResponse)?.statusCode != 200 {
                            artLoadFailed = true
                        }
                    }
                }

                VStack {
                    HStack {
                        if card.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundStyle(ThemeColor.premiumGold)
                                .padding(.horizontal, ThemeSpacing.s)
                                .padding(.vertical, ThemeSpacing.xs)
                                .background {
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .stroke(ThemeColor.premiumGold.opacity(0.3), lineWidth: 1)
                                }
                        }

                        Spacer()

                        Text(card.network)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, ThemeSpacing.s)
                            .padding(.vertical, ThemeSpacing.xs)
                            .background {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            }
                    }

                    Spacer()

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.productName)
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            Text("•••• \(card.last4)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }
                .padding(ThemeSpacing.l)
            }
            .matchedGeometryEffect(id: card.id, in: namespace)
            .zIndex(zIndex)
            .shadow(
                color: .black.opacity(isTopCard ? 0.3 : 0.1),
                radius: isTopCard ? 16 : 8,
                x: 0,
                y: isTopCard ? 8 : 4
            )
        }
    }
}

#Preview {
    @Namespace var namespace

    let card = CardUI(
        institutionId: "chase",
        productName: "Chase Sapphire Preferred",
        last4: "1234",
        artURL: URL(string: "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_preferred_card.png")!,
        isPremium: true,
        network: "Visa"
    )

    return ZStack {
        NeonBackground()
        CardTile(card: card, isTopCard: true, zIndex: 1, namespace: namespace)
            .frame(width: 300, height: 200)
    }
}