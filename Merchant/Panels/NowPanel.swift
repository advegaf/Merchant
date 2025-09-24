
import SwiftUI

struct NowPanel: View {
    @State private var bestCard = "Chase Sapphire Preferred"
    @State private var multiplier = "3×"
    @State private var category = "Dining"
    @State private var venue = "The Local Bistro"

    var body: some View {
        ModernGlassCard(style: .secondary) {
            HStack(spacing: ModernSpacing.lg) {
                VStack(alignment: .leading, spacing: ModernSpacing.xs) {
                    HStack {
                        Text("Best card here")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(ModernColors.reward)
                    }

                    Text("\(bestCard) (\(multiplier) \(category))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("Earn triple points on all dining purchases")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Button(action: {
                    #if os(iOS)
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    #endif
                }) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(ModernSpacing.sm)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(ModernSpacing.lg)
        }
        .padding(.horizontal, ModernSpacing.xl)
    }
}

#Preview {
    ZStack {
        ModernBackground()
        NowPanel()
    }
}