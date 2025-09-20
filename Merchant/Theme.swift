// Rules: Neon-on-dark theme tokens with Liquid Glass surfaces, iOS 26+ Materials, accessibility compliance
// Inputs: Environment color scheme, accessibility preferences
// Outputs: Color tokens, spacing, radii, shadows, glass components
// Constraints: AA contrast compliance, Reduce Motion support, High Contrast fallbacks

import SwiftUI

struct ThemeColor {
    // True dark background - nearly black with subtle warmth
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.02, green: 0.02, blue: 0.02),   // #050505 - true black
            Color(red: 0.04, green: 0.04, blue: 0.04)    // #0A0A0A - deep charcoal
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Electric neon that pops against true dark
    static let primaryNeon = Color(red: 0.0, green: 1.0, blue: 0.3) // #00FF4D - electric green
    static let secondaryNeon = Color(red: 0.0, green: 0.8, blue: 1.0) // #00CCFF - electric blue
    static let accentNeon = Color(red: 1.0, green: 0.2, blue: 0.8) // #FF3399 - electric pink

    // Sophisticated accent colors
    static let rewardGold = Color(red: 1.0, green: 0.84, blue: 0.0) // #FFD700
    static let premiumGold = Color(red: 0.96, green: 0.87, blue: 0.7) // #F5DEB3
    static let warningAmber = Color(red: 1.0, green: 0.75, blue: 0.0) // #FFBF00

    // Glass system with better contrast
    static let glassStroke = Color.white.opacity(0.08)
    static let glassHighlight = Color.white.opacity(0.04)
    static let glassShadow = Color.black.opacity(0.6)

    // Text hierarchy
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)
}

struct ThemeSpacing {
    static let xs: CGFloat = 2
    static let s: CGFloat = 4
    static let m: CGFloat = 8
    static let l: CGFloat = 12
    static let xl: CGFloat = 16
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let huge: CGFloat = 48
}

struct ThemeRadius {
    static let card: CGFloat = 24
    static let container: CGFloat = 20
    static let button: CGFloat = 16
    static let small: CGFloat = 12
}

struct ThemeShadow {
    static let glass = Shadow(
        color: ThemeColor.glassShadow,
        radius: 32,
        x: 0,
        y: 16
    )

    static let card = Shadow(
        color: Color.black.opacity(0.8),
        radius: 24,
        x: 0,
        y: 12
    )

    static let subtle = Shadow(
        color: Color.black.opacity(0.3),
        radius: 8,
        x: 0,
        y: 4
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct NeonBackground: View {
    var body: some View {
        ThemeColor.backgroundGradient
            .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let hasGlow: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    init(cornerRadius: CGFloat = ThemeRadius.card, hasGlow: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.hasGlow = hasGlow
    }

    var body: some View {
        content
            .background {
                ZStack {
                    if contrast == .increased {
                        // High contrast fallback
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.black)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    } else {
                        // Premium glass effect
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                            .background {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.05),
                                                Color.clear,
                                                Color.black.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .overlay {
                                // Inner glow
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.2),
                                                Color.white.opacity(0.05),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                            .shadow(
                                color: ThemeShadow.glass.color,
                                radius: reduceMotion ? 0 : ThemeShadow.glass.radius,
                                x: ThemeShadow.glass.x,
                                y: reduceMotion ? 0 : ThemeShadow.glass.y
                            )

                        // Optional neon glow effect
                        if hasGlow {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(ThemeColor.primaryNeon.opacity(0.3), lineWidth: 1)
                                .blur(radius: 2)
                        }
                    }
                }
            }
    }
}

#Preview {
    ZStack {
        NeonBackground()

        VStack(spacing: ThemeSpacing.xxxl) {
            GlassCard(hasGlow: true) {
                VStack(spacing: ThemeSpacing.l) {
                    HStack {
                        Text("Merchant")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(ThemeColor.primaryNeon)
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(ThemeColor.accentNeon)
                    }

                    Text("Award-winning card optimization")
                        .font(.headline)
                        .foregroundStyle(ThemeColor.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(ThemeSpacing.xxxl)
            }

            HStack(spacing: ThemeSpacing.xl) {
                GlassCard {
                    VStack(spacing: ThemeSpacing.m) {
                        Text("$2,847")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(ThemeColor.rewardGold)

                        Text("This month")
                            .font(.caption)
                            .foregroundStyle(ThemeColor.textTertiary)
                    }
                    .padding(ThemeSpacing.xl)
                }

                GlassCard {
                    VStack(spacing: ThemeSpacing.m) {
                        Text("5.2×")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(ThemeColor.secondaryNeon)

                        Text("Multiplier")
                            .font(.caption)
                            .foregroundStyle(ThemeColor.textTertiary)
                    }
                    .padding(ThemeSpacing.xl)
                }
            }
        }
        .padding(ThemeSpacing.xxxl)
    }
    .preferredColorScheme(.dark)
}