// Rules: Premium card tile showcasing official issuer art, Max Rewards style
// Inputs: CardUI with official artURL, focus state, z-index, matched geometry namespace
// Outputs: High-quality card display with official art, elegant overlays
// Constraints: Official art only, sophisticated visual hierarchy, award-level polish

import SwiftUI

struct CardTile: View {
    let card: CardUI
    let isTopCard: Bool
    let zIndex: Double
    let namespace: Namespace.ID
    @State private var artLoadFailed = false
    @State private var imageLoaded = false

    var body: some View {
        if !artLoadFailed {
            GeometryReader { geometry in
                ZStack {
                    // Official card art - high quality display
                    AsyncImage(url: card.artURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .onAppear {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        imageLoaded = true
                                    }
                                }
                        case .failure(_):
                            Color.clear
                                .onAppear {
                                    artLoadFailed = true
                                }
                        case .empty:
                            // Premium loading state
                            ZStack {
                                RoundedRectangle(cornerRadius: ModernRadius.card)
                                    .fill(.ultraThinMaterial)

                                VStack(spacing: ModernSpacing.md) {
                                    ProgressView()
                                        .tint(ModernColors.accent)
                                        .scaleEffect(0.8)

                                    Text("Loading card art...")
                                        .font(.caption2)
                                        .foregroundStyle(ModernColors.textTertiary)
                                }
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: ModernRadius.card))

                    // Elegant gradient overlay for readability
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.4),
                            Color.clear,
                            Color.clear,
                            Color.black.opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: ModernRadius.card))
                    .opacity(imageLoaded ? 1 : 0)

                    // Premium overlays
                    VStack {
                        // Top row - premium badge and network
                        HStack {
                            if card.isPremium {
                                HStack(spacing: ModernSpacing.xs) {
                                    Image(systemName: "crown.fill")
                                        .font(.caption2)
                                    Text("PREMIUM")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .tracking(0.5)
                                }
                                .foregroundStyle(ModernColors.reward)
                                .padding(.horizontal, ModernSpacing.md)
                                .padding(.vertical, ModernSpacing.xs)
                                .background {
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .stroke(ModernColors.reward.opacity(0.4), lineWidth: 1)
                                        .shadow(color: ModernColors.reward.opacity(0.3), radius: 4)
                                }
                            }

                            Spacer()

                            // Network badge with sophisticated styling
                            Text(card.network.uppercased())
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .tracking(0.3)
                                .foregroundStyle(.white)
                                .padding(.horizontal, ModernSpacing.md)
                                .padding(.vertical, ModernSpacing.xs)
                                .background {
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay {
                                            Capsule()
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        }
                                }
                        }

                        Spacer()

                        // Bottom row - card details with premium typography
                        HStack {
                            VStack(alignment: .leading, spacing: ModernSpacing.xs) {
                                Text(card.productName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2)

                                HStack(spacing: ModernSpacing.xs) {
                                    Text("••••")
                                        .font(.caption)
                                        .tracking(2)
                                    Text(card.last4)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .tracking(1)
                                }
                                .foregroundStyle(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.5), radius: 1)
                            }

                            Spacer()

                            // Subtle focus indicator for top card
                            if isTopCard {
                                Circle()
                                    .fill(ModernColors.accent)
                                    .frame(width: 8, height: 8)
                                    .shadow(color: ModernColors.accent, radius: 4)
                            }
                        }
                    }
                    .padding(ModernSpacing.xl)
                    .opacity(imageLoaded ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.1), value: imageLoaded)
                }
            }
            .aspectRatio(1.586, contentMode: .fit) // Standard credit card ratio
            .matchedGeometryEffect(id: card.id, in: namespace)
            .zIndex(zIndex)
        }
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

    return ZStack {
        ModernBackground()
        CardTile(card: card, isTopCard: true, zIndex: 1, namespace: namespace)
            .frame(width: 300, height: 200)
    }
}