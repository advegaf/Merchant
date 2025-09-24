
import SwiftUI

struct ThemeColor {
    static let primaryNeon = Color(red: 0.0, green: 0.78, blue: 0.02) // #00C805
    static let rewardAccent = Color(red: 1.0, green: 0.78, blue: 0.34) // #FFC857
    static let premiumGold = Color(red: 0.9, green: 0.78, blue: 0.63) // #E6C8A1
    static let premiumGoldHighlight = Color(red: 0.97, green: 0.9, blue: 0.82) // #F7E6D0

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.043, green: 0.071, blue: 0.098), // #0B1219
            Color(red: 0.063, green: 0.102, blue: 0.157)  // #101A28
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let glassStroke = Color.white.opacity(0.12)
    static let glassShadow = Color.black.opacity(0.25)
}

struct ThemeSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
}

struct ThemeRadius {
    static let card: CGFloat = 28
    static let container: CGFloat = 24
}

struct ThemeShadow {
    static let glass = Shadow(
        color: ThemeColor.glassShadow,
        radius: 24,
        x: 0,
        y: 12
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background {
                if contrast == .increased {
                    RoundedRectangle(cornerRadius: ThemeRadius.card)
                        .fill(Color.black)
                        .stroke(ThemeColor.glassStroke, lineWidth: 1)
                } else {
                    RoundedRectangle(cornerRadius: ThemeRadius.card)
                        .fill(.ultraThinMaterial)
                        .stroke(ThemeColor.glassStroke, lineWidth: 1)
                        .shadow(
                            color: ThemeShadow.glass.color,
                            radius: reduceMotion ? 0 : ThemeShadow.glass.radius,
                            x: ThemeShadow.glass.x,
                            y: reduceMotion ? 0 : ThemeShadow.glass.y
                        )
                }
            }
    }
}

#Preview {
    ZStack {
        NeonBackground()

        VStack(spacing: ThemeSpacing.xl) {
            GlassCard {
                VStack {
                    Text("Sample Glass Card")
                        .foregroundStyle(ThemeColor.primaryNeon)
                    Text("Liquid Glass Material")
                        .foregroundStyle(.secondary)
                }
                .padding(ThemeSpacing.xl)
            }

            GlassCard {
                HStack {
                    Text("$247")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(ThemeColor.rewardAccent)
                    Spacer()
                    Text("This week")
                        .foregroundStyle(.secondary)
                }
                .padding(ThemeSpacing.xl)
            }
        }
        .padding(ThemeSpacing.xl)
    }
    .preferredColorScheme(.dark)
}