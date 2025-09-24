// Account settings with profile, connectors, and notification preferences.

import SwiftUI

struct AccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UIState.self) private var uiState
    @Environment(NotificationPreferencesStore.self) private var prefs
    @Environment(UserProfileStore.self) private var profile
    @State private var animateContent = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Page Title
                    HStack {
                        Text("Account")
                            .font(CopilotDesign.Typography.displayMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        Spacer()
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 15)

                    // Account Section
                    AccountSection()
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                    // Connectors Section
                    ConnectorsSection()
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 25)

                    // Notifications Section
                    NotificationsSection()
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)

                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
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
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
}

struct AccountSection: View {
    @Environment(UserProfileStore.self) private var profile

    var body: some View {
        VStack(spacing: 12) {
            // Section Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.accent)

                    Text("Account")
                        .font(CopilotDesign.Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 4)

            // Section Content
            CleanCard(style: .flat) {
                VStack(spacing: 16) {
                    HStack {
                        Text("Display Name")
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textSecondary)
                        Spacer()
                    }

                    TextField("Enter your name", text: Binding(
                        get: { profile.displayName },
                        set: { profile.displayName = $0; profile.save() }
                    ))
                    .font(CopilotDesign.Typography.bodyMedium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(CopilotDesign.Colors.surface)
                    }
                }
                .padding(16)
            }
        }
    }
}

struct ConnectorsSection: View {
    @Environment(UIState.self) private var uiState

    var body: some View {
        VStack(spacing: 12) {
            // Section Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.accent)

                    Text("Connectors")
                        .font(CopilotDesign.Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 4)

            // Section Content
            CleanCard(style: .flat) {
                Button(action: { uiState.showPlaidLinkSheet = true }) {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(CopilotDesign.Colors.accent.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "building.columns.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(CopilotDesign.Colors.accent)
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Connect Bank (Plaid)")
                                .font(CopilotDesign.Typography.bodyMedium)
                                .fontWeight(.medium)
                                .foregroundStyle(CopilotDesign.Colors.textPrimary)

                            Text("Link your bank account for transaction data")
                                .font(CopilotDesign.Typography.labelSmall)
                                .foregroundStyle(CopilotDesign.Colors.textTertiary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(CopilotDesign.Colors.textTertiary)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct NotificationsSection: View {
    @Environment(NotificationPreferencesStore.self) private var prefs

    var body: some View {
        VStack(spacing: 12) {
            // Section Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.accent)

                    Text("Notifications")
                        .font(CopilotDesign.Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 4)

            // Section Content
            CleanCard(style: .flat) {
                VStack(spacing: 0) {
                    NotificationToggleRow(
                        title: "Enable Notifications",
                        subtitle: "Receive card recommendations and alerts",
                        isOn: Binding(
                            get: { prefs.enabled },
                            set: { prefs.enabled = $0; prefs.save() }
                        )
                    )

                    Divider()
                        .padding(.horizontal, 16)

                    NotificationToggleRow(
                        title: "Restaurants",
                        subtitle: "Alerts when near dining establishments",
                        isOn: Binding(
                            get: { prefs.restaurants },
                            set: { prefs.restaurants = $0; prefs.save() }
                        )
                    )

                    Divider()
                        .padding(.horizontal, 16)

                    NotificationToggleRow(
                        title: "Coffee",
                        subtitle: "Alerts when near coffee shops",
                        isOn: Binding(
                            get: { prefs.coffee },
                            set: { prefs.coffee = $0; prefs.save() }
                        )
                    )

                    Divider()
                        .padding(.horizontal, 16)

                    NotificationToggleRow(
                        title: "Groceries",
                        subtitle: "Alerts when near grocery stores",
                        isOn: Binding(
                            get: { prefs.groceries },
                            set: { prefs.groceries = $0; prefs.save() }
                        )
                    )

                    Divider()
                        .padding(.horizontal, 16)

                    NotificationToggleRow(
                        title: "Gas",
                        subtitle: "Alerts when near gas stations",
                        isOn: Binding(
                            get: { prefs.gas },
                            set: { prefs.gas = $0; prefs.save() }
                        ),
                        isLast: true
                    )
                }
            }
        }
    }
}

struct NotificationToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var isLast: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(CopilotDesign.Typography.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                Text(subtitle)
                    .font(CopilotDesign.Typography.labelSmall)
                    .foregroundStyle(CopilotDesign.Colors.textTertiary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(16)
    }
}


