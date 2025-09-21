// Rules: Reusable button components with Apple-precise styling and function placeholders
// Inputs: Button configuration, action handlers
// Outputs: Consistent button UI with customizable functions
// Constraints: Follow Apple HIG, beautiful rounded corners, premium feel

import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let icon: String?
    let action: (() -> Void)?
    @State private var isPressed = false

    init(title: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action?()
        }) {
            HStack(spacing: CopilotDesign.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(CopilotDesign.Typography.labelLarge)
                }

                Text(title)
                    .font(CopilotDesign.Typography.labelLarge)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CopilotDesign.Colors.brandPrimary)
                    .shadow(
                        color: CopilotDesign.Colors.brandPrimary.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct SecondaryActionButton: View {
    let title: String
    let icon: String?
    let action: (() -> Void)?
    @State private var isPressed = false

    init(title: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action?()
        }, label: {
            HStack(spacing: CopilotDesign.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(CopilotDesign.Typography.labelLarge)
                }

                Text(title)
                    .font(CopilotDesign.Typography.labelLarge)
                    .fontWeight(.medium)
            }
            .foregroundStyle(CopilotDesign.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CopilotDesign.Colors.surface2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(CopilotDesign.Colors.surface3, lineWidth: 1)
                    }
            }
        })
        .buttonStyle(PressableButtonStyle(scale: 0.96))
    }
}

struct TertiaryActionButton: View {
    let title: String
    let icon: String?
    let action: (() -> Void)?
    @State private var isPressed = false

    init(title: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action?()
        }, label: {
            HStack(spacing: CopilotDesign.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(CopilotDesign.Typography.labelMedium)
                }

                Text(title)
                    .font(CopilotDesign.Typography.labelMedium)
                    .fontWeight(.medium)
            }
            .foregroundStyle(CopilotDesign.Colors.brandPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(CopilotDesign.Colors.brandPrimary, lineWidth: 2)
            }
        })
        .buttonStyle(PressableButtonStyle(scale: 0.96))
    }
}

struct CircularIconButton: View {
    let icon: String
    let size: CGFloat
    let action: (() -> Void)?
    @State private var isPressed = false

    init(icon: String, size: CGFloat = 44, action: (() -> Void)? = nil) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action?()
        }, label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundStyle(CopilotDesign.Colors.textPrimary)
                .frame(width: size, height: size)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Circle()
                                .strokeBorder(CopilotDesign.Colors.surface3, lineWidth: 1)
                        }
                }
        })
        .buttonStyle(PressableButtonStyle(scale: 0.9))
    }
}

struct DestructiveActionButton: View {
    let title: String
    let icon: String?
    let action: (() -> Void)?
    @State private var isPressed = false

    init(title: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action?()
        }) {
            HStack(spacing: CopilotDesign.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(CopilotDesign.Typography.labelLarge)
                }

                Text(title)
                    .font(CopilotDesign.Typography.labelLarge)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CopilotDesign.Colors.error)
                    .shadow(
                        color: CopilotDesign.Colors.error.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Preview
#Preview("Button Components") {
    VStack(spacing: CopilotDesign.Spacing.lg) {
        PrimaryActionButton(title: "Primary Action", icon: "creditcard.fill") {
            print("Primary action tapped")
        }

        SecondaryActionButton(title: "Secondary Action", icon: "chart.bar.fill") {
            print("Secondary action tapped")
        }

        TertiaryActionButton(title: "Tertiary Action", icon: "gear") {
            print("Tertiary action tapped")
        }

        HStack(spacing: CopilotDesign.Spacing.md) {
            CircularIconButton(icon: "person.crop.circle.fill") {
                print("Profile tapped")
            }

            CircularIconButton(icon: "bell.fill") {
                print("Notifications tapped")
            }

            CircularIconButton(icon: "gear") {
                print("Settings tapped")
            }
        }

        DestructiveActionButton(title: "Delete Account", icon: "trash.fill") {
            print("Destructive action tapped")
        }
    }
    .padding(CopilotDesign.Spacing.xl)
    .background(CopilotDesign.Colors.background)
}