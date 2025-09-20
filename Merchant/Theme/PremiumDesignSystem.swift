// Rules: Premium design system inspired by Copilot's sophisticated visual hierarchy
// Inputs: Environment conditions, user interactions, data states
// Outputs: Premium visual components with advanced materials and animations
// Constraints: Performance-first, accessibility-compliant, iOS 26+ features

import SwiftUI

/// Premium design system that makes the app feel like a $100+ product
struct PremiumDesign {

    // MARK: - Advanced Typography System

    struct Typography {
        // Premium font weights with precise hierarchy
        static let displayLarge = Font.system(size: 44, weight: .heavy, design: .rounded)
        static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
        static let displaySmall = Font.system(size: 28, weight: .semibold, design: .rounded)

        static let headlineLarge = Font.system(size: 24, weight: .bold, design: .default)
        static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .default)
        static let headlineSmall = Font.system(size: 18, weight: .medium, design: .default)

        static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

        static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
        static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
        static let labelSmall = Font.system(size: 11, weight: .semibold, design: .default)

        // Monospace for numbers (like Copilot)
        static let numberLarge = Font.system(size: 28, weight: .bold, design: .monospaced)
        static let numberMedium = Font.system(size: 20, weight: .semibold, design: .monospaced)
        static let numberSmall = Font.system(size: 16, weight: .medium, design: .monospaced)
    }

    // MARK: - Premium Color Palette

    struct Colors {
        // Sophisticated neutral grays with warm undertones
        static let gray100 = Color(.displayP3, red: 0.02, green: 0.02, blue: 0.04, opacity: 1.0)
        static let gray200 = Color(.displayP3, red: 0.04, green: 0.05, blue: 0.08, opacity: 1.0)
        static let gray300 = Color(.displayP3, red: 0.08, green: 0.09, blue: 0.12, opacity: 1.0)
        static let gray400 = Color(.displayP3, red: 0.12, green: 0.13, blue: 0.16, opacity: 1.0)
        static let gray500 = Color(.displayP3, red: 0.16, green: 0.17, blue: 0.20, opacity: 1.0)
        static let gray600 = Color(.displayP3, red: 0.24, green: 0.25, blue: 0.28, opacity: 1.0)
        static let gray700 = Color(.displayP3, red: 0.32, green: 0.33, blue: 0.36, opacity: 1.0)
        static let gray800 = Color(.displayP3, red: 0.48, green: 0.49, blue: 0.52, opacity: 1.0)
        static let gray900 = Color(.displayP3, red: 0.72, green: 0.73, blue: 0.76, opacity: 1.0)

        // Premium accent colors with P3 color space
        static let primaryBlue = Color(.displayP3, red: 0.0, green: 0.5, blue: 1.0, opacity: 1.0)
        static let primaryGreen = Color(.displayP3, red: 0.0, green: 0.8, blue: 0.4, opacity: 1.0)
        static let primaryOrange = Color(.displayP3, red: 1.0, green: 0.6, blue: 0.0, opacity: 1.0)
        static let primaryPurple = Color(.displayP3, red: 0.6, green: 0.4, blue: 1.0, opacity: 1.0)

        // Semantic colors with enhanced vibrancy
        static let success = Color(.displayP3, red: 0.0, green: 0.8, blue: 0.4, opacity: 1.0)
        static let warning = Color(.displayP3, red: 1.0, green: 0.6, blue: 0.0, opacity: 1.0)
        static let error = Color(.displayP3, red: 1.0, green: 0.3, blue: 0.3, opacity: 1.0)
        static let info = Color(.displayP3, red: 0.0, green: 0.7, blue: 1.0, opacity: 1.0)
    }

    // MARK: - Advanced Spacing System

    struct Spacing {
        // Mathematical ratio-based spacing (1.618 golden ratio)
        static let ratio: CGFloat = 1.618

        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 16
        static let xl: CGFloat = 26    // 16 * 1.618
        static let xxl: CGFloat = 42   // 26 * 1.618
        static let xxxl: CGFloat = 68  // 42 * 1.618
        static let huge: CGFloat = 110 // 68 * 1.618
    }

    // MARK: - Premium Shadows & Elevations

    struct Elevation {
        static let subtle = (
            color: Color.black.opacity(0.08),
            radius: CGFloat(2),
            x: CGFloat(0),
            y: CGFloat(1)
        )

        static let low = (
            color: Color.black.opacity(0.12),
            radius: CGFloat(4),
            x: CGFloat(0),
            y: CGFloat(2)
        )

        static let medium = (
            color: Color.black.opacity(0.16),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(4)
        )

        static let high = (
            color: Color.black.opacity(0.20),
            radius: CGFloat(16),
            x: CGFloat(0),
            y: CGFloat(8)
        )

        static let dramatic = (
            color: Color.black.opacity(0.24),
            radius: CGFloat(32),
            x: CGFloat(0),
            y: CGFloat(16)
        )
    }

    // MARK: - Advanced Animation System

    struct Animations {
        // Copilot-style spring animations
        static let gentleSpring = Animation.spring(
            response: 0.6,
            dampingFraction: 0.8,
            blendDuration: 0.2
        )

        static let responsiveSpring = Animation.spring(
            response: 0.4,
            dampingFraction: 0.75,
            blendDuration: 0.1
        )

        static let playfulSpring = Animation.spring(
            response: 0.5,
            dampingFraction: 0.65,
            blendDuration: 0.15
        )

        static let dramaticSpring = Animation.spring(
            response: 0.8,
            dampingFraction: 0.7,
            blendDuration: 0.3
        )

        // Custom timing curves
        static let easeOutCubic = Animation.timingCurve(0.33, 1, 0.68, 1, duration: 0.4)
        static let easeInOutQuart = Animation.timingCurve(0.76, 0, 0.24, 1, duration: 0.5)
        static let easeOutExpo = Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.6)
    }
}

// MARK: - Premium Material Effects

struct PremiumMaterialCard<Content: View>: View {
    let content: Content
    let style: MaterialStyle
    @State private var isHovered = false
    @State private var isPressed = false

    enum MaterialStyle {
        case glass       // Ultra-thin material with subtle border
        case frosted     // Thick material with enhanced blur
        case elevated    // Thick material with dramatic shadow
        case premium     // Custom gradient with glass overlay
    }

    init(style: MaterialStyle = .glass, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .background {
                materialBackground
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderGradient, lineWidth: borderWidth)
            }
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowOffset.x,
                y: shadowOffset.y
            )
            .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.02 : 1.0))
            .animation(PremiumDesign.Animations.responsiveSpring, value: isPressed)
            .animation(PremiumDesign.Animations.gentleSpring, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            .pressEvents {
                isPressed = true
            } onRelease: {
                isPressed = false
            }
    }

    private var materialBackground: some View {
        Group {
            switch style {
            case .glass:
                Color.clear
                    .background(.ultraThinMaterial)
            case .frosted:
                Color.clear
                    .background(.thickMaterial)
            case .elevated:
                Color.clear
                    .background(.regularMaterial)
            case .premium:
                LinearGradient(
                    colors: [
                        PremiumDesign.Colors.gray300.opacity(0.8),
                        PremiumDesign.Colors.gray400.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(.ultraThinMaterial)
            }
        }
    }

    private var cornerRadius: CGFloat {
        switch style {
        case .glass: return 16
        case .frosted: return 20
        case .elevated: return 24
        case .premium: return 28
        }
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(style == .premium ? 0.3 : 0.15),
                Color.white.opacity(style == .premium ? 0.1 : 0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderWidth: CGFloat {
        style == .premium ? 1.5 : 1.0
    }

    private var shadowColor: Color {
        switch style {
        case .glass: return PremiumDesign.Elevation.subtle.color
        case .frosted: return PremiumDesign.Elevation.low.color
        case .elevated: return PremiumDesign.Elevation.medium.color
        case .premium: return PremiumDesign.Elevation.high.color
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .glass: return PremiumDesign.Elevation.subtle.radius
        case .frosted: return PremiumDesign.Elevation.low.radius
        case .elevated: return PremiumDesign.Elevation.medium.radius
        case .premium: return PremiumDesign.Elevation.high.radius
        }
    }

    private var shadowOffset: (x: CGFloat, y: CGFloat) {
        switch style {
        case .glass: return (PremiumDesign.Elevation.subtle.x, PremiumDesign.Elevation.subtle.y)
        case .frosted: return (PremiumDesign.Elevation.low.x, PremiumDesign.Elevation.low.y)
        case .elevated: return (PremiumDesign.Elevation.medium.x, PremiumDesign.Elevation.medium.y)
        case .premium: return (PremiumDesign.Elevation.high.x, PremiumDesign.Elevation.high.y)
        }
    }
}

// MARK: - Advanced Number Display (Copilot-style)

struct PremiumNumberDisplay: View {
    let value: String
    let label: String?
    let trend: TrendDirection?
    let size: NumberSize
    @State private var animateValue = false

    enum TrendDirection {
        case up, down, neutral

        var color: Color {
            switch self {
            case .up: return PremiumDesign.Colors.success
            case .down: return PremiumDesign.Colors.error
            case .neutral: return PremiumDesign.Colors.gray700
            }
        }

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
    }

    enum NumberSize {
        case large, medium, small

        var font: Font {
            switch self {
            case .large: return PremiumDesign.Typography.numberLarge
            case .medium: return PremiumDesign.Typography.numberMedium
            case .small: return PremiumDesign.Typography.numberSmall
            }
        }

        var spacing: CGFloat {
            switch self {
            case .large: return PremiumDesign.Spacing.md
            case .medium: return PremiumDesign.Spacing.sm
            case .small: return PremiumDesign.Spacing.xs
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: size.spacing) {
            HStack(alignment: .firstTextBaseline, spacing: PremiumDesign.Spacing.sm) {
                Text(value)
                    .font(size.font)
                    .fontWeight(.bold)
                    .foregroundStyle(PremiumDesign.Colors.gray900)
                    .scaleEffect(animateValue ? 1.05 : 1.0)
                    .animation(PremiumDesign.Animations.playfulSpring, value: animateValue)

                if let trend = trend {
                    HStack(spacing: PremiumDesign.Spacing.xxs) {
                        Image(systemName: trend.icon)
                            .font(.caption)
                        Text("5.2%")
                            .font(PremiumDesign.Typography.labelSmall)
                    }
                    .foregroundStyle(trend.color)
                    .padding(.horizontal, PremiumDesign.Spacing.sm)
                    .padding(.vertical, PremiumDesign.Spacing.xxs)
                    .background {
                        Capsule()
                            .fill(trend.color.opacity(0.1))
                    }
                }
            }

            if let label = label {
                Text(label)
                    .font(PremiumDesign.Typography.labelMedium)
                    .foregroundStyle(PremiumDesign.Colors.gray700)
            }
        }
        .onAppear {
            withAnimation(PremiumDesign.Animations.gentleSpring.delay(0.2)) {
                animateValue = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(PremiumDesign.Animations.gentleSpring) {
                    animateValue = false
                }
            }
        }
    }
}

// MARK: - Custom Press Events Modifier

struct PressEventModifier: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: 0) { } onPressingChanged: { pressing in
                if pressing {
                    onPress()
                } else {
                    onRelease()
                }
            }
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.modifier(PressEventModifier(onPress: onPress, onRelease: onRelease))
    }
}