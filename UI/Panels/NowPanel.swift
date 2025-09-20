// Rules: Glass tile showing current location suggestion with best card and reason
// Inputs: Mock location context, best card recommendation
// Outputs: Compact suggestion panel with sparkles accent, tap interaction
// Constraints: Single line reason, amber sparkles glyph, glass background

import SwiftUI

struct NowPanel: View {
    @State private var bestCard = "Chase Sapphire Preferred"
    @State private var multiplier = "3×"
    @State private var category = "Dining"
    @State private var venue = "The Local Bistro"

    var body: some View {
        GlassCard {
            HStack(spacing: ThemeSpacing.l) {
                VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                    HStack {
                        Text("Best card here")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(ThemeColor.rewardAccent)
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
                        .padding(ThemeSpacing.s)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(ThemeSpacing.l)
        }
        .padding(.horizontal, ThemeSpacing.xl)
    }
}

#Preview {
    ZStack {
        NeonBackground()
        NowPanel()
    }
}