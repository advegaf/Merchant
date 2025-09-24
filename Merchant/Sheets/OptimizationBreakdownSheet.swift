// Explains how the optimization score is calculated and how to improve it.

import SwiftUI

struct OptimizationBreakdownSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Optimization Breakdown")
                            .font(CopilotDesign.Typography.displaySmall)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                        Text("How we calculate your 92% optimization score")
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Score overview
                    CleanCard {
                        VStack(spacing: 20) {
                            // Large score display
                            VStack(spacing: 8) {
                                Text("92%")
                                    .font(CopilotDesign.Typography.numberHuge)
                                    .foregroundStyle(CopilotDesign.Colors.success)

                                Text("Optimization Score")
                                    .font(CopilotDesign.Typography.headlineMedium)
                                    .foregroundStyle(CopilotDesign.Colors.textPrimary)

                                Text("Excellent! You're using the right cards.")
                                    .font(CopilotDesign.Typography.bodyMedium)
                                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }

                            // Progress bar
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("0%")
                                        .font(CopilotDesign.Typography.labelSmall)
                                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                                    Spacer()
                                    Text("100%")
                                        .font(CopilotDesign.Typography.labelSmall)
                                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                                }

                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(CopilotDesign.Colors.surface2)
                                        .frame(height: 8)

                                    GeometryReader { proxy in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    colors: [CopilotDesign.Colors.success, CopilotDesign.Colors.brandGreen],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: max(0, proxy.size.width * 0.92), height: 8)
                                    }
                                    .frame(height: 8)
                                }
                            }
                        }
                        .padding(24)
                    }

                    // Category breakdown
                    VStack(spacing: 16) {
                        HStack {
                            Text("Category Breakdown")
                                .font(CopilotDesign.Typography.headlineMedium)
                                .foregroundStyle(CopilotDesign.Colors.textPrimary)
                            Spacer()
                        }

                        VStack(spacing: 12) {
                            OptimizationCategoryRow(
                                category: "Dining & Restaurants",
                                score: 98,
                                icon: "fork.knife",
                                color: CopilotDesign.Colors.brandOrange,
                                description: "Perfect! Using Sapphire Preferred for 3× points."
                            )

                            OptimizationCategoryRow(
                                category: "Groceries",
                                score: 95,
                                icon: "cart.fill",
                                color: CopilotDesign.Colors.brandGreen,
                                description: "Excellent! Using Blue Cash Preferred for 6% back."
                            )

                            OptimizationCategoryRow(
                                category: "Gas Stations",
                                score: 88,
                                icon: "fuelpump.fill",
                                color: CopilotDesign.Colors.brandBlue,
                                description: "Good! Sometimes using Freedom instead of Custom Cash."
                            )

                            OptimizationCategoryRow(
                                category: "Everything Else",
                                score: 85,
                                icon: "creditcard",
                                color: CopilotDesign.Colors.accent,
                                description: "Room for improvement. Consider Freedom Unlimited more."
                            )
                        }
                    }

                    // Improvement suggestions
                    CleanCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("How to Improve")
                                .font(CopilotDesign.Typography.headlineMedium)
                                .foregroundStyle(CopilotDesign.Colors.textPrimary)

                            VStack(spacing: 12) {
                                ImprovementTip(
                                    icon: "lightbulb.fill",
                                    title: "Gas Station Optimization",
                                    description: "Use Citi Custom Cash at gas stations for 5% back instead of Freedom (1.5%).",
                                    impact: "+$8/month"
                                )

                                ImprovementTip(
                                    icon: "star.fill",
                                    title: "Quarterly Categories",
                                    description: "Activate Freedom's Q4 bonus category for department stores.",
                                    impact: "+$12/month"
                                )
                            }
                        }
                        .padding(20)
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

struct OptimizationCategoryRow: View {
    let category: String
    let score: Int
    let icon: String
    let color: Color
    let description: String

    var body: some View {
        CleanCard(style: .flat) {
            HStack(spacing: 16) {
                // Category icon
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(color)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(category)
                            .font(CopilotDesign.Typography.bodyMedium)
                            .foregroundStyle(CopilotDesign.Colors.textPrimary)

                        Spacer()

                        Text("\(score)%")
                            .font(CopilotDesign.Typography.numberSmall)
                            .fontWeight(.semibold)
                            .foregroundStyle(scoreColor)
                    }

                    Text(description)
                        .font(CopilotDesign.Typography.labelSmall)
                        .foregroundStyle(CopilotDesign.Colors.textTertiary)
                        .lineLimit(2)
                }
            }
            .padding(16)
        }
    }

    private var scoreColor: Color {
        switch score {
        case 95...100: return CopilotDesign.Colors.success
        case 85..<95: return CopilotDesign.Colors.brandOrange
        default: return CopilotDesign.Colors.error
        }
    }
}

struct ImprovementTip: View {
    let icon: String
    let title: String
    let description: String
    let impact: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(CopilotDesign.Colors.info.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(CopilotDesign.Colors.info)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(CopilotDesign.Typography.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.textPrimary)

                    Spacer()

                    Text(impact)
                        .font(CopilotDesign.Typography.labelSmall)
                        .fontWeight(.semibold)
                        .foregroundStyle(CopilotDesign.Colors.success)
                }

                Text(description)
                    .font(CopilotDesign.Typography.labelSmall)
                    .foregroundStyle(CopilotDesign.Colors.textSecondary)
                    .lineLimit(nil)
            }
        }
    }
}

#Preview {
    OptimizationBreakdownSheet()
}