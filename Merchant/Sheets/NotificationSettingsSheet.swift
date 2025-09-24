// Notification preferences with category toggles and timing options.

import SwiftUI

struct NotificationSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var preferences = NotificationPreferencesStore.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Notification Settings")
                            .font(CopilotDesign.Typography.displaySmall)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                        Text("Customize when and how you receive card recommendations")
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Master toggle
                    CleanCard {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Smart Notifications")
                                        .font(CopilotDesign.Typography.headlineMedium)
                                        .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                    Text("Get card recommendations based on your location")
                                        .font(CopilotDesign.Typography.bodySmall)
                                        .foregroundStyle(CopilotDesign.Colors.textSecondary)
                                }

                                Spacer()

                                Toggle("", isOn: $preferences.enabled)
                                    .tint(CopilotDesign.Colors.accent)
                            }

                            if preferences.enabled {
                                Divider()
                                    .background(CopilotDesign.Colors.border)

                                VStack(spacing: 12) {
                                    NotificationCategoryRow(
                                        title: "Restaurants & Dining",
                                        subtitle: "Earn 3X Points/$ with dining cards",
                                        icon: "fork.knife",
                                        color: CopilotDesign.Colors.brandOrange,
                                        isEnabled: $preferences.restaurants
                                    )

                                    NotificationCategoryRow(
                                        title: "Coffee & Cafés",
                                        subtitle: "Earn 3X Points/$ with dining cards",
                                        icon: "cup.and.saucer",
                                        color: Color.brown,
                                        isEnabled: $preferences.coffee
                                    )

                                    NotificationCategoryRow(
                                        title: "Grocery Stores",
                                        subtitle: "Earn up to 6X Points/$ on groceries",
                                        icon: "cart.fill",
                                        color: CopilotDesign.Colors.brandGreen,
                                        isEnabled: $preferences.groceries
                                    )

                                    NotificationCategoryRow(
                                        title: "Gas Stations",
                                        subtitle: "Earn up to 5X Points/$ on gas",
                                        icon: "fuelpump.fill",
                                        color: CopilotDesign.Colors.brandBlue,
                                        isEnabled: $preferences.gas
                                    )
                                }
                            }
                        }
                        .padding(20)
                    }

                    // Timing preferences
                    if preferences.enabled {
                        CleanCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Timing & Frequency")
                                    .font(CopilotDesign.Typography.headlineMedium)
                                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Only notify when card earns")
                                            .font(CopilotDesign.Typography.bodyMedium)
                                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                        Spacer()

                                        Text("≥ 2X Points/$")
                                            .font(CopilotDesign.Typography.numberSmall)
                                            .foregroundStyle(CopilotDesign.Colors.accent)
                                    }

                                    HStack {
                                        Text("Maximum per day")
                                            .font(CopilotDesign.Typography.bodyMedium)
                                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                        Spacer()

                                        Text("3 notifications")
                                            .font(CopilotDesign.Typography.numberSmall)
                                            .foregroundStyle(CopilotDesign.Colors.accent)
                                    }

                                    HStack {
                                        Text("Quiet hours")
                                            .font(CopilotDesign.Typography.bodyMedium)
                                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                        Spacer()

                                        Text("10 PM - 8 AM")
                                            .font(CopilotDesign.Typography.numberSmall)
                                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                                    }
                                }
                            }
                            .padding(20)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .background(.ultraThinMaterial)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        let h = UIImpactFeedbackGenerator(style: .light)
                        h.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.2)) { dismiss() }
                    }
                }
            }
        }
    }
}

struct NotificationCategoryRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(color)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(CopilotDesign.Typography.bodyMedium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                Text(subtitle)
                    .font(CopilotDesign.Typography.labelSmall)
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .tint(CopilotDesign.Colors.accent)
        }
    }
}

#Preview {
    NotificationSettingsSheet()
}