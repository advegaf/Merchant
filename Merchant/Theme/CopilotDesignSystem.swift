// Rules: Copilot and Robinhood-inspired design system with premium animations
// Inputs: User interactions, state changes, data updates
// Outputs: Sophisticated UI patterns matching fintech leaders
// Constraints: 60fps performance, iOS 26+ features, award-level polish

import SwiftUI

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .displayP3,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// Design system inspired by Copilot and Robinhood's premium fintech aesthetics
struct CopilotDesign {

    // MARK: - Typography System (Robinhood-inspired)

    struct Typography {
        // Robinhood uses SF Pro with specific weights and spacing
        static let displayLarge = Font.system(size: 40, weight: .black, design: .default)
        static let displayMedium = Font.system(size: 32, weight: .heavy, design: .default)
        static let displaySmall = Font.system(size: 24, weight: .bold, design: .default)

        static let headlineLarge = Font.system(size: 22, weight: .bold, design: .default)
        static let headlineMedium = Font.system(size: 18, weight: .semibold, design: .default)
        static let headlineSmall = Font.system(size: 16, weight: .semibold, design: .default)

        static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

        static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
        static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
        static let labelSmall = Font.system(size: 11, weight: .semibold, design: .default)

        // Numbers use tabular spacing for alignment (Copilot-style)
        static let numberHuge = Font.system(size: 48, weight: .black, design: .default).monospaced()
        static let numberLarge = Font.system(size: 32, weight: .bold, design: .default).monospaced()
        static let numberMedium = Font.system(size: 20, weight: .semibold, design: .default).monospaced()
        static let numberSmall = Font.system(size: 16, weight: .medium, design: .default).monospaced()
    }

    // MARK: - Clean Color System (Professional Dark Theme)

    struct Colors {
        // Background hierarchy - clean dark gray progression
        static let background = Color(hex: "0F0F0F")     // Deep dark gray base
        static let surface = Color(hex: "1C1C1E")        // Elevated surface
        static let surface1 = Color(hex: "1C1C1E")       // Primary surface (alias)
        static let surface2 = Color(hex: "2C2C2E")       // Secondary surface
        static let surface3 = Color(hex: "3A3A3C")       // Tertiary surface
        static let surface4 = Color(hex: "48484A")       // Quaternary surface
        static let surfaceSecondary = Color(hex: "2C2C2E") // Secondary surface
        static let border = Color(hex: "48484A")         // Subtle borders

        // Text hierarchy - high contrast and readable
        static let textPrimary = Color.white            // Pure white
        static let textSecondary = Color(hex: "E4E4E7") // Near white
        static let textTertiary = Color(hex: "A1A1AA")  // Medium gray
        static let textMuted = Color(hex: "71717A")     // Subtle gray

        // Brand colors - coral accent system
        static let accent = Color(hex: "E94560")        // Primary coral
        static let brandPrimary = Color(hex: "E94560")  // Brand primary (alias for accent)
        static let accentSecondary = Color(hex: "F26B8A") // Light coral
        static let accentMuted = Color(hex: "C73650")   // Dark coral

        // Semantic colors - clean and purposeful
        static let success = Color(hex: "10B981")       // Green
        static let brandGreen = Color(hex: "10B981")    // Brand green (alias for success)
        static let warning = Color(hex: "F59E0B")       // Amber
        static let brandOrange = Color(hex: "F59E0B")   // Brand orange (alias for warning)
        static let error = Color(hex: "EF4444")         // Red
        static let info = Color(hex: "3B82F6")          // Blue
        static let brandBlue = Color(hex: "3B82F6")     // Brand blue (alias for info)

        // Interactive states
        static let buttonPressed = Color.white.opacity(0.1)
        static let cardHover = Color.white.opacity(0.05)
    }

    // MARK: - Spacing System (8pt grid like Robinhood)

    struct Spacing {
        static let xs: CGFloat = 4    // 0.5 units
        static let sm: CGFloat = 8    // 1 unit
        static let md: CGFloat = 16   // 2 units
        static let lg: CGFloat = 24   // 3 units
        static let xl: CGFloat = 32   // 4 units
        static let xxl: CGFloat = 48  // 6 units
        static let xxxl: CGFloat = 64 // 8 units
    }

    // MARK: - Animations (Robinhood-style)

    struct Animations {
        // Robinhood's signature smooth animations
        static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)
        static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.15)
        static let gentleSpring = Animation.spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0.2)
        static let dramaticSpring = Animation.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.3)

        // Timing curves for specific interactions
        static let buttonPress = Animation.easeOut(duration: 0.15)
        static let buttonRelease = Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let slideTransition = Animation.timingCurve(0.25, 1, 0.5, 1, duration: 0.4)
        static let fadeTransition = Animation.easeInOut(duration: 0.25)
    }
}

// MARK: - Pressable ButtonStyle (fast, no gesture conflicts)

struct PressableButtonStyle: ButtonStyle {
    let scale: CGFloat
    let pressedOpacity: Double

    init(scale: CGFloat = 0.98, pressedOpacity: Double = 1.0) {
        self.scale = scale
        self.pressedOpacity = pressedOpacity
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? pressedOpacity : 1.0)
            .animation(CopilotDesign.Animations.quickSpring, value: configuration.isPressed)
    }
}

// MARK: - Clean Button System

struct CleanButton: View {
    let title: String
    let style: Style
    let size: Size
    let isLoading: Bool
    let action: () -> Void

    @State private var isPressed = false

    enum Style {
        case primary, secondary, tertiary, destructive, glass

        var backgroundColor: Color {
            switch self {
            case .primary: return CopilotDesign.Colors.accent
            case .secondary: return CopilotDesign.Colors.surface
            case .tertiary: return Color.clear
            case .destructive: return CopilotDesign.Colors.error
            case .glass: return Color.clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .destructive: return Color.white
            case .secondary: return CopilotDesign.Colors.textPrimary
            case .tertiary: return CopilotDesign.Colors.accent
            case .glass: return CopilotDesign.Colors.textPrimary
            }
        }

        var borderColor: Color? {
            switch self {
            case .tertiary: return nil
            case .glass: return Color.white.opacity(0.12)
            default: return nil
            }
        }

        var isFullWidth: Bool {
            switch self {
            case .primary, .secondary, .destructive:
                return true
            case .tertiary, .glass:
                return false
            }
        }
    }

    enum Size {
        case large, medium, small, extraSmall

        var height: CGFloat {
            switch self {
            case .large: return 56
            case .medium: return 48
            case .small: return 40
            case .extraSmall: return 36
            }
        }

        var cornerRadius: CGFloat {
            return height / 2
        }

        var font: Font {
            switch self {
            case .large: return CopilotDesign.Typography.labelLarge
            case .medium: return CopilotDesign.Typography.labelMedium
            case .small: return CopilotDesign.Typography.labelSmall
            case .extraSmall: return CopilotDesign.Typography.labelSmall
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .large: return 24
            case .medium: return 20
            case .small: return 16
            case .extraSmall: return 16
            }
        }

        var minWidth: CGFloat {
            switch self {
            case .large: return 120
            case .medium: return 100
            case .small: return 72
            case .extraSmall: return 56
            }
        }
    }

    init(
        _ title: String,
        style: Style = .primary,
        size: Size = .large,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: {
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(style.foregroundColor)
                }

                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundStyle(style.foregroundColor)
            }
            .padding(.horizontal, size.horizontalPadding)
            .frame(minWidth: size.minWidth)
            .frame(maxWidth: style.isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .background {
                if style == .tertiary || style == .glass {
                    Capsule()
                        .fill(.thinMaterial)
                        .overlay {
                            if let borderColor = style.borderColor {
                                Capsule()
                                    .strokeBorder(borderColor, lineWidth: 1)
                            }
                        }
                        .overlay {
                            if isPressed {
                                Capsule()
                                    .fill(CopilotDesign.Colors.buttonPressed)
                            }
                        }
                } else {
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .fill(style.backgroundColor)
                        .overlay {
                            if let borderColor = style.borderColor {
                                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                                    .strokeBorder(borderColor, lineWidth: 1)
                            }
                        }
                        .overlay {
                            if isPressed {
                                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                                    .fill(CopilotDesign.Colors.buttonPressed)
                            }
                        }
                }
            }
        }
        .disabled(isLoading)
        .scaleEffect(isPressed && style != .tertiary ? 0.98 : 1.0)
        .animation(CopilotDesign.Animations.quickSpring, value: isPressed)
        .buttonStyle(.plain)
        // Avoid zero-duration long-press gestures that can swallow taps; rely on default button highlight.
    }
}

// MARK: - Copilot-Style Number Display

struct CopilotNumberDisplay: View {
    let value: String
    let subtitle: String?
    let trend: TrendDirection?
    let size: NumberSize
    @State private var animateIn = false

    enum TrendDirection {
        case up, down, neutral

        var color: Color {
            switch self {
            case .up: return CopilotDesign.Colors.success
            case .down: return CopilotDesign.Colors.error
            case .neutral: return CopilotDesign.Colors.textTertiary
            }
        }

        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }
    }

    enum NumberSize {
        case huge, large, medium, small

        var font: Font {
            switch self {
            case .huge: return CopilotDesign.Typography.numberHuge
            case .large: return CopilotDesign.Typography.numberLarge
            case .medium: return CopilotDesign.Typography.numberMedium
            case .small: return CopilotDesign.Typography.numberSmall
            }
        }

        var spacing: CGFloat {
            switch self {
            case .huge: return CopilotDesign.Spacing.md
            case .large: return CopilotDesign.Spacing.sm
            case .medium: return CopilotDesign.Spacing.xs
            case .small: return CopilotDesign.Spacing.xs
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: size.spacing) {
            HStack(alignment: .firstTextBaseline, spacing: CopilotDesign.Spacing.sm) {
                Text(value)
                    .font(size.font)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .offset(y: animateIn ? 0 : 10)

                if let trend = trend {
                    HStack(spacing: CopilotDesign.Spacing.xs) {
                        Image(systemName: trend.icon)
                            .font(.caption2)
                        Text("12.5%")
                            .font(CopilotDesign.Typography.labelSmall)
                    }
                    .foregroundStyle(trend.color)
                    .padding(.horizontal, CopilotDesign.Spacing.sm)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .fill(trend.color.opacity(0.1))
                    }
                    .opacity(animateIn ? 1.0 : 0.0)
                    .offset(x: animateIn ? 0 : 20)
                }
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(CopilotDesign.Typography.labelMedium)
                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .offset(y: animateIn ? 0 : 5)
            }
        }
        .onAppear {
            withAnimation(CopilotDesign.Animations.smoothSpring.delay(0.1)) {
                animateIn = true
            }
        }
    }
}

// MARK: - Clean Card System

struct CleanCard<Content: View>: View {
    let content: Content
    let style: Style

    enum Style {
        case elevated, flat, transparent

        var backgroundColor: Color {
            switch self {
            case .elevated, .flat: return CopilotDesign.Colors.surface
            case .transparent: return Color.clear
            }
        }

        var borderColor: Color? {
            switch self {
            case .flat: return CopilotDesign.Colors.border
            default: return nil
            }
        }

        var hasShadow: Bool {
            switch self {
            case .elevated: return true
            default: return false
            }
        }
    }

    init(style: Style = .elevated, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(style.backgroundColor)
                    .overlay {
                        if let borderColor = style.borderColor {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(borderColor, lineWidth: 1)
                        }
                    }
                    .shadow(
                        color: style.hasShadow ? Color.black.opacity(0.1) : Color.clear,
                        radius: style.hasShadow ? 8 : 0,
                        x: 0,
                        y: style.hasShadow ? 2 : 0
                    )
            }
    }
}

// MARK: - Premium Segmented Control (Robinhood-style)

struct RobinhoodSegmentedControl: View {
    let options: [String]
    @Binding var selectedIndex: Int
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button(action: {
                    withAnimation(CopilotDesign.Animations.smoothSpring) {
                        selectedIndex = index
                    }

                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    Text(option)
                        .font(CopilotDesign.Typography.labelMedium)
                        .fontWeight(selectedIndex == index ? .semibold : .medium)
                        .foregroundStyle(
                            selectedIndex == index
                                ? CopilotDesign.Colors.textPrimary
                                : CopilotDesign.Colors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if selectedIndex == index {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(CopilotDesign.Colors.surface3)
                                    .matchedGeometryEffect(id: "segment", in: animation)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(CopilotDesign.Colors.surface2)
        }
    }
}