// Rules: Beautiful settings page with premium design and comprehensive options
// Inputs: User preferences, account settings, app configuration
// Outputs: Elegant settings interface with smooth animations
// Constraints: Intuitive organization, premium aesthetics, accessibility

import SwiftUI
import UIKit

struct BeautifulSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserProfileStore.self) private var userProfile
    @State private var animateContent = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Page Title
                    HStack {
                        Text("Settings")
                            .font(CopilotDesign.Typography.displayMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        Spacer()
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 15)

                    // Profile Header
                    ProfileHeaderSection()
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                    // Settings Sections
                    VStack(spacing: 16) {
                        CardsSettingsSection()
                        NotificationSettingsSection()
                        PrivacySettingsSection()
                        AppearanceSettingsSection()
                        DataSettingsSection()
                        SupportSettingsSection()
                    }
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
                    CleanButton("Done", style: .glass, size: .small) { dismiss() }
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

struct ProfileHeaderSection: View {
    @Environment(UserProfileStore.self) private var userProfile
    @State private var profileImageScale: CGFloat = 0.9
    @State private var showEditProfile = false
    @State private var showImagePicker = false

    var body: some View {
        CleanCard {
            HStack(spacing: 16) {
                // Profile Image
                Button(action: { showImagePicker = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        CopilotDesign.Colors.accent.opacity(0.2),
                                        CopilotDesign.Colors.info.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        if let profileImage = userProfile.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Text(String(userProfile.displayName.prefix(1)).uppercased())
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            CopilotDesign.Colors.accent,
                                            CopilotDesign.Colors.info
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        // Camera overlay for profile picture change
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.white)
                            }
                            .opacity(0.8)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(profileImageScale)

                // Profile Info
                VStack(alignment: .leading, spacing: 6) {
                    Button(action: { showEditProfile = true }) {
                        HStack(spacing: 4) {
                            Text(userProfile.displayName)
                                .font(CopilotDesign.Typography.headlineLarge)
                                .fontWeight(.bold)
                                .foregroundStyle(CopilotDesign.Colors.textPrimary)

                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(CopilotDesign.Colors.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)

                    Text("Premium Member")
                        .font(CopilotDesign.Typography.labelMedium)
                        .foregroundStyle(CopilotDesign.Colors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background {
                            Capsule()
                                .fill(CopilotDesign.Colors.accent.opacity(0.1))
                        }

                    Text("Optimizing rewards since 2025")
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }

                Spacer()
            }
            .padding(20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                profileImageScale = 1.0
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerSheet()
        }
    }
}

struct CardsSettingsSection: View {
    @Environment(UIState.self) private var uiState

    var body: some View {
        SettingsSection(title: "Cards & Rewards", icon: "creditcard.fill") {
            SettingsRow(
                title: "Manage Cards",
                subtitle: "Add, remove, or organize your cards",
                icon: "creditcard.and.123",
                action: {
                    uiState.showCardPicker = true
                }
            )

            SettingsRow(
                title: "Reward Categories",
                subtitle: "Customize spending category preferences",
                icon: "tag.fill",
                action: {
                    uiState.showNearbyCategories = true
                }
            )

            SettingsRow(
                title: "Optimization Settings",
                subtitle: "Fine-tune recommendation algorithms",
                icon: "slider.horizontal.3",
                action: {
                    uiState.showOptimizationBreakdown = true
                }
            )
        }
    }
}

struct NotificationSettingsSection: View {
    @Environment(UIState.self) private var uiState

    var body: some View {
        SettingsSection(title: "Notifications", icon: "bell.fill") {
            SettingsRow(
                title: "Smart Alerts",
                subtitle: "Location-based card recommendations",
                icon: "location.fill",
                action: {
                    uiState.showNotificationSettings = true
                }
            )

            SettingsRow(
                title: "Spending Reminders",
                subtitle: "Budget and goal notifications",
                icon: "exclamationmark.triangle.fill",
                action: {
                    uiState.showNotificationSettings = true
                }
            )

            SettingsRow(
                title: "Weekly Summary",
                subtitle: "Earnings and optimization reports",
                icon: "chart.bar.fill",
                action: {
                    uiState.showNotificationSettings = true
                }
            )
        }
    }
}

struct PrivacySettingsSection: View {
    var body: some View {
        SettingsSection(title: "Privacy & Security", icon: "lock.fill") {
            SettingsRow(
                title: "Location Services",
                subtitle: "Control how location data is used",
                icon: "location.circle.fill",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )

            SettingsRow(
                title: "Data Usage",
                subtitle: "Manage what data is collected",
                icon: "chart.pie.fill",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )

            SettingsRow(
                title: "Biometric Lock",
                subtitle: "Secure app with Face ID or Touch ID",
                icon: "faceid",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
    }
}

struct AppearanceSettingsSection: View {
    var body: some View {
        SettingsSection(title: "Appearance", icon: "paintbrush.fill") {
            SettingsRow(
                title: "Theme",
                subtitle: "Dark mode, light mode, or auto",
                icon: "moon.fill",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )

            SettingsRow(
                title: "Liquid Glass Effects",
                subtitle: "Enhanced visual effects",
                icon: "drop.fill",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )

            SettingsRow(
                title: "Animations",
                subtitle: "Customize motion and transitions",
                icon: "wand.and.stars",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
    }
}

struct DataSettingsSection: View {
    var body: some View {
        SettingsSection(title: "Data & Storage", icon: "internaldrive.fill") {
            SettingsRow(
                title: "Export Data",
                subtitle: "Download your transaction history",
                icon: "square.and.arrow.up.fill",
                action: {
                    let data = TransactionStore.shared.all()
                    guard let encoded = try? JSONEncoder().encode(data) else { return }
                    let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("merchant-transactions.json")
                    try? encoded.write(to: tmpURL)
                    #if canImport(UIKit)
                    let av = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        root.present(av, animated: true)
                    }
                    #endif
                }
            )

            SettingsRow(
                title: "Clear Cache",
                subtitle: "Free up storage space",
                icon: "trash.fill",
                action: {
                    SelectedCardsStore.shared.clear()
                    TransactionStore.shared.clear()
                }
            )

            SettingsRow(
                title: "Reset Settings",
                subtitle: "Restore app to default state",
                icon: "arrow.clockwise",
                action: {
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
                    UserDefaults.standard.synchronize()
                }
            )
        }
    }
}

struct SupportSettingsSection: View {
    var body: some View {
        SettingsSection(title: "Support & About", icon: "questionmark.circle.fill") {
            SettingsRow(
                title: "Help Center",
                subtitle: "Guides and frequently asked questions",
                icon: "book.fill",
                action: {
                    if let url = URL(string: "https://merchant.example.com/help") { UIApplication.shared.open(url) }
                }
            )

            SettingsRow(
                title: "Contact Support",
                subtitle: "Get help from our team",
                icon: "message.fill",
                action: {
                    if let url = URL(string: "mailto:support@merchant.example.com") { UIApplication.shared.open(url) }
                }
            )

            SettingsRow(
                title: "Rate Merchant",
                subtitle: "Share your experience on the App Store",
                icon: "star.fill",
                action: {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id000000000?action=write-review") { UIApplication.shared.open(url) }
                }
            )

            SettingsRow(
                title: "Privacy Policy",
                subtitle: "How we protect your information",
                icon: "doc.text.fill",
                action: {
                    if let url = URL(string: "https://merchant.example.com/privacy") { UIApplication.shared.open(url) }
                }
            )

            SettingsRow(
                title: "Version",
                subtitle: "Merchant 1.0.0 (Build 1)",
                icon: "info.circle.fill",
                action: nil
            )
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 12) {
            // Section Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.accent)

                    Text(title)
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
                    content
                }
            }
        }
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: (() -> Void)?

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action?()
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 16) {
                // Icon
                Circle()
                    .fill(CopilotDesign.Colors.accent.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(CopilotDesign.Colors.accent)
                    }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(CopilotDesign.Typography.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)

                    Text(subtitle)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                        .lineLimit(2)
                }

                Spacer()

                // Chevron
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                }
            }
            .padding(16)
            .background(
                isPressed
                    ? CopilotDesign.Colors.cardHover
                    : Color.clear
            )
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(CopilotDesign.Animations.quickSpring, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { } onPressingChanged: { pressing in
            if action != nil {
                isPressed = pressing
            }
        }
    }
}

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserProfileStore.self) private var userProfile
    @State private var displayName: String = ""
    @State private var animateContent = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Page Title
                    HStack {
                        Text("Edit Profile")
                            .font(CopilotDesign.Typography.displayMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        Spacer()
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 15)

                    // Name Section
                    CleanCard {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Display Name")
                                    .font(CopilotDesign.Typography.headlineMedium)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(CopilotDesign.Colors.textPrimary)
                                Spacer()
                            }

                            TextField("Enter your name", text: $displayName)
                                .font(CopilotDesign.Typography.bodyMedium)
                                .foregroundStyle(CopilotDesign.Colors.textPrimary)
                                .padding(16)
                                .background {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(CopilotDesign.Colors.surface)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(CopilotDesign.Colors.border, lineWidth: 1)
                                        }
                                }
                        }
                        .padding(20)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)

                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        CopilotDesign.Colors.background,
                        CopilotDesign.Colors.surface.opacity(0.3),
                        CopilotDesign.Colors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CleanButton("Cancel", style: .glass, size: .small) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Save", style: .glass, size: .small) {
                        userProfile.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                        userProfile.save()
                        dismiss()
                    }
                    .disabled(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            displayName = userProfile.displayName
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
}

struct ImagePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserProfileStore.self) private var userProfile
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var animateContent = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Page Title
                    HStack {
                        Text("Profile Picture")
                            .font(CopilotDesign.Typography.displayMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)
                        Spacer()
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 15)

                    // Current Profile Picture Preview
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            CopilotDesign.Colors.accent.opacity(0.2),
                                            CopilotDesign.Colors.info.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)

                            if let profileImage = userProfile.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Text(String(userProfile.displayName.prefix(1)).uppercased())
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                CopilotDesign.Colors.accent,
                                                CopilotDesign.Colors.info
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }

                        Text("Choose a new profile picture")
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)

                    // Options
                    VStack(spacing: 12) {
                        // Take Photo
                        CleanCard(style: .flat) {
                            Button(action: { showCamera = true }) {
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(CopilotDesign.Colors.accent.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(CopilotDesign.Colors.accent)
                                        }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Take Photo")
                                            .font(CopilotDesign.Typography.bodyMedium)
                                            .fontWeight(.medium)
                                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                        Text("Use your camera to take a new photo")
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

                        // Choose from Library
                        CleanCard(style: .flat) {
                            Button(action: { showPhotoLibrary = true }) {
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(CopilotDesign.Colors.info.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(CopilotDesign.Colors.info)
                                        }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Choose from Library")
                                            .font(CopilotDesign.Typography.bodyMedium)
                                            .fontWeight(.medium)
                                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                        Text("Select a photo from your library")
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

                        // Remove Current Photo
                        if userProfile.profileImage != nil {
                            CleanCard(style: .flat) {
                                Button(action: {
                                    userProfile.clearProfileImage()
                                    dismiss()
                                }) {
                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(CopilotDesign.Colors.error.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                            .overlay {
                                                Image(systemName: "trash.fill")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundStyle(CopilotDesign.Colors.error)
                                            }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Remove Current Photo")
                                                .font(CopilotDesign.Typography.bodyMedium)
                                                .fontWeight(.medium)
                                                .foregroundStyle(CopilotDesign.Colors.error)

                                            Text("Use initials instead")
                                                .font(CopilotDesign.Typography.labelSmall)
                                                .foregroundStyle(CopilotDesign.Colors.textTertiary)
                                        }

                                        Spacer()
                                    }
                                    .padding(16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 25)

                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        CopilotDesign.Colors.background,
                        CopilotDesign.Colors.surface.opacity(0.3),
                        CopilotDesign.Colors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                userProfile.profileImage = image
                userProfile.save()
                dismiss()
            }
        }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary) { image in
                userProfile.profileImage = image
                userProfile.save()
                dismiss()
            }
        }
    }
}

import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    BeautifulSettingsSheet()
        .environment(UIState())
        .environment(UserProfileStore.shared)
}