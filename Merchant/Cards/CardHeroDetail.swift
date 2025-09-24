
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
                        .clipShape(RoundedRectangle(cornerRadius: ModernRadius.card))
                } placeholder: {
                    RoundedRectangle(cornerRadius: ModernRadius.card)
                        .fill(.ultraThinMaterial)
                        .aspectRatio(1.6, contentMode: .fit)
                        .overlay {
                            ProgressView()
                                .tint(ModernColors.accent)
                        }
                }
                .matchedGeometryEffect(id: card.id, in: namespace)
                .frame(maxWidth: 350)
                .padding(.horizontal, ModernSpacing.xl)

                ScrollView {
                    VStack(spacing: ModernSpacing.xl) {
                        VStack(spacing: ModernSpacing.lg) {
                            HStack {
                                VStack(alignment: .leading, spacing: ModernSpacing.xs) {
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

                                VStack(alignment: .trailing, spacing: ModernSpacing.xs) {
                                    Text(card.network)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)

                                    if card.isPremium {
                                        HStack(spacing: ModernSpacing.xs) {
                                            Image(systemName: "crown.fill")
                                                .font(.caption2)
                                            Text("Premium")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundStyle(ModernColors.reward)
                                    }
                                }
                            }

                            ModernGlassCard(style: .secondary) {
                                VStack(alignment: .leading, spacing: ModernSpacing.lg) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(ModernColors.reward)
                                        Text("Why here")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                    }

                                    Text(CardBenefitsCatalog.benefits(for: card.selectionKey))
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(ModernSpacing.xl)
                            }

                            HStack(spacing: ModernSpacing.lg) {
                                ModernGlassCard(style: .secondary) {
                                    VStack(spacing: ModernSpacing.sm) {
                                        Text("3×")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(ModernColors.accent)

                                        Text("Dining")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(ModernSpacing.lg)
                                }

                                ModernGlassCard(style: .secondary) {
                                    VStack(spacing: ModernSpacing.sm) {
                                        Text("$327")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(ModernColors.reward)

                                        Text("This month")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(ModernSpacing.lg)
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
                                .padding(.vertical, ModernSpacing.lg)
                                .background {
                                    ModernGlassCard(style: .secondary) {
                                        Color.clear
                                    }
                                }
                        }
                    }
                    .padding(ModernSpacing.xl)
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                            onDismiss()
                        }
                    }
                }
        )
    }
}

#Preview {
    @Previewable @Namespace var namespace

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