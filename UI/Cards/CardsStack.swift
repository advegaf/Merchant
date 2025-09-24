
import SwiftUI

struct CardsStack: View {
    let cards: [CardUI]
    @State private var focusIndex = 0
    @State private var dragOffset = CGSize.zero
    @State private var selectedCard: CardUI?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var cardNamespace

    var body: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardTile(
                    card: card,
                    isTopCard: index == focusIndex,
                    zIndex: Double(cards.count - index),
                    namespace: cardNamespace
                )
                .scaleEffect(scale(for: index))
                .offset(y: yOffset(for: index))
                .rotation3DEffect(
                    .degrees(reduceMotion ? 0 : tiltAngle(for: index)),
                    axis: (x: 1, y: 0, z: 0)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        if index == focusIndex {
                            selectedCard = card
                        } else {
                            focusIndex = index
                        }
                    }

                    #if os(iOS)
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    #endif
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if index == focusIndex {
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            if index == focusIndex {
                                let threshold: CGFloat = 80

                                if value.translation.x > threshold && focusIndex > 0 {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                                        focusIndex -= 1
                                    }
                                } else if value.translation.x < -threshold && focusIndex < cards.count - 1 {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                                        focusIndex += 1
                                    }
                                }

                                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                    dragOffset = .zero
                                }
                            }
                        }
                )
                .offset(x: index == focusIndex ? dragOffset.x * 0.3 : 0)
            }
        }
        .fullScreenCover(item: $selectedCard) { card in
            CardHeroDetail(card: card, namespace: cardNamespace) {
                selectedCard = nil
            }
        }
    }

    private func scale(for index: Int) -> CGFloat {
        let distance = abs(index - focusIndex)
        return 1.0 - (CGFloat(distance) * 0.03)
    }

    private func yOffset(for index: Int) -> CGFloat {
        let distance = abs(index - focusIndex)
        return CGFloat(distance) * 16
    }

    private func tiltAngle(for index: Int) -> Double {
        if index == focusIndex {
            return dragOffset.x * 0.02
        }
        return 0
    }
}

#Preview {
    let mockCards = [
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
        ),
        CardUI(
            institutionId: "citi",
            productName: "Citi Double Cash",
            last4: "9012",
            artURL: URL(string: "https://www.citi.com/CRD/images/citi-double-cash-card/citi-double-cash-card-art.png")!,
            isPremium: false,
            network: "Mastercard"
        )
    ]

    return ZStack {
        NeonBackground()
        CardsStack(cards: mockCards)
            .frame(height: 240)
    }
}