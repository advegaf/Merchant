
import SwiftUI

/// Modern color system inspired by premium fintech and design leaders
struct ModernColors {

    // MARK: - Primary Background System

    /// Rich, warm dark backgrounds - sophisticated not stark
    static let background = LinearGradient(
        colors: [
            Color(red: 0.02, green: 0.02, blue: 0.04),     // Deep navy-black #050508
            Color(red: 0.04, green: 0.05, blue: 0.08)      // Charcoal blue #0A0D14
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Surface colors for cards and containers
    static let surfacePrimary = Color(red: 0.06, green: 0.07, blue: 0.10)      // #0F1219
    static let surfaceSecondary = Color(red: 0.08, green: 0.09, blue: 0.12)    // #141822
    static let surfaceElevated = Color(red: 0.10, green: 0.11, blue: 0.15)     // #1A1C26

    // MARK: - Semantic Color System

    /// Success/profit colors - sophisticated green palette
    static let success = Color(red: 0.0, green: 0.8, blue: 0.4)               // #00CC66 - Fresh success
    static let successSoft = Color(red: 0.0, green: 0.7, blue: 0.35)          // #00B359 - Softer success
    static let successBackground = Color(red: 0.0, green: 0.8, blue: 0.4).opacity(0.1)

    /// Reward/earning colors - warm gold system
    static let reward = Color(red: 1.0, green: 0.8, blue: 0.2)               // #FFCC33 - Premium gold
    static let rewardRich = Color(red: 0.95, green: 0.7, blue: 0.15)         // #F2B526 - Rich gold
    static let rewardBackground = Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.1)

    /// Premium/luxury colors - sophisticated blue-violet
    static let premium = Color(red: 0.4, green: 0.5, blue: 1.0)              // #6680FF - Electric blue
    static let premiumDeep = Color(red: 0.3, green: 0.4, blue: 0.9)          // #4D66E6 - Deep blue
    static let premiumBackground = Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.1)

    /// Alert/warning colors - sophisticated coral
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.4)              // #FF9966 - Warm coral
    static let warningBackground = Color(red: 1.0, green: 0.6, blue: 0.4).opacity(0.1)

    /// Error colors - refined red
    static let error = Color(red: 1.0, green: 0.4, blue: 0.4)                // #FF6666 - Soft error red
    static let errorBackground = Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.1)

    // MARK: - Text & Content Hierarchy

    /// Text colors with proper contrast ratios
    static let textPrimary = Color.white                                       // #FFFFFF
    static let textSecondary = Color.white.opacity(0.8)                      // 80% white
    static let textTertiary = Color.white.opacity(0.6)                       // 60% white
    static let textQuaternary = Color.white.opacity(0.4)                     // 40% white

    /// Accent colors for interactive elements
    static let accent = Color(red: 0.5, green: 0.7, blue: 1.0)               // #80B3FF - Friendly blue
    static let accentHover = Color(red: 0.6, green: 0.75, blue: 1.0)         // #99BFFF - Lighter blue

    // MARK: - Glass & Material System

    /// Modern glass effects
    static let glassBackground = Color.white.opacity(0.05)
    static let glassBorder = Color.white.opacity(0.12)
    static let glassHighlight = Color.white.opacity(0.08)
    static let glassShadow = Color.black.opacity(0.3)

    // MARK: - Interactive States

    /// Hover and press states
    static let interactiveHover = Color.white.opacity(0.05)
    static let interactivePress = Color.white.opacity(0.1)
    static let interactiveFocus = accent.opacity(0.2)

    // MARK: - Data Visualization

    /// Chart and graph colors
    static let chartPrimary = success
    static let chartSecondary = reward
    static let chartTertiary = premium
    static let chartQuaternary = accent
    static let chartBackground = surfaceSecondary

    // MARK: - Context-Aware Colors

    /// Purchase context colors
    static func purchaseContextColor(for category: PurchaseCategory) -> Color {
        switch category {
        case .dining:
            return Color(red: 1.0, green: 0.7, blue: 0.3)      // Warm orange
        case .groceries:
            return Color(red: 0.3, green: 0.8, blue: 0.5)      // Fresh green
        case .gas:
            return Color(red: 0.5, green: 0.6, blue: 1.0)      // Blue
        case .travel:
            return Color(red: 0.8, green: 0.4, blue: 1.0)      // Purple
        case .shopping:
            return Color(red: 1.0, green: 0.5, blue: 0.7)      // Pink
        case .utilities:
            return Color(red: 0.6, green: 0.8, blue: 0.9)      // Light blue
        case .other:
            return textTertiary
        }
    }

    /// Card network colors
    static func networkColor(for network: String) -> Color {
        switch network.lowercased() {
        case "visa":
            return Color(red: 0.0, green: 0.4, blue: 0.8)      // Visa blue
        case "mastercard":
            return Color(red: 1.0, green: 0.4, blue: 0.0)      // Mastercard orange
        case "american express", "amex":
            return Color(red: 0.0, green: 0.5, blue: 0.6)      // Amex teal
        case "discover":
            return Color(red: 1.0, green: 0.6, blue: 0.0)      // Discover orange
        default:
            return textSecondary
        }
    }
}

enum PurchaseCategory: String, CaseIterable {
    case dining = "Dining"
    case groceries = "Groceries"
    case gas = "Gas"
    case travel = "Travel"
    case shopping = "Shopping"
    case utilities = "Utilities"
    case other = "Other"
}

/// Enhanced spacing system for better rhythm
struct ModernSpacing {
    static let xxxs: CGFloat = 1
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 6
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let xxl: CGFloat = 20
    static let xxxl: CGFloat = 24
    static let xxxxl: CGFloat = 32
    static let huge: CGFloat = 40
    static let massive: CGFloat = 48
    static let colossal: CGFloat = 64
}

/// Modern radius system
struct ModernRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 6
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let xxl: CGFloat = 20
    static let xxxl: CGFloat = 24
    static let card: CGFloat = 20
    static let container: CGFloat = 16
    static let button: CGFloat = 12
}

/// Sophisticated shadow system
struct ModernShadows {
    static let subtle = (
        color: ModernColors.glassShadow,
        radius: CGFloat(4),
        x: CGFloat(0),
        y: CGFloat(2)
    )

    static let card = (
        color: ModernColors.glassShadow,
        radius: CGFloat(12),
        x: CGFloat(0),
        y: CGFloat(6)
    )

    static let elevated = (
        color: ModernColors.glassShadow,
        radius: CGFloat(20),
        x: CGFloat(0),
        y: CGFloat(10)
    )

    static let dramatic = (
        color: ModernColors.glassShadow,
        radius: CGFloat(32),
        x: CGFloat(0),
        y: CGFloat(16)
    )
}

/// Modern background component
struct ModernBackground: View {
    var body: some View {
        ModernColors.background
            .ignoresSafeArea()
    }
}

/// Enhanced glass card with modern styling
struct ModernGlassCard<Content: View>: View {
    let content: Content
    let style: Style

    enum Style {
        case primary
        case secondary
        case elevated
        case premium
    }

    init(style: Style = .primary, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: ModernRadius.card)
                    .fill(backgroundForStyle())
                    .overlay {
                        RoundedRectangle(cornerRadius: ModernRadius.card)
                            .stroke(borderForStyle(), lineWidth: 1)
                    }
                    .shadow(
                        color: shadowForStyle().color,
                        radius: shadowForStyle().radius,
                        x: shadowForStyle().x,
                        y: shadowForStyle().y
                    )
            }
    }

    private func backgroundForStyle() -> some ShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(.ultraThinMaterial)
        case .secondary:
            return AnyShapeStyle(ModernColors.surfaceSecondary)
        case .elevated:
            return AnyShapeStyle(ModernColors.surfaceElevated)
        case .premium:
            return AnyShapeStyle(.regularMaterial)
        }
    }

    private func borderForStyle() -> Color {
        switch style {
        case .primary:
            return ModernColors.glassBorder
        case .secondary:
            return ModernColors.glassBorder.opacity(0.5)
        case .elevated:
            return ModernColors.glassBorder
        case .premium:
            return ModernColors.premium.opacity(0.3)
        }
    }

    private func shadowForStyle() -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch style {
        case .primary:
            return ModernShadows.card
        case .secondary:
            return ModernShadows.subtle
        case .elevated:
            return ModernShadows.elevated
        case .premium:
            return ModernShadows.dramatic
        }
    }
}

#Preview {
    ZStack {
        ModernBackground()

        VStack(spacing: ModernSpacing.xxxl) {
            ModernGlassCard(style: .primary) {
                VStack(spacing: ModernSpacing.lg) {
                    HStack {
                        Text("Best Card Here")
                            .font(.headline)
                            .foregroundStyle(ModernColors.textPrimary)
                        Spacer()
                        Text("3× Dining")
                            .font(.subheadline)
                            .foregroundStyle(ModernColors.success)
                    }

                    Text("Chase Sapphire Preferred will earn you 47% more on this purchase")
                        .font(.body)
                        .foregroundStyle(ModernColors.textSecondary)
                }
                .padding(ModernSpacing.xxl)
            }

            HStack(spacing: ModernSpacing.lg) {
                ModernGlassCard(style: .secondary) {
                    VStack(spacing: ModernSpacing.md) {
                        Text("$127")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(ModernColors.reward)
                        Text("This Week")
                            .font(.caption)
                            .foregroundStyle(ModernColors.textTertiary)
                    }
                    .padding(ModernSpacing.xl)
                }

                ModernGlassCard(style: .premium) {
                    VStack(spacing: ModernSpacing.md) {
                        Text("4.2×")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(ModernColors.premium)
                        Text("Avg Multiplier")
                            .font(.caption)
                            .foregroundStyle(ModernColors.textTertiary)
                    }
                    .padding(ModernSpacing.xl)
                }
            }
        }
        .padding(ModernSpacing.xxxl)
    }
    .preferredColorScheme(.dark)
}