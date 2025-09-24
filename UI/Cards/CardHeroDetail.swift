
import SwiftUI

struct CardHeroDetail: View {
    let card: CardUI
    let namespace: Namespace.ID
    let onDismiss: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        onDismiss()
                    }
                }

            VStack(spacing: 0) {
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
                .matchedGeometryEffect(id: card.id, in: namespace)
                .frame(maxWidth: 350)
                .padding(.horizontal, ThemeSpacing.xl)

                ScrollView {
                    VStack(spacing: ThemeSpacing.xl) {
                        VStack(spacing: ThemeSpacing.l) {
                            HStack {
                                VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                                    Text(card.productName)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)

                                    Text("•••• •••• •••• \(card.last4)")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                        .fontDesign(.monospaced)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: ThemeSpacing.xs) {
                                    Text(card.network)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)

                                    if card.isPremium {
                                        HStack(spacing: ThemeSpacing.xs) {
                                            Image(systemName: "crown.fill")
                                                .font(.caption2)
                                            Text("Premium")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundStyle(ThemeColor.premiumGold)
                                    }
                                }
                            }

                            GlassCard {
                                VStack(alignment: .leading, spacing: ThemeSpacing.l) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(ThemeColor.rewardAccent)
                                        Text("Why here")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                    }

                                    Text("Best for dining purchases with 3× points per dollar spent. No foreign transaction fees.")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(ThemeSpacing.xl)
                            }

                            HStack(spacing: ThemeSpacing.l) {
                                GlassCard {
                                    VStack(spacing: ThemeSpacing.s) {
                                        Text("3×")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(ThemeColor.primaryNeon)

                                        Text("Dining")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(ThemeSpacing.l)
                                }

                                GlassCard {
                                    VStack(spacing: ThemeSpacing.s) {
                                        Text("$327")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(ThemeColor.rewardAccent)

                                        Text("This month")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(ThemeSpacing.l)
                                }
                            }
                        }

                        Button(action: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                                onDismiss()
                            }
                        }) {
                            Text("Close")
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
                    }
                    .padding(ThemeSpacing.xl)
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.y > 100 {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                            onDismiss()
                        }
                    }
                }
        )
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

    return CardHeroDetail(card: card, namespace: namespace) {
        // Dismiss action
    }
}