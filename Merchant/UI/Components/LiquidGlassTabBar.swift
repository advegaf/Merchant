// Rules: Liquid glass floating tab bar with blur effects and smooth animations
// Inputs: Tab selection state, navigation actions
// Outputs: Floating tab bar with glass morphism effects
// Constraints: iOS 26+ features, 60fps animations, accessibility support

import SwiftUI

enum TabBarItem: String, CaseIterable {
    case home = "house.fill"
    case nearby = "location.fill"

    var title: String {
        switch self {
        case .home: return "Home"
        case .nearby: return "Nearby"
        }
    }
}

private extension Array where Element == TabBarItem {
    static var mainTabs: [TabBarItem] { [.home, .nearby] }
}

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabBarItem
    @Environment(UIState.self) private var uiState
    @State private var animateSelection = false
    @Namespace private var tabSelection

    var body: some View {
        HStack(spacing: 0) {
            ForEach([TabBarItem].mainTabs, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: tabSelection
                ) {
                    withAnimation(CopilotDesign.Animations.smoothSpring) {
                        selectedTab = tab
                        animateSelection = true
                    }

                    // Handle tab-specific actions
                    handleTabAction(tab)

                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            // Enhanced liquid glass effect
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    // Inner glow
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear,
                                    Color.black.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    // Glass border
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 25,
                    x: 0,
                    y: 12
                )
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        }
        .scaleEffect(animateSelection ? 1.05 : 1.0)
        .animation(CopilotDesign.Animations.quickSpring, value: animateSelection)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateSelection = false
            }
        }
    }

    private func handleTabAction(_ tab: TabBarItem) {
        switch tab {
        case .home:
            break
        case .nearby:
            uiState.showNearbySheet = true
        }
    }
}

struct TabBarButton: View {
    let tab: TabBarItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Background for selected state
                    if isSelected {
                        Capsule()
                            .fill(CopilotDesign.Colors.accent.opacity(0.2))
                            .frame(width: 56, height: 32)
                            .matchedGeometryEffect(id: "selectedTab", in: namespace)
                    }

                    Image(systemName: tab.rawValue)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(
                            isSelected
                                ? CopilotDesign.Colors.accent
                                : CopilotDesign.Colors.textTertiary
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }

                Text(tab.title)
                    .font(CopilotDesign.Typography.labelSmall)
                    .foregroundStyle(
                        isSelected
                            ? CopilotDesign.Colors.accent
                            : CopilotDesign.Colors.textTertiary
                    )
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .animation(CopilotDesign.Animations.smoothSpring, value: isSelected)
        .buttonStyle(PressableButtonStyle(scale: 0.96))
    }
}

#Preview {
    VStack {
        Spacer()
        LiquidGlassTabBar(selectedTab: .constant(.home))
            .environment(UIState())
            .padding()
    }
    .background(CopilotDesign.Colors.background)
}

// MARK: - Modern iOS 26 Tab Bar

struct ModernTabBar: View {
    @Binding var selectedTab: TabBarItem
    @Environment(UIState.self) private var uiState
    @State private var animateSelection = false
    @Namespace private var tabSelection

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabBarItem.allCases, id: \.self) { tab in
                ModernTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: tabSelection
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)) {
                        selectedTab = tab
                        animateSelection = true
                    }

                    // Handle tab-specific actions
                    handleTabAction(tab)

                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            // Modern iOS 26 style background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            Color.white.opacity(0.2),
                            lineWidth: 0.5
                        )
                }
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 15,
                    x: 0,
                    y: 8
                )
        }
        .scaleEffect(animateSelection ? 1.02 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.9), value: animateSelection)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animateSelection = false
            }
        }
    }

    private func handleTabAction(_ tab: TabBarItem) {
        switch tab {
        case .home:
            // Already on home
            break
        case .nearby:
            uiState.showNearbySheet = true
        }
    }
}

struct ModernTabButton: View {
    let tab: TabBarItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // Background pill for selected state
                    if isSelected {
                        Capsule()
                            .fill(CopilotDesign.Colors.accent)
                            .frame(width: 50, height: 28)
                            .matchedGeometryEffect(id: "selectedTab", in: namespace)
                    }

                    Image(systemName: tab.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(
                            isSelected
                                ? Color.white
                                : CopilotDesign.Colors.textTertiary
                        )
                        .scaleEffect(isSelected ? 1.0 : 0.95)
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(
                        isSelected
                            ? CopilotDesign.Colors.accent
                            : CopilotDesign.Colors.textTertiary
                    )
                    .opacity(isSelected ? 1.0 : 0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        .buttonStyle(PressableButtonStyle(scale: 0.96))
    }
}