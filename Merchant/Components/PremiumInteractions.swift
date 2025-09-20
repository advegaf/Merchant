// Rules: Premium interactive components with advanced micro-interactions
// Inputs: User gestures, state changes, data updates
// Outputs: Sophisticated animations, haptic feedback, visual transitions
// Constraints: 60fps performance, accessibility support, premium feel

import SwiftUI

/// Premium interactive components that elevate the user experience
struct PremiumInteractions {

    // MARK: - Segmented Control (Copilot-style)

    struct PremiumSegmentedControl: View {
        let options: [String]
        @Binding var selectedIndex: Int
        @State private var segmentFrames: [CGRect] = []
        @Namespace private var animation

        var body: some View {
            HStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        withAnimation(PremiumDesign.Animations.responsiveSpring) {
                            selectedIndex = index
                        }

                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Text(option)
                            .font(PremiumDesign.Typography.labelLarge)
                            .fontWeight(selectedIndex == index ? .semibold : .medium)
                            .foregroundStyle(
                                selectedIndex == index
                                    ? PremiumDesign.Colors.gray900
                                    : PremiumDesign.Colors.gray700
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PremiumDesign.Spacing.md)
                            .background {
                                if selectedIndex == index {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white)
                                        .shadow(
                                            color: PremiumDesign.Elevation.low.color,
                                            radius: PremiumDesign.Elevation.low.radius,
                                            x: PremiumDesign.Elevation.low.x,
                                            y: PremiumDesign.Elevation.low.y
                                        )
                                        .matchedGeometryEffect(id: "segment", in: animation)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(PremiumDesign.Spacing.xs)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(PremiumDesign.Colors.gray300)
            }
        }
    }

    // MARK: - Premium Button

    struct PremiumButton: View {
        let title: String
        let style: ButtonStyle
        let action: () -> Void

        @State private var isPressed = false
        @State private var isHovered = false

        enum ButtonStyle {
            case primary, secondary, ghost, destructive

            var backgroundColor: Color {
                switch self {
                case .primary: return PremiumDesign.Colors.primaryBlue
                case .secondary: return PremiumDesign.Colors.gray300
                case .ghost: return Color.clear
                case .destructive: return PremiumDesign.Colors.error
                }
            }

            var foregroundColor: Color {
                switch self {
                case .primary: return .white
                case .secondary: return PremiumDesign.Colors.gray900
                case .ghost: return PremiumDesign.Colors.primaryBlue
                case .destructive: return .white
                }
            }

            var borderColor: Color? {
                switch self {
                case .ghost: return PremiumDesign.Colors.primaryBlue
                default: return nil
                }
            }
        }

        var body: some View {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                action()
            }) {
                Text(title)
                    .font(PremiumDesign.Typography.labelLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(style.foregroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PremiumDesign.Spacing.lg)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(style.backgroundColor)
                            .overlay {
                                if let borderColor = style.borderColor {
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(borderColor, lineWidth: 1.5)
                                }
                            }
                    }
            }
            .scaleEffect(isPressed ? 0.96 : (isHovered ? 1.02 : 1.0))
            .animation(PremiumDesign.Animations.responsiveSpring, value: isPressed)
            .animation(PremiumDesign.Animations.gentleSpring, value: isHovered)
            .pressEvents {
                isPressed = true
            } onRelease: {
                isPressed = false
            }
            .onHover { hovering in
                isHovered = hovering
            }
        }
    }

    // MARK: - Floating Action Button

    struct FloatingActionButton: View {
        let icon: String
        let action: () -> Void
        @State private var isPressed = false
        @State private var rotationAngle: Double = 0

        var body: some View {
            Button(action: {
                withAnimation(PremiumDesign.Animations.playfulSpring) {
                    rotationAngle += 180
                }

                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                action()
            }) {
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [PremiumDesign.Colors.primaryBlue, PremiumDesign.Colors.primaryPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: PremiumDesign.Colors.primaryBlue.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                    }
            }
            .rotationEffect(.degrees(rotationAngle))
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(PremiumDesign.Animations.responsiveSpring, value: isPressed)
            .pressEvents {
                isPressed = true
            } onRelease: {
                isPressed = false
            }
        }
    }

    // MARK: - Premium Card Selector

    struct PremiumCardSelector: View {
        let cards: [SelectableCard]
        @Binding var selectedCardId: UUID?

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PremiumDesign.Spacing.lg) {
                    ForEach(cards) { card in
                        CardSelectorItem(
                            card: card,
                            isSelected: selectedCardId == card.id
                        ) {
                            withAnimation(PremiumDesign.Animations.responsiveSpring) {
                                selectedCardId = selectedCardId == card.id ? nil : card.id
                            }
                        }
                    }
                }
                .padding(.horizontal, PremiumDesign.Spacing.xl)
            }
        }
    }

    private struct CardSelectorItem: View {
        let card: SelectableCard
        let isSelected: Bool
        let onTap: () -> Void

        @State private var isPressed = false

        var body: some View {
            Button(action: onTap) {
                VStack(spacing: PremiumDesign.Spacing.md) {
                    // Card art placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [card.primaryColor, card.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 63)
                        .overlay {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(.white, lineWidth: 3)
                            }
                        }
                        .overlay {
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .background {
                                        Circle()
                                            .fill(PremiumDesign.Colors.success)
                                            .frame(width: 24, height: 24)
                                    }
                                    .offset(x: 8, y: -8)
                            }
                        }

                    VStack(spacing: PremiumDesign.Spacing.xxs) {
                        Text(card.name)
                            .font(PremiumDesign.Typography.labelMedium)
                            .fontWeight(.medium)
                            .foregroundStyle(PremiumDesign.Colors.gray900)
                            .lineLimit(1)

                        Text(card.multiplier)
                            .font(PremiumDesign.Typography.labelSmall)
                            .foregroundStyle(card.primaryColor)
                    }
                }
                .frame(width: 120)
            }
            .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
            .animation(PremiumDesign.Animations.responsiveSpring, value: isPressed)
            .animation(PremiumDesign.Animations.gentleSpring, value: isSelected)
            .pressEvents {
                isPressed = true
            } onRelease: {
                isPressed = false
            }
        }
    }

    // MARK: - Progress Indicator

    struct PremiumProgressIndicator: View {
        let progress: Double
        let title: String
        let subtitle: String
        @State private var animatedProgress: Double = 0

        var body: some View {
            VStack(alignment: .leading, spacing: PremiumDesign.Spacing.lg) {
                VStack(alignment: .leading, spacing: PremiumDesign.Spacing.xs) {
                    HStack {
                        Text(title)
                            .font(PremiumDesign.Typography.headlineSmall)
                            .foregroundStyle(PremiumDesign.Colors.gray900)

                        Spacer()

                        Text("\(Int(progress * 100))%")
                            .font(PremiumDesign.Typography.numberSmall)
                            .foregroundStyle(PremiumDesign.Colors.primaryBlue)
                    }

                    Text(subtitle)
                        .font(PremiumDesign.Typography.labelMedium)
                        .foregroundStyle(PremiumDesign.Colors.gray700)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(PremiumDesign.Colors.gray300)
                            .frame(height: 8)

                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [PremiumDesign.Colors.primaryBlue, PremiumDesign.Colors.primaryPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * animatedProgress, height: 8)
                    }
                }
                .frame(height: 8)
                .onAppear {
                    withAnimation(PremiumDesign.Animations.easeOutExpo.delay(0.2)) {
                        animatedProgress = progress
                    }
                }
            }
        }
    }
}

// MARK: - Data Models

struct SelectableCard: Identifiable {
    let id = UUID()
    let name: String
    let multiplier: String
    let primaryColor: Color
    let secondaryColor: Color
}

// MARK: - Sample Data

extension PremiumInteractions {
    static let sampleCards = [
        SelectableCard(
            name: "Sapphire Preferred",
            multiplier: "3× Dining",
            primaryColor: PremiumDesign.Colors.primaryBlue,
            secondaryColor: PremiumDesign.Colors.primaryPurple
        ),
        SelectableCard(
            name: "Gold Card",
            multiplier: "4× Groceries",
            primaryColor: PremiumDesign.Colors.primaryOrange,
            secondaryColor: Color.yellow
        ),
        SelectableCard(
            name: "Freedom Unlimited",
            multiplier: "1.5× Everything",
            primaryColor: PremiumDesign.Colors.primaryGreen,
            secondaryColor: Color.mint
        )
    ]
}