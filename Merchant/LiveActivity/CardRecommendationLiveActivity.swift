
// Build-gated Live Activity + Widget definitions
#if canImport(ActivityKit)
import ActivityKit
import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Live Activity Attributes

@available(iOS 16.1, *)
struct CardRecommendationAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var venueName: String
        var venueCategory: String
        var bestCard: String
        var recommendation: String
        var estimatedSavings: String
        var lastUpdated: Date
    }

    var userId: String
}

// MARK: - Live Activity Widget

@available(iOS 16.1, *)
struct CardRecommendationLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CardRecommendationAttributes.self) { context in
            // Lock Screen View
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island Views
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.venueName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Text("Best: \(context.state.bestCard)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.state.estimatedSavings)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)

                        Text("savings")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Button(intent: OpenWalletIntent()) {
                        HStack(spacing: 6) {
                            Image(systemName: "wallet.pass.fill")
                                .font(.caption2)
                            Text("Open Wallet")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.tint)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: categoryIcon(for: context.state.venueCategory))
                            .font(.caption2)
                            .foregroundColor(.orange)

                        Text(context.state.recommendation)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)

                        Spacer()
                    }
                }
            } compactLeading: {
                // Compact leading view
                Image(systemName: categoryIcon(for: context.state.venueCategory))
                    .font(.caption2)
                    .foregroundColor(.orange)
            } compactTrailing: {
                // Compact trailing view
                Text(context.state.estimatedSavings)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            } minimal: {
                // Minimal view
                Image(systemName: "creditcard.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
    }

    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "dining", "restaurant": return "fork.knife"
        case "gas": return "fuelpump.fill"
        case "groceries": return "cart.fill"
        case "coffee": return "cup.and.saucer"
        default: return "building.2"
        }
    }
}

// MARK: - Lock Screen Live Activity View

@available(iOS 16.1, *)
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<CardRecommendationAttributes>

    var body: some View {
        VStack(spacing: 12) {
            // Header with venue info
            HStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Image(systemName: categoryIcon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(categoryColor)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.venueName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(context.state.venueCategory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(context.state.estimatedSavings)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("potential savings")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Best card recommendation
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best Card:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(context.state.bestCard)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(context.state.recommendation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Open Wallet button
                Button(intent: OpenWalletIntent()) {
                    HStack(spacing: 6) {
                        Image(systemName: "wallet.pass.fill")
                            .font(.caption)
                        Text("Open Wallet")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.tint)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var categoryIcon: String {
        switch context.state.venueCategory.lowercased() {
        case "dining", "restaurant": return "fork.knife"
        case "gas": return "fuelpump.fill"
        case "groceries": return "cart.fill"
        case "coffee": return "cup.and.saucer"
        default: return "building.2"
        }
    }

    private var categoryColor: Color {
        switch context.state.venueCategory.lowercased() {
        case "dining", "restaurant": return .orange
        case "gas": return .blue
        case "groceries": return .green
        case "coffee": return .brown
        default: return .gray
        }
    }
}

// MARK: - App Intent for Opening Wallet

@available(iOS 16.0, *)
struct OpenWalletIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Wallet"
    static var description = IntentDescription("Opens the Wallet app to access your cards")

    func perform() async throws -> some IntentResult {
        // Open the Wallet app using URL scheme
        if let walletURL = URL(string: "shoebox://") {
            await MainActor.run {
                UIApplication.shared.open(walletURL)
            }
        }
        return .result()
    }
}

// Preview removed to avoid build issues with macro arguments on older toolchains.
#endif // canImport(ActivityKit)