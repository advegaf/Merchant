
import SwiftUI

struct LiveActivityBanner: View {
    let venueName: String
    let venueCategory: String
    let bestCard: String
    let recommendation: String
    let estimatedSavings: String
    @State private var isAnimating = false

    var body: some View {
        Button(action: openWallet) {
            HStack(spacing: 12) {
                // Animated location indicator
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Circle()
                        .stroke(categoryColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 44, height: 44)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0 : 1)

                    Image(systemName: categoryIcon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(categoryColor)
                }

                // Venue and card info
                VStack(alignment: .leading, spacing: 4) {
                    Text("You are at \(venueName) (\(categoryLabel))")
                        .font(CopilotDesign.Typography.bodyMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)

                    Text("Best: \(bestCard)")
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textSecondary)
                        .lineLimit(1)
                }

                // Open Wallet button
                VStack(spacing: 4) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.accent)

                    Text("Wallet")
                        .font(CopilotDesign.Typography.labelSmall)
                        .fontWeight(.medium)
                        .foregroundStyle(CopilotDesign.Colors.accent)
                }
                .frame(width: 56)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        categoryColor.opacity(0.3),
                                        categoryColor.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }

    private var categoryIcon: String {
        switch venueCategory.lowercased() {
        case "dining", "restaurant": return "fork.knife"
        case "gas": return "fuelpump.fill"
        case "groceries": return "cart.fill"
        case "coffee": return "cup.and.saucer"
        default: return "building.2"
        }
    }

    private var categoryColor: Color {
        switch venueCategory.lowercased() {
        case "dining", "restaurant": return CopilotDesign.Colors.brandOrange
        case "gas": return CopilotDesign.Colors.brandBlue
        case "groceries": return CopilotDesign.Colors.brandGreen
        case "coffee": return Color.brown
        default: return CopilotDesign.Colors.accent
        }
    }

    private var categoryLabel: String {
        switch venueCategory.lowercased() {
        case "dining", "restaurant": return "Groceries" == venueCategory ? "Groceries" : "Dining"
        case "gas": return "Gas"
        case "groceries": return "Groceries"
        case "coffee": return "Coffee"
        default: return venueCategory.capitalized
        }
    }

    private func openWallet() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        // Open Wallet app
        if let walletURL = URL(string: "shoebox://") {
            UIApplication.shared.open(walletURL)
        }
    }
}

#Preview {
    VStack {
        LiveActivityBanner(
            venueName: "Starbucks Coffee",
            venueCategory: "Dining",
            bestCard: "Chase Sapphire Preferred",
            recommendation: "3× points",
            estimatedSavings: "$1.25"
        )
        .padding()

        Spacer()
    }
    .background(CopilotDesign.Colors.background)
}